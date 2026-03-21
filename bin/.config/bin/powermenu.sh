#!/usr/bin/env bash

choice=$(printf "  Lock\n 󰍃 Logout\n 󰜉 Reboot\n 󰐥 Shutdown" \
  | wofi -n --conf ~/.config/wofi/config --style ~/.config/wofi/style.css --dmenu --prompt "Power")

case "$choice" in
  *Lock*)
    hyprlock ;;
  *Logout*)
    hyprctl dispatch exit ;;
  *Reboot*)
    ~/.config/bin/powermenu-reboot.sh ;;
  *Shutdown*)
    ~/.config/bin/powermenu-shutdown.sh ;;
esac
