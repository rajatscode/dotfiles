# 40-agents.zsh - AI Agent Workflow Integration
# Enhances shell for parallel AI coding sessions with context management

## ============================================================================
## Agent Session Detection
## ============================================================================

# Export current agent session (if any)
# This can be set by `agent switch` or detected from directory
if [ -z "${AGENT_SESSION:-}" ] && command -v agent &>/dev/null; then
    export AGENT_SESSION=$(agent current 2>/dev/null || echo "")
fi

## ============================================================================
## Quick Agent Aliases
## ============================================================================

if command -v agent &>/dev/null; then
    alias anew="agent new"
    alias asw="agent switch"
    alias alist="agent list"
    alias actx="agent context"
    alias async="agent sync"
    alias aclose="agent close"

    ## acd: enhanced cd that recognizes session names
    acd() {
        if [ $# -eq 0 ]; then
            cd
            return
        fi

        # Check if argument is an agent session
        if agent list 2>/dev/null | grep -q "^$1$"; then
            agent switch "$1"
        else
            cd "$@"
        fi
    }

    ## aedit: edit current session's context
    aedit() {
        if [ -n "${AGENT_SESSION:-}" ]; then
            agent context "$AGENT_SESSION" --edit
        else
            echo "Not in an agent session. Use 'agent switch <session>' first."
            return 1
        fi
    }

    ## ainfo: show current session info
    ainfo() {
        if [ -n "${AGENT_SESSION:-}" ]; then
            echo "Current Agent Session: $AGENT_SESSION"
            agent context "$AGENT_SESSION"
        else
            echo "Not in an agent session."
            agent list
        fi
    }
fi

## ============================================================================
## Context Management Helpers
## ============================================================================

## ashare: share a file between sessions
ashare() {
    if [ $# -lt 3 ]; then
        echo "Usage: ashare <from-session> <to-session> <filename>"
        return 1
    fi

    agent share-context "$1" "$2" --file="$3"
}

## alock/aunlock: lock/unlock current session
alock() {
    if [ -z "${AGENT_SESSION:-}" ]; then
        echo "Not in an agent session"
        return 1
    fi

    local reason="${1:-Working on session}"
    agent lock "$AGENT_SESSION" "$reason"
}

aunlock() {
    if [ -z "${AGENT_SESSION:-}" ]; then
        echo "Not in an agent session"
        return 1
    fi

    agent unlock "$AGENT_SESSION"
}

## ============================================================================
## AI Agent Quick Start
## ============================================================================

## aquick: quickly start a new agent session with sensible defaults
aquick() {
    local session_name="$1"
    local task="${2:-feature}"

    if [ -z "$session_name" ]; then
        echo "Usage: aquick <session-name> [task-type]"
        echo "  task-type: feature (default), bugfix, refactor, exploration"
        return 1
    fi

    # Create session
    agent new "$session_name" --template="$task"

    # Open context in editor
    agent context "$session_name" --edit

    # Instructions for next steps
    echo ""
    echo "Session created! Next steps:"
    echo "  1. Launch your AI coding tool in: $(agent list | grep "$session_name" | awk '{print $NF}')"
    echo "  2. Share context with: agent context $session_name"
    echo "  3. When done: agent close $session_name"
}

## ============================================================================
## Enhanced Prompt Integration
## ============================================================================

# Function to get current agent session for prompt
__agent_ps1() {
    if [ -n "${AGENT_SESSION:-}" ]; then
        echo " [agent:${AGENT_SESSION}]"
    fi
}

## ============================================================================
## Auto Context Sync (Optional)
## ============================================================================

# If AGENT_AUTO_SYNC is enabled, sync context periodically
if [ "${AGENT_AUTO_SYNC:-false}" = "true" ]; then
    # Add to precmd to sync before each prompt
    __agent_sync_precmd() {
        context-sync --once 2>/dev/null
    }

    if [[ ! "${precmd_functions[(r)__agent_sync_precmd]}" == "__agent_sync_precmd" ]]; then
        precmd_functions+=(__agent_sync_precmd)
    fi
fi

## ============================================================================
## Git Worktree Integration
## ============================================================================

## Check if we're in a worktree created by agent
__in_agent_worktree() {
    local current_dir=$(pwd)
    if [[ "$current_dir" =~ -wt- ]]; then
        return 0
    fi
    return 1
}

## Warn before committing in agent worktree
if command -v git &>/dev/null; then
    # This is handled by the agent tool, but we can add additional helpers
    :
fi

## ============================================================================
## Tab Completion for Agent Commands
## ============================================================================

_agent_sessions_completion() {
    local -a sessions
    sessions=(${(f)"$(agent list 2>/dev/null | awk '/^[a-zA-Z]/ {print $1}' 2>/dev/null)"})
    _describe 'session' sessions
}

compdef _agent_sessions_completion asw acd actx async aclose ashare alock aunlock
