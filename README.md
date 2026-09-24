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
