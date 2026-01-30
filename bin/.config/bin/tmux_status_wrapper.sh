#!/usr/bin/env bash
status_str=$(~/.config/bin/git_branch.sh)
if [[ $status_str ]]; then
    echo "#[fg=green][#[fg=cyan]$status_str#[fg=green]]"
fi
