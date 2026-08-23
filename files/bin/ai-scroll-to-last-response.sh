#!/usr/bin/env bash
# Tmux helper: in the focused pane, scroll to the start of the latest assistant
# response from the AI agent (Claude Code or Codex) running there.
#
# Strategy: read the latest assistant message from the agent's on-disk
# transcript, take its first line, then enter tmux copy-mode and search
# backward for that string. The cursor lands on the first rendered line of the
# response. Marker-agnostic — works for any TUI as long as the rendered text
# contains the message verbatim.
#
# Usage (from tmux.conf):
#   bind-key a run-shell -b '#{@dotfiles}/files/bin/ai-scroll-to-last-response.sh #{pane_id}'
set -u

pane_id="${1:?pane_id required}"

warn() { tmux display-message "ai-scroll: $*"; }

pane_pid=$(tmux display-message -p -t "$pane_id" '#{pane_pid}')
[ -n "$pane_pid" ] || { warn "no pane pid"; exit 1; }

# BFS through pane's process descendants to find the agent.
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

# Resolve the active transcript file for this agent_pid.
transcript=""
case "$agent" in
  claude)
    # Claude's per-PID metadata gives us the sessionId; the transcript path
    # uses that id plus an encoded cwd, but the id alone is unique.
    session_meta="$HOME/.claude/sessions/${agent_pid}.json"
    if [ ! -f "$session_meta" ]; then
      warn "no session meta for claude pid $agent_pid"; exit 1
    fi
    session_id=$(python3 -c "import json,sys; print(json.load(open(sys.argv[1])).get('sessionId',''))" "$session_meta" 2>/dev/null)
    [ -n "$session_id" ] || { warn "missing sessionId"; exit 1; }
    transcript=$(ls -t "$HOME/.claude/projects/"*/"${session_id}.jsonl" 2>/dev/null | head -1)
    ;;
  codex)
    # Codex keeps its active session jsonl(s) open for writing. Pick the most
    # recently modified one held by this codex PID — that's the live convo.
    transcript=$(lsof -p "$agent_pid" 2>/dev/null \
      | awk '$4 ~ /w$/ && $NF ~ /\.codex\/sessions\/.*\.jsonl$/ {print $NF}' \
      | xargs -I{} stat -f '%m %N' {} 2>/dev/null \
      | sort -rn | head -1 | awk '{print $2}')
    ;;
esac

[ -n "$transcript" ] && [ -f "$transcript" ] || { warn "transcript not found"; exit 1; }

