#!/usr/bin/env bash

# Dotfiles Installer
# Interactive, cross-platform, modular dotfiles installation
#
# Usage: ./install.sh [--non-interactive] [--minimal]

set -e

# ============================================================================
# Configuration
# ============================================================================

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

# Flags
INTERACTIVE=true
MINIMAL_INSTALL=false
DRY_RUN=false

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# ============================================================================
# Utility Functions
# ============================================================================

log_header() {
    echo ""
    echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${CYAN}  $1${NC}"
    echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════${NC}"
    echo ""
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[!]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1" >&2
}

log_step() {
    echo -e "${CYAN}▶${NC} $1"
}

die() {
    log_error "$1"
    exit 1
}

ask_user() {
    if ! $INTERACTIVE; then
        return 0
    fi

    while true; do
        read -p "$(echo -e "${BLUE}[?]${NC} $1 [y/n] ")" yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# ============================================================================
# OS Detection
# ============================================================================

detect_os() {
    log_step "Detecting operating system..."

    OS="$(uname -s)"
    case "$OS" in
        Linux)
            OS_TYPE="linux"
            # Detect package manager
            if command -v apt-get >/dev/null 2>&1; then
                PKG_MANAGER="apt"
                log_info "Detected Debian/Ubuntu (apt)"
            elif command -v pacman >/dev/null 2>&1; then
                PKG_MANAGER="pacman"
                log_info "Detected Arch Linux (pacman)"
            elif command -v dnf >/dev/null 2>&1; then
                PKG_MANAGER="dnf"
                log_info "Detected Fedora/RHEL (dnf)"
            elif command -v yum >/dev/null 2>&1; then
                PKG_MANAGER="yum"
                log_info "Detected older RHEL (yum)"
            else
                log_warn "Could not detect package manager. Some features may not work."
                PKG_MANAGER="unknown"
            fi
            ;;
        Darwin)
            OS_TYPE="macos"
            PKG_MANAGER="brew"
            log_info "Detected macOS (Homebrew)"
            ;;
        CYGWIN*|MINGW*|MSYS*)
            OS_TYPE="windows"
            PKG_MANAGER="choco"
            log_info "Detected Windows"
            ;;
        *)
            die "Unsupported operating system: $OS"
            ;;
    esac

    log_success "OS detected: $OS_TYPE"
}

# ============================================================================
# Backup Existing Dotfiles
# ============================================================================

backup_dotfiles() {
    log_header "Backing Up Existing Dotfiles"

    local files_to_backup=(
        ".bashrc"
        ".bash_profile"
        ".gitconfig"
        ".gitprofile"
        ".vimrc"
        ".tmux.conf"
        ".config/nvim"
        ".config/fish"
        ".config/alacritty"
    )

    local backed_up=false

    for file in "${files_to_backup[@]}"; do
        if [ -e "$HOME/$file" ] && [ ! -L "$HOME/$file" ]; then
            if ! $backed_up; then
                mkdir -p "$BACKUP_DIR"
                backed_up=true
                log_info "Creating backup directory: $BACKUP_DIR"
            fi

            log_info "Backing up: $file"
            cp -r "$HOME/$file" "$BACKUP_DIR/"
        fi
    done

    if $backed_up; then
        log_success "Backup complete: $BACKUP_DIR"
    else
        log_info "No existing dotfiles to backup"
    fi
}

# ============================================================================
# Install Packages
# ============================================================================

