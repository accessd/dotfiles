#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Toggle Tailscale Wallarm
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🔗
# @raycast.packageName Network

TAILSCALE="/Applications/Tailscale.app/Contents/MacOS/Tailscale"

status=$("$TAILSCALE" status 2>&1)

if echo "$status" | grep -q "Tailscale is stopped"; then
    "$TAILSCALE" up
    echo "Tailscale connected"
else
    "$TAILSCALE" down
    echo "Tailscale disconnected"
fi