# Build a search needle that matches the rendered start of the latest turn.
# The turn can be one of:
#   - a normal assistant text response
#   - an ExitPlanMode tool call (plan mode), which renders as a "Plan: <title>"
#     header in the TUI rather than as flowing prose
# The TUI styles markdown (strips `##`, `**`, backticks, etc.) so we pick a
# prose line and scrub inline markers before using it as a literal substring.
needle=$(AGENT="$agent" TRANSCRIPT="$transcript" python3 - <<'PY'
import json, os, re, sys

agent = os.environ["AGENT"]
path  = os.environ["TRANSCRIPT"]
NEEDLE_CAP = 40

DECORATION_START = re.compile(r"^[#>\-*|`\s]")
INLINE_MARKERS   = re.compile(r"\*\*|__|`")

def first_prose_line(text):
    # Prefer lines that start with a letter/digit/quote so the markdown
    # rendering doesn't strip our needle's leading characters.
    for raw in text.splitlines():
        line = raw.strip()
        if not line or DECORATION_START.match(line):
            continue
        return INLINE_MARKERS.sub("", line)[:NEEDLE_CAP]
    # Fallback: first non-empty line with leading decorations stripped.
    for raw in text.splitlines():
        line = raw.strip()
        if not line:
            continue
        line = re.sub(r"^[#>\-*\s]+", "", line)
        return INLINE_MARKERS.sub("", line)[:NEEDLE_CAP]
    return ""

def claude_extract(obj):
    # Returns ("text", str) | ("plan", title) | None
    if obj.get("type") != "assistant" or obj.get("isSidechain"):
        return None
    content = (obj.get("message") or {}).get("content")
    if isinstance(content, str):
        return ("text", content) if content.strip() else None
    if not isinstance(content, list):
        return None
    plan_title = None
    text_parts = []
    for b in content:
        if not isinstance(b, dict):
            continue
        t = b.get("type")
        if t == "text":
            txt = b.get("text") or ""
            if txt.strip():
                text_parts.append(txt)
        elif t == "tool_use" and b.get("name") == "ExitPlanMode":
            plan = (b.get("input") or {}).get("plan") or ""
            for raw in plan.splitlines():
                line = raw.strip()
                if line.startswith("#"):
                    plan_title = line.lstrip("# ").strip()
                    break
                if line:
                    plan_title = line
                    break
    # When a turn includes both intro text and ExitPlanMode, treat it as a
    # plan: the plan box is the visually dominant artifact and the user's
    # stated intent is to land on the latest plan, not on the brief lead-in.
    if plan_title:
        return ("plan", plan_title)
    if text_parts:
        return ("text", "".join(text_parts))
    return None

def codex_extract(obj):
    if obj.get("type") != "response_item":
        return None
    p = obj.get("payload") or {}
    if not (isinstance(p, dict) and p.get("type") == "message" and p.get("role") == "assistant"):
        return None
    parts = [c.get("text","") for c in (p.get("content") or [])
             if isinstance(c, dict) and c.get("type") == "output_text"]
    joined = "".join(parts)
    return ("text", joined) if joined.strip() else None

extract = claude_extract if agent == "claude" else codex_extract

turns = []
with open(path, "r", encoding="utf-8", errors="replace") as f:
    for line in f:
        try:
            obj = json.loads(line)
        except Exception:
            continue
        got = extract(obj)
        if got is not None:
            turns.append(got)

if not turns:
    sys.exit(1)

# Skip-heuristic: when the absolute-latest turn is a brief follow-up
# question, walk back to the latest substantive answer. A turn counts as a
# "short question" if its first terminal punctuation is '?' AND its total
# length is below ~600 chars. Plan turns are always considered substantive.
SHORT_QUESTION_LEN = 600
TERMINATOR = re.compile(r"[.!?]")

def is_short_question(text):
    if len(text) >= SHORT_QUESTION_LEN:
        return False
    m = TERMINATOR.search(text)
    return bool(m and text[m.start()] == "?")

chosen = None
for kind, payload in reversed(turns):
    if kind == "plan":
        chosen = (kind, payload)
        break
    if is_short_question(payload):
        continue
    chosen = (kind, payload)
    break

if chosen is None:
    chosen = turns[-1]

kind, payload = chosen
if kind == "plan":
    # Plan boxes render with a literal " Plan: <title>" header line. The
    # title is the first H1 of the plan; some plans phrase the H1 as
    # "# Plan: <X>", others as just "# <X>", so normalize before re-adding
    # the "Plan: " prefix. Also scrub markdown markers since the TUI strips
    # backticks/asterisks before rendering.
    title = INLINE_MARKERS.sub("", payload).strip()
    if title.lower().startswith("plan:"):
        title = title[len("plan:"):].lstrip()
    needle = ("Plan: " + title)[:NEEDLE_CAP]
else:
    needle = first_prose_line(payload)

if not needle:
    sys.exit(1)
sys.stdout.write(needle)
PY
)

if [ -z "$needle" ]; then
  warn "no assistant text found"; exit 1
fi

# Drop into copy-mode, jump to history bottom, search backward for the
# needle. Tmux's literal substring search lands on the most recent matching
# row, which is exactly the start of the latest response/plan.
tmux copy-mode -t "$pane_id"
tmux send-keys -t "$pane_id" -X history-bottom
tmux send-keys -t "$pane_id" -X search-backward "$needle"
# Scroll the view down half a pane-height so the response body is visible
# below the match line. scroll-down (vs. page-down) moves the view without
# moving the cursor, so the cursor stays on the response start for easy
# copy-mode navigation.
pane_height=$(tmux display-message -p -t "$pane_id" '#{pane_height}')
half=$(( pane_height / 2 ))
[ "$half" -gt 0 ] && tmux send-keys -t "$pane_id" -X -N "$half" scroll-down