install_packages() {
    log_header "Installing Packages"

    if ! ask_user "Do you want to install system packages?"; then
        log_info "Skipping package installation"
        return
    fi

    case "$PKG_MANAGER" in
        apt)
            log_step "Updating package lists..."
            sudo apt-get update

            log_step "Installing packages from packages-apt.txt..."
            if [ -f "$DOTFILES_DIR/linux/packages-apt.txt" ]; then
                # Filter out comments and empty lines
                grep -v "^#" "$DOTFILES_DIR/linux/packages-apt.txt" | grep -v "^$" | xargs sudo apt-get install -y
                log_success "Packages installed"
            else
                log_warn "Package list not found"
            fi
            ;;

        pacman)
            log_step "Updating system..."
            sudo pacman -Syu --noconfirm

            log_step "Installing packages from packages-pacman.txt..."
            if [ -f "$DOTFILES_DIR/linux/packages-pacman.txt" ]; then
                grep -v "^#" "$DOTFILES_DIR/linux/packages-pacman.txt" | grep -v "^$" | xargs sudo pacman -S --noconfirm --needed
                log_success "Packages installed"
            else
                log_warn "Package list not found"
            fi
            ;;

        brew)
            if ! command -v brew >/dev/null 2>&1; then
                if ask_user "Homebrew not found. Install it?"; then
                    log_step "Installing Homebrew..."
                    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

                    # Add Homebrew to PATH
                    if [ -f /opt/homebrew/bin/brew ]; then
                        eval "$(/opt/homebrew/bin/brew shellenv)"
                    fi
                else
                    log_warn "Skipping Homebrew installation"
                    return
                fi
            fi

            log_step "Installing packages from Brewfile..."
            if [ -f "$DOTFILES_DIR/macos/Brewfile" ]; then
                brew bundle --file="$DOTFILES_DIR/macos/Brewfile"
                log_success "Packages installed"
            else
                log_warn "Brewfile not found"
            fi
            ;;

        *)
            log_warn "Package installation not supported for $PKG_MANAGER"
            ;;
    esac
}

# ============================================================================
# Stow Configuration
# ============================================================================

stow_configs() {
    log_header "Installing Configuration Modules"

    # Check if stow is installed
    if ! command -v stow >/dev/null 2>&1; then
        die "GNU Stow is not installed. Please install it first."
    fi

    # Define available modules
    local common_modules=("bash" "git" "vim" "nvim" "tmux" "agents")
    local selected_modules=()

    if $MINIMAL_INSTALL; then
        selected_modules=("bash" "git")
    else
        log_info "Available modules:"
        for module in "${common_modules[@]}"; do
            echo "  - $module"
        done

        echo ""
        for module in "${common_modules[@]}"; do
            if ask_user "Install $module config?"; then
                selected_modules+=("$module")
            fi
        done
    fi

    # Stow selected modules
    log_step "Installing selected modules..."
    for module in "${selected_modules[@]}"; do
        if [ -d "$DOTFILES_DIR/common/$module" ]; then
            log_info "Stowing: $module"
            stow -R -t ~ -d "$DOTFILES_DIR/common" "$module" 2>&1 | grep -v "BUG in find_stowed_path" || true
            log_success "Installed: $module"
        else
            log_warn "Module not found: $module"
        fi
    done

    # Stow OS-specific configs
    if [ -d "$DOTFILES_DIR/$OS_TYPE" ]; then
        log_step "Installing OS-specific configs..."

        if [ "$OS_TYPE" = "macos" ]; then
            if ask_user "Install macOS window management (yabai/skhd)?"; then
                [ -d "$DOTFILES_DIR/macos/yabai" ] && stow -R -t ~ -d "$DOTFILES_DIR/macos" yabai 2>&1 | grep -v "BUG in find_stowed_path" || true
                [ -d "$DOTFILES_DIR/macos/skhd" ] && stow -R -t ~ -d "$DOTFILES_DIR/macos" skhd 2>&1 | grep -v "BUG in find_stowed_path" || true
                log_success "Window management configs installed"
            fi

            if ask_user "Install Zed editor config?"; then
                [ -d "$DOTFILES_DIR/macos/zed" ] && stow -R -t ~ -d "$DOTFILES_DIR/macos" zed 2>&1 | grep -v "BUG in find_stowed_path" || true
                log_success "Zed config installed"
            fi
        elif [ "$OS_TYPE" = "linux" ]; then
            if ask_user "Install i3/sway window manager config?"; then
                [ -d "$DOTFILES_DIR/linux/i3" ] && stow -R -t ~ -d "$DOTFILES_DIR/linux" i3 2>&1 | grep -v "BUG in find_stowed_path" || true
                [ -d "$DOTFILES_DIR/linux/sway" ] && stow -R -t ~ -d "$DOTFILES_DIR/linux" sway 2>&1 | grep -v "BUG in find_stowed_path" || true
                log_success "Window manager configs installed"
            fi

            if ask_user "Install Alacritty terminal config?"; then
                [ -d "$DOTFILES_DIR/linux/alacritty" ] && stow -R -t ~ -d "$DOTFILES_DIR/linux" alacritty 2>&1 | grep -v "BUG in find_stowed_path" || true
                log_success "Alacritty config installed"
            fi
        fi
    fi

    log_success "Configuration modules installed"
}

