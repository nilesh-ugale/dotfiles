#!/usr/bin/env bash

# Usage: screenshot.sh [region|full]
# Copies the image to the clipboard. Click the popup within 5 s to also save it
# to ~/Pictures/Screenshots.

dir="$HOME/Pictures/Screenshots"
tmp=$(mktemp --suffix=.png)
trap 'rm -f "$tmp"' EXIT

case "${1:-region}" in
    region)
        geometry=$(slurp) || exit 0 # Esc cancels the selection
        grim -g "$geometry" "$tmp"
        ;;
    full)
        grim "$tmp"
        ;;
    *)
        echo "usage: $0 [region|full]" >&2
        exit 1
        ;;
esac

wl-copy < "$tmp"

action=$(notify-send -i "$tmp" -t 5000 -A "default=Save" --wait \
    "Screenshot copied" "Click to save")

if [[ $action == default ]]; then
    mkdir -p "$dir"
    file="$dir/$(date +%Y-%m-%d_%H-%M-%S).png"
    cp "$tmp" "$file"
    notify-send -t 3000 "Screenshot saved" "${file/#$HOME/\~}"
fi
