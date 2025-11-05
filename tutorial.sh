#!/usr/bin/env bash

# Dotfiles Tutorial - Comprehensive Edition
# Interactive walkthrough of your complete development environment
#
# Usage: ./tutorial.sh [--skip-intro]

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
TREE='🌳'
TERMINAL='💻'
EDITOR='📝'
WINDOW='🪟'
CHECK='✓'
ARROW='▶'
TMUX='🔲'
WORKFLOW='⚡'

# Tutorial state
DEMO_DIR="${HOME}/.dotfiles-tutorial-demo"
SKIP_INTRO=false

# Parse args
for arg in "$@"; do
    case $arg in
        --skip-intro) SKIP_INTRO=true ;;
    esac
done

# ============================================================================
# Utility Functions
# ============================================================================

print_header() {
    clear
    echo ""
    echo -e "${BOLD}${MAGENTA}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${MAGENTA}║                                                                ║${NC}"
    echo -e "${BOLD}${MAGENTA}║${NC}     ${CYAN}${BOLD}Complete Dotfiles Tour ${SPARKLES}${ROCKET}${NC}  ${MAGENTA}${BOLD}║${NC}"
    echo -e "${BOLD}${MAGENTA}║${NC}     ${DIM}Your entire development environment explained${NC}       ${MAGENTA}${BOLD}║${NC}"
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

print_tip() {
    echo -e "${YELLOW}💡 TIP:${NC} ${DIM}$1${NC}"
}

# Print formatted text from heredoc with ANSI codes interpreted
print_formatted() {
    while IFS= read -r line || [ -n "$line" ]; do
        echo -e "$line"
    done
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
    sleep 1
    eval "$cmd" || true
    echo ""
}

# ============================================================================
# Tutorial Sections
# ============================================================================

welcome() {
    print_header

    print_formatted << EOF
${BOLD}Welcome to your complete development environment!${NC}

This comprehensive tour will walk you through every aspect of
your dotfiles, from shell navigation to full development workflows.

${BOLD}What you'll master:${NC}

  ${TERMINAL} ${CYAN}Shell Power${NC} - Bash/Fish with Starship, powerful aliases
  ${COMPASS} ${CYAN}Navigation System${NC} - Directory aliasing, smart cd, location stacks
  ${GIT} ${CYAN}Git Mastery${NC} - 30+ shortcuts, workflow helpers
  ${TREE} ${CYAN}Git Worktrees${NC} - Parallel development with 'wt'
  ${TMUX} ${CYAN}Tmux Multiplexing${NC} - Terminal sessions, panes, windows
  ${EDITOR} ${CYAN}Editor Setup${NC} - Vim/Neovim with LSP, plugins
  ${WINDOW} ${CYAN}Window Management${NC} - i3/sway/yabai for tiling WMs
  ${ROBOT} ${CYAN}AI Agent System${NC} - Multi-agent parallel workflows
  ${WORKFLOW} ${CYAN}Complete Dev Workflow${NC} - Start to deployment

${BOLD}Estimated time:${NC} 30-45 minutes
${BOLD}Format:${NC} Interactive with live demos

${DIM}Demo directory: ${DEMO_DIR}${NC}

${BOLD}Ready to become a terminal ninja?${NC}
EOF

    wait_for_user
}

# ============================================================================
# SECTION 1: Shell Fundamentals
# ============================================================================

section_shell() {
    print_header
    print_section "${TERMINAL} Shell Power"

    echo -e "${BOLD}Your shell is the foundation of everything.${NC}"
    echo ""
    echo "These dotfiles support:"
    echo -e "  • ${GREEN}Bash${NC} - Universal, with modular configuration"
    echo -e "  • ${GREEN}Fish${NC} - User-friendly with autosuggestions"
    echo -e "  • ${GREEN}Starship${NC} - Beautiful, fast cross-shell prompt"
    echo ""
    echo "All share the same aliases and functions!"

    wait_for_user

    print_subsection "Starship Prompt"
    echo -e "${BOLD}Starship provides a beautiful, informative prompt:${NC}"
    echo ""
    echo "Shows you:"
    echo "  • Current directory (with path trimming)"
    echo "  • Git branch and status (✓ clean, ⁅⁆ dirty)"
    echo "  • Programming language versions (Node, Python, Rust, etc.)"
    echo "  • Command duration for slow commands"
    echo "  • Agent session (if active)"
    echo ""
    echo -e "${CYAN}Try it:${NC}"
    echo "  cd into a git repo to see branch info"
    echo "  Run a slow command (sleep 3) to see duration"
    echo "  Activate an agent session to see session name"
    echo ""

    wait_for_user

    print_subsection "Shell Configuration Structure"
    print_formatted << EOF
${BOLD}Modular bash configuration in ~/.bashrc.d/:${NC}

  ${CYAN}00-init.bashrc${NC}          Core initialization
  ${CYAN}10-navigation.bashrc${NC}    Navigation helpers (al, fal, mkcd)
  ${CYAN}20-aliases.bashrc${NC}       System aliases (updoot, plz, myip)
  ${CYAN}30-git.bashrc${NC}           Git shortcuts (gwip, gco, gsync)
  ${CYAN}40-agents.bashrc${NC}        Agent integration (anew, asw)
  ${CYAN}45-wt-completion.bashrc${NC} Worktree tab completion
  ${CYAN}50-prompt.bashrc${NC}        Prompt configuration
  ${CYAN}60-history.bashrc${NC}       History settings
  ${CYAN}70-aesthetics.bashrc${NC}    Colors and styling
  ${CYAN}80-languages.bashrc${NC}     Programming language setups
  ${CYAN}99-local.bashrc${NC}         Personal overrides

${BOLD}Why modular?${NC}
  ✓ Easy to enable/disable features
  ✓ Clean organization
  ✓ Simple to add custom modules
  ✓ Source control friendly
EOF

    wait_for_user

    print_subsection "Key Shell Features"
    print_formatted << EOF
${CYAN}History Management:${NC}
  • Infinite history (HISTSIZE=HISTFILESIZE)
  • Deduplication (ignoreboth)
  • Cross-session sharing
  • Timestamp tracking

  ${DIM}Try: history | tail${NC}
  ${DIM}Try: Ctrl+R (reverse search)${NC}

${CYAN}Smart Completion:${NC}
  • Git commands and branches
  • Agent session names
  • Worktree names
  • File paths with Tab

  ${DIM}Try: git checkout [Tab]${NC}
  ${DIM}Try: wt switch [Tab]${NC}

${CYAN}Environment Detection:${NC}
  • OS type (Linux/macOS/Windows)
  • Package manager (apt/pacman/brew)
  • Git repo and worktree
  • Agent session

${GREEN}Everything just works across different environments!${NC}
EOF

    wait_for_user
}

# ============================================================================
# SECTION 2: Navigation System
# ============================================================================

section_navigation() {
    print_header
    print_section "${COMPASS} Navigation System"

    print_formatted << EOF
${BOLD}Move around your filesystem like a pro.${NC}

Features:
  • Directory aliasing (bookmark locations)
  • Smart cd with backoff (handles typos)
  • Location stacks (push/pop like a browser)
  • Create-and-cd shortcuts
  • File detection (cd file.txt → vim file.txt)
EOF

    wait_for_user

    mkdir -p "$DEMO_DIR"/{projects/{web,api,mobile},docs,scripts}
    cd "$DEMO_DIR"

    print_subsection "1. Directory Aliasing"
    print_formatted << EOF
${BOLD}Bookmark frequently used directories:${NC}

${CYAN}al <name> [path]${NC}     Alias current (or specified) directory
${CYAN}fal <name>${NC}           Jump to aliased directory
${CYAN}lal${NC}                  List all aliases
${CYAN}xal <name>${NC}           Delete an alias

${YELLOW}Demo:${NC}
EOF

    cd "$DEMO_DIR/projects/web"
    echo -e "${DIM}$ al webapp${NC}"
    echo -e "${GREEN}Aliased: webapp → $(pwd)${NC}"

    cd "$DEMO_DIR/docs"
    echo -e "${DIM}$ al docs${NC}"
    echo -e "${GREEN}Aliased: docs → $(pwd)${NC}"

    echo ""
    echo -e "${DIM}$ lal${NC}"
    echo -e "${CYAN}webapp${NC} → $DEMO_DIR/projects/web"
    echo -e "${CYAN}docs${NC} → $DEMO_DIR/docs"

    wait_for_user

    print_subsection "2. Location Stack"
    print_formatted << EOF
${BOLD}Push and pop directories like browser history:${NC}

${CYAN}pl${NC}    Push current location
${CYAN}gl${NC}    Go to last pushed location (keep on stack)
${CYAN}ol${NC}    Pop location (go to and remove from stack)

${BOLD}Example workflow:${NC}
  You're working in ${DIM}~/projects/api${NC}
  ${DIM}$ pl${NC}                    # Save location
  ${DIM}$ cd ~/docs${NC}             # Go somewhere else
  ${DIM}$ gl${NC}                    # Jump back to ~/projects/api
  ${DIM}$ cd ~/scripts${NC}          # Go elsewhere again
  ${DIM}$ ol${NC}                    # Pop and go back

Perfect for jumping between related directories!
EOF

    wait_for_user

    print_subsection "3. Smart Navigation"
    print_formatted << EOF
${CYAN}mkcd <path>${NC}        Create directory and cd into it
${CYAN}pcd <path>${NC}         cd with backoff (goes to deepest valid path)
${CYAN}vcd <path>${NC}         cd to directory OR open file in vim
${CYAN}up${NC}                 cd ..
${CYAN}bk${NC}                 cd - (back to previous)

${YELLOW}Examples:${NC}
  ${DIM}$ mkcd new/deep/path${NC}           # Creates all parents
  ${DIM}$ pcd /typo/in/path/file.txt${NC}  # Goes to deepest valid dir
  ${DIM}$ vcd ~/code/script.sh${NC}         # Opens file in vim
  ${DIM}$ vcd ~/code${NC}                    # Normal cd to directory
EOF

    wait_for_user
}

# ============================================================================
# SECTION 3: Git Mastery
# ============================================================================

section_git() {
    print_header
    print_section "${GIT} Git Mastery"

    print_formatted << EOF
${BOLD}30+ Git shortcuts and workflow helpers.${NC}

From basic operations to advanced workflows, everything
is faster and more intuitive.
EOF

    wait_for_user

    print_subsection "Basic Git Shortcuts"
    print_formatted << EOF
${CYAN}Basic Operations:${NC}
  status, add, commit, push, stash  ${DIM}(full word aliases)${NC}
  gpom                              ${DIM}git push origin main${NC}

${CYAN}Smart Functions:${NC}
  ${BOLD}gco <branch|file>${NC}      Smart checkout (branch or file)
  ${BOLD}gnew <name> [base]${NC}     Create and checkout new branch
  ${BOLD}gsync [base]${NC}           Sync current branch with main/base
  ${BOLD}gclean${NC}                 Delete merged branches

${CYAN}Quick WIP Commits:${NC}
  ${BOLD}gwip${NC}                   Quick WIP commit with timestamp
  ${BOLD}gunwip${NC}                 Undo last WIP commit

${CYAN}Safety First:${NC}
  ${BOLD}push-please${NC}            git push --force-with-lease
  ${BOLD}gundo${NC}                  Undo last commit (keep changes)

${YELLOW}Example workflow:${NC}
  ${DIM}$ gnew feature-auth${NC}              # Create branch
  ${DIM}$ # ... make changes ...${NC}
  ${DIM}$ gwip${NC}                            # Quick save
  ${DIM}$ # ... more work ...${NC}
  ${DIM}$ gunwip${NC}                          # Unwrap WIP
  ${DIM}$ commit -m "Add auth"${NC}           # Proper commit
  ${DIM}$ gsync${NC}                           # Sync with main
  ${DIM}$ gpom${NC}                            # Push!
EOF

    wait_for_user

    print_subsection "Git Workflow Patterns"
    print_formatted << EOF
${BOLD}Feature Branch Workflow:${NC}

  1. ${CYAN}gnew feature-oauth develop${NC}   # Branch from develop
  2. ${CYAN}# ... code ...${NC}
  3. ${CYAN}add .${NC}
  4. ${CYAN}commit -m "Add OAuth"${NC}
  5. ${CYAN}gsync develop${NC}                # Stay in sync
  6. ${CYAN}push${NC}
  7. ${CYAN}# ... create PR ...${NC}
  8. ${CYAN}gclean${NC}                       # Clean up after merge

${BOLD}Quick Hotfix Workflow:${NC}

  1. ${CYAN}pl${NC}                           # Save current location
  2. ${CYAN}wt add hotfix${NC}                # New worktree
  3. ${CYAN}# ... fix bug ...${NC}
  4. ${CYAN}commit -m "Fix bug"${NC}
  5. ${CYAN}push${NC}
  6. ${CYAN}ol${NC}                           # Back to original work
  7. ${CYAN}wt remove hotfix${NC}             # Clean up

${BOLD}Experimentation:${NC}

  1. ${CYAN}gwip${NC}                         # Save current work
  2. ${CYAN}# ... try experimental approach ...${NC}
  3. ${CYAN}git reset --hard HEAD~1${NC}     # Discard if bad
  4. ${DIM}OR${NC}
  5. ${CYAN}gunwip && commit -m "Good experiment"${NC}
EOF

    wait_for_user
}

# ============================================================================
# SECTION 4: Git Worktrees
# ============================================================================

section_worktrees() {
    print_header
    print_section "${TREE} Git Worktrees Made Easy"

    print_formatted << EOF
${BOLD}Work on multiple branches simultaneously.${NC}

Worktrees let you check out multiple branches at once, each in
its own directory. No more stashing or branch switching!

${BOLD}Without worktrees:${NC}
  ${RED}✗${NC} Stash current work
  ${RED}✗${NC} Switch branch
  ${RED}✗${NC} Make changes
  ${RED}✗${NC} Switch back
  ${RED}✗${NC} Pop stash
  ${RED}✗${NC} Hope nothing conflicts

${BOLD}With worktrees:${NC}
  ${GREEN}✓${NC} Keep all work active
  ${GREEN}✓${NC} Switch instantly (just cd)
  ${GREEN}✓${NC} Compare side-by-side
  ${GREEN}✓${NC} No conflicts, no stashing
EOF

    wait_for_user

    print_subsection "wt Command Overview"
    print_formatted << EOF
${CYAN}Creation & Removal:${NC}
  ${BOLD}wt add <name> [branch]${NC}         Create worktree
  ${BOLD}wt remove <name>${NC}               Remove worktree

${CYAN}Navigation:${NC}
  ${BOLD}wt list${NC}                        List all worktrees
  ${BOLD}wt switch <name>${NC}               Switch to worktree
  ${BOLD}wt goto <name>${NC}                 Open in new shell

${CYAN}Information:${NC}
  ${BOLD}wt path [name]${NC}                 Show path
  ${BOLD}wt branch [name]${NC}               Show branch
  ${BOLD}wt info [name]${NC}                 Show detailed info

${CYAN}Advanced:${NC}
  ${BOLD}wt add feat --from=develop${NC}     Branch from specific base
  ${BOLD}wt each git status${NC}             Run command in all worktrees
  ${BOLD}wt clean${NC}                       Remove stale worktrees
EOF

    wait_for_user

    print_subsection "Real-World Scenarios"
    print_formatted << EOF
${BOLD}Scenario 1: Feature + Urgent Fix${NC}

  ${DIM}# Working on feature${NC}
  ${CYAN}wt add feature-oauth${NC}
  ${CYAN}cd \$(wt path feature-oauth)${NC}
  ${DIM}# ... coding ...${NC}

  ${DIM}# Urgent bug! Don't stash${NC}
  ${CYAN}wt add hotfix-login${NC}
  ${CYAN}wt switch hotfix-login${NC}
  ${DIM}# ... fix bug, commit, push ...${NC}

  ${DIM}# Back to feature - work still there!${NC}
  ${CYAN}wt switch feature-oauth${NC}
  ${DIM}# ... continue coding ...${NC}

${BOLD}Scenario 2: Compare Approaches${NC}

  ${DIM}# Try two different implementations${NC}
  ${CYAN}wt add approach-rest${NC}
  ${CYAN}wt add approach-graphql${NC}

  ${DIM}# Work on both${NC}
  ${DIM}# Compare results side-by-side${NC}
  ${DIM}# Keep the better one${NC}

${BOLD}Scenario 3: Review Someone's PR${NC}

  ${DIM}# Don't disrupt your work${NC}
  ${CYAN}wt add review-pr-123${NC}
  ${CYAN}wt switch review-pr-123${NC}
  ${CYAN}git fetch origin pull/123/head:pr-123${NC}
  ${CYAN}git checkout pr-123${NC}
  ${DIM}# ... review, test ...${NC}
  ${CYAN}wt remove review-pr-123${NC}
EOF

    wait_for_user

    print_subsection "wt Power Features"
    print_formatted << EOF
${BOLD}Fuzzy Matching:${NC}
  ${DIM}$ wt switch feat${NC}     ${GREEN}→ Matches 'feature-oauth'${NC}
  ${DIM}$ wt remove hot${NC}      ${GREEN}→ Matches 'hotfix-login'${NC}

${BOLD}Run Commands Everywhere:${NC}
  ${CYAN}wt each git status${NC}          ${DIM}# Status of all worktrees${NC}
  ${CYAN}wt each git fetch${NC}           ${DIM}# Update all${NC}
  ${CYAN}wt each npm test${NC}            ${DIM}# Test all branches${NC}

${BOLD}Agent Integration:${NC}
  ${DIM}$ wt list${NC}
  ${GREEN}* feature-oauth${NC}
    ${DIM}Branch: feature/oauth${NC}
    ${MAGENTA}Agent: oauth-session${NC}   ${DIM}← Automatically detected!${NC}

${BOLD}Tab Completion:${NC}
  ${DIM}$ wt switch [Tab]${NC}   ${GREEN}→ Shows all worktree names${NC}
  ${DIM}$ wt add new [Tab]${NC}  ${GREEN}→ Shows all branches${NC}
EOF

    print_tip "Use 'wt' for quick tasks, 'agent' for full AI sessions with context tracking"

    wait_for_user
}

# ============================================================================
# SECTION 5: Tmux Multiplexing
# ============================================================================

section_tmux() {
    print_header
    print_section "${TMUX} Tmux - Terminal Multiplexer"

    print_formatted << EOF
${BOLD}One terminal, infinite possibilities.${NC}

Tmux lets you:
  • Run multiple programs in one terminal
  • Split your terminal into panes
  • Create multiple windows (tabs)
  • Detach and reattach sessions
  • Survive SSH disconnections

${BOLD}Think of it as:${NC}
  Sessions = Projects
  Windows = Tabs
  Panes = Split views
EOF

    wait_for_user

    print_subsection "Tmux Prefix Key"
    print_formatted << EOF
${BOLD}Your tmux prefix: ${CYAN}Ctrl+a${NC}

Everything starts with ${CYAN}Ctrl+a${NC}, then a command key.

${BOLD}Why Ctrl+a instead of Ctrl+b?${NC}
  ✓ Easier to reach
  ✓ Consistent with screen
  ✓ Less pinky strain

${YELLOW}How to use:${NC}
  1. Press and release ${CYAN}Ctrl+a${NC}
  2. Press command key

  Example: ${CYAN}Ctrl+a${NC} then ${CYAN}|${NC}  ${DIM}(vertical split)${NC}
EOF

    wait_for_user

    print_subsection "Essential Tmux Commands"
    print_formatted << EOF
${CYAN}Session Management:${NC}
  ${BOLD}tmux${NC}                     Start new session
  ${BOLD}tmux new -s work${NC}         Named session
  ${BOLD}tmux ls${NC}                  List sessions
  ${BOLD}tmux attach -t work${NC}      Attach to session
  ${BOLD}Ctrl+a d${NC}                 Detach session
  ${BOLD}Ctrl+a :${NC}                 Command prompt

${CYAN}Windows (Tabs):${NC}
  ${BOLD}Ctrl+a c${NC}                 Create window
  ${BOLD}Ctrl+a n${NC}                 Next window
  ${BOLD}Ctrl+a p${NC}                 Previous window
  ${BOLD}Ctrl+a 0-9${NC}               Jump to window number
  ${BOLD}Ctrl+a ,${NC}                 Rename window

${CYAN}Panes (Splits):${NC}
  ${BOLD}Ctrl+a |${NC}                 Vertical split
  ${BOLD}Ctrl+a "${NC}                 Horizontal split
  ${BOLD}Ctrl+a arrows${NC}            Navigate panes
  ${BOLD}Ctrl+a x${NC}                 Close pane
  ${BOLD}Ctrl+Shift+arrows${NC}        Resize panes

${CYAN}Copy Mode (Vim bindings):${NC}
  ${BOLD}Ctrl+a [${NC}                 Enter copy mode
  ${BOLD}Space${NC}                    Start selection
  ${BOLD}Enter${NC}                    Copy selection
  ${BOLD}Ctrl+a ]${NC}                 Paste
EOF

    wait_for_user

    print_subsection "Tmux Workflow Patterns"
    print_formatted << EOF
${BOLD}Pattern 1: Project Session${NC}

  ${CYAN}tmux new -s myproject${NC}

  Window 0: Editor (vim/nvim)
  Window 1: Server (npm run dev)
  Window 2: Shell (git commands)
  Window 3: Logs (tail -f)

${BOLD}Pattern 2: Split Panes for Full-Stack${NC}

  ${CYAN}Ctrl+a |${NC}    Split vertically

  Left pane:  Frontend (npm run dev)
  Right pane: Backend (python manage.py runserver)

  ${CYAN}Ctrl+a "${NC}    Split right pane horizontally

  Top right:    Backend server
  Bottom right: Database shell

${BOLD}Pattern 3: Remote Development${NC}

  ${DIM}# On local machine${NC}
  ${CYAN}ssh server${NC}
  ${CYAN}tmux new -s dev${NC}
  ${DIM}# ... work work work ...${NC}
  ${CYAN}Ctrl+a d${NC}    ${DIM}# Detach${NC}
  ${CYAN}exit${NC}         ${DIM}# Close SSH${NC}

  ${DIM}# Later, or from different computer${NC}
  ${CYAN}ssh server${NC}
  ${CYAN}tmux attach -s dev${NC}  ${DIM}# Everything still running!${NC}

${BOLD}Pattern 4: Agent Sessions${NC}

  ${DIM}# One tmux window per agent session${NC}
  ${CYAN}tmux new -s agents${NC}
  ${CYAN}Ctrl+a c${NC}    ${DIM}# Window for each agent${NC}
  ${CYAN}wt switch feature-auth${NC}
  ${CYAN}Ctrl+a ,${NC}    ${DIM}# Rename window to "auth"${NC}
  ${CYAN}Ctrl+a c${NC}    ${DIM}# New window${NC}
  ${CYAN}wt switch bugfix-login${NC}
  ${CYAN}Ctrl+a ,${NC}    ${DIM}# Rename to "bugfix"${NC}

EOF

    wait_for_user

    print_subsection "Tmux Pro Tips"
    print_formatted << EOF
${GREEN}1. Mouse Support${NC}
   ${DIM}Your tmux has mouse support enabled!${NC}
   • Click to switch panes
   • Drag borders to resize
   • Scroll to browse history

${GREEN}2. Copy Mode${NC}
   ${DIM}Vim keybindings in copy mode:${NC}
   • ${CYAN}h,j,k,l${NC} to move
   • ${CYAN}/${NC} to search
   • ${CYAN}v${NC} for visual selection
   • Mouse scrolling works too!

${GREEN}3. Persistent Sessions${NC}
   ${DIM}Name your sessions meaningfully:${NC}
   • ${CYAN}tmux new -s work${NC}
   • ${CYAN}tmux new -s personal${NC}
   • ${CYAN}tmux new -s agent-dev${NC}

${GREEN}4. Status Bar${NC}
   ${DIM}Bottom bar shows:${NC}
   • Session name
   • Window list
   • Current window (highlighted)
   • System info (customizable)
EOF

    print_tip "Add 'alias t=tmux' to your ~/.bash_profile for quick access"

    wait_for_user
}

# ============================================================================
# SECTION 6: Editors
# ============================================================================

section_editors() {
    print_header
    print_section "${EDITOR} Editor Setup"

    print_formatted << EOF
${BOLD}Three powerful editors, all configured for you.${NC}

  ${CYAN}Vim${NC}      - Classic, fast, available everywhere
  ${CYAN}Neovim${NC}   - Modern Vim with LSP and better defaults
  ${CYAN}Zed${NC}      - Fast, modern, AI-first (via Homebrew)

All three share similar keybindings and workflows!
EOF

    wait_for_user

    print_subsection "Neovim - The Modern Choice"
    print_formatted << EOF
${BOLD}Your Neovim setup includes:${NC}

${CYAN}Language Support:${NC}
  ✓ Python (Pyright + Ruff)
  ✓ JavaScript/TypeScript (ts_ls + ESLint)
  ✓ Rust (rust-analyzer)
  ✓ Go, OCaml, and more

${CYAN}Features:${NC}
  ✓ LSP (Language Server Protocol) - IntelliSense everywhere
  ✓ Autocompletion with snippets
  ✓ Syntax highlighting (Treesitter)
  ✓ File explorer (NvimTree)
  ✓ Fuzzy finder (Telescope)
  ✓ Git integration (Gitsigns, Fugitive)
  ✓ AI completions (TabNine)
  ✓ Auto-formatting on save
  ✓ Linting
  ✓ Beautiful Dracula theme

${CYAN}Key Bindings (Space = Leader):${NC}
  ${BOLD}Space e${NC}      Toggle file explorer
  ${BOLD}Space ff${NC}     Find files
  ${BOLD}Space fg${NC}     Live grep (search in files)
  ${BOLD}Space fb${NC}     Find buffers
  ${BOLD}Space fd${NC}     Find diagnostics (errors/warnings)

  ${BOLD}gd${NC}           Go to definition
  ${BOLD}gr${NC}           Go to references
  ${BOLD}K${NC}            Hover documentation
  ${BOLD}Space rn${NC}     Rename symbol
  ${BOLD}Space ca${NC}     Code actions
  ${BOLD}Space f${NC}      Format file

  ${BOLD}Space mp${NC}     Markdown preview
  ${BOLD}Space w${NC}      Save file
  ${BOLD}Space q${NC}      Quit

${CYAN}Window Navigation:${NC}
  ${BOLD}Ctrl+h/j/k/l${NC} Move between splits
  ${BOLD}Shift+h/l${NC}    Previous/next buffer
EOF

    wait_for_user

    print_subsection "Vim - The Classic"
    print_formatted << EOF
${BOLD}Classic Vim with plugins:${NC}

${CYAN}Installed Plugins:${NC}
  • ${BOLD}NERDTree${NC}        File explorer (${CYAN}Leader nn${NC})
  • ${BOLD}CtrlP${NC}           Fuzzy file finder (${CYAN}Ctrl+f${NC})
  • ${BOLD}Fugitive${NC}        Git integration (${CYAN}:Git${NC})
  • ${BOLD}YankStack${NC}       Clipboard history
  • ${BOLD}Emmet${NC}           HTML/CSS expansion
  • ${BOLD}snipMate${NC}        Code snippets

${CYAN}Common Vim Commands:${NC}
  ${BOLD}:w${NC}               Save
  ${BOLD}:q${NC}               Quit
  ${BOLD}:wq${NC}              Save and quit
  ${BOLD}/pattern${NC}         Search
  ${BOLD}n / N${NC}            Next/previous match
  ${BOLD}dd${NC}               Delete line
  ${BOLD}yy${NC}               Yank (copy) line
  ${BOLD}p${NC}                Paste
  ${BOLD}u${NC}                Undo
  ${BOLD}Ctrl+r${NC}           Redo
  ${BOLD}v${NC}                Visual mode
  ${BOLD}:split${NC}           Horizontal split
  ${BOLD}:vsplit${NC}          Vertical split

${BOLD}Why Vim?${NC}
  ✓ Available on every system
  ✓ Works over SSH
  ✓ Lightning fast
  ✓ Muscle memory transfers to Neovim, Zed, and even IDEs
EOF

    wait_for_user

    print_subsection "Editor Workflow Integration"
    print_formatted << EOF
${BOLD}Editors + Tmux = Power Combo${NC}

${YELLOW}Pattern: Full-screen editor${NC}
  ${CYAN}tmux new -s code${NC}
  ${CYAN}nvim .${NC}                ${DIM}# Open directory${NC}
  ${CYAN}Space e${NC}               ${DIM}# Toggle file tree${NC}
  ${CYAN}Space ff${NC}              ${DIM}# Find and open file${NC}
  ${DIM}# Work in Neovim${NC}
  ${CYAN}Ctrl+a |${NC}              ${DIM}# Split tmux pane${NC}
  ${DIM}# Now: Editor left, terminal right${NC}

${YELLOW}Pattern: Edit, run, test${NC}
  Pane 1: ${CYAN}nvim main.py${NC}
  Pane 2: ${CYAN}python main.py${NC}
  Pane 3: ${CYAN}pytest${NC}

  ${DIM}Edit in pane 1, run in pane 2, test in pane 3${NC}
  ${DIM}Switch with Ctrl+a arrows${NC}

${YELLOW}Pattern: Agent workflow${NC}
  ${CYAN}agent new feature-auth${NC}
  ${CYAN}wt switch feature-auth${NC}
  ${CYAN}tmux new -s auth${NC}
  ${CYAN}nvim .${NC}
  ${CYAN}Space e${NC}               ${DIM}# File tree${NC}
  ${CYAN}Space ff${NC}              ${DIM}# Find files${NC}
  ${DIM}# AI suggests in tmux pane, you implement in Neovim${NC}

EOF

    print_tip "Use 'nvim' for modern projects, 'vim' when SSH'd to servers"

    wait_for_user
}

# ============================================================================
# SECTION 7: Window Management
# ============================================================================

section_window_managers() {
    print_header
    print_section "${WINDOW} Window Management"

    echo -e "${BOLD}Tiling window managers for maximum productivity.${NC}"
    echo ""
    echo -e "${BOLD}What's a tiling WM?${NC}"
    echo "Instead of overlapping windows, tiles arrange windows to use"
    echo "all available screen space automatically."
    echo ""
    echo -e "${CYAN}Linux:${NC}   i3 / Sway"
    echo -e "${CYAN}macOS:${NC}   yabai / skhd (optional), Rectangle"
    echo ""
    echo -e "${BOLD}Benefits:${NC}"
    echo "  ✓ No window juggling"
    echo "  ✓ Keyboard-driven"
    echo "  ✓ Consistent layouts"
    echo "  ✓ Multi-monitor friendly"
    echo "  ✓ Workspace organization"

    wait_for_user

    print_subsection "i3 / Sway (Linux)"
    print_formatted << EOF
${BOLD}i3 (X11) and Sway (Wayland) are tiling window managers.${NC}

${CYAN}Core Concepts:${NC}
  • ${BOLD}Workspaces${NC}    - Virtual desktops (1-10)
  • ${BOLD}Containers${NC}    - Windows arranged in tree
  • ${BOLD}Layouts${NC}       - Horizontal, vertical, tabbed, stacked
  • ${BOLD}Mod key${NC}       - Usually Super (Windows) key

${CYAN}Common Keybindings (Mod = Super):${NC}
  ${BOLD}Mod+Enter${NC}         Open terminal
  ${BOLD}Mod+d${NC}             Application launcher
  ${BOLD}Mod+1-9${NC}           Switch workspace
  ${BOLD}Mod+Shift+1-9${NC}     Move window to workspace

  ${BOLD}Mod+h/j/k/l${NC}       Navigate windows (vim-style)
  ${BOLD}Mod+Shift+h/j/k/l${NC} Move windows

  ${BOLD}Mod+v${NC}             Vertical split
  ${BOLD}Mod+h${NC}             Horizontal split
  ${BOLD}Mod+e${NC}             Toggle split direction
  ${BOLD}Mod+f${NC}             Fullscreen
  ${BOLD}Mod+Shift+q${NC}       Close window

${CYAN}Workflow Example:${NC}
  Workspace 1: Terminal + Vim (split)
  Workspace 2: Browser (research)
  Workspace 3: Multiple terminals (tmux sessions)
  Workspace 4: Slack / Chat

  ${BOLD}Mod+1${NC} - Code
  ${BOLD}Mod+2${NC} - Research
  ${BOLD}Mod+3${NC} - Servers
  ${BOLD}Mod+4${NC} - Chat
EOF

    wait_for_user

    print_subsection "yabai / skhd (macOS)"
    print_formatted << EOF
${BOLD}Tiling window manager for macOS (requires manual install).${NC}

${CYAN}Features:${NC}
  • BSP (Binary Space Partitioning) layout
  • Stack layout
  • Float mode for specific apps
  • Multi-monitor support

${CYAN}Common skhd Keybindings:${NC}
  ${DIM}(If you've installed yabai/skhd)${NC}

  ${BOLD}Alt+Enter${NC}         New terminal
  ${BOLD}Alt+h/j/k/l${NC}       Focus window
  ${BOLD}Shift+Alt+h/j/k/l${NC} Move window
  ${BOLD}Alt+f${NC}             Toggle fullscreen
  ${BOLD}Alt+r${NC}             Rotate tree
  ${BOLD}Alt+1-9${NC}           Switch space

${CYAN}Alternative: Rectangle${NC}
  ${DIM}Simpler window management (via Homebrew)${NC}

  • Snap windows to halves/quarters
  • Keyboard shortcuts
  • Works immediately (no SIP disable)
  • Good for beginners

EOF

    print_tip "Start with Rectangle on macOS, graduate to yabai when comfortable"

    wait_for_user

    print_subsection "Integrated Workflow"
    print_formatted << EOF
${BOLD}Combining all the tools:${NC}

${YELLOW}The Full Stack:${NC}

  ${BOLD}Window Manager${NC}  (i3/sway/yabai)
  ↓ Workspaces organized by project/task

  ${BOLD}Terminal${NC}        (Alacritty/iTerm2)
  ↓ Fast, GPU-accelerated

  ${BOLD}Tmux${NC}            (Terminal multiplexer)
  ↓ Multiple sessions, windows, panes

  ${BOLD}Shell${NC}           (Bash/Fish with Starship)
  ↓ Powerful navigation and git

  ${BOLD}Editor${NC}          (Neovim with LSP)
  ↓ Full IDE features

  ${BOLD}Git Worktrees${NC}   (via wt command)
  ↓ Multiple branches active

  ${BOLD}Agent System${NC}    (AI parallel workflows)
  ✓ Everything tracked and organized

${YELLOW}Real-world example:${NC}

  ${BOLD}Workspace 1: Main Development${NC}
    Tmux session "main"
      Window 1: Neovim (main project)
      Window 2: Server running
      Window 3: Git commands

  ${BOLD}Workspace 2: Agent Feature${NC}
    Tmux session "feature-auth"
      Window 1: Neovim (worktree: feature-oauth)
      Window 2: Test server
      Window 3: Agent AI terminal

  ${BOLD}Workspace 3: Code Review${NC}
    Tmux session "review"
      Pane 1: Vim (their code)
      Pane 2: Browser (PR on GitHub)
      Pane 3: Running their tests

  ${BOLD}Workspace 4: Communication${NC}
    Slack, Discord, Email

${GREEN}One keystroke switches entire contexts!${NC}
EOF

    wait_for_user
}

# ============================================================================
# SECTION 8: AI Agent System
# ============================================================================

section_agents() {
    print_header
    print_section "${ROBOT} AI Agent Parallelization"

    echo -e "${BOLD}Run multiple AI coding sessions in parallel.${NC}"
    echo ""
    echo -e "The agent system builds on top of ${CYAN}wt${NC} (worktrees) to add:"
    echo "  • Session management and context tracking"
    echo "  • Shared context directories between sessions"
    echo "  • Templates for different workflow types"
    echo "  • Lock files to prevent conflicts"
    echo "  • Shell prompt integration"
    echo ""
    echo -e "${BOLD}Perfect for:${NC}"
    echo "  • Multiple features developed simultaneously"
    echo "  • Separating exploration from production"
    echo "  • Sharing context between related tasks"
    echo "  • Parallel AI agents working independently"

    wait_for_user

    print_subsection "Agent vs wt"
    print_formatted << EOF
${BOLD}When to use what?${NC}

${CYAN}Use 'wt' for:${NC}
  ✓ Quick feature branches
  ✓ Simple context switching
  ✓ Review someone's PR
  ✓ Trying an experiment
  ✓ Manual development

${CYAN}Use 'agent' for:${NC}
  ✓ Long-running AI sessions
  ✓ Complex features needing context
  ✓ Sharing info between sessions
  ✓ Tracked progress and notes
  ✓ Team collaboration
  ✓ Structured workflows

${YELLOW}Example:${NC}
  ${DIM}# Quick fix${NC}
  ${CYAN}wt add hotfix${NC}
  ${DIM}# ... fix, commit, done${NC}

  ${DIM}# AI-driven feature${NC}
  ${CYAN}agent new oauth-integration --template=feature${NC}
  ${CYAN}agent context oauth-integration --edit${NC}
  ${DIM}# ... AI reads context, writes code, updates notes${NC}
  ${DIM}# ... session tracked, progress saved${NC}
EOF

    wait_for_user

    print_subsection "Agent Commands"
    print_formatted << EOF
${CYAN}Session Management:${NC}
  ${BOLD}agent new <name>${NC}          Create session
  ${BOLD}agent list${NC}                List all sessions
  ${BOLD}agent switch <name>${NC}       Switch to session
  ${BOLD}agent close <name>${NC}        Close session
  ${BOLD}agent current${NC}             Show current session

${CYAN}Context Management:${NC}
  ${BOLD}agent context <name> --edit${NC}   Edit context
  ${BOLD}agent share-context A B --file=X${NC}  Share file
  ${BOLD}agent sync <name>${NC}         Sync with upstream

${CYAN}Quick Aliases:${NC}
  ${BOLD}anew${NC}     →  agent new
  ${BOLD}asw${NC}      →  agent switch
  ${BOLD}alist${NC}    →  agent list
  ${BOLD}actx${NC}     →  agent context
  ${BOLD}aclose${NC}   →  agent close
  ${BOLD}ainfo${NC}    →  show current session info
  ${BOLD}aedit${NC}    →  edit current session context

${CYAN}Templates:${NC}
  ${BOLD}--template=feature${NC}       New feature development
  ${BOLD}--template=bugfix${NC}        Bug fix
  ${BOLD}--template=refactor${NC}      Code refactoring
  ${BOLD}--template=exploration${NC}   Experimental work
EOF

    wait_for_user

    print_subsection "Agent Workflow Example"
    print_formatted << EOF
${BOLD}Complete AI-assisted development workflow:${NC}

${YELLOW}1. Create session${NC}
   ${CYAN}agent new auth-feature --template=feature${NC}

   Creates:
     • Worktree at ../repo-wt-auth-feature
     • Context dir with templates
     • Session metadata

${YELLOW}2. Edit context${NC}
   ${CYAN}agent context auth-feature --edit${NC}

   Fill in:
     • Objective: "Add OAuth2 authentication"
     • Approach: "Use passport.js library"
     • Tasks: Checklist of TODOs
     • Notes: Architecture decisions

${YELLOW}3. Work with AI${NC}
   ${CYAN}wt switch auth-feature${NC}
   ${CYAN}tmux new -s auth${NC}

   Left pane:  Your AI tool reading context
   Right pane: Editor implementing suggestions

${YELLOW}4. Parallel session${NC}
   ${CYAN}agent new bugfix-login --template=bugfix${NC}
   ${CYAN}agent switch bugfix-login${NC}

   Fix bug while AI continues on auth-feature!

${YELLOW}5. Share context${NC}
   ${CYAN}agent share-context auth-feature bugfix-login --file=api-spec.md${NC}

   Both sessions now have same API spec

${YELLOW}6. Close when done${NC}
   ${CYAN}agent close auth-feature --archive${NC}

   Archives context for future reference
EOF

    wait_for_user

    print_subsection "Multi-Agent Patterns"
    print_formatted << EOF
${BOLD}Pattern 1: Feature + Tests${NC}
  Agent A: Implements feature
  Agent B: Writes tests
  ${DIM}Share: API spec, type definitions${NC}

${BOLD}Pattern 2: Frontend + Backend${NC}
  Agent A: React frontend
  Agent B: API backend
  ${DIM}Share: API contract, data models${NC}

${BOLD}Pattern 3: Experiment + Production${NC}
  Agent A: Explore new approach
  Agent B: Maintain current code
  ${DIM}Keep isolated, merge best parts${NC}

${BOLD}Pattern 4: Parallel Features${NC}
  Agent A: OAuth integration
  Agent B: Email notifications
  Agent C: User profiles
  ${DIM}All work independently, merge when ready${NC}

${BOLD}Pattern 5: Review + Fix${NC}
  Agent A: Review codebase for issues
  Agent B: Fix identified issues
  ${DIM}Share: Issue list, refactoring plan${NC}

EOF

    print_tip "Each agent session gets its own tmux session and workspace"

    wait_for_user
}

# ============================================================================
# SECTION 9: Complete Development Workflow
# ============================================================================

section_workflow() {
    print_header
    print_section "${WORKFLOW} Complete Development Workflow"

    print_formatted << EOF
${BOLD}Putting it all together: Start to deployment.${NC}

Let's walk through a real-world development workflow using
every tool we've covered.

${BOLD}Scenario:${NC}
  Building a new API endpoint with authentication,
  writing tests, and deploying to production.
EOF

    wait_for_user

    print_subsection "Step 1: Project Setup"
    print_formatted << EOF
${YELLOW}Morning: Starting fresh${NC}

${DIM}# Start window manager workspace 1${NC}
${CYAN}Mod+1${NC}                          ${DIM}(Switch to workspace 1)${NC}

${DIM}# Open terminal and start tmux${NC}
${CYAN}tmux new -s myapi${NC}

${DIM}# Navigate to project${NC}
${CYAN}fal myproject${NC}                  ${DIM}(Jump to aliased directory)${NC}

${DIM}# Or create new project${NC}
${CYAN}mkcd ~/projects/new-api${NC}
${CYAN}al myapi${NC}                       ${DIM}(Alias for quick access)${NC}

${DIM}# Check git status${NC}
${CYAN}gs${NC}                             ${DIM}(git status)${NC}

${DIM}# Update dependencies${NC}
${CYAN}npm install${NC}                    ${DIM}(or pip install -r requirements.txt)${NC}
EOF

    wait_for_user

    print_subsection "Step 2: Create Feature Branch"
    print_formatted << EOF
${YELLOW}Creating an isolated workspace${NC}

${DIM}# Create worktree for feature${NC}
${CYAN}wt add feature-auth${NC}

${DIM}# Switch to it${NC}
${CYAN}wt switch feature-auth${NC}

${DIM}# Or use agent for tracked development${NC}
${CYAN}agent new feature-auth --template=feature${NC}
${CYAN}agent context feature-auth --edit${NC}

${BOLD}Edit context:${NC}
  ${DIM}Objective: Add JWT authentication to API${NC}
  ${DIM}Approach: Use jsonwebtoken library${NC}
  ${DIM}Tasks:${NC}
    ${DIM}[ ] Install dependencies${NC}
    ${DIM}[ ] Create auth middleware${NC}
    ${DIM}[ ] Add login endpoint${NC}
    ${DIM}[ ] Add protected routes${NC}
    ${DIM}[ ] Write tests${NC}
    ${DIM}[ ] Update docs${NC}

${CYAN}agent switch feature-auth${NC}
EOF

    wait_for_user

    print_subsection "Step 3: Development Environment"
    print_formatted << EOF
${YELLOW}Setting up tmux workspace${NC}

${DIM}# Window 1: Editor${NC}
${CYAN}nvim .${NC}
${CYAN}Space e${NC}                        ${DIM}(Toggle file tree)${NC}
${CYAN}Space ff${NC}                       ${DIM}(Find file: auth.js)${NC}

${DIM}# Create new window for server${NC}
${CYAN}Ctrl+a c${NC}
${CYAN}Ctrl+a ,${NC}                       ${DIM}(Rename to "server")${NC}
${CYAN}npm run dev${NC}

${DIM}# Create window for tests${NC}
${CYAN}Ctrl+a c${NC}
${CYAN}Ctrl+a ,${NC}                       ${DIM}(Rename to "tests")${NC}
${CYAN}npm run test:watch${NC}

${DIM}# Create window for git/shell${NC}
${CYAN}Ctrl+a c${NC}
${CYAN}Ctrl+a ,${NC}                       ${DIM}(Rename to "git")${NC}

${BOLD}Now you have:${NC}
  Window 0 [vim]:    Editor
  Window 1 [server]: Dev server running
  Window 2 [tests]:  Tests watching
  Window 3 [git]:    Git commands

${DIM}Switch with:${NC} ${CYAN}Ctrl+a 0-3${NC}
EOF

    wait_for_user

    print_subsection "Step 4: Coding + Testing"
    print_formatted << EOF
${YELLOW}Development loop${NC}

${DIM}# In vim window (Ctrl+a 0)${NC}
${CYAN}Space ff${NC}                       ${DIM}(Find: auth.js)${NC}
${DIM}... write middleware code ...${NC}
${CYAN}:w${NC}                             ${DIM}(Save - auto-formats on save!)${NC}

${DIM}# Check server logs (Ctrl+a 1)${NC}
${DIM}... server auto-restarted ...${NC}

${DIM}# Check tests (Ctrl+a 2)${NC}
${DIM}... tests auto-ran ...${NC}
${GREEN}✓ All tests passing${NC}

${DIM}# Write more tests${NC}
${CYAN}Ctrl+a 0${NC}                       ${DIM}(Back to vim)${NC}
${CYAN}Space ff${NC}                       ${DIM}(Find: auth.test.js)${NC}
${DIM}... write tests ...${NC}

${DIM}# Commit progress (Ctrl+a 3 - git window)${NC}
${CYAN}gs${NC}                             ${DIM}(git status)${NC}
${CYAN}add src/auth.js src/auth.test.js${NC}
${CYAN}commit -m "Add JWT authentication middleware"${NC}

${DIM}# Quick save work-in-progress${NC}
${CYAN}gwip${NC}                           ${DIM}(Quick WIP commit)${NC}
EOF

    wait_for_user

    print_subsection "Step 5: Urgent Interruption"
    print_formatted << EOF
${YELLOW}Production bug! Don't lose your work${NC}

${DIM}# You're in the middle of feature development${NC}
${DIM}# Urgent bug report comes in${NC}

${DIM}# DON'T stash or commit half-done work!${NC}

${DIM}# Create new worktree for hotfix${NC}
${CYAN}wt add hotfix-login${NC}

${DIM}# Switch workspace (Mod+2)${NC}
${DIM}# Or split current tmux window${NC}
${CYAN}Ctrl+a |${NC}                       ${DIM}(Vertical split)${NC}
${CYAN}wt switch hotfix-login${NC}

${DIM}# Fix the bug${NC}
${CYAN}vim src/login.js${NC}
${DIM}... fix bug ...${NC}
${CYAN}:wq${NC}

${DIM}# Test it${NC}
${CYAN}npm test${NC}
${GREEN}✓ Tests pass${NC}

${DIM}# Commit and push${NC}
${CYAN}add src/login.js${NC}
${CYAN}commit -m "Fix login validation bug"${NC}
${CYAN}push-please${NC}                    ${DIM}(Force push safely)${NC}

${DIM}# Back to feature work${NC}
${CYAN}wt switch feature-auth${NC}
${DIM}# Your work is exactly where you left it!${NC}

${DIM}# Clean up hotfix when merged${NC}
${CYAN}wt remove hotfix-login${NC}
EOF

    wait_for_user

    print_subsection "Step 6: Code Review + Refinement"
    print_formatted << EOF
${YELLOW}Using LSP features for quality${NC}

${DIM}# In Neovim${NC}
${CYAN}Space fd${NC}                       ${DIM}(Find diagnostics)${NC}
${DIM}... shows all errors/warnings ...${NC}

${DIM}# Navigate to error${NC}
${CYAN}gd${NC}                             ${DIM}(Go to definition)${NC}
${CYAN}gr${NC}                             ${DIM}(Find references)${NC}
${CYAN}K${NC}                              ${DIM}(Show documentation)${NC}

${DIM}# Rename variable everywhere${NC}
${CYAN}Space rn${NC}                       ${DIM}(Rename symbol)${NC}
${DIM}... type new name ...${NC}
${DIM}... updated everywhere!${NC}

${DIM}# Format code${NC}
${CYAN}Space f${NC}                        ${DIM}(Format file)${NC}

${DIM}# Run linter${NC}
${DIM}... happens automatically on save ...${NC}

${DIM}# Check across all worktrees${NC}
${CYAN}wt each npm run lint${NC}           ${DIM}(Lint all branches!)${NC}
EOF

    wait_for_user

    print_subsection "Step 7: Documentation + Merge"
    print_formatted << EOF
${YELLOW}Finishing touches${NC}

${DIM}# Update README${NC}
${CYAN}Space ff${NC}                       ${DIM}(Find: README.md)${NC}
${DIM}... document new endpoint ...${NC}

${DIM}# Preview markdown (if installed)${NC}
${CYAN}Space mp${NC}                       ${DIM}(Markdown preview)${NC}

${DIM}# Update context notes${NC}
${CYAN}aedit${NC}                          ${DIM}(Edit agent context)${NC}
${DIM}... mark tasks as complete ...${NC}
  ${GREEN}[✓] Install dependencies${NC}
  ${GREEN}[✓] Create auth middleware${NC}
  ${GREEN}[✓] Add login endpoint${NC}
  ${GREEN}[✓] Add protected routes${NC}
  ${GREEN}[✓] Write tests${NC}
  ${GREEN}[✓] Update docs${NC}

${DIM}# Final commit${NC}
${CYAN}gs${NC}
${CYAN}add .${NC}
${CYAN}commit -m "Complete JWT authentication feature

- Add auth middleware with JWT verification
- Implement login endpoint
- Protect sensitive routes
- Add comprehensive tests (95% coverage)
- Update API documentation"${NC}

${DIM}# Sync with main${NC}
${CYAN}gsync main${NC}                     ${DIM}(Rebase on main)${NC}

${DIM}# Push${NC}
${CYAN}gpom${NC}                           ${DIM}(git push origin main)${NC}
EOF

    wait_for_user

    print_subsection "Step 8: Multi-Agent Parallel Work"
    print_formatted << EOF
${YELLOW}While waiting for review, start another feature${NC}

${DIM}# First feature awaiting review${NC}
${CYAN}agent list${NC}
  ${GREEN}feature-auth${NC}    (awaiting review)

${DIM}# Start second feature${NC}
${CYAN}agent new feature-notifications --template=feature${NC}
${CYAN}agent context feature-notifications --edit${NC}

${DIM}# Share API spec from auth feature${NC}
${CYAN}agent share-context feature-auth feature-notifications --file=api-spec.md${NC}

${DIM}# New workspace for new feature (Mod+3)${NC}
${DIM}# New tmux session${NC}
${CYAN}tmux new -s notifications${NC}
${CYAN}agent switch feature-notifications${NC}
${CYAN}nvim .${NC}

${BOLD}Now you have two features in parallel:${NC}
  Workspace 1: feature-auth (awaiting review)
  Workspace 2: main work
  Workspace 3: feature-notifications (active development)

${DIM}Switch between workspaces with ${CYAN}Mod+1-3${NC}
EOF

    wait_for_user

    print_subsection "Step 9: Deployment"
    print_formatted << EOF
${YELLOW}Deploying to production${NC}

${DIM}# Feature merged to main${NC}
${CYAN}wt switch main-dev${NC}              ${DIM}(or just cd to main repo)${NC}
${CYAN}git checkout main${NC}
${CYAN}git pull${NC}

${DIM}# Run full test suite${NC}
${CYAN}npm run test${NC}
${GREEN}✓ 247 tests passing${NC}

${DIM}# Build for production${NC}
${CYAN}npm run build${NC}

${DIM}# Deploy${NC}
${CYAN}npm run deploy${NC}                 ${DIM}(or your deploy script)${NC}

${DIM}# Monitor logs in new tmux window${NC}
${CYAN}Ctrl+a c${NC}
${CYAN}ssh production${NC}
${CYAN}tail -f /var/log/app.log${NC}

${DIM}# If issues, quick rollback${NC}
${CYAN}git revert HEAD${NC}
${CYAN}gpom${NC}
${CYAN}npm run deploy${NC}
EOF

    wait_for_user

    print_subsection "Step 10: Cleanup"
    print_formatted << EOF
${YELLOW}Cleaning up after successful deployment${NC}

${DIM}# Close finished agent sessions${NC}
${CYAN}agent close feature-auth --archive${NC}
${GREEN}✓ Context archived to ~/.config/agents/archive/${NC}

${DIM}# Remove merged worktrees${NC}
${CYAN}wt remove feature-auth${NC}

${DIM}# Clean up merged branches${NC}
${CYAN}gclean${NC}
${GREEN}✓ Deleted 3 merged branches${NC}

${DIM}# Exit tmux sessions${NC}
${CYAN}Ctrl+a d${NC}                       ${DIM}(Detach from current)${NC}
${CYAN}tmux kill-session -t auth${NC}

${DIM}# Update local dotfiles${NC}
${CYAN}dotfiles-update${NC}

${BOLD}Ready for the next feature!${NC}
EOF

    wait_for_user

    print_subsection "Workflow Summary"
    print_formatted << EOF
${BOLD}Complete workflow recap:${NC}

${CYAN}1. Setup${NC}
   Workspace → Tmux → Navigate → Project

${CYAN}2. Feature Branch${NC}
   Worktree or Agent → Context

${CYAN}3. Development${NC}
   Tmux windows → Editor + Server + Tests

${CYAN}4. Interruptions${NC}
   New worktree → Fix → Back to work

${CYAN}5. Quality${NC}
   LSP features → Linting → Formatting

${CYAN}6. Review${NC}
   Documentation → Commit → Sync

${CYAN}7. Parallel Work${NC}
   Multiple agents → Shared context

${CYAN}8. Deploy${NC}
   Test → Build → Deploy → Monitor

${CYAN}9. Cleanup${NC}
   Archive → Remove → Clean

${GREEN}${BOLD}Every tool working together seamlessly!${NC}
EOF

    wait_for_user
}

# ============================================================================
# SECTION 10: Next Steps
# ============================================================================

section_next_steps() {
    print_header
    print_section "${ROCKET} Next Steps"

    print_formatted << EOF
${GREEN}${BOLD}Congratulations! You've completed the comprehensive tour.${NC}

${BOLD}What to do next:${NC}

${CYAN}1. Practice the basics${NC}
   Start with navigation and git shortcuts
   Add some directory aliases
   Try creating a worktree

${CYAN}2. Set up your environment${NC}
   Configure: ${YELLOW}~/.bash_profile${NC}
   Git config: ${YELLOW}~/.gitprofile${NC}
   Tmux config: ${YELLOW}~/.tmux.profile${NC}
   Nvim config: ${YELLOW}~/.config/nvim/personal.lua${NC}

${CYAN}3. Master one tool at a time${NC}
   Week 1: Shell navigation + git shortcuts
   Week 2: Tmux basics
   Week 3: Neovim essentials
   Week 4: Worktrees
   Week 5: Agent system
   Week 6: Window manager (optional)

${CYAN}4. Build muscle memory${NC}
   Use the tools daily
   Resist going back to old habits
   Shortcuts feel weird at first - that's normal!

${CYAN}5. Customize${NC}
   Add your own aliases
   Tweak keybindings
   Create custom scripts
   Share improvements!

${BOLD}Quick Reference Card:${NC}

${DIM}Navigation:${NC}    al, fal, lal, mkcd, pl/gl/ol, up, bk
${DIM}Git:${NC}           gs, ga, gc, gp, gco, gnew, gwip, gunwip, gsync
${DIM}Worktrees:${NC}     wt add/list/switch/remove/each/info
${DIM}Agent:${NC}         agent new/list/switch/close, anew, asw, aedit
${DIM}Tmux:${NC}          Ctrl+a |/"/c/n/p/d/[/]
${DIM}Nvim:${NC}          Space e/ff/fg/fb, gd/gr/K, Space rn/ca/f
${DIM}Utilities:${NC}     updoot, plz, myip, weather, ports, freeport

${BOLD}Resources:${NC}

  ${CYAN}./tutorial.sh${NC}                  Run this tutorial again
  ${CYAN}agent help${NC}                    Agent system help
  ${CYAN}wt help${NC}                       Worktree wrapper help
  ${CYAN}man tmux${NC}                      Tmux manual
  ${CYAN}:help${NC}                         Vim/Neovim help

  ${CYAN}README.md${NC}                     Getting started guide
  ${CYAN}ARCHITECTURE.md${NC}               System design
  ${CYAN}docs/AGENT_WORKFLOWS.md${NC}       Agent examples
  ${CYAN}docs/CUSTOMIZATION.md${NC}         Customization guide

${BOLD}Get Help:${NC}

  ${DIM}In Vim:${NC}        ${CYAN}:help <topic>${NC}
  ${DIM}In Neovim:${NC}     ${CYAN}:checkhealth${NC}  ${DIM}(verify LSP setup)${NC}
  ${DIM}In Tmux:${NC}       ${CYAN}Ctrl+a ?${NC}       ${DIM}(show all keys)${NC}
  ${DIM}In Shell:${NC}      ${CYAN}man <command>${NC}

${MAGENTA}${BOLD}Happy coding! ${ROCKET}${SPARKLES}${NC}

${DIM}This tutorial created a demo directory at: ${DEMO_DIR}${NC}
${DIM}Feel free to explore or delete it: ${CYAN}rm -rf ${DEMO_DIR}${NC}
EOF

    echo ""
}

cleanup() {
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
    if [ "$SKIP_INTRO" = false ]; then
        welcome
    fi

    section_shell
    section_navigation
    section_git
    section_worktrees
    section_tmux
    section_editors
    section_window_managers
    section_agents
    section_workflow
    section_next_steps
    cleanup

    echo ""
    print_success "Tutorial complete!"
    echo ""
    echo -e "${CYAN}Run again with: ${GREEN}./tutorial.sh${NC}"
    echo -e "${CYAN}Skip intro with: ${GREEN}./tutorial.sh --skip-intro${NC}"
    echo ""
}

main "$@"