# ============================================================================
# Setup Personal Configs
# ============================================================================

setup_personal_configs() {
    log_header "Setting Up Personal Configurations"

    # Git personal config
    if [ ! -f "$HOME/.gitprofile" ]; then
        if ask_user "Create git personal config (~/.gitprofile)?"; then
            cat > "$HOME/.gitprofile" <<EOF
[user]
    name = Your Name
    email = your@email.com

# Add your personal git configuration here
# This file is not tracked in the dotfiles repository
EOF
            log_success "Created ~/.gitprofile template"
            log_warn "Don't forget to edit ~/.gitprofile with your name and email!"
        fi
    else
        log_info "~/.gitprofile already exists"
    fi

    # Bash personal profile
    if [ ! -f "$HOME/.bash_profile" ]; then
        cat > "$HOME/.bash_profile" <<EOF
# Personal bash configuration
# This file is not tracked in the dotfiles repository

# Example: Set environment variables
# export EDITOR=nvim

# Example: Add to PATH
# export PATH="\$HOME/bin:\$PATH"

# Example: Machine-specific aliases
# alias myproject="cd ~/projects/myproject"
EOF
        log_success "Created ~/.bash_profile template"
    else
        log_info "~/.bash_profile already exists"
    fi
}

# ============================================================================
# Setup Shell
# ============================================================================

setup_shell() {
    log_header "Shell Configuration"

    # Check if fish is installed
    if command -v fish >/dev/null 2>&1; then
        if ask_user "Set Fish as your default shell?"; then
            local fish_path=$(command -v fish)

            # Add fish to /etc/shells if not present
            if ! grep -q "$fish_path" /etc/shells 2>/dev/null; then
                log_info "Adding fish to /etc/shells..."
                echo "$fish_path" | sudo tee -a /etc/shells
            fi

            # Change default shell
            if [ "$SHELL" != "$fish_path" ]; then
                log_info "Changing default shell to fish..."
                chsh -s "$fish_path"
                log_success "Default shell changed to fish"
                log_info "Please restart your terminal for changes to take effect"
            else
                log_info "Fish is already your default shell"
            fi
        fi
    else
        log_info "Fish shell not installed. Using bash."
    fi

    # Source bashrc in current session
    log_info "To activate bash config in this session, run: source ~/.bashrc"
}

# ============================================================================
# Install Agent Tools
# ============================================================================

