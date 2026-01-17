#!/usr/bin/env bash

choice=$(printf "  Lock\n 󰍃 Logout\n 󰜉 Reboot\n 󰐥 Shutdown" \
  | wofi --config ~/.config/wofi/config --style ~/.config/wofi/style.css --dmenu --prompt "Power")

case "$choice" in
  *Lock*)
    hyprlock ;;
  *Logout*)
    hyprctl dispatch exit ;;
  *Reboot*)
    systemctl reboot ;;
  *Shutdown*)
    systemctl poweroff ;;
esac
