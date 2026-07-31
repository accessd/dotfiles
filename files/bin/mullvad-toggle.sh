#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Toggle Mullvad VPN
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🔒
# @raycast.packageName Network

MULLVAD=$(command -v mullvad)

status=$("$MULLVAD" status 2>&1)

if echo "$status" | grep -q "Disconnected"; then
    "$MULLVAD" connect
    echo "Mullvad connected"
else
    "$MULLVAD" disconnect
    echo "Mullvad disconnected"
fi
