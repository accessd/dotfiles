#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./sync-projects.sh [--dry-run] [user@host]

Copy the remote ~/projects/ into local ~/projects/ over SSH.
The default source is macbook.local. Includes hidden files, Git metadata,
dependencies and build outputs. Never deletes local files. Replaced files
are backed up under ${XDG_STATE_HOME:-~/.local/state}/projects-sync/.
Rerun the same command to resume an interrupted transfer.
EOF
}

dry_run=()
source_host=macbook.local
host_set=false
for arg in "$@"; do
  case "$arg" in
    --dry-run) dry_run=(--dry-run) ;;
    -h|--help) usage; exit 0 ;;
    -*) printf 'Unknown option: %s\n' "$arg" >&2; exit 1 ;;
    *)
      if "$host_set"; then usage >&2; exit 1; fi
      source_host=$arg
      host_set=true
      ;;
  esac
done
if [[ ! "$source_host" =~ ^[a-zA-Z0-9_][a-zA-Z0-9_.@-]*$ ]]; then
  echo 'Expected an SSH hostname or user@host.' >&2
  exit 1
fi

backup_dir="${XDG_STATE_HOME:-$HOME/.local/state}/projects-sync/$(date +%Y%m%d-%H%M%S)-$$"
ssh_options=(-o BatchMode=yes -o ConnectTimeout=15 -o ServerAliveInterval=30 -o ServerAliveCountMax=3)
# Non-interactive SSH on macOS may select Apple's older openrsync even when
# Homebrew's modern rsync is installed.
remote_rsync=$(ssh "${ssh_options[@]}" "$source_host" \
  'if [ -x /opt/homebrew/bin/rsync ]; then echo /opt/homebrew/bin/rsync; elif [ -x /usr/local/bin/rsync ]; then echo /usr/local/bin/rsync; else command -v rsync; fi')
if (( ${#dry_run[@]} == 0 )); then mkdir -p -- "$HOME/projects"; fi
printf 'Source: %s:~/projects/\nDestination: %s/projects/\nBackups: %s\n' \
  "$source_host" "$HOME" "$backup_dir"

rsync -az --no-owner --no-group --human-readable \
  --partial --info=progress2 --stats --rsync-path="$remote_rsync" \
  --backup --backup-dir="$backup_dir" \
  -e 'ssh -o BatchMode=yes -o ConnectTimeout=15 -o ServerAliveInterval=30 -o ServerAliveCountMax=3' \
  "${dry_run[@]}" -- "$source_host:projects/" "$HOME/projects/"
