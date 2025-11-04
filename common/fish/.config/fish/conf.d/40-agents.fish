# 40-agents.fish - AI Agent Workflow Integration
# Enhances shell for parallel AI coding sessions with context management

## ============================================================================
## Agent Session Detection
## ============================================================================

# Export current agent session (if any)
if test -z "$AGENT_SESSION"; and command -v agent &>/dev/null
    set -x AGENT_SESSION (agent current 2>/dev/null; or echo "")
end

## ============================================================================
## Quick Agent Aliases
## ============================================================================

if command -v agent &>/dev/null
    alias anew="agent new"
    alias asw="agent switch"
    alias alist="agent list"
    alias actx="agent context"
    alias async="agent sync"
    alias aclose="agent close"

    ## acd: enhanced cd that recognizes session names
    function acd
        if test (count $argv) -eq 0
            cd
            return
        end

        # Check if argument is an agent session
        if agent list 2>/dev/null | grep -q "^$argv[1]\$"
            agent switch $argv[1]
        else
            cd $argv
        end
    end

    ## aedit: edit current session's context
    function aedit
        if test -n "$AGENT_SESSION"
            agent context $AGENT_SESSION --edit
        else
            echo "Not in an agent session. Use 'agent switch <session>' first."
            return 1
        end
    end

    ## ainfo: show current session info
    function ainfo
        if test -n "$AGENT_SESSION"
            echo "Current Agent Session: $AGENT_SESSION"
            agent context $AGENT_SESSION
        else
            echo "Not in an agent session."
            agent list
        end
    end
end

## ============================================================================
## Context Management Helpers
## ============================================================================

## ashare: share a file between sessions
function ashare
    if test (count $argv) -lt 3
        echo "Usage: ashare <from-session> <to-session> <filename>"
        return 1
    end

    agent share-context $argv[1] $argv[2] --file=$argv[3]
end

## alock/aunlock: lock/unlock current session
function alock
    if test -z "$AGENT_SESSION"
        echo "Not in an agent session"
        return 1
    end

    set -l reason $argv[1]
    if test -z "$reason"
        set reason "Working on session"
    end

    agent lock $AGENT_SESSION $reason
end

function aunlock
    if test -z "$AGENT_SESSION"
        echo "Not in an agent session"
        return 1
    end

    agent unlock $AGENT_SESSION
end

## ============================================================================
## AI Agent Quick Start
## ============================================================================

## aquick: quickly start a new agent session
function aquick
    set -l session_name $argv[1]
    set -l task $argv[2]
    if test -z "$task"
        set task feature
    end

    if test -z "$session_name"
        echo "Usage: aquick <session-name> [task-type]"
        echo "  task-type: feature (default), bugfix, refactor, exploration"
        return 1
    end

    # Create session
    agent new $session_name --template=$task

    # Open context in editor
    agent context $session_name --edit

    # Instructions for next steps
    echo ""
    echo "Session created! Next steps:"
    echo "  1. Launch your AI coding tool in: "(agent list | grep $session_name | awk '{print $NF}')
    echo "  2. Share context with: agent context $session_name"
    echo "  3. When done: agent close $session_name"
end

## ============================================================================
## Enhanced Prompt Integration
## ============================================================================

# Function to get current agent session for prompt
function __agent_ps1
    if test -n "$AGENT_SESSION"
        echo " [agent:$AGENT_SESSION]"
    end
end

## ============================================================================
## Git Worktree Integration
## ============================================================================

## Check if we're in a worktree created by agent
function __in_agent_worktree
    set -l current_dir (pwd)
    string match -q '*-wt-*' $current_dir
end

## ============================================================================
## Tab Completion for Agent Commands
## ============================================================================

function __agent_sessions
    agent list 2>/dev/null | awk '/^[a-zA-Z]/ {print $1}' 2>/dev/null
end

complete -c asw -a "(__agent_sessions)"
complete -c acd -a "(__agent_sessions)"
complete -c actx -a "(__agent_sessions)"
complete -c async -a "(__agent_sessions)"
complete -c aclose -a "(__agent_sessions)"
complete -c ashare -a "(__agent_sessions)"
complete -c alock -a "(__agent_sessions)"
complete -c aunlock -a "(__agent_sessions)"
