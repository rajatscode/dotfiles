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

`memory-groom` reconciles each Claude Code auto-memory `MEMORY.md` in place,
preserving its existing text, headings, and order while adding unlisted memory
files and removing links to archived files. It archives project memories idle
for 21 days (`MEMORY_GROOM_DAYS`) unless their frontmatter sets
`metadata.pinned: true`. Before changing a memory directory, it commits any
existing local Git changes as a baseline, then commits its own changes locally;
it never pushes. It requires `uv` and a configured Git identity.

Install it without installing the rest of these dotfiles:

```sh
mkdir -p ~/.local/bin
curl -fsSL https://raw.githubusercontent.com/rajatscode/dotfiles/main/dot_local/bin/executable_memory-groom -o ~/.local/bin/memory-groom
chmod +x ~/.local/bin/memory-groom
~/.local/bin/memory-groom --dry-run
```

Review the preview, then run `~/.local/bin/memory-groom` to apply changes.
Pass `--dir PATH` to groom one directory containing `MEMORY.md`. The default
root is `~/.claude/projects`; use `--root PATH` or `MEMORY_GROOM_ROOT` to
select another root.

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
