# 30-git.bashrc - Git shortcuts and workflow helpers

## ============================================================================
## Basic Git Aliases
## ============================================================================

alias gpom="git push origin main"
alias add="git add"
alias commit="git commit"
alias push="git push"
alias status="git status"
alias stash="git stash"

## push-please: force push with lease (don't overwrite remote branch commits)
alias push-please="git push --force-with-lease"

## ============================================================================
## Enhanced Git Functions
## ============================================================================

## gco: smart checkout (branch or file)
gco() {
    if [ $# -eq 0 ]; then
        echo "Usage: gco <branch|file>"
        return 1
    fi

    # If it's a file, checkout the file
    if [ -f "$1" ]; then
        git checkout -- "$1"
    else
        # Otherwise, try to checkout the branch
        git checkout "$@"
    fi
}

## gnew: create and checkout a new branch
gnew() {
    if [ $# -eq 0 ]; then
        echo "Usage: gnew <branch-name> [base-branch]"
        return 1
    fi

    local branch_name="$1"
    local base_branch="${2:-main}"

    git checkout -b "$branch_name" "$base_branch"
}

## gsync: sync current branch with main
gsync() {
    local current_branch=$(git branch --show-current)
    local base_branch="${1:-main}"

    echo "Syncing $current_branch with $base_branch..."

    git fetch origin "$base_branch"
    git rebase "origin/$base_branch"
}

## gclean: clean up merged branches
gclean() {
    echo "Cleaning up merged branches..."
    git branch --merged | grep -v "\*" | grep -v "main" | grep -v "master" | xargs -n 1 git branch -d 2>/dev/null || echo "No branches to clean"
}

## gundo: undo last commit (keep changes)
alias gundo="git reset --soft HEAD~1"

## gwip: quick work-in-progress commit
gwip() {
    git add .
    git commit -m "WIP: $(date '+%Y-%m-%d %H:%M:%S')"
}

## gunwip: undo last WIP commit
gunwip() {
    if git log -1 --pretty=%B | grep -q "^WIP:"; then
        git reset --soft HEAD~1
        echo "WIP commit undone"
    else
        echo "Last commit is not a WIP commit"
        return 1
    fi
}

## ============================================================================
## Git Worktree Helpers (for Agent Workflows)
## ============================================================================

## gwt: shorthand for git worktree
alias gwt="git worktree"
alias gwtl="git worktree list"
alias gwta="git worktree add"
alias gwtr="git worktree remove"

## ============================================================================
## Git Info in Prompt (if .git-prompt.sh exists)
## ============================================================================

# This will be used by 50-prompt.bashrc
if [ -f ~/.git-prompt.sh ]; then
    source ~/.git-prompt.sh
elif [ -f /usr/share/git-core/contrib/completion/git-prompt.sh ]; then
    source /usr/share/git-core/contrib/completion/git-prompt.sh
elif [ -f /usr/lib/git-core/git-sh-prompt ]; then
    source /usr/lib/git-core/git-sh-prompt
fi
