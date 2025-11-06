# AI Agent Workflows Guide

This guide shows you how to use the multi-agent parallelization harness to run multiple AI coding sessions in parallel.

## Table of Contents

- [Overview](#overview)
- [Basic Concepts](#basic-concepts)
- [Quick Start](#quick-start)
- [Common Workflows](#common-workflows)
- [Advanced Usage](#advanced-usage)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Overview

The agent harness enables you to:
- Run multiple AI coding assistants (Claude, Codex, etc.) in parallel
- Give each agent its own git worktree for isolated work
- Share context and architectural knowledge between sessions
- Prevent conflicts with lock files
- Manage session lifecycle (create, sync, close)

## Basic Concepts

### Sessions

A **session** represents a single AI coding task. Each session has:
- A unique name (e.g., `feature-auth`)
- Its own git worktree (e.g., `~/myproject-wt-feature-auth/`)
- A dedicated context directory (`~/.config/agents/contexts/myproject/session-feature-auth/`)
- A git branch (e.g., `feature/auth`)

### Context

**Context** is shared information that helps AI agents understand your codebase:
- `context.md` - What this session is working on
- `notes.md` - Development notes
- `shared-tempfiles/` - Files shared across sessions
- `global/` - Repository-wide context (architecture, conventions, etc.)

### Templates

**Templates** provide pre-configured context for different task types:
- `feature` - New feature development
- `bugfix` - Bug fixes
- `refactor` - Code refactoring
- `exploration` - Codebase exploration

## Quick Start

### 1. Create Your First Session

```bash
cd ~/projects/myproject
agent new feature-auth --template=feature
```

This creates:
- Git worktree at `~/projects/myproject-wt-feature-auth/`
- Context directory
- Pre-filled context.md from template

### 2. Edit the Context

```bash
agent context feature-auth --edit
```

Fill in:
- Objective: What are you building?
- Approach: How will you build it?
- Progress: Task checklist

### 3. Launch Your AI Agent

Open your AI coding tool (Claude Code, Cursor, etc.) in the worktree directory:

```bash
cd ~/projects/myproject-wt-feature-auth/
# Launch your AI tool here
```

Share the context with your AI agent by showing it `context.md`.

### 4. Work and Iterate

As you work:
- Update `notes.md` with findings
- Check off progress items
- Commit changes to the feature branch

### 5. Close the Session

When done:

```bash
agent close feature-auth --archive --delete-branch
```

This:
- Archives the context
- Removes the worktree
- Optionally deletes the git branch

## Common Workflows

### Parallel Feature Development

Work on multiple features simultaneously with different AI agents:

```bash
# Session 1: Authentication
agent new auth --branch=feature/oauth --template=feature

# Session 2: User Profile
agent new profile --branch=feature/user-profile --template=feature

# Session 3: API Endpoints
agent new api --branch=feature/api-v2 --template=feature

# List all sessions
agent list
```

Now launch three AI agents, each in their own worktree!

### Bug Fix Workflow

```bash
# Create bug fix session
agent new fix-login-crash --branch=bugfix/login-crash --template=bugfix

# Edit context to describe the bug
agent context fix-login-crash --edit

# Launch AI agent in the worktree
cd $(agent list | grep fix-login-crash | awk '{print $NF}')

# When fixed, close the session
agent close fix-login-crash --archive --delete-branch
```

### Exploration and Research

Use the exploration template when you need to understand a codebase:

```bash
# Create exploration session
agent new explore-auth --template=exploration

# Edit context with your questions
agent context explore-auth --edit

# Launch AI agent to explore
# Document findings in notes.md

# Close when done (keep branch for reference)
agent close explore-auth --archive
```

### Refactoring Workflow

```bash
# Create refactoring session
agent new refactor-api --branch=refactor/api-cleanup --template=refactor

# Edit context with refactoring goals
agent context refactor-api --edit

# Launch AI agent

# Ensure tests pass throughout refactoring
# Mark progress items as complete

# Close when refactoring is done
agent close refactor-api --archive --delete-branch
```

### PR Review Workflow with Agent Sessions

When you receive PR review comments, use the agent system to systematically address them:

#### Recommended Workflow (Agent-Based)

```bash
# 1. You have a PR branch with review comments
git checkout rajat/hchb-ar/specialist-assignment-to-db

# 2. Create an agent session to address the comments
agent new pr-review-fixes

# 3. Switch to the agent worktree
agent switch pr-review-fixes
# OR: cd ~/myrepo-wt-pr-review-fixes

# 4. Run shepherd to fetch PR comments
agent shepherd

# Shepherd will:
# - Auto-detect the PR from your base branch (not the agent branch!)
# - Fetch all unresolved review comments
# - Create shepherd.md with all comments in your session context
# - Launch your AI tool with both context.md and shepherd.md

# 5. Address the comments in your AI tool
# The AI tool will read:
#   - context.md: Your session objectives
#   - shepherd.md: All PR review comments with code context

# 6. Make fixes, commit them
git add .
git commit -m "Address PR review comments"

# 7. Integrate changes back to PR branch
agent integrate pr-review-fixes --push --close

# Your PR branch now has the fixes!
# Push to update the PR:
cd ~/myrepo  # back to main worktree
git push
```

**What shepherd does:**

1. Detects if you're in an agent session
2. If in agent session, looks for PR on the **base branch** (not agent branch)
3. Fetches unresolved review comments from GitHub
4. Creates `shepherd.md` in your session context directory
5. Stores PR number in session metadata
6. Launches your AI tool with full context

**Key Features:**

- **Session isolation**: Work on PR fixes in isolated worktree
- **Context separation**: `context.md` (objectives) + `shepherd.md` (PR comments)
- **Smart PR detection**: Finds PR on base branch when in agent session
- **Progress tracking**: Session tracks your PR review progress
- **Easy integration**: Merge fixes back with `agent integrate`

**Command Options:**

```bash
# Auto-detect PR from base branch (when in agent session)
agent shepherd

# Specify PR number explicitly
agent shepherd --pr=123

# Dry run (preview comments without launching AI)
agent shepherd --dry-run
```

**Requirements:**
- GitHub CLI (`gh`) must be installed and authenticated: `gh auth login`
- Must be in a git repository with a PR
- AI tool configured: `agent config`

**Tips:**
- Use `--dry-run` first to preview comments
- Both `context.md` and `shepherd.md` are available to your AI tool
- Run `/agent-instructions` in your AI tool to load both contexts
- Session remembers the PR number for easy re-runs

## Advanced Usage

### Sharing Context Between Sessions

Share files between sessions to coordinate work:

```bash
# Session 1 creates an API spec
# In session 1's worktree
echo "API Specification..." > api-spec.md

# Share with session 2
agent share-context feature-auth feature-profile --file=api-spec.md

# Now session 2 can use the API spec
```

### Syncing with Main Branch

Keep your session up-to-date with main:

```bash
# Sync session with latest main
agent sync feature-auth

# This fetches and rebases onto origin/main
```

### Integrating Changes Back to Base Branch

When you're done with a session, use `agent integrate` to merge changes back to your base branch:

```bash
# Local merge only (no push)
agent integrate feature-auth

# Merge and push to remote
agent integrate feature-auth --push

# Merge, push, and close session in one command
agent integrate feature-auth --push --close

# Force a merge commit (no fast-forward)
agent integrate feature-auth --no-ff
```

**How it works:**
1. Switches to your base branch (the branch you created the session from)
2. Merges the agent branch into the base branch
3. Optionally pushes the result
4. Optionally closes the session and cleans up

**Important notes:**
- The base branch is automatically tracked when you create the session
- By default, `agent new` uses your **current branch** as the base (not main)
- Use `--base=<branch>` to explicitly specify a different base branch
- If conflicts occur, you'll need to resolve them manually

**Example: Feature branch workflow**

```bash
# On your feature branch
git checkout feature/oauth

# Create agent session (will use feature/oauth as base)
agent new add-tests

# Work in the agent worktree...
cd ~/myproject-wt-add-tests/
# Make changes, commit them

# Integrate back to feature/oauth
agent integrate add-tests --push --close
```

**Example: Working from main**

```bash
# On main branch
git checkout main

# Create agent session (will use main as base)
agent new fix-bug

# Work in the agent worktree...
# Make changes, commit them

# Integrate back to main
agent integrate fix-bug --push
```

### Locking Sessions

Prevent concurrent edits to shared context:

```bash
# Lock before editing shared context
agent lock feature-auth "Editing API spec"

# Edit shared files...

# Unlock when done
agent unlock feature-auth
```

### Using Global Context

Share architecture notes across all sessions:

```bash
# Create global context (done automatically)
cd ~/.config/agents/contexts/myproject/global/

# Edit architecture.md
vim architecture.md

# Edit conventions.md
vim conventions.md

# All sessions can read these files!
```

### Context Syncing

Automatically sync context between sessions:

```bash
# Sync once
context-sync --once

# Watch and sync continuously (in separate terminal)
context-sync --watch

# Check sync status
context-sync --status
```

## Best Practices

### 1. Use Descriptive Session Names

Good:
```bash
agent new oauth-integration
agent new fix-memory-leak
agent new refactor-auth-layer
```

Bad:
```bash
agent new test
agent new new-feature
agent new fix
```

### 2. Keep Context Updated

Regularly update `context.md` and `notes.md`:
- When objectives change
- When you discover important information
- When you complete tasks

### 3. Share Global Context Early

Create `global/architecture.md` and `global/conventions.md` before starting parallel work:

```bash
cd ~/.config/agents/contexts/myproject/global/
vim architecture.md  # Document high-level architecture
vim conventions.md   # Document coding standards
```

### 4. Sync Frequently

Sync sessions with main to avoid merge conflicts:

```bash
# Daily or before major work
agent sync feature-auth
```

### 5. Close Completed Sessions

Don't let old sessions accumulate:

```bash
# Archive and clean up
agent close old-feature --archive --delete-branch

# Or just list and clean
agent list
worktree-clean
```

### 6. Use Templates Consistently

Choose the right template for your task:
- `feature` - New functionality
- `bugfix` - Fixing bugs
- `refactor` - Code improvement
- `exploration` - Research/learning

## Troubleshooting

### Session Not Found

```bash
$ agent switch feature-auth
Error: Session 'feature-auth' not found
```

**Solution**: List sessions to check the exact name:
```bash
agent list
```

### Worktree Directory Missing

```bash
$ agent switch feature-auth
Error: Worktree directory not found
```

**Solution**: The worktree was deleted externally. Close and recreate:
```bash
agent close feature-auth
agent new feature-auth --branch=feature/auth
```

### Can't Lock Session

```bash
$ agent lock feature-auth "Editing"
Error: Session is already locked
```

**Solution**: Check who has the lock:
```bash
cat ~/.config/agents/contexts/myproject/session-feature-auth/.lock
```

If it's safe, force unlock:
```bash
agent unlock feature-auth
```

### Merge Conflicts After Sync

```bash
$ agent sync feature-auth
Error: Rebase failed
```

**Solution**: Resolve conflicts manually:
```bash
cd ~/projects/myproject-wt-feature-auth/
git status
# Resolve conflicts
git add .
git rebase --continue
```

### Too Many Sessions

```bash
$ agent list
# Shows 20+ sessions...
```

**Solution**: Close completed sessions:
```bash
# Close with archive
agent close old-session --archive

# Clean stale worktrees
worktree-clean
```

### Shepherd Can't Find PR

```bash
$ agent shepherd
Error: No PR found for this branch
```

**Solution**: Specify PR number manually:
```bash
agent shepherd --pr=123
```

Or ensure you're on the correct branch:
```bash
git branch --show-current
gh pr list --head $(git branch --show-current)
```

### GitHub CLI Not Authenticated

```bash
$ agent shepherd
Error: GitHub CLI is not authenticated
```

**Solution**: Authenticate with GitHub:
```bash
gh auth login
```

### Shepherd Analysis Failing

If the AI analysis helper fails:

**Solution 1**: Install Claude CLI for better analysis:
```bash
# See: https://github.com/anthropics/claude-code
```

**Solution 2**: Use manual mode:
- The analysis prompt is saved to `/tmp/shepherd-analysis-*.md`
- Copy the prompt and paste into any AI assistant
- Apply suggested changes manually

## Example: Full Feature Development

Here's a complete example of developing a feature with multiple AI agents:

```bash
# 1. Create main feature session
agent new oauth-main --branch=feature/oauth --template=feature
agent context oauth-main --edit
# Fill in: OAuth 2.0 integration with Google

# 2. Create sub-tasks in parallel
agent new oauth-frontend --branch=feature/oauth-ui --template=feature
agent new oauth-backend --branch=feature/oauth-api --template=feature
agent new oauth-tests --branch=feature/oauth-tests --template=feature

# 3. Set up global context
cat > ~/.config/agents/contexts/myproject/global/oauth-spec.md <<EOF
# OAuth Integration Specification

## Provider: Google OAuth 2.0
## Scopes: email, profile
## Callback: /auth/google/callback
EOF

# 4. Launch AI agents
# - Agent 1: Work on oauth-frontend
# - Agent 2: Work on oauth-backend
# - Agent 3: Write tests

# 5. Share context as needed
agent share-context oauth-backend oauth-frontend --file=api-endpoints.md
agent share-context oauth-backend oauth-tests --file=test-scenarios.md

# 6. Sync regularly
agent sync oauth-frontend
agent sync oauth-backend
agent sync oauth-tests

# 7. When done, integrate and close
# Option A: Merge locally with integrate
agent integrate oauth-frontend --push --close
agent integrate oauth-backend --push --close
agent integrate oauth-tests --push --close
agent integrate oauth-main --push --close

# Option B: Create PRs for review (manual process)
# Push branches and create PRs via GitHub
# Then close sessions after PRs are merged
agent close oauth-frontend --archive --delete-branch
agent close oauth-backend --archive --delete-branch
agent close oauth-tests --archive --delete-branch
agent close oauth-main --archive --delete-branch
```

## Tips & Tricks

### Quick Session Switching

Add to your `~/.bash_profile`:

```bash
# Quick session switching
alias asw='agent switch'
alias anew='agent new'
alias actx='agent context'
```

### Auto-Sync on Shell Start

Add to your `~/.bash_profile`:

```bash
# Auto-sync context when starting shell
if [ -n "$AGENT_SESSION" ]; then
    context-sync --once &>/dev/null &
fi
```

### Session Status in Prompt

Your prompt already shows the active session if you're using the provided bashrc!

Look for: `[agent:feature-auth]` in your prompt

### List Sessions by Age

```bash
# Show oldest sessions first
agent list | sort -k4
```

---

**Happy parallel coding! 🚀**

For more information, see:
- [ARCHITECTURE.md](../ARCHITECTURE.md) - System design
- [README.md](../README.md) - Overview and installation
