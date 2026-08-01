#!/bin/bash

set -euo pipefail

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Toggle Tailscale Wallarm
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🔗
# @raycast.packageName Network

tailscale_bin=${TAILSCALE_BIN:-}
if [[ -z "$tailscale_bin" ]]; then
    for candidate in \
        /usr/local/bin/tailscale \
        /opt/homebrew/bin/tailscale \
        /Applications/Tailscale.app/Contents/MacOS/Tailscale; do
        if [[ -x "$candidate" ]]; then
            tailscale_bin=$candidate
            break
        fi
    done
fi

if [[ -z "$tailscale_bin" || ! -x "$tailscale_bin" ]]; then
    echo "Tailscale CLI not found" >&2
    exit 1
fi

jq_bin=$(command -v jq || true)
if [[ -z "$jq_bin" && -x /opt/homebrew/bin/jq ]]; then
    jq_bin=/opt/homebrew/bin/jq
fi
if [[ -z "$jq_bin" ]]; then
    echo "jq not found" >&2
    exit 1
fi

state=$("$tailscale_bin" status --json | "$jq_bin" -r .BackendState)

case "$state" in
    Running)
        "$tailscale_bin" down
        echo "Tailscale disconnected"
        ;;
    Stopped|NeedsLogin|NoState)
        "$tailscale_bin" up
        echo "Tailscale connected"
        ;;
    *)
        echo "Unsupported Tailscale state: $state" >&2
        exit 1
        ;;
esac
