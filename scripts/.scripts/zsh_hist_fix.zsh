#!/usr/bin/env zsh

mv ~/.zsh_history ~/.zsh_history_bad
strings -eS ~/.zsh_history_bad > ~/.zsh_history
#R in capital gives an error so the solution
fc -R ~/.zsh_history
rm ~/.zsh_history_bad
