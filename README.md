# dotfiles

[![Build Status](https://travis-ci.org/rajatscode/dotfiles.svg?branch=main)](https://travis-ci.org/rajatscode/dotfiles)
[![License](https://img.shields.io/github/license/rajatscode/dotfiles)](https://github.com/rajatscode/dotfiles/blob/main/LICENSE)

These are my dotfiles. There are many like them, but these ones are mine.

My dotfiles are my best friends. They are my life. I must master them as I must
master my life.

Without me, my dotfiles are abandoned. Without my dotfiles, I am unproductive.
I must maintain my dotfiles faithfully. I must maintain harder than technical
debt that is trying to destroy me. I must build my productivity before tech
debt tanks it. I will!

My dotfiles and I know that what counts in development are not the lines we
write, the coverage of our tests, nor the lack of linter errors. We know that
it is the sanity that counts. We will stay sane!

My dotfiles are human, even as I, because they are my life. Thus, I will learn
them as a brother. I will learn their weaknesses, their strength, their parts,
their accessories, their directories and their scripts. I will keep my dotfiles
clean and useful, even as I am clean and useful. We will become part of each
other. We will!

Before root, I swear this creed. My dotfiles and I are the defenders of
civilization. We are the masters of technical debt. We are the saviors of my
life.

So be it, until victory is GNU's and there is no technical debt, but
maintainability!

## Installation

Using these dotfiles **will overwrite** your `.bashrc`, `.vimrc`,
`.gitconfig`, and `.tmux.conf`. If you want to preserve your existing
dotfiles, see [Customization](#customization).

To get started with these dotfiles:

1. Download and source `sync.sh`. This will install the repository (at
   `main`) in `~/.configs/dotfiles` (you can set this using the
   `$DOTFILES_HOME_DIR` environment variable, before you run the script). To
   run the script, you can use: ``` source <(curl -s
   https://raw.githubusercontent.com/rajatscode/dotfiles/main/sync.sh) ```
2. Consider whether you want to enable autosync (which will automatically keep
   your dotfiles in line with `main`). This is controlled by the
   `$DOTFILES_AUTOSYNC` environment variable; set it to true to enable
   autosync. To keep autosync disabled, either leave `$DOTFILES_AUTOSYNC` unset
   or set it to false. You can also control the frequency at which dotfile
   autosyncing occurs using the `$DOTFILES_AUTOSYNC_PERIOD_IN_HOURS` variable.
   By default, if `$DOTFILES_AUTOSYNC` is set to true, dotfiles will be synced
   every 24 hours. If `DOTFILES_AUTOSYNC_PERIOD_IN_HOURS` is 0, dotfiles will
   be synced every time `~/.bashrc` is sourced. Note that this happens in the
   background as a non-blocking operation so the overhead is low.

## Usage

These dotfiles are intended for bash, vim, git, and tmux users. If you do not
use any of those four tools, you are unlikely to reap any benefit from
installing these dotfiles.

For now, there is no documentation of the exact features in these dotfiles.
However, you can check out the files (bash and vim dotfiles are broken up by
function in directories) or alternatively incrementally pick up features from
these dotfiles as you run into them in your ordinary workflow.

## Customization

All dotfiles in this repository will include/source other files (if they exist)
where you can extend or override this repository's dotfiles. The naming
convention for these filenames will be to end with `profile`. You can find a
list of these filenames in `vars.sh` or below:

* for bash: `~/.bash_profile` and `~/.bash_aliases`
* for git: `~/.gitprofile`
* for tmux: `~/.tmux.profile`
* for vi(m): `~/.vim_profile`

Of course, you can source other dotfiles *from* these profile files. You can
even just move your existing dotfiles to these new locations, where they'll
override dotfiles in this repository in case of conflict.
