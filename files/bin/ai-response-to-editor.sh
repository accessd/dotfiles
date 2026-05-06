#!/usr/bin/env bash
# Tmux helper: copy the latest assistant response from the AI agent running in
# the focused pane into the system clipboard, then open the agent's external
# editor (Ctrl+G in both Claude Code and Codex) and paste the clipboard into it.
#
# Claude Code path: read the per-PID session metadata under
#   ~/.claude/sessions/<pid>.json
# to map this pane's claude PID to its sessionId, then parse the matching
#   ~/.claude/projects/<encoded-cwd>/<sessionId>.jsonl
# transcript and grab the last main-thread assistant turn.
#
# Codex path: Codex CLI has its own Ctrl+O shortcut that copies the latest
# assistant message to the system clipboard. Send it and let Codex do the work.
#
# Usage (from tmux.conf):
#   bind-key g run-shell -b '~/dotfiles/files/bin/ai-response-to-editor.sh #{pane_id}'
set -u

pane_id="${1:?pane_id required}"

warn() { tmux display-message "ai-paste: $*"; }

pane_pid=$(tmux display-message -p -t "$pane_id" '#{pane_pid}')
[ -n "$pane_pid" ] || { warn "no pane pid"; exit 1; }

# BFS through the pane's process descendants. The first claude/codex we find
# is the agent owning this pane; that PID is what we hand off downstream.
agent=""
agent_pid=""
visit=("$pane_pid")
while [ ${#visit[@]} -gt 0 ]; do
  next=()
  for pid in "${visit[@]}"; do
    comm=$(ps -o comm= -p "$pid" 2>/dev/null | xargs basename 2>/dev/null)
    case "$comm" in
      claude) agent=claude; agent_pid=$pid; break 2 ;;
      codex)  agent=codex;  agent_pid=$pid; break 2 ;;
    esac
    while read -r child; do
      [ -n "$child" ] && next+=("$child")
    done < <(pgrep -P "$pid" 2>/dev/null)
  done
  visit=("${next[@]}")
done

if [ -z "$agent" ]; then
  warn "no claude/codex in pane process tree"
  exit 1
fi

case "$agent" in
  codex)
    # Codex's built-in shortcut copies its last assistant message into the
    # system clipboard. Small delay to let the copy land before we proceed.
    tmux send-keys -t "$pane_id" C-o
    sleep 0.15
    ;;
  claude)
    # Claude doesn't have a "copy last response" shortcut, so we read the
    # transcript directly. The session-meta file is keyed by claude's PID,
    # which uniquely identifies this pane's session even when several Claude
    # sessions share a working directory.
    session_meta="$HOME/.claude/sessions/${agent_pid}.json"
    if [ ! -f "$session_meta" ]; then
      warn "no session meta for claude pid $agent_pid"
      exit 1
    fi
    text=$(SESSION_META="$session_meta" python3 - <<'PY'
import glob, json, os, sys
meta_path = os.environ["SESSION_META"]
try:
    with open(meta_path) as f:
        meta = json.load(f)
except Exception as e:
    print(f"meta read failed: {e}", file=sys.stderr)
    sys.exit(1)
session_id = meta.get("sessionId")
if not session_id:
    sys.exit(1)
# The transcript lives under projects/<encoded-cwd>/<sessionId>.jsonl. The
# encoded-cwd may not match the current pane's cwd (e.g. when claude is
# launched through a wrapper from a different directory), so glob across all
# project dirs and rely on the unique sessionId.
candidates = glob.glob(os.path.expanduser(f"~/.claude/projects/*/{session_id}.jsonl"))
if not candidates:
    sys.exit(1)
target = candidates[0]

def extract_text(content):
    # An assistant turn's content can be a plain string or a list of typed
    # blocks. We only want the rendered text — skip thinking/tool_use blocks.
    if isinstance(content, str):
        return content
    if not isinstance(content, list):
        return ""
    parts = []
    for block in content:
        if isinstance(block, dict) and block.get("type") == "text":
            t = block.get("text")
            if isinstance(t, str):
                parts.append(t)
    return "".join(parts)

# Walk the file once and keep the most recent main-thread assistant turn.
# isSidechain==True means the entry came from a sub-agent spawned by the Task
# tool — those aren't visible to the user as the "last response".
last = None
with open(target, "r", encoding="utf-8", errors="replace") as f:
    for line in f:
        try:
            obj = json.loads(line)
        except Exception:
            continue
        if obj.get("type") != "assistant":
            continue
        if obj.get("isSidechain"):
            continue
        msg = obj.get("message") or {}
        text = extract_text(msg.get("content"))
        if text.strip():
            last = text

if not last:
    sys.exit(1)
sys.stdout.write(last)
PY
)
    if [ -z "$text" ]; then
      warn "no claude assistant text found"
      exit 1
    fi
    printf '%s' "$text" | pbcopy
    ;;
esac

# Both agents bind Ctrl+G to "open $EDITOR on a temp file with the current
# input pre-filled". The editor opens with the cursor at the start of an empty
# buffer; "+P pastes the system clipboard before the cursor in normal-mode
# (neo)vim. The 0.35s sleep covers nvim cold start — bump it if startup is
# slower on this machine.
tmux send-keys -t "$pane_id" C-g
sleep 0.35
tmux send-keys -t "$pane_id" '"+P'
