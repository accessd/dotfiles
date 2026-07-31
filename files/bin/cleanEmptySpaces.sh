#!/usr/bin/env bash
set -euo pipefail

# Remove only leaked, empty, unlabeled Spaces after the 10 managed ones.
# Do not destroy non-empty or labeled spaces.
spaces_to_destroy=$(yabai -m query --spaces \
  | jq -r 'map(select((.index > 10) and (.label == "") and ((.windows | length) == 0)).index) | reverse | .[]')

[ -n "$spaces_to_destroy" ] || exit 0

printf '%s\n' "$spaces_to_destroy" | while IFS= read -r space_index; do
  yabai -m space "$space_index" --destroy
done
