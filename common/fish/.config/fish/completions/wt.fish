# Fish completion for wt (worktree wrapper)

# Helper function to get worktree names
function __wt_worktrees
    set -l git_root (git rev-parse --show-toplevel 2>/dev/null)
    test -z "$git_root"; and return

    git worktree list --porcelain 2>/dev/null | while read -l line
        if string match -qr '^worktree (.+)$' $line
            set -l wt_path (string replace -r '^worktree (.+)$' '$1' $line)

            # Skip main worktree
            test "$wt_path" = "$git_root"; and continue

            # Extract worktree name
            set -l wt_basename (basename $wt_path)
            set -l wt_name (string replace -r '^wt-' '' $wt_basename)
            set -l repo_name (basename $git_root)
            set wt_name (string replace -r "^$repo_name-" '' $wt_name)

            echo $wt_name
        end
    end
end

# Helper function to get branches
function __wt_branches
    git branch --format='%(refname:short)' 2>/dev/null
end

# Clear existing completions
complete -c wt -e

# Commands
complete -c wt -f -n "__fish_use_subcommand" -a "add" -d "Create a new worktree"
complete -c wt -f -n "__fish_use_subcommand" -a "new" -d "Create a new worktree"
complete -c wt -f -n "__fish_use_subcommand" -a "list" -d "List all worktrees"
complete -c wt -f -n "__fish_use_subcommand" -a "ls" -d "List all worktrees"
complete -c wt -f -n "__fish_use_subcommand" -a "remove" -d "Remove a worktree"
complete -c wt -f -n "__fish_use_subcommand" -a "rm" -d "Remove a worktree"
complete -c wt -f -n "__fish_use_subcommand" -a "delete" -d "Remove a worktree"
complete -c wt -f -n "__fish_use_subcommand" -a "switch" -d "Switch to a worktree"
complete -c wt -f -n "__fish_use_subcommand" -a "sw" -d "Switch to a worktree"
complete -c wt -f -n "__fish_use_subcommand" -a "goto" -d "Open worktree in new shell"
complete -c wt -f -n "__fish_use_subcommand" -a "go" -d "Open worktree in new shell"
complete -c wt -f -n "__fish_use_subcommand" -a "open" -d "Open worktree in new shell"
complete -c wt -f -n "__fish_use_subcommand" -a "prune" -d "Clean up stale worktree files"
complete -c wt -f -n "__fish_use_subcommand" -a "path" -d "Show path to worktree"
complete -c wt -f -n "__fish_use_subcommand" -a "pwd" -d "Show path to worktree"
complete -c wt -f -n "__fish_use_subcommand" -a "branch" -d "Show branch of worktree"
complete -c wt -f -n "__fish_use_subcommand" -a "br" -d "Show branch of worktree"
complete -c wt -f -n "__fish_use_subcommand" -a "info" -d "Show worktree information"
complete -c wt -f -n "__fish_use_subcommand" -a "show" -d "Show worktree information"
complete -c wt -f -n "__fish_use_subcommand" -a "clean" -d "Remove stale worktrees"
complete -c wt -f -n "__fish_use_subcommand" -a "cleanup" -d "Remove stale worktrees"
complete -c wt -f -n "__fish_use_subcommand" -a "each" -d "Run command in each worktree"
complete -c wt -f -n "__fish_use_subcommand" -a "foreach" -d "Run command in each worktree"
complete -c wt -f -n "__fish_use_subcommand" -a "help" -d "Show help message"

# Options for 'add' command
complete -c wt -f -n "__fish_seen_subcommand_from add new" -l from -d "Base branch" -a "(__wt_branches)"
complete -c wt -f -n "__fish_seen_subcommand_from add new" -l no-create-branch -d "Don't create branch"

# Options for 'list' command
complete -c wt -f -n "__fish_seen_subcommand_from list ls" -s a -l all -d "Include main worktree"
complete -c wt -f -n "__fish_seen_subcommand_from list ls" -s v -l verbose -d "Show full paths"

# Options for 'remove' command
complete -c wt -f -n "__fish_seen_subcommand_from remove rm delete" -s f -l force -d "Force removal"
complete -c wt -f -n "__fish_seen_subcommand_from remove rm delete" -a "(__wt_worktrees)"

# Options for 'switch' command
complete -c wt -f -n "__fish_seen_subcommand_from switch sw" -a "(__wt_worktrees)"

# Options for 'goto' command
complete -c wt -f -n "__fish_seen_subcommand_from goto go open" -a "(__wt_worktrees)"

# Options for 'prune' command
complete -c wt -f -n "__fish_seen_subcommand_from prune" -l dry-run -d "Show what would be pruned"

# Options for 'path' command
complete -c wt -f -n "__fish_seen_subcommand_from path pwd" -a "(__wt_worktrees)"

# Options for 'branch' command
complete -c wt -f -n "__fish_seen_subcommand_from branch br" -a "(__wt_worktrees)"

# Options for 'info' command
complete -c wt -f -n "__fish_seen_subcommand_from info show" -a "(__wt_worktrees)"

# Options for 'clean' command
complete -c wt -f -n "__fish_seen_subcommand_from clean cleanup" -s f -l force -d "Force cleanup"

# Options for 'each' command - suggest git subcommands
complete -c wt -f -n "__fish_seen_subcommand_from each foreach; and not __fish_seen_subcommand_from status fetch pull push log diff branch checkout" -a "status fetch pull push log diff branch checkout"
