#!/usr/bin/env bash

# Dotfiles Tutorial
# Interactive walkthrough of all the cool features in these dotfiles
#
# Usage: ./tutorial.sh

set -e

# ============================================================================
# Configuration
# ============================================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m' # No Color

# Emoji
SPARKLES='✨'
ROCKET='🚀'
ROBOT='🤖'
COMPASS='🧭'
TOOLS='🛠️'
GIT='🌿'
CHECK='✓'
ARROW='▶'

# Tutorial state
DEMO_DIR="${HOME}/.dotfiles-tutorial-demo"

# ============================================================================
# Utility Functions
# ============================================================================

print_header() {
    clear
    echo ""
    echo -e "${BOLD}${MAGENTA}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${MAGENTA}║                                                                ║${NC}"
    echo -e "${BOLD}${MAGENTA}║${NC}        ${CYAN}${BOLD}Dotfiles Tutorial ${SPARKLES}${NC}  ${MAGENTA}${BOLD}║${NC}"
    echo -e "${BOLD}${MAGENTA}║${NC}        ${DIM}Master your command line like a pro${NC}              ${MAGENTA}${BOLD}║${NC}"
    echo -e "${BOLD}${MAGENTA}║                                                                ║${NC}"
    echo -e "${BOLD}${MAGENTA}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_section() {
    echo ""
    echo -e "${BOLD}${CYAN}════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${CYAN}  $1${NC}"
    echo -e "${BOLD}${CYAN}════════════════════════════════════════════════════════${NC}"
    echo ""
}

print_subsection() {
    echo ""
    echo -e "${BOLD}${BLUE}$ARROW $1${NC}"
    echo ""
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[$CHECK]${NC} $1"
}

print_demo() {
    echo -e "${YELLOW}[DEMO]${NC} ${BOLD}$1${NC}"
}

print_command() {
    echo -e "${DIM}$ ${NC}${CYAN}$1${NC}"
}

wait_for_user() {
    echo ""
    echo -e "${DIM}Press Enter to continue...${NC}"
    read
}

run_demo_command() {
    local cmd="$1"
    local description="$2"

    if [ -n "$description" ]; then
        echo -e "${YELLOW}$description${NC}"
    fi

    print_command "$cmd"

    # Give user time to read
    sleep 1

    # Execute the command
    eval "$cmd"

    echo ""
}

# ============================================================================
# Tutorial Sections
# ============================================================================

welcome() {
    print_header

    cat << EOF
${BOLD}Welcome to your dotfiles tutorial!${NC}

This interactive walkthrough will introduce you to all the powerful
features and tools included in these dotfiles.

${BOLD}What you'll learn:${NC}

  ${COMPASS} ${CYAN}Navigation System${NC} - Enhanced directory navigation
  ${TOOLS} ${CYAN}Aliases & Utilities${NC} - 50+ productivity shortcuts
  ${GIT} ${CYAN}Git Enhancements${NC} - Streamlined version control
  🌳 ${CYAN}Git Worktrees${NC} - Easy worktree management with 'wt'
  ${ROBOT} ${CYAN}AI Agent Parallelization${NC} - Multi-agent workflow management

${DIM}This tutorial will create a demo directory at:${NC}
${DIM}  ${DEMO_DIR}${NC}

${BOLD}Ready to get started?${NC}
EOF

    wait_for_user
}

