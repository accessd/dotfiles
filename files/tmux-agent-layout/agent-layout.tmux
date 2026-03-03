#!/usr/bin/env bash
# tmux-agent-layout: TPM-compatible plugin for Claude Code multi-agent workflows.
# Tags a lead pane, distributes agent panes into left/right columns.

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Defaults
tmux set-option -g @center_width "$(tmux show-option -gqv @center_width || echo 120)" 2>/dev/null
nav=$(tmux show-option -gqv @agent-layout-nav)
nav="${nav:-on}"

# Layout keybindings (prefix + key)
tmux bind-key t run-shell "$CURRENT_DIR/scripts/layout.sh team"
tmux bind-key y run-shell "$CURRENT_DIR/scripts/layout.sh team-restore"
tmux bind-key = run-shell "$CURRENT_DIR/scripts/layout.sh rebalance"

# Neovim-aware pane navigation with auto-focus
if [ "$nav" = "on" ]; then
    tmux bind-key -n C-h run-shell "$CURRENT_DIR/scripts/select_pane.sh -L"
    tmux bind-key -n C-j run-shell "$CURRENT_DIR/scripts/select_pane.sh -D"
    tmux bind-key -n C-k run-shell "$CURRENT_DIR/scripts/select_pane.sh -U"
    tmux bind-key -n C-l run-shell "$CURRENT_DIR/scripts/select_pane.sh -R"

    tmux bind-key -T copy-mode-vi C-h run-shell "$CURRENT_DIR/scripts/select_pane.sh -L"
    tmux bind-key -T copy-mode-vi C-j run-shell "$CURRENT_DIR/scripts/select_pane.sh -D"
    tmux bind-key -T copy-mode-vi C-k run-shell "$CURRENT_DIR/scripts/select_pane.sh -U"
    tmux bind-key -T copy-mode-vi C-l run-shell "$CURRENT_DIR/scripts/select_pane.sh -R"
fi
