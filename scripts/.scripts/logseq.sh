#!/usr/bin/env bash

if hyprctl clients | grep -q "class: Logseq"; then
    hyprctl dispatch focuswindow class:Logseq
else
    logseq &
    hyprctl dispatch focuswindow class:Logseq
fi