section_navigation() {
    print_header
    print_section "${COMPASS} Navigation System"

    cat << EOF
${BOLD}The navigation system makes moving around your filesystem effortless.${NC}

It includes:
  • Directory aliasing (bookmark your favorite locations)
  • Smart cd with backoff (handles typos gracefully)
  • Location stacks (push/pop directories like a browser)
  • Create-and-cd shortcuts
  • File detection (tried to cd into a file? opens in vim!)

Let's try some commands...
EOF

    wait_for_user

    # Create demo structure
    print_subsection "Setting up demo directories"
    mkdir -p "$DEMO_DIR"/{projects/{web-app,api,mobile},documents,downloads}
    cd "$DEMO_DIR"

    print_success "Created demo directory structure at $DEMO_DIR"
    echo ""

    # mkcd demo
    print_subsection "1. mkcd - Create and cd into a directory"
    cat << EOF
${DIM}mkcd creates a directory (and all parent directories) then cd's into it.${NC}

${BOLD}Try it:${NC}
EOF
    run_demo_command "mkcd projects/new-idea/src" "Creating nested directories"
    run_demo_command "pwd" "Current location:"

    wait_for_user

    # Directory aliasing
    print_subsection "2. Directory Aliasing - Bookmark locations"
    cat << EOF
${BOLD}al${NC}  - ${DIM}Alias (bookmark) current directory${NC}
${BOLD}fal${NC} - ${DIM}Follow alias (jump to bookmarked directory)${NC}
${BOLD}lal${NC} - ${DIM}List all aliases${NC}
${BOLD}xal${NC} - ${DIM}Delete an alias${NC}

Let's bookmark some directories:
EOF

    cd "$DEMO_DIR/projects/web-app"
    run_demo_command "al webapp" "Aliasing web-app directory as 'webapp'"

    cd "$DEMO_DIR/projects/api"
    run_demo_command "al api" "Aliasing api directory as 'api'"

    cd "$DEMO_DIR/documents"
    run_demo_command "al docs" "Aliasing documents directory as 'docs'"

    echo ""
    print_info "Now you can jump to these directories from anywhere!"
    echo ""

    run_demo_command "lal" "Listing all aliases:"

    wait_for_user

    print_subsection "3. Using aliases to navigate"

    cd /tmp
    run_demo_command "pwd" "Currently in:"
    echo ""
    print_info "Let's jump to the webapp directory..."
    run_demo_command "cd $DEMO_DIR && source ~/.bashrc && fal webapp 2>/dev/null || cd $DEMO_DIR/projects/web-app" "Jumping to 'webapp' alias"
    run_demo_command "pwd" "Now we're at:"

    wait_for_user

    # Location stack
    print_subsection "4. Location Stack - Push/Pop directories"
    cat << EOF
${BOLD}pl${NC}  - ${DIM}Push location (save current directory to stack)${NC}
${BOLD}gl${NC}  - ${DIM}Go to last pushed location${NC}
${BOLD}ol${NC}  - ${DIM}Pop location (go to and remove from stack)${NC}

This is like browser back/forward but for directories!
EOF

    echo ""
    print_demo "Imagine you're working on the web app and need to check the API..."
    cd "$DEMO_DIR/projects/web-app"

    run_demo_command "pwd" "Currently in web-app:"
    run_demo_command "echo 'Saving this location...'" ""
    # Can't actually use pl in this script context, so simulate
    echo -e "${DIM}$ ${NC}${CYAN}pl${NC}"
    echo -e "${DIM}(location pushed)${NC}"

    echo ""
    cd "$DEMO_DIR/projects/api"
    run_demo_command "pwd" "Moved to API directory:"

    echo ""
    print_info "Now use 'gl' to jump back to the saved location"
    echo -e "${DIM}$ ${NC}${CYAN}gl${NC}"
    echo -e "${DIM}(would return to: $DEMO_DIR/projects/web-app)${NC}"

    wait_for_user

    # Smart cd
    print_subsection "5. Smart cd with backoff"
    cat << EOF
${BOLD}pcd${NC} - ${DIM}cd with backoff (goes to deepest valid path)${NC}
${BOLD}vcd${NC} - ${DIM}cd or open file in vim${NC}

These handle typos and edge cases gracefully:
  • ${DIM}pcd /path/that/doesnt/exist/yet${NC} → goes to deepest valid directory
  • ${DIM}vcd some/file.txt${NC} → cd to directory and opens file in vim
  • ${DIM}vcd some/directory${NC} → just cd normally

These are aliased to work with regular 'cd' too!
EOF

    wait_for_user

    print_subsection "Navigation System - Summary"
    cat << EOF
${GREEN}${BOLD}Quick Reference:${NC}

${CYAN}Directory Creation:${NC}
  ${BOLD}mkcd${NC} path/to/dir     Create and cd into directory

${CYAN}Aliasing:${NC}
  ${BOLD}al${NC} name [path]       Alias a directory
  ${BOLD}fal${NC} name             Jump to aliased directory
  ${BOLD}lal${NC}                  List all aliases
  ${BOLD}xal${NC} name             Delete an alias

${CYAN}Location Stack:${NC}
  ${BOLD}pl${NC}                   Push current location
  ${BOLD}gl${NC}                   Go to last pushed location
  ${BOLD}ol${NC}                   Pop and go to location

${CYAN}Quick Movement:${NC}
  ${BOLD}up${NC}                   cd ..
  ${BOLD}bk${NC}                   cd - (back)
  ${BOLD}vcd${NC} path             cd or open in vim
EOF

    wait_for_user
}

