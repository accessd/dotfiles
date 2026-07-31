#!/bin/bash
# Sketchybar watchdog: restarts if unresponsive (e.g. after wake from sleep)

if ! pgrep -q sketchybar; then
  logger -t sketchybar-watchdog "sketchybar not running, starting"
  brew services start sketchybar 2>/dev/null
  exit 0
fi

query_output=$(mktemp -t sketchybar-query.XXXXXX)
sketchybar_bin="$(brew --prefix sketchybar)/bin/sketchybar"
if ! timeout 3 "$sketchybar_bin" --query bar >"$query_output" 2>/dev/null \
  || [ ! -s "$query_output" ]; then
  logger -t sketchybar-watchdog "sketchybar unresponsive or returned empty query, restarting"
  killall sketchybar 2>/dev/null
  sleep 1
  brew services start sketchybar 2>/dev/null
fi
rm -f "$query_output"
