# Dotfiles

This is the chezmoi source directory for my shell, editor, Git, tmux, and
worktree setup.

```sh
chezmoi init --apply git@github.com:rajatscode/dotfiles.git
chezmoi diff
chezmoi apply
```

Machine-specific package lists live in `macos/` and `linux/`; they are source
repo material and are not copied into `$HOME`.

`wt-reap` is installed at `~/.local/bin/wt-reap`. Run it without arguments to
preview eligible worktrees, or pass `--apply` to remove them. It scans Git
repositories directly under `~/dev` by default; set `WT_REAP_ROOTS` or use
`--repo /path/to/repo` to select repositories. The default idle limits are three
days for temporary worktrees and fourteen days elsewhere; override them with
`WT_REAP_TMP_IDLE_DAYS` and `WT_REAP_IDLE_DAYS`.

`memory-groom` keeps Claude Code auto-memory indexes trim. For each
`~/.claude/projects/*/memory/` with a `MEMORY.md`, it moves project memories
untouched for 21 days (`MEMORY_GROOM_DAYS`) into `archive/` unless their
frontmatter sets `metadata.pinned: true`, rebuilds `MEMORY.md` from the
remaining files' frontmatter, and commits the result in that directory's local
Git repository. Bullets that point at no memory file are kept under
`## Unfiled`. `--dry-run` prints the diff; `--dir PATH` limits it to one
directory. Tests: `uv run --script tests/test_memory_groom.py`.

On macOS, `chezmoi apply` also:

- caps OrbStack at two thirds of the cores and a third of the memory
  (`orb stop`, then reopen OrbStack, applies new limits);
- loads LaunchAgents that run `wt-reap --apply` hourly over `~/dev/fira` and
  `orb-reap --apply` every two hours, and `agent-nice --apply` every 30
  seconds, which renices `claude` and `codex` process trees to 10 however they
  were launched, and `memory-groom` daily at 04:00. `orb-reap` removes containers whose
  compose working directory is gone, stops containers up longer than
  `ORB_REAP_MAX_HOURS` (48) unless their restart policy keeps them up, and
  prunes build cache older than a week plus dangling images;
- adds `~/dev`, `~/tmp`, `~/Library/pnpm`, and `~/.cache` to the Spotlight
  Privacy list through `spotlight-exclude`, which needs root and Full Disk
  Access for the terminal.