section_aliases() {
    print_header
    print_section "${TOOLS} Aliases & Utilities"

    cat << EOF
${BOLD}Over 50 productivity aliases and utilities are included.${NC}

Let's explore the most useful ones...
EOF

    wait_for_user

    # System updates
    print_subsection "1. System Updates"
    cat << EOF
${BOLD}updoot${NC} - ${DIM}Update all packages (works on any OS!)${NC}

This intelligently detects your package manager and runs
the appropriate update commands:
  • ${DIM}macOS:${NC} brew update && brew upgrade
  • ${DIM}Ubuntu/Debian:${NC} apt update && apt upgrade
  • ${DIM}Arch:${NC} pacman -Syu
  • ${DIM}Fedora:${NC} dnf upgrade

Just run: ${CYAN}updoot${NC}
EOF

    wait_for_user

    # Sudo helper
    print_subsection "2. Sudo Helper"
    cat << EOF
${BOLD}plz${NC} - ${DIM}Re-run last command as root${NC}

Ever run a command and get "Permission denied"?

Instead of:
  ${DIM}$ apt install something${NC}
  ${DIM}Permission denied${NC}
  ${DIM}$ sudo !!${NC}

Just do:
  ${DIM}$ apt install something${NC}
  ${DIM}Permission denied${NC}
  ${CYAN}$ plz${NC}

Much cleaner!
EOF

    wait_for_user

    # Network utilities
    print_subsection "3. Network Utilities"
    cat << EOF
${BOLD}Network & Internet Commands:${NC}

${CYAN}myip${NC}               Show your public IP address
${CYAN}weather NYC${NC}        Check weather for any location
${CYAN}ports${NC}              List all open ports
${CYAN}freeport 8080${NC}      Kill process on specified port
${CYAN}connected${NC}          Check if internet is working

Let's try some:
EOF

    echo ""

    if command -v curl &>/dev/null; then
        run_demo_command "curl -s icanhazip.com | head -1 || echo '203.0.113.1'" "Your public IP:"
    else
        echo -e "${DIM}(curl not available in demo environment)${NC}"
        echo -e "${GREEN}Your IP: 203.0.113.1${NC}"
    fi

    echo ""
    print_info "Try: ${CYAN}weather${NC} followed by your city or zip code"
    print_info "Example: ${CYAN}weather NYC${NC} or ${CYAN}weather 90210${NC}"

    wait_for_user

    # File management
    print_subsection "4. File Listing & Management"
    cat << EOF
${BOLD}Enhanced ls aliases:${NC}

${CYAN}l${NC}     ls -CF           Classify entries
${CYAN}la${NC}    ls -A            Show hidden files
${CYAN}ll${NC}    ls -alF          Long format with indicators
${CYAN}lsm${NC}   ls -hlAFG        Human-readable, all files

${CYAN}dir${NC}                    List only directories
${CYAN}cls${NC}                    Clear and then ls
EOF

    wait_for_user

    # Disk space
    print_subsection "5. Disk Space Utilities"
    cat << EOF
${BOLD}Disk space commands:${NC}

${CYAN}space${NC}              Show disk space (df -h)
${CYAN}used${NC}               Show space used in current directory
EOF

    echo ""
    run_demo_command "df -h 2>/dev/null | head -5 || echo 'Filesystem usage would be shown here'" "Disk space:"

    wait_for_user

    # Archive utilities
    print_subsection "6. Archive Utilities"
    cat << EOF
${BOLD}Archive commands:${NC}

${CYAN}untar file.tar.gz${NC}     Extract tar archive
                        (no need to remember flags!)

${CYAN}download URL${NC}          Download entire website
                        (uses wget with proper flags)
EOF

    wait_for_user

    # Shell management
    print_subsection "7. Shell Management"
    cat << EOF
${BOLD}Shell utilities:${NC}

${CYAN}restart${NC}            Reload shell config (source ~/.bashrc)
${CYAN}refresh${NC}            Go to home and clear screen
${CYAN}bye${NC}                Clear and exit (for privacy)

${CYAN}incognito start${NC}    Stop saving command history
${CYAN}incognito stop${NC}     Resume saving history
EOF

    wait_for_user

    print_subsection "Aliases & Utilities - Summary"
    cat << EOF
${GREEN}${BOLD}Quick Reference:${NC}

${CYAN}System:${NC}
  ${BOLD}updoot${NC}              Update all packages
  ${BOLD}plz${NC}                 Re-run last command with sudo
  ${BOLD}restart${NC}             Reload shell config

${CYAN}Network:${NC}
  ${BOLD}myip${NC}                Your public IP
  ${BOLD}weather${NC} [location]  Check weather
  ${BOLD}ports${NC}               List open ports
  ${BOLD}freeport${NC} [port]     Kill process on port

${CYAN}Files:${NC}
  ${BOLD}ll${NC}                  Long listing
  ${BOLD}space${NC}               Disk usage
  ${BOLD}used${NC}                Directory size
  ${BOLD}untar${NC}               Extract tar files

${CYAN}Fun:${NC}
  ${BOLD}stonks${NC} AAPL         Check stock prices
  ${BOLD}incognito start${NC}     Disable command history
EOF

    wait_for_user
}

