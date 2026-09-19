#!/usr/bin/env bash

self=${BASH_SOURCE[0]}
[[ $self == /* ]] || self=$PWD/$self

usage="usage: ${0##*/} [-g|--git] [-r|--refresh] [directory]"

repos_only=0
force_refresh=0
mode=pick

while [[ $# -gt 0 ]]; do
    case $1 in
        -g | --git)     repos_only=1;    shift ;;
        -r | --refresh) force_refresh=1; shift ;;
        --scan)         mode=scan;       shift ;;  # internal: emit the candidate list
        --preview)      mode=preview;    shift ;;  # internal: render the fzf preview
        -h | --help)    echo "$usage";   exit 0 ;;
        --)             shift; break ;;
        -*)             echo "$usage" >&2; exit 1 ;;
        *)              break ;;
    esac
done

# -- fzf preview ---------------------------------------------------------------

if [[ $mode == preview ]]; then
    d=${1:-}
    [[ -d $d ]] || exit 0
    if [[ -e $d/.git ]]; then
        # Branch and recent history only. `git status` is deliberately absent:
        # on a Windows drive mount it took 24s in a large repo, which would peg
        # a core every time the cursor moved.
        branch=$(git -C "$d" branch --show-current 2>/dev/null)
        [[ -n $branch ]] || branch="detached @$(git -C "$d" rev-parse --short HEAD 2>/dev/null)"
        printf '\033[1;33m%s\033[0m\n\n' "$branch"
        git -C "$d" --no-pager log --oneline --decorate -n 15 2>/dev/null
    else
        ls -A -- "$d"
    fi
    exit 0
fi

# -- candidate list ------------------------------------------------------------

