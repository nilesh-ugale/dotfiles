#!/usr/bin/env bash

if hyprctl clients | grep -q "class: Logseq"; then
    hyprctl dispatch 'hl.dsp.focus({ window = hl.get_window("class:Logseq") })'
else
    logseq &
    hyprctl dispatch 'hl.dsp.focus({ window = hl.get_window("class:Logseq") })'
fi

