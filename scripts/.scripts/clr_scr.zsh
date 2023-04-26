#!/bin/zsh
var="true"
clear;
if [ -n $PAB ]
then
    [[ "$PAB" == "$var" ]] && print ${(pl:$LINES::\n:):-}
fi
exit 0