section_git() {
    print_header
    print_section "${GIT} Git Enhancements"

    cat << EOF
${BOLD}Streamlined Git workflow with powerful aliases.${NC}

These aliases make common Git operations faster and safer.
EOF

    wait_for_user

    print_subsection "Common Git Aliases"
    cat << EOF
${CYAN}Basic Operations:${NC}
  ${BOLD}gs${NC}                   git status
  ${BOLD}ga${NC}                   git add
  ${BOLD}gc${NC}                   git commit
  ${BOLD}gp${NC}                   git push
  ${BOLD}gpl${NC}                  git pull

${CYAN}Branch Operations:${NC}
  ${BOLD}gco${NC}                  git checkout
  ${BOLD}gcb${NC}                  git checkout -b (new branch)
  ${BOLD}gb${NC}                   git branch
  ${BOLD}gbd${NC}                  git branch -d (delete)

${CYAN}Viewing Changes:${NC}
  ${BOLD}gd${NC}                   git diff
  ${BOLD}gds${NC}                  git diff --staged
  ${BOLD}gl${NC}                   git log --oneline --graph
  ${BOLD}glog${NC}                 git log with nice formatting

${CYAN}Push Variations:${NC}
  ${BOLD}gpom${NC}                 git push origin main
  ${BOLD}push-please${NC}          git push --force-with-lease (safe force push)

${CYAN}Quick WIP Commits:${NC}
  ${BOLD}gwip${NC}                 Create quick WIP commit
  ${BOLD}gunwip${NC}               Undo last WIP commit

${CYAN}Stash Operations:${NC}
  ${BOLD}gst${NC}                  git stash
  ${BOLD}gstp${NC}                 git stash pop
  ${BOLD}gstl${NC}                 git stash list
EOF

    wait_for_user

    print_subsection "Example Git Workflow"
    cat << EOF
${BOLD}Typical workflow using aliases:${NC}

  ${DIM}# Check status${NC}
  ${CYAN}$ gs${NC}

  ${DIM}# Create and switch to new branch${NC}
  ${CYAN}$ gcb feature/new-thing${NC}

  ${DIM}# Make changes, then add and commit${NC}
  ${CYAN}$ ga .${NC}
  ${CYAN}$ gc -m "Add new feature"${NC}

  ${DIM}# Push to origin${NC}
  ${CYAN}$ gp${NC}

  ${DIM}# View git log${NC}
  ${CYAN}$ gl${NC}

${BOLD}Compare to vanilla Git:${NC}

  ${DIM}$ git status${NC}
  ${DIM}$ git checkout -b feature/new-thing${NC}
  ${DIM}$ git add .${NC}
  ${DIM}$ git commit -m "Add new feature"${NC}
  ${DIM}$ git push${NC}
  ${DIM}$ git log --oneline --graph${NC}

${GREEN}Much faster with aliases!${NC}
EOF

    wait_for_user
}

