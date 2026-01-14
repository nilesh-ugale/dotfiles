#!/usr/bin/env bash

# Generic hyprpaper random wallpaper script
# Works on any distro, any user, any monitor setup

WALLDIR="${WALLDIR:-/usr/share/backgrounds}"
CURRENT="$HOME/.config/hypr/wallpaper/current"

# Exit quietly if wallpaper directory does not exist
[ -d "$WALLDIR" ] || exit 0

# Pick a random image (png/jpg/webp)
WALL=$(find "$WALLDIR" -type f \( \
  -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \
\) 2>/dev/null | shuf -n 1)

# Exit if nothing found
[ -n "$WALL" ] || exit 0

# Update symlink (extension-agnostic)
ln -sf "$WALL" "$CURRENT"

# Apply wallpaper via hyprpaper (single stable path)
hyprctl hyprpaper unload all
hyprctl hyprpaper preload "$CURRENT" >/dev/null 2>&1
hyprctl hyprpaper wallpaper ",$CURRENT" >/dev/null 2>&1
