#!/usr/bin/env bash

# Usage: screenshot.sh [region|full]
# Saves to ~/Pictures/Screenshots and copies the image to the clipboard.

dir="$HOME/Pictures/Screenshots"
mkdir -p "$dir"
file="$dir/$(date +%Y-%m-%d_%H-%M-%S).png"

case "${1:-region}" in
    region)
        geometry=$(slurp) || exit 0 # Esc cancels the selection
        grim -g "$geometry" "$file"
        ;;
    full)
        grim "$file"
        ;;
    *)
        echo "usage: $0 [region|full]" >&2
        exit 1
        ;;
esac

wl-copy < "$file"
notify-send -i "$file" "Screenshot saved" "${file/#$HOME/\~}"