section_worktrees() {
    print_header
    print_section "🌳 Git Worktrees Made Easy"

    cat << EOF
${BOLD}The 'wt' command makes git worktrees incredibly easy to use.${NC}

Git worktrees let you check out multiple branches at once, each in
its own directory. No more stashing or switching branches!

${BOLD}Why use worktrees?${NC}
  • Work on multiple features simultaneously
  • Quick bug fixes without disrupting current work
  • Compare different branches side-by-side
  • Parallel testing of different approaches

EOF

    wait_for_user

    print_subsection "Core wt Commands"
    cat << EOF
${BOLD}Basic Operations:${NC}

${CYAN}wt add <name>${NC}              Create a new worktree
${CYAN}wt list${NC}                    List all worktrees
${CYAN}wt switch <name>${NC}           Switch to a worktree
${CYAN}wt remove <name>${NC}           Remove a worktree
${CYAN}wt info [name]${NC}             Show worktree info

${BOLD}Quick Example:${NC}

  ${DIM}# Create worktree for a feature${NC}
  ${GREEN}wt add feature-auth${NC}

  ${DIM}# Switch to it${NC}
  ${GREEN}wt switch feature-auth${NC}

  ${DIM}# Work on your feature...${NC}

  ${DIM}# Switch back to main work${NC}
  ${GREEN}cd \$(wt path main-work)${NC}

  ${DIM}# Remove when done${NC}
  ${GREEN}wt remove feature-auth${NC}

${BOLD}Advanced Features:${NC}

  ${CYAN}wt add feat --from=develop${NC}      Branch from develop
  ${CYAN}wt each git status${NC}              Run command in all worktrees
  ${CYAN}wt path feature-auth${NC}            Get path for scripts
  ${CYAN}wt branch${NC}                       Show current branch

EOF

    wait_for_user

    print_subsection "Fuzzy Matching"
    cat << EOF
${BOLD}wt supports fuzzy matching - no need to type full names!${NC}

  ${GREEN}wt switch feat${NC}     # Matches 'feature-auth'
  ${GREEN}wt remove fix${NC}      # Matches 'fix-bug-123'
  ${GREEN}wt info api${NC}        # Matches 'api-refactor'

${BOLD}Tab Completion:${NC}
  wt [tab]           # Shows all commands
  wt switch [tab]    # Shows all worktree names
  wt add new [tab]   # Shows all branches

EOF

    wait_for_user
}

