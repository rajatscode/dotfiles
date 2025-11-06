function agent --description 'Agent session manager with directory switching support'
    # Find the agent script
    set -l agent_script "$DOTFILES_DIR/bin/agent"

    if test -z "$DOTFILES_DIR"
        set agent_script "$HOME/.dotfiles/bin/agent"
    end

    if not test -x "$agent_script"
        echo "Error: agent script not found at $agent_script" >&2
        return 1
    end

    # Special handling for 'agent switch'
    if test "$argv[1]" = "switch"
        set -l session_name $argv[2]

        if test -z "$session_name"
            echo "Error: Session name is required. Usage: agent switch <session-name>" >&2
            return 1
        end

        # Run agent script to validate session and get worktree path
        set -l output ($agent_script switch $session_name 2>&1)
        set -l exit_code $status

        if test $exit_code -ne 0
            # Validation failed, show error
            echo $output
            return $exit_code
        end

        # Extract worktree path from the output
        # The script outputs: "[INFO] Working directory: /path/to/worktree"
        set -l worktree (echo $output | grep "Working directory:" | sed 's/.*Working directory: //')

        if test -z "$worktree"; or not test -d "$worktree"
            echo "Error: Could not determine worktree directory" >&2
            echo $output
            return 1
        end

        # Show the success message
        echo $output

        # Change to worktree directory in parent shell
        cd $worktree; or return 1

        # Export environment variable for session tracking
        set -gx AGENT_SESSION $session_name

        return 0
    else
        # For all other commands, pass through to agent script
        $agent_script $argv
        return $status
    end
end
