# Global Instructions

- Don't spawn more than 5 agents at any point during this session.
- If additional work is needed, queue it rather than creating more concurrent agents.
- Prefer sequential execution over excessive parallelism.

# Working style

Ask for confirmation before editing any file. Treat a question about the code
("what about naming it X?", "similarly for Y") as a request for analysis only,
never as approval to apply the change. Explicit approval covers only the change
it was given for — it does not carry over to the next one.

Write in simple English. Use short sentences and common words. Avoid idioms,
rare vocabulary, and long subordinate clauses. Keep technical terms — it is the
prose around them that should be plain.

# Claude Code gotchas

- `settings.json` `env` values are **literal** — no `${VAR}`, `$VAR`, or
  embedded expansion of any kind (verified by probe on the Windows install;
  same binary, so expect the same here). Never write `"PATH": "${PATH}:..."`;
  it sets PATH to that literal string and breaks every command. Put PATH
  changes in the shell rc file instead.
- The Bash tool does not source rc files per command. It replays a per-launch
  snapshot under `~/.claude/shell-snapshots/` that captures functions and
  aliases but exports exactly one variable: PATH. So rc-file PATH changes do
  reach the tool shell after a restart, but any other variable exported there
  does not. A function whose body dereferences a lost variable fails with a
  confusing "command not found" — export what such functions depend on, inline
  in the command. Edits to an rc file never reach the *current* session, whose
  snapshot is already captured; verify with `bash -lc '...'`, which builds a
  fresh shell.

# Embedded toolchains live on the Windows side

The RH850 (Renesas CC-RH), C2000 (TI CGT) and STM32 (STM32CubeCLT) toolchains
are installed under Windows, not in this distro. They are reachable through
`/mnt/c`, but they are Windows executables and do not understand WSL paths — a
`-I/mnt/c/...` or a `/home/...` source argument will not resolve. Convert with
`wslpath -w` first, or just run those builds from the Windows side, where the
paths and the IDE already line up.

Native here: `python` (`/usr/sbin/python`), `gcc`, `cmake`, `ninja`, `make`.
No `arm-none-eabi-gcc`.

Miniforge is installed at `~/miniforge3` (conda 25.11.0, Python 3.12.12) but no
rc file has a `conda init` block, so neither `conda` nor its `python` is on
PATH — `python` resolves to the system one. Call `~/miniforge3/bin/conda` and
`~/miniforge3/bin/python` by absolute path, or run `~/miniforge3/bin/conda init
bash` to wire it up. Note this is a separate installation from the Windows
miniforge; the two share nothing.

# C/C++ style (SEDEMAC)

Full guide: `~/.claude/c-style-guide.md`. Read it before writing C in a SEDEMAC
repo. The rules most often missed:

- Signed integers take `s8`/`s16`/`s32`/`s64`, **not** `i32`. Unsigned take `u8`
  and so on. Globals add `g`, pointers add `p`, custom types use `x`.
- Every `#endif` names the macro it closes: `#endif /* FOO */`.
- Private functions are `prv`-prefixed. Public are `xMODULE_` (returns data) or
  `vMODULE_` (void).
- Every `switch` has a `default:` case.
- One variable per declaration. No comma-separated lists.
- No space between `if`/`for`/`while` and `(`, but spaces just inside the parens.
- Source files use this banner order: Includes, Definitions, Variables, Extern
  Variables, Extern Functions, Private Function Declarations, Public Function
  Implementation, Private Function Implementation.
- Never reformat legacy files that predate the guide - it creates diff noise.
