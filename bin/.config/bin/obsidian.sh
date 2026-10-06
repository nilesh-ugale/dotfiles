#!/usr/bin/env bash

# Focus Obsidian if it's already open, otherwise launch it
# (a window rule sends it to workspace 3)
if hyprctl clients | grep -qE "class: (md\.obsidian\.Obsidian|obsidian)$"; then
    hyprctl dispatch 'hl.dsp.focus({ window = "class:md.obsidian.Obsidian" })'
else
    obsidian &
fi
