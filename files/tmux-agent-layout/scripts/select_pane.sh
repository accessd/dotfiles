#!/usr/bin/env bash
# Select pane with neovim awareness and auto-focus in team mode.
# Usage: select_pane.sh {-L|-R|-U|-D}

set -eu

DIR="$1"

is_vim=$(tmux display-message -p '#{@pane-is-vim}')

if [ "$is_vim" = "1" ]; then
    case "$DIR" in
        -L) tmux send-keys C-h ;;
        -D) tmux send-keys C-j ;;
        -U) tmux send-keys C-k ;;
        -R) tmux send-keys C-l ;;
    esac
else
    tmux select-pane "$DIR"

    if [ "$(tmux show-option -wqv @team_mode)" = "1" ]; then
        SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        "$SCRIPT_DIR/layout.sh" auto-focus 2>/dev/null || true
    fi
fi