section_agents() {
    print_header
    print_section "${ROBOT} AI Agent Parallelization"

    cat << EOF
${BOLD}The crown jewel: Multi-agent workflow management.${NC}

This system lets you run multiple AI agent sessions in parallel,
each with their own git worktree and isolated environment.

${BOLD}The 'agent' command builds on 'wt' with:${NC}
  • Session management and context tracking
  • Shared context between sessions
  • Templates for different workflow types
  • Lock files to prevent conflicts
  • Integration with your shell prompt

${BOLD}Perfect for:${NC}
  • Working on multiple features simultaneously
  • Separating exploration from production work
  • Sharing context between related tasks
  • Keeping your main workspace clean

EOF

    wait_for_user

    print_subsection "Core Concepts"
    cat << EOF
${BOLD}Git Worktrees:${NC}
Instead of juggling branches in one directory, each agent session
gets its own directory (worktree) linked to the same repository.

${BOLD}Sessions:${NC}
A session represents one AI agent working on one task. Each session
includes:
  • Its own git worktree (separate directory)
  • A context directory for sharing information
  • Lock files to prevent conflicts
  • Template-based setup (feature/bugfix/refactor/exploration)
EOF

    wait_for_user

    print_subsection "Agent Commands"
    cat << EOF
${CYAN}Creating and Managing Sessions:${NC}

  ${BOLD}agent new${NC} [name] [--template=TYPE] [--branch=NAME]
      Create a new agent session
      Templates: feature, bugfix, refactor, exploration

  ${BOLD}agent list${NC}
      List all active sessions

  ${BOLD}agent switch${NC} [name]
      Switch to a session's worktree

  ${BOLD}agent close${NC} [name] [--archive] [--delete-branch]
      Close a session and clean up

${CYAN}Context Sharing:${NC}

  ${BOLD}agent context${NC} [name] [--edit]
      View or edit session context

  ${BOLD}agent share-context${NC} [from] [to] --file=FILE
      Share context files between sessions

${CYAN}Maintenance:${NC}

  ${BOLD}worktree-clean${NC}
      Clean up stale worktrees

  ${BOLD}context-sync${NC} [--watch] [--status]
      Sync context between sessions
EOF

    wait_for_user

    print_subsection "Example Workflow"
    cat << EOF
${BOLD}Scenario: Working on authentication while fixing a bug${NC}

${DIM}# Create a feature session for authentication${NC}
${CYAN}$ agent new auth-feature --template=feature --branch=feature/oauth${NC}

${DIM}# Create a bugfix session for login issue${NC}
${CYAN}$ agent new login-bugfix --template=bugfix --branch=bugfix/login-error${NC}

${DIM}# List active sessions${NC}
${CYAN}$ agent list${NC}
${GREEN}Active sessions:
  • auth-feature (feature/oauth)
  • login-bugfix (bugfix/login-error)${NC}

${DIM}# Share API spec between sessions${NC}
${CYAN}$ agent share-context auth-feature login-bugfix --file=api-spec.md${NC}

${DIM}# Work in parallel with two AI agents${NC}
${DIM}(Open two terminals, switch each to a different session)${NC}

${DIM}# When done, close sessions${NC}
${CYAN}$ agent close auth-feature --archive${NC}
${CYAN}$ agent close login-bugfix --archive --delete-branch${NC}

${GREEN}${BOLD}Result:${NC} Two features developed in parallel without conflicts!
EOF

    wait_for_user

    print_subsection "Templates Explained"
    cat << EOF
${BOLD}feature:${NC}      New feature development
              → Creates feature/ branch
              → Full context template

${BOLD}bugfix:${NC}       Bug fix work
              → Creates bugfix/ branch
              → Focused on issue resolution

${BOLD}refactor:${NC}     Code refactoring
              → Creates refactor/ branch
              → Maintains functionality

${BOLD}exploration:${NC}  Experimental work
              → Creates experiment/ branch
              → No commitment to merge
EOF

    wait_for_user

    print_subsection "AI Agent System - Summary"
    cat << EOF
${GREEN}${BOLD}Quick Reference:${NC}

${CYAN}Session Management:${NC}
  ${BOLD}agent new${NC} name [opts]         Create session
  ${BOLD}agent list${NC}                    List all sessions
  ${BOLD}agent switch${NC} name             Switch to session
  ${BOLD}agent close${NC} name [opts]       Close session

${CYAN}Context Sharing:${NC}
  ${BOLD}agent context${NC} name [--edit]   View/edit context
  ${BOLD}agent share-context${NC} A B       Share between sessions

${CYAN}Utilities:${NC}
  ${BOLD}worktree-clean${NC}                Clean stale worktrees
  ${BOLD}context-sync${NC} [--watch]        Sync contexts

${YELLOW}${BOLD}Pro Tip:${NC} Use this system when you have an AI coding assistant.
Let multiple agents work on different features simultaneously!

${DIM}See docs/AGENT_WORKFLOWS.md for detailed examples.${NC}
EOF

    wait_for_user
}

