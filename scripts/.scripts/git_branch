#!/usr/bin/env bash

# Used in tmux status wrapper script to get the current branch
if git rev-parse --git-dir > /dev/null 2>&1; then
    toplevel_cnt=$(git rev-parse --show-superproject-working-tree --show-toplevel | wc -l)
    if [[ $toplevel_cnt == '2' ]]; then
        dir_name=$(basename -s .git `git config --get remote.origin.url`);
        b_name=$(git branch --show-current);
        if [[ $b_name == '' ]]; then
            b_name=$(git rev-parse --short HEAD);
            b_name="@${b_name}"
        fi
        echo_str="${dir_name} -> ${b_name}";
    else
        echo_str=$(git rev-parse --abbrev-ref HEAD);
    fi
    echo $echo_str;
fi