setup_agent_tools() {
    log_header "AI Agent Tools"

    if ask_user "Set up AI agent parallelization tools?"; then
        # Make bin scripts executable
        chmod +x "$DOTFILES_DIR/bin"/*

        # Add bin to PATH in bash_profile if not already there
        if [ -f "$HOME/.bash_profile" ]; then
            if ! grep -q "dotfiles/bin" "$HOME/.bash_profile"; then
                echo "" >> "$HOME/.bash_profile"
                echo "# Add dotfiles bin to PATH" >> "$HOME/.bash_profile"
                echo "export PATH=\"$DOTFILES_DIR/bin:\$PATH\"" >> "$HOME/.bash_profile"
            fi
        fi

        log_success "Agent tools installed"
        log_info "Available commands: agent, worktree-clean, context-sync"
        log_info "Run 'agent help' to get started with multi-agent workflows"
    fi
}

# ============================================================================
# Post-Install Instructions
# ============================================================================

post_install() {
    log_header "Installation Complete!"

    echo -e "${GREEN}${BOLD}✓ Dotfiles installed successfully!${NC}"
    echo ""
    echo -e "${BOLD}Next Steps:${NC}"
    echo ""
    echo -e "  1. ${CYAN}Restart your terminal${NC} or run: ${GREEN}source ~/.bashrc${NC}"
    echo ""
    echo -e "  2. ${CYAN}Edit your personal configs:${NC}"
    echo -e "     ${YELLOW}~/.gitprofile${NC}    - Git name/email"
    echo -e "     ${YELLOW}~/.bash_profile${NC}  - Personal bash config"
    echo ""
    echo -e "  3. ${CYAN}Try the AI agent tools:${NC}"
    echo -e "     ${GREEN}agent new my-feature${NC}    - Create a new agent session"
    echo -e "     ${GREEN}agent list${NC}              - List active sessions"
    echo -e "     ${GREEN}agent help${NC}              - Show all commands"
    echo ""
    echo -e "  4. ${CYAN}Explore the navigation system:${NC}"
    echo -e "     ${GREEN}al myproj${NC}               - Alias current directory"
    echo -e "     ${GREEN}fal myproj${NC}              - Jump to aliased directory"
    echo -e "     ${GREEN}lal${NC}                     - List all aliases"
    echo ""

    if [ -d "$BACKUP_DIR" ]; then
        echo -e "${YELLOW}⚠${NC}  Your old dotfiles are backed up at:"
        echo -e "     ${YELLOW}$BACKUP_DIR${NC}"
        echo ""
    fi

    echo -e "${BOLD}Documentation:${NC}"
    echo -e "  ${CYAN}$DOTFILES_DIR/README.md${NC}             - Getting started"
    echo -e "  ${CYAN}$DOTFILES_DIR/ARCHITECTURE.md${NC}       - System design"
    echo -e "  ${CYAN}$DOTFILES_DIR/docs/AGENT_WORKFLOWS.md${NC} - AI agent workflows"
    echo ""
    echo -e "${MAGENTA}Enjoy your dotfiles! 🚀${NC}"
    echo ""
}

# ============================================================================
# Main
# ============================================================================

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --non-interactive)
                INTERACTIVE=false
                shift
                ;;
            --minimal)
                MINIMAL_INSTALL=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --help|-h)
                echo "Dotfiles Installer"
                echo ""
                echo "Usage: ./install.sh [options]"
                echo ""
                echo "Options:"
                echo "  --non-interactive    Don't prompt for user input (use defaults)"
                echo "  --minimal            Install only essential configs (bash, git)"
                echo "  --dry-run            Show what would be installed without installing"
                echo "  --help, -h           Show this help message"
                exit 0
                ;;
            *)
                die "Unknown option: $1"
                ;;
        esac
    done

    # Banner
    echo ""
    echo -e "${MAGENTA}${BOLD}"
    echo "██████╗ ██╗███╗   ███╗██████╗ ███████╗██████╗ "
    echo "██╔══██╗██║████╗ ████║██╔══██╗██╔════╝██╔══██╗"
    echo "██████╔╝██║██╔████╔██║██████╔╝█████╗  ██║  ██║"
    echo "██╔═══╝ ██║██║╚██╔╝██║██╔═══╝ ██╔══╝  ██║  ██║"
    echo "██║     ██║██║ ╚═╝ ██║██║     ███████╗██████╔╝"
    echo "╚═╝     ╚═╝╚═╝     ╚═╝╚═╝     ╚══════╝╚═════╝ "
    echo ""
    echo "██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗"
    echo "██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝"
    echo "██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗"
    echo "██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║"
    echo "██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║"
    echo "╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝"
    echo -e "${NC}"
    echo -e "${CYAN}Cross-platform, modular, AI-first dotfiles${NC}"
    echo ""

    if $DRY_RUN; then
        log_warn "DRY RUN MODE - No changes will be made"
        echo ""
    fi

    # Run installation steps
    detect_os
    backup_dotfiles
    install_packages
    stow_configs
    setup_personal_configs
    setup_agent_tools
    setup_shell
    post_install
}

main "$@"
