#!/usr/bin/env bash

# Generic hyprpaper random wallpaper script
# Works on any distro, any user, any monitor setup

WALLDIR="${WALLDIR:-/usr/share/backgrounds}"
CURRENT="$HOME/.config/hypr/wallpaper/current"

CUR_DIR="$HOME/.config/hypr/wallpaper"

# Ensure the directory exists
if [ ! -d "$CUR_DIR" ]; then
    mkdir -p "$CUR_DIR"
fi

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
# hyprctl hyprpaper unload all
# hyprctl -v hyprpaper preload "$CURRENT" >/dev/null 2>&1
# hyprctl hyprpaper wallpaper ",$CURRENT" >/dev/null 2>&1
if pgrep -x "hyprpaper" > /dev/null; then
    # echo "Hyprpaper is running. Killing and restarting..."
    pkill -x hyprpaper >/dev/null 2>&1
    # Wait a moment for the process to actually die
    # sleep 0.
fi

hyprpaper >/dev/null 2>&1 &
