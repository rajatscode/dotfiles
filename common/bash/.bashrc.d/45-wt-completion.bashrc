# 45-wt-completion.bashrc - Bash completion for wt (worktree wrapper)

_wt_completion() {
    local cur prev words cword
    _init_completion || return

    # Commands
    local commands="add new list ls remove rm delete switch sw goto go open integrate merge return ret back prune path pwd branch br info show clean cleanup each foreach help"

    # Get list of worktree names (excluding main)
    _wt_get_worktrees() {
        local git_root=$(git rev-parse --show-toplevel 2>/dev/null)
        [[ -z "$git_root" ]] && return

        git worktree list --porcelain 2>/dev/null | while IFS= read -r line; do
            if [[ $line =~ ^worktree\ (.+)$ ]]; then
                local wt_path="${BASH_REMATCH[1]}"
                # Skip main worktree
                [[ "$wt_path" == "$git_root" ]] && continue

                # Extract worktree name
                local wt_basename=$(basename "$wt_path")
                local wt_name="${wt_basename#wt-}"
                local repo_name=$(basename "$git_root")
                wt_name="${wt_name#${repo_name}-}"

                echo "$wt_name"
            fi
        done
    }

    # Get list of branches
    _wt_get_branches() {
        git branch --format='%(refname:short)' 2>/dev/null
    }

    # First argument: complete command
    if [[ $cword -eq 1 ]]; then
        COMPREPLY=( $(compgen -W "$commands" -- "$cur") )
        return
    fi

    # Get the command
    local command="${words[1]}"

    case "$command" in
        add|new)
            # Second argument: name (no completion)
            # Third argument: branch name
            if [[ $cword -eq 3 ]]; then
                COMPREPLY=( $(compgen -W "$(_wt_get_branches)" -- "$cur") )
            elif [[ $cur == --* ]]; then
                COMPREPLY=( $(compgen -W "--from= --no-create-branch" -- "$cur") )
            fi
            ;;

        remove|rm|delete|switch|sw|goto|go|open|path|branch|br|info|show)
            # Complete with worktree names
            if [[ $cword -eq 2 ]]; then
                COMPREPLY=( $(compgen -W "$(_wt_get_worktrees)" -- "$cur") )
            elif [[ $cur == --* ]]; then
                case "$command" in
                    remove|rm|delete)
                        COMPREPLY=( $(compgen -W "--force" -- "$cur") )
                        ;;
                esac
            fi
            ;;

        list|ls)
            if [[ $cur == --* ]]; then
                COMPREPLY=( $(compgen -W "--all --verbose" -- "$cur") )
            fi
            ;;

        prune)
            if [[ $cur == --* ]]; then
                COMPREPLY=( $(compgen -W "--dry-run" -- "$cur") )
            fi
            ;;

        clean|cleanup)
            if [[ $cur == --* ]]; then
                COMPREPLY=( $(compgen -W "--force" -- "$cur") )
            fi
            ;;

        each|foreach)
            # Complete with git subcommands for convenience
            if [[ $cword -eq 2 ]]; then
                local git_commands="status fetch pull push log diff branch checkout"
                COMPREPLY=( $(compgen -W "$git_commands" -- "$cur") )
            fi
            ;;

        integrate|merge)
            # Complete with worktree/branch names for source
            if [[ $cword -eq 2 ]]; then
                local worktrees=$(_wt_get_worktrees)
                local branches=$(_wt_get_branches)
                COMPREPLY=( $(compgen -W "$worktrees $branches" -- "$cur") )
            elif [[ $cur == --* ]]; then
                COMPREPLY=( $(compgen -W "--into=" -- "$cur") )
            elif [[ $prev == --into ]]; then
                COMPREPLY=( $(compgen -W "$(_wt_get_worktrees)" -- "$cur") )
            fi
            ;;

        return|ret|back)
            if [[ $cur == --* ]]; then
                COMPREPLY=( $(compgen -W "--merge" -- "$cur") )
            fi
            ;;
    esac
}

complete -F _wt_completion wt
