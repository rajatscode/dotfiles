# Agent command wrapper for zsh
# Intercepts 'agent switch' to change directory in parent shell

agent() {
    # Find the agent script
    local agent_script="${DOTFILES_DIR:-$HOME/.dotfiles}/bin/agent"

    if [[ ! -x "$agent_script" ]]; then
        echo "Error: agent script not found at $agent_script" >&2
        return 1
    fi

    # Special handling for 'agent leave'
    if [[ "$1" == "leave" ]]; then
        if [[ -z "$AGENT_SESSION" ]]; then
            echo "Not in an agent session" >&2
            return 1
        fi

        # Get the repo path from session metadata
        local output=$("$agent_script" leave 2>&1)
        local exit_code=$?

        if [[ $exit_code -ne 0 ]]; then
            echo "$output"
            return $exit_code
        fi

        # Extract repo path from output
        # Script outputs: "Left agent session, returned to: /path/to/repo"
        local repo_path=$(echo "$output" | grep "returned to:" | sed 's/.*returned to: //')

        # Unset the session variable
        unset AGENT_SESSION

        # Change directory if we got a path
        if [[ -n "$repo_path" && -d "$repo_path" ]]; then
            cd "$repo_path"
            echo "Left agent session, returned to: $repo_path"
        else
            echo "Left agent session"
        fi

        return 0
    # Special handling for 'agent switch'
    elif [[ "$1" == "switch" ]]; then
        local session_name="$2"

        if [[ -z "$session_name" ]]; then
            echo "Error: Session name is required. Usage: agent switch <session-name>" >&2
            return 1
        fi

        # Run agent script to validate session and get worktree path
        local output=$("$agent_script" switch "$session_name" 2>&1)
        local exit_code=$?

        if [[ $exit_code -ne 0 ]]; then
            # Validation failed, show error
            echo "$output"
            return $exit_code
        fi

        # Extract worktree path from the output
        # The script outputs: "[INFO] Working directory: /path/to/worktree"
        local worktree=$(echo "$output" | grep "Working directory:" | sed 's/.*Working directory: //')

        if [[ -z "$worktree" || ! -d "$worktree" ]]; then
            echo "Error: Could not determine worktree directory" >&2
            echo "$output"
            return 1
        fi

        # Show the success message
        echo "$output"

        # Change to worktree directory in parent shell
        cd "$worktree" || return 1

        # Export environment variable for session tracking
        export AGENT_SESSION="$session_name"

        return 0
    else
        # For all other commands, pass through to agent script
        "$agent_script" "$@"
        return $?
    fi
}
