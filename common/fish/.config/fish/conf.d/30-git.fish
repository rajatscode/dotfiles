# 30-git.fish - Git shortcuts and workflow helpers

## ============================================================================
## Basic Git Aliases
## ============================================================================

alias gpom="git push origin main"
alias add="git add"
alias commit="git commit"
alias push="git push"
alias status="git status"
alias stash="git stash"

## push-please: force push with lease
alias push-please="git push --force-with-lease"

## ============================================================================
## Enhanced Git Functions
## ============================================================================

## gco: smart checkout (branch or file)
function gco
    if test (count $argv) -eq 0
        echo "Usage: gco <branch|file>"
        return 1
    end

    # If it's a file, checkout the file
    if test -f $argv[1]
        git checkout -- $argv[1]
    else
        # Otherwise, try to checkout the branch
        git checkout $argv
    end
end

## gnew: create and checkout a new branch
function gnew
    if test (count $argv) -eq 0
        echo "Usage: gnew <branch-name> [base-branch]"
        return 1
    end

    set -l branch_name $argv[1]
    set -l base_branch $argv[2]
    if test -z "$base_branch"
        set base_branch main
    end

    git checkout -b $branch_name $base_branch
end

## gsync: sync current branch with main
function gsync
    set -l current_branch (git branch --show-current)
    set -l base_branch $argv[1]
    if test -z "$base_branch"
        set base_branch main
    end

    echo "Syncing $current_branch with $base_branch..."
    git fetch origin $base_branch
    git rebase origin/$base_branch
end

## gclean: clean up merged branches
function gclean
    echo "Cleaning up merged branches..."
    git branch --merged | grep -v "\*" | grep -v "main" | grep -v "master" | xargs -n 1 git branch -d 2>/dev/null; or echo "No branches to clean"
end

## gundo: undo last commit (keep changes)
alias gundo="git reset --soft HEAD~1"

## gwip: quick work-in-progress commit
function gwip
    git add .
    git commit -m "WIP: "(date '+%Y-%m-%d %H:%M:%S')
end

## gunwip: undo last WIP commit
function gunwip
    if git log -1 --pretty=%B | grep -q "^WIP:"
        git reset --soft HEAD~1
        echo "WIP commit undone"
    else
        echo "Last commit is not a WIP commit"
        return 1
    end
end

## ============================================================================
## Git Worktree Helpers (for Agent Workflows)
## ============================================================================

alias gwt="git worktree"
alias gwtl="git worktree list"
alias gwta="git worktree add"
alias gwtr="git worktree remove"