section_next_steps() {
    print_header
    print_section "${ROCKET} Next Steps"

    cat << EOF
${GREEN}${BOLD}Congratulations! You've completed the tutorial.${NC}

${BOLD}What to do next:${NC}

${CYAN}1. Try the commands${NC}
   Start using the navigation system, aliases, and git shortcuts
   in your daily workflow. They'll become second nature quickly!

${CYAN}2. Customize your config${NC}
   Edit these files for personal preferences:
     ${YELLOW}~/.bash_profile${NC}         Personal bash config
     ${YELLOW}~/.gitprofile${NC}           Git name/email
     ${YELLOW}~/.tmux.profile${NC}         Tmux settings
     ${YELLOW}~/.config/nvim/personal.lua${NC}  Neovim config

${CYAN}3. Explore the agent system${NC}
   If you use AI coding assistants, try the multi-agent workflow:
     ${GREEN}agent new my-first-feature --template=feature${NC}

${CYAN}4. Read the docs${NC}
     ${YELLOW}README.md${NC}              Getting started
     ${YELLOW}ARCHITECTURE.md${NC}        System design
     ${YELLOW}docs/AGENT_WORKFLOWS.md${NC}  Agent examples
     ${YELLOW}docs/CUSTOMIZATION.md${NC}   Customization guide

${CYAN}5. Update regularly${NC}
     ${GREEN}dotfiles-update${NC}  or  ${GREEN}cd ~/dotfiles && git pull${NC}

${BOLD}Quick command reference:${NC}

  ${DIM}Navigation:${NC}    al, fal, lal, mkcd, pl/gl/ol
  ${DIM}Utilities:${NC}     updoot, plz, myip, weather, ports
  ${DIM}Git:${NC}           gs, ga, gc, gp, gco, gwip
  ${DIM}Worktrees:${NC}     wt add/list/switch/remove
  ${DIM}Agent:${NC}         agent new/list/switch/close

${BOLD}Getting help:${NC}

  ${CYAN}agent help${NC}              Agent system help
  ${CYAN}man bash${NC}                Bash manual
  ${CYAN}git help${NC}                Git documentation

${MAGENTA}${BOLD}Happy coding! ${ROCKET}${NC}

${DIM}(This tutorial created a demo directory at ${DEMO_DIR})${NC}
${DIM}(Feel free to explore or delete it: rm -rf ${DEMO_DIR})${NC}
EOF

    echo ""
}

cleanup() {
    # Optionally clean up demo directory
    if [ -d "$DEMO_DIR" ]; then
        echo ""
        echo -e "${BLUE}[?]${NC} Remove tutorial demo directory? [y/N] "
        read yn
        case $yn in
            [Yy]* )
                rm -rf "$DEMO_DIR"
                print_success "Demo directory removed"
                ;;
            * )
                print_info "Demo directory kept at: $DEMO_DIR"
                ;;
        esac
    fi
}

# ============================================================================
# Main
# ============================================================================

main() {
    # Check if running in a shell with dotfiles loaded
    if ! type -t mkcd &>/dev/null && ! type -t al &>/dev/null; then
        echo ""
        echo -e "${YELLOW}[!]${NC} Dotfiles don't seem to be loaded in this shell."
        echo -e "${BLUE}[INFO]${NC} Some features will be demonstrated conceptually."
        echo -e "${BLUE}[INFO]${NC} To use them for real, restart your terminal or run:"
        echo -e "    ${CYAN}source ~/.bashrc${NC}"
        echo ""
        echo -e "${DIM}Press Enter to continue anyway...${NC}"
        read
    fi

    # Run tutorial sections
    welcome
    section_navigation
    section_aliases
    section_git
    section_worktrees
    section_agents
    section_next_steps
    cleanup

    echo ""
    print_success "Tutorial complete!"
    echo ""
}

main "$@"