# TMUX_SEARCH_DIR holds one directory, or several separated by ':' as in PATH.
# A root that has gone missing is skipped with a warning; only losing all of
# them is fatal.
read_roots() {
    local -a raw=()
    local part
    roots=()
    if [[ -z ${TMUX_SEARCH_DIR:-} ]]; then
        echo "tmux-sessionizer: TMUX_SEARCH_DIR is not set" >&2
        return 1
    fi
    IFS=':' read -r -a raw <<< "$TMUX_SEARCH_DIR"
    for part in "${raw[@]}"; do
        [[ -n $part ]] || continue
        if [[ -d $part ]]; then
            roots+=("$part")
        else
            echo "tmux-sessionizer: skipping missing search dir: $part" >&2
        fi
    done
    if (( ${#roots[@]} == 0 )); then
        echo "tmux-sessionizer: no usable directory in TMUX_SEARCH_DIR: $TMUX_SEARCH_DIR" >&2
        return 1
    fi
}

# Prune before descending. .git alone holds enough subdirectories to dominate
# the walk, which is painful when a search root lives on a Windows drive mount.
scan() {
    local -a find_expr
    if (( repos_only )); then
        # A directory holding .git is a worktree: print it and stop there, so
        # the repo's own subdirectories -- submodules included -- stay out of
        # the list and cost nothing to walk.
        find_expr=(
            '(' -type d '(' -name node_modules -o -name .cache -o -name .venv ')' -prune ')'
            -o '(' -type d -exec test -e '{}/.git' ';' -print -prune ')'
        )
    else
        find_expr=(
            '(' -type d '(' -name .git -o -name node_modules -o -name .cache -o -name .venv ')' -prune ')'
            -o -type d -print
        )
    fi
    # No -mindepth: a root that is itself a repo (~/dotfiles, say) has to be
    # selectable, and -mindepth 1 would only ever offer its children.
    find "${roots[@]}" -maxdepth 4 "${find_expr[@]}" 2>/dev/null
}

cache_file=""
init_cache() {
    local dir=${XDG_CACHE_HOME:-$HOME/.cache}/tmux-sessionizer
    mkdir -p -- "$dir" 2>/dev/null || return 0
    cache_file=$dir/list-$(printf '%s\0%s' "$repos_only" "$TMUX_SEARCH_DIR" | cksum | cut -d' ' -f1)
}

# Always fill the cache from a complete scan before emitting anything: a
# consumer that closes the pipe early (fzf being dismissed) must not leave a
# truncated list behind.
scan_cached() {
    local tmp
    if [[ -n $cache_file ]] && tmp=$(mktemp -- "$cache_file.XXXXXX" 2>/dev/null); then
        if scan > "$tmp"; then
            mv -f -- "$tmp" "$cache_file" && { cat -- "$cache_file"; return 0; }
        fi
        rm -f -- "$tmp"
    fi
    scan
}

if [[ $mode == scan ]]; then
    read_roots || exit 1
    init_cache
    scan_cached
    exit 0
fi

# -- pick ----------------------------------------------------------------------

if [[ $# -gt 1 ]]; then
    echo "$usage" >&2
    exit 1
fi

if [[ $# -eq 1 ]]; then
    selected=$1
else
    read_roots || exit 1
    init_cache

    scan_cmd="$(printf '%q' "$self") --scan"
    (( repos_only )) && scan_cmd+=" --git"
    scan_cmd+=" 2>/dev/null"

    fzf_opts=(
        --layout=reverse --info=inline --border --margin=1 --padding=1
        --header="CTRL-C cancel / CTRL-R rescan"
        --preview "$(printf '%q' "$self") --preview {} 2>/dev/null"
        --bind "ctrl-r:reload($scan_cmd)"
        # bg+ used to be -1, i.e. no background at all, which left the current
        # line indistinguishable from the rest. surface0 from catppuccin mocha
        # matches the nvim theme; gutter stays transparent so the popup keeps
        # its see-through background.
        --highlight-line
        --color="bg+:#313244,fg+:white:bold,gutter:-1,spinner:0,hl:yellow,header:blue,info:green,pointer:red,marker:blue,hl+:red"
    )

    if (( force_refresh )) || [[ -z $cache_file || ! -s $cache_file ]]; then
        selected=$(scan_cached | fzf "${fzf_opts[@]}")
    else
        # The cache opens the picker instantly; the reload on start refreshes the
        # list in place and leaves the cache current for next time.
        selected=$(fzf "${fzf_opts[@]}" --bind "start:reload($scan_cmd)" < "$cache_file")
    fi
fi

if [[ -z $selected ]]; then
    exit 0
fi

# A stale cache entry or a mistyped argument must not reach tmux as a raw error.
if [[ ! -d $selected ]]; then
    echo "tmux-sessionizer: not a directory: $selected" >&2
    exit 1
fi
selected=$(cd -- "$selected" && pwd -P) || exit 1

# -- session name --------------------------------------------------------------

declare -A session_path_by_name=()
while IFS=$'\t' read -r sname spath; do
    [[ -n $sname ]] && session_path_by_name[$sname]=$spath
done < <(tmux list-sessions -F "#{session_name}"$'\t'"#{session_path}" 2>/dev/null)

# Basenames repeat constantly across a repo tree -- docs, src, toolchain -- and
# a bare basename would silently attach to whichever one got there first. Widen
# the name with parent directories until it is either free or already points at
# this very path.
resolve_session_name() {
    local dir=$1
    local -a parts=() comps=()
    local part name depth n base suffix

    IFS='/' read -r -a parts <<< "$dir"
    for part in "${parts[@]}"; do
        [[ -n $part ]] && comps+=("$part")
    done
    n=${#comps[@]}

    for (( depth = 1; depth <= n; depth++ )); do
        name=$(IFS='_'; printf '%s' "${comps[*]: n - depth:depth}")
        # tmux reads '.' and ':' as target separators, a bare space splits the
        # name, and '/' would read as a path.
        name=$(printf '%s' "$name" | tr './: ' '_')
        if [[ -z ${session_path_by_name[$name]+set} ]]; then
            printf '%s' "$name"
            return 0
        fi
        if [[ $(readlink -m -- "${session_path_by_name[$name]}") == "$dir" ]]; then
            printf '%s' "$name"
            return 0
        fi
    done

    base=$name
    suffix=2
    while [[ -n ${session_path_by_name[$base-$suffix]+set} ]]; do
        (( suffix++ ))
    done
    printf '%s' "$base-$suffix"
}

selected_name=$(resolve_session_name "$selected")

if [[ -z ${TMUX:-} ]]; then
    if [[ -n ${session_path_by_name[$selected_name]+set} ]]; then
        tmux a -t "=$selected_name"
    else
        tmux new-session -s "$selected_name" -c "$selected"
    fi
else
    if [[ -z ${session_path_by_name[$selected_name]+set} ]]; then
        tmux new-session -ds "$selected_name" -c "$selected"
    fi

    tmux switch-client -t "=$selected_name"
fi
