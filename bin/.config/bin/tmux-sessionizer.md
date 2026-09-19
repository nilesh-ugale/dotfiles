# tmux-sessionizer

Fuzzy-picks a directory under `$TMUX_SEARCH_DIR` and attaches a tmux session
named after it, creating it first if it does not exist yet.

Two ways in: `tms` (shell alias), or `Ctrl-A Space` (tmux popup, 80% wide).

## Invoke

| Command               | What it does                                           |
|-----------------------|--------------------------------------------------------|
| `tms`                 | Picker over every directory, 4 levels deep (3432 here) |
| `tms -g`  `--git`     | Git repos only, outermost one per tree (76 here)       |
| `tms -r`  `--refresh` | Rescan first, ignoring the cache                       |
| `tms <dir>`           | Skip the picker and open that directory                |
| `tms -h`  `--help`    | Usage line                                             |

- `tms -g <dir>` — the path wins, `-g` is ignored.
- Two paths, or an unknown flag, print usage and exit 1.
- `--scan` and `--preview` exist so fzf can re-invoke the script. Not meant
  to be typed.
- A path argument may be relative, and need not be a repo.

## In the picker

- `Ctrl-R` — rescan and refresh the cache without closing the picker.
  This is the script's own binding.
- `Enter` — open the highlighted directory.
- `Ctrl-C` — cancel. Exits 0, nothing created.
- Typing filters the list; movement and the rest are fzf's own defaults.

The preview pane shows the branch and last 15 commits for a repo, or `ls -A`
for a plain directory. Deliberately no `git status` — see Timings.

## What gets listed

- **Depth**: 4 levels below each root. A repo nested deeper never appears.
  Each root is offered too, so a root that is itself a repo is selectable.
- **Always pruned**: `node_modules`, `.cache`, `.venv` — plus `.git` in the
  default listing.
- **`-g` includes**: anything holding a `.git`, so ordinary clones and linked
  worktrees (where `.git` is a file, not a directory).
- **`-g` excludes**: submodules, because the walk stops at the outermost repo.
  Also bare repos, which have no `.git` inside them.

## Session names

The name is the directory's basename, with `.` `:` `/` and spaces turned into
`_` — tmux reads the first two as target separators.

Basenames repeat constantly across a repo tree: `docs` appears 32 times here,
`toolchain` 20, `src` 18. A bare basename would silently drop you into
whichever one got there first, so a name already taken by a *different* path
grows leftward until it is unambiguous:

    pick  a/toolchain     ->  toolchain
    pick  b/toolchain     ->  b_toolchain      # toolchain taken by another path
    pick  c/b/toolchain   ->  c_b_toolchain    # b_toolchain taken too
    pick  a/toolchain     ->  toolchain        # same path: reuses, no new session

Matching is by the session's real path, so re-picking a repo always lands back
in its existing session instead of spawning a duplicate. If every
ancestor-qualified name is somehow taken, a `-2` counter is appended.

Inside tmux the session is created detached and switched to; outside, it is
attached directly.

## Configure

- **`TMUX_SEARCH_DIR`** — one root, or several separated by `:` like `PATH`.
  Currently `/mnt/e/repos:/mnt/e/sd:$HOME/dotfiles:$HOME/work`, set in
  `~/.config.zsh`.
- **After changing it, restart the tmux server.** Popups inherit the server's
  environment, not your shell's, so a new value will not reach them until then.
- **Cache** — `~/.cache/tmux-sessionizer/`, one file per mode and root set.
  Safe to delete; it rebuilds on the next run.
- **`max_repo_depth`** — edit near the top of the script to search deeper
  than 4 levels.

## When it complains

    TMUX_SEARCH_DIR is not set
      -> export it, or pass a directory

    skipping missing search dir: /x
      -> warning only; the other roots are still scanned

    no usable directory in TMUX_SEARCH_DIR: ...
      -> every root is gone. exit 1

    not a directory: /x/y
      -> stale cache entry or a typo. exit 1

A cancelled picker exits 0 silently. Every real failure exits 1 with one of
the lines above.

## Timings

Measured on the Windows drive mount, which is where the cost lives.

| What                                           | Time       |
|------------------------------------------------|------------|
| Warm cache - what the popup normally costs     | 1 ms       |
| Full scan, default listing (3432 entries)      | 2.7-2.9 s  |
| Full scan, `-g` (76 entries, one stat per dir) | 760-830 ms |
| `git log` in the preview pane, async           | 132 ms     |
| `git status` in a large repo                   | 24 s       |

That `git status` row is why it is not in the preview: it would peg a core
every time the cursor moved.

The default listing is dominated by whatever large repos sit under a root -
the kernel tree under `/mnt/e/sd` accounts for most of those 3432 entries and
most of the 2.9s. `-g` stays far cheaper because it stops at each repo's edge
instead of walking through it.

The picker opens from the cache and refreshes itself in place, so the list
corrects while you are already typing and the cache is current for next time.
That is why `-g` being slower rarely shows — you only pay it on the first run
after a change, or with `-r`.

## Not this script

- `Ctrl-A s` — jump between sessions that already exist.
- `ts` — start a session in the current repo.
- `tk` — kill the tmux server.
