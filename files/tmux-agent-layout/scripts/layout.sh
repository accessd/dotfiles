#!/usr/bin/env bash
# Agent team layout for tmux.
# Tags a lead pane, distributes agent panes into left/right columns
# flanking the lead. Ported from AlexHarn/tmux-config with ultrawide/
# triple/spacer/nesting logic removed.

set -eu

COMMAND="${1:-help}"

AGENT_MIN_HEIGHT=5

# =====================================================================
# Helpers
# =====================================================================

get_option() {
    tmux show-option -gqv "$1"
}

get_window_option() {
    tmux show-option -wqv "$1"
}

get_pane_option() {
    tmux show-option -pqv -t "${1:-}" "$2" 2>/dev/null
}

center_width() {
    local w
    w=$(get_option @center_width)
    echo "${w:-120}"
}

count_panes() {
    tmux list-panes -F '#{pane_id}' | wc -l | tr -d ' '
}

tag_center() {
    tmux set-option -p -t "$1" @is_center 1
}

equalize_column() {
    local -a panes=("$@")
    local count=${#panes[@]}
    if [ "$count" -le 1 ]; then return; fi

    local window_height
    window_height=$(tmux display-message -p '#{window_height}')
    local target=$(( window_height / count ))

    local i
    for i in $(seq 0 $((count - 2))); do
        tmux resize-pane -t "${panes[$i]}" -y "$target" 2>/dev/null || true
    done
}

# =====================================================================
# team: tag lead pane, arrange into 3-column layout
# =====================================================================

cmd_team() {
    local has_center=""
    while IFS= read -r pane; do
        if [ "$(get_pane_option "$pane" @is_center)" = "1" ]; then
            has_center=1
            break
        fi
    done < <(tmux list-panes -F '#{pane_id}')

    if [ -z "$has_center" ]; then
        tag_center "$(tmux display-message -p '#{pane_id}')"
    fi

    cmd_auto_layout

    # Reset border styles Claude Code may have overridden
    tmux setw pane-active-border-style "fg=red"
    tmux setw pane-border-style "fg=colour238"
    tmux setw pane-border-status off
}

# =====================================================================
# auto-layout: classify panes and rebuild 3-column layout
# =====================================================================

cmd_auto_layout() {
    local center=""
    local -a others=()

    while IFS= read -r pane; do
        if [ "$(get_pane_option "$pane" @is_center)" = "1" ]; then
            center="$pane"
        else
            others+=("$pane")
        fi
    done < <(tmux list-panes -F '#{pane_id}')

    if [ -z "$center" ]; then return; fi

    local n=${#others[@]}
    if [ "$n" -lt 2 ]; then
        if [ "$n" -eq 1 ]; then
            # Only 2 panes total: simple horizontal split, center gets configured width
            tmux select-layout even-horizontal
            tmux resize-pane -t "$center" -x "$(center_width)" 2>/dev/null || true
        fi
        tmux set-option -w @team_mode 1
        tmux set-option -w @team_lead "$center"
        tmux select-pane -t "$center"
        return
    fi

    # Break all non-center panes to temporary windows
    for pane in "${others[@]}"; do
        tmux break-pane -d -s "$pane"
    done

    local total_width cw sw
    total_width=$(tmux display-message -p '#{window_width}')
    cw=$(center_width)

    if [ "$total_width" -le "$cw" ]; then
        # Terminal too narrow: tile everything
        for pane in "${others[@]}"; do
            tmux join-pane -v -t "$center" -s "$pane"
        done
        tmux select-layout tiled
        tmux set-option -w @team_mode 1
        tmux set-option -w @team_lead "$center"
        tmux select-pane -t "$center"
        return
    fi

    sw=$(( (total_width - cw) / 2 ))

    local left_count=$(( n / 2 ))
    local right_count=$(( n - left_count ))

    # Right column
    local right_anchor_idx=$left_count
    tmux join-pane -h -t "$center" -s "${others[$right_anchor_idx]}" -l "$sw"
    local i
    for i in $(seq $((right_anchor_idx + 1)) $((n - 1))); do
        tmux join-pane -v -t "${others[$right_anchor_idx]}" -s "${others[$i]}"
    done

    # Left column
    tmux join-pane -hb -t "$center" -s "${others[0]}" -l "$sw"
    for i in $(seq 1 $((left_count - 1))); do
        tmux join-pane -v -t "${others[0]}" -s "${others[$i]}"
    done

    # Equalize agent pane heights within each column
    equalize_column "${others[@]:0:$left_count}"
    equalize_column "${others[@]:$left_count:$right_count}"

    tmux set-option -w @team_mode 1
    tmux set-option -w @team_lead "$center"
    tmux select-pane -t "$center"
}

# =====================================================================
# team-restore: kill agent panes, return to single lead pane
# =====================================================================

cmd_team_restore() {
    local center=""
    local -a others=()

    while IFS= read -r pane; do
        if [ "$(get_pane_option "$pane" @is_center)" = "1" ]; then
            center="$pane"
        else
            others+=("$pane")
        fi
    done < <(tmux list-panes -F '#{pane_id}')

    if [ -z "$center" ]; then
        tmux display-message "No tagged center pane found"
        return
    fi

    for pane in "${others[@]}"; do
        tmux kill-pane -t "$pane" 2>/dev/null || true
    done

    tmux set-option -wu @team_mode
    tmux set-option -wu @team_lead

    # Reset border styles Claude Code may have overridden
    tmux setw pane-active-border-style "fg=red"
    tmux setw pane-border-style "fg=colour238"
    tmux setw pane-border-status off

    # Clear center tag so the pane is clean for reuse
    tmux set-option -pu @is_center

    tmux select-pane -t "$center"
    tmux display-message "Team layout cleared"
}

# =====================================================================
# auto-focus: expand focused agent pane, equalize on lead focus
# =====================================================================

cmd_auto_focus() {
    if [ "$(get_window_option @team_mode)" != "1" ]; then return; fi

    local lead
    lead=$(get_window_option @team_lead)
    if [ -n "$lead" ]; then
        if ! tmux list-panes -F '#{pane_id}' | grep -qF "$lead"; then
            tmux set-option -wu @team_mode
            tmux set-option -wu @team_lead
            return
        fi
    fi

    local current
    current=$(tmux display-message -p '#{pane_id}')

    local window_height
    window_height=$(tmux display-message -p '#{window_height}')

    # Lead focused: equalize all agent pane heights per column
    if [ "$(get_pane_option "$current" @is_center)" = "1" ]; then
        local -a left_col=() right_col=()
        local center_x
        center_x=$(tmux display-message -p -t "$current" '#{pane_left}')
        while IFS=$'\t' read -r pid px; do
            if [ "$(get_pane_option "$pid" @is_center)" = "1" ]; then continue; fi
            if [ "$px" -lt "$center_x" ]; then
                left_col+=("$pid")
            else
                right_col+=("$pid")
            fi
        done < <(tmux list-panes -F '#{pane_id}	#{pane_left}')
        if [ "${#left_col[@]}" -gt 0 ]; then
            equalize_column "${left_col[@]}"
        fi
        if [ "${#right_col[@]}" -gt 0 ]; then
            equalize_column "${right_col[@]}"
        fi
        return
    fi

    # Agent focused: expand vertically to 60%
    local target=$(( window_height * 60 / 100 ))

    local col_x sibling_count
    col_x=$(tmux display-message -p '#{pane_left}')
    sibling_count=$(tmux list-panes -F '#{pane_id}' \
        -f "#{==:#{pane_left},${col_x}}" | wc -l | tr -d ' ')
    local max_target=$(( window_height - (sibling_count - 1) * AGENT_MIN_HEIGHT ))
    if [ "$target" -gt "$max_target" ]; then
        target=$max_target
    fi

    tmux resize-pane -y "$target" 2>/dev/null || true
}

# =====================================================================
# rebalance: simple tiled fallback
# =====================================================================

cmd_rebalance() {
    local n
    n=$(count_panes)
    if [ "$n" -le 1 ]; then
        tmux display-message "Only 1 pane, nothing to rebalance"
        return
    fi
    tmux select-layout tiled
    tmux display-message "Rebalanced $n panes (tiled)"
}

# =====================================================================
# Dispatch
# =====================================================================

case "$COMMAND" in
    team)         cmd_team ;;
    auto-layout)  cmd_auto_layout ;;
    team-restore) cmd_team_restore ;;
    auto-focus)   cmd_auto_focus ;;
    rebalance)    cmd_rebalance ;;
    *)
        echo "Usage: layout.sh {team|team-restore|auto-focus|rebalance}"
        exit 1
        ;;
esac
