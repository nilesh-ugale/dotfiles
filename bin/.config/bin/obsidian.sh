#!/usr/bin/env bash

# Focus Obsidian if it's already open, otherwise launch it
# (a window rule sends it to workspace 3)
if hyprctl clients | grep -q "class: obsidian"; then
    hyprctl dispatch 'hl.dsp.focus({ window = hl.get_window("class:obsidian") })'
else
    obsidian &
fi
