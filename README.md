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

On macOS, `chezmoi apply` also:

- caps OrbStack at two thirds of the cores and half the memory less 2 GiB
  (`orb stop`, then reopen OrbStack, applies new limits);
- loads LaunchAgents that run `wt-reap --apply` hourly over `~/dev/fira` and
  `orb-reap --apply` every two hours. `orb-reap` removes containers whose
  compose working directory is gone, stops containers up longer than
  `ORB_REAP_MAX_HOURS` (48) unless their restart policy keeps them up, and
  prunes build cache older than a week plus dangling images;
- adds `~/dev`, `~/tmp`, `~/Library/pnpm`, and `~/.cache` to the Spotlight
  Privacy list through `spotlight-exclude`, which needs root and Full Disk
  Access for the terminal.
