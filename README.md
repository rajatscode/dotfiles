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
`WT_REAP_TMP_IDLE_DAYS` and `WT_REAP_IDLE_DAYS`. The macOS job uses one day
for both, including dirty worktrees whose commits are published. Their
uncommitted edits are removed with the worktree. Clean worktrees kept for
unpublished commits retain their source and branch; after three idle days, the
job removes their Git-ignored root
`node_modules` and root or immediate-child `.venv` directories if no process
has its working directory there. Override that limit with `WT_REAP_CACHE_IDLE_DAYS`.

On macOS, `chezmoi apply` also:

- caps OrbStack at two thirds of the cores and a third of the memory
  (`orb stop`, then reopen OrbStack, applies new limits);
- loads LaunchAgents that run `wt-reap --apply` hourly over `~/dev/fira` and
  `orb-reap --apply` every two hours, and `agent-nice --apply` every 30
  seconds, which renices `claude` and `codex` process trees to 10 however they
  were launched. `orb-reap` removes containers whose
  compose working directory is gone, stops containers up longer than
  `ORB_REAP_MAX_HOURS` (48) unless their restart policy keeps them up, and
  prunes build cache older than a week plus dangling images. Below 80 GiB of
  host free space, it also prunes unused images older than one day and
  unused build cache older than 24 hours; override the image age with
  `ORB_REAP_IMAGE_DAYS` and the free-space threshold with
  `ORB_REAP_MIN_FREE_GIB`;
- adds `~/dev`, `~/tmp`, `~/Library/pnpm`, and `~/.cache` to the Spotlight
  Privacy list through `spotlight-exclude`, which needs root and Full Disk
  Access for the terminal.
