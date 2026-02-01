#!/usr/bin/env bash

CURRENT="$HOME/.config/hypr/wallpaper/current"
WALL="/usr/share/backgrounds/wallhaven_5yyjm9.jpg"

# Update symlink (extension-agnostic)
ln -sf "$WALL" "$CURRENT"

hyprpaper
