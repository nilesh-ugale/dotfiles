#!/bin/zsh
var="true"

# Detect if terminal is Kitty
if [[ "$TERM" == "xterm-kitty" ]]; then
    # Clear using Kitty-specific escape sequences
    printf '\033[2J\033[H\033[3J'
else
    clear
fi

# Check PAB variable
if [[ -n "$PAB" ]]; then
    [[ "$PAB" == "$var" ]] && print ${(pl:$LINES::\n:):-}
fi
exit 0

