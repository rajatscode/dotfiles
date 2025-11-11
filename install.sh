#!/usr/bin/env bash

# Dotfiles Installer
# Interactive, cross-platform, modular dotfiles installation
#
# Usage: ./install.sh [--non-interactive] [--minimal]

set -e

# ============================================================================
# Configuration
# ============================================================================

DOTFILES_REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$HOME/.dotfiles"

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
        printf "${BLUE}[?]${NC} %s [y/n] " "$1"
        read yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# ============================================================================
# Sync Dotfiles to Installation Directory
# ============================================================================

sync_dotfiles() {
    log_header "Syncing Dotfiles to Installation Directory"

    if [ -d "$DOTFILES_DIR/.git" ]; then
        log_step "Updating existing installation at $DOTFILES_DIR..."

        # Fetch and pull latest changes
        if git -C "$DOTFILES_DIR" fetch origin && git -C "$DOTFILES_DIR" pull origin main 2>&1; then
            log_success "Dotfiles updated from remote"
        else
            log_warn "Could not update from remote, using existing installation"
        fi
    else
        log_step "Cloning dotfiles to $DOTFILES_DIR..."

        # Remove if exists but not a git repo
        if [ -d "$DOTFILES_DIR" ]; then
            log_warn "Removing non-git directory at $DOTFILES_DIR"
            rm -rf "$DOTFILES_DIR"
        fi

        # Clone the repo
        if git clone "$DOTFILES_REPO" "$DOTFILES_DIR"; then
            log_success "Dotfiles cloned to $DOTFILES_DIR"
        else
            log_error "Failed to clone dotfiles"
            die "Could not set up dotfiles installation directory"
        fi
    fi

    log_info "Installation directory: $DOTFILES_DIR"
    log_info "Repository directory: $DOTFILES_REPO"
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
# Check for Existing Dotfiles
# ============================================================================

check_existing_dotfiles() {
    log_header "Checking for Existing Dotfiles"

    local existing_files=()

    for file in ".bashrc" ".gitconfig" ".vimrc" ".tmux.conf"; do
        if [ -e "$HOME/$file" ] && [ ! -L "$HOME/$file" ]; then
            existing_files+=("$file")
        fi
    done

    if [ ${#existing_files[@]} -gt 0 ]; then
        log_warn "Found existing dotfiles that will be replaced by stow:"
        for file in "${existing_files[@]}"; do
            echo "  - ~/$file"
        done
        echo ""
        log_info "Stow will overwrite these files with symlinks to the dotfiles repo."
        log_info "Back them up manually if needed, then remove them before continuing."
        echo ""

        if ! ask_user "Continue with installation?"; then
            log_info "Installation cancelled. Please back up your dotfiles and try again."
            exit 0
        fi
    else
        log_info "No conflicting dotfiles found."
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
# Loader Configuration (New Pattern)
# ============================================================================

# Helper function to backup existing config files
backup_existing_config() {
    local config_file="$1"
    local backup_dir="$HOME/.dotfiles_backup_$(date +%Y%m%d)"

    if [ -e "$config_file" ] || [ -L "$config_file" ]; then
        mkdir -p "$backup_dir"
        local backup_file="$backup_dir/$(basename "$config_file")"

        if [ -L "$config_file" ]; then
            log_info "  → Removing old symlink: $config_file"
            rm "$config_file"
        else
            log_info "  → Backing up to: $backup_file"
            cp -a "$config_file" "$backup_file"
            rm "$config_file"
        fi
    fi
}

# Install loader file for a specific module
install_loader() {
    local module="$1"
    local target_file="$2"
    local loader_template="$3"

    if [ ! -f "$DOTFILES_DIR/templates/loaders/$loader_template" ]; then
        log_warn "Loader template not found: $loader_template"
        return 1
    fi

    # Create parent directory if needed
    mkdir -p "$(dirname "$target_file")"

    # Backup existing config
    backup_existing_config "$target_file"

    # Install loader
    cp "$DOTFILES_DIR/templates/loaders/$loader_template" "$target_file"

    # Set DOTFILES_DIR in the loader if not already set
    if ! grep -q "export DOTFILES_DIR=" "$target_file" 2>/dev/null; then
        sed -i "1i export DOTFILES_DIR=\"$DOTFILES_DIR\"" "$target_file" 2>/dev/null || true
    fi

    log_success "  → Installed loader: $target_file"
}

install_configs() {
    log_header "Installing Configuration Loaders"

    log_info "${BOLD}${CYAN}New Pattern: Loaders instead of Symlinks${NC}"
    echo ""
    echo "This installation uses a new pattern where your config files"
    echo "source the dotfiles instead of being symlinked."
    echo ""
    echo "Benefits:"
    echo "  ✓ External tools (npm, pnpm, etc.) can safely modify your configs"
    echo "  ✓ Your dotfiles git repo stays clean"
    echo "  ✓ Easy to add local customizations"
    echo ""

    # Define available modules by category
    local shell_modules=("bash" "zsh" "fish")
    local vcs_modules=("git" "hg" "jj")
    local editor_modules=("vim" "nvim")
    local other_modules=("tmux" "starship")
    local selected_modules=()

    if $MINIMAL_INSTALL; then
        selected_modules=("bash" "git")
    else
        # Shell selection
        log_info "\n${BOLD}Shell Configuration:${NC}"
        echo "Select which shells to configure (you can choose multiple):"
        for module in "${shell_modules[@]}"; do
            if ask_user "Install $module config?"; then
                selected_modules+=("$module")
            fi
        done

        # VCS selection
        log_info "\n${BOLD}Version Control Systems:${NC}"
        echo "Select which VCS to configure:"
        for module in "${vcs_modules[@]}"; do
            if ask_user "Install $module config?"; then
                selected_modules+=("$module")
            fi
        done

        # Editor selection
        log_info "\n${BOLD}Text Editors:${NC}"
        echo "Select which editors to configure:"
        for module in "${editor_modules[@]}"; do
            if ask_user "Install $module config?"; then
                selected_modules+=("$module")
            fi
        done

        # Other tools
        log_info "\n${BOLD}Other Tools:${NC}"
        for module in "${other_modules[@]}"; do
            if ask_user "Install $module config?"; then
                selected_modules+=("$module")
            fi
        done
    fi

    # Install loaders for selected modules
    log_step "Installing configuration loaders..."

    for module in "${selected_modules[@]}"; do
        log_info "Installing: $module"

        case "$module" in
            bash)
                install_loader "bash" "$HOME/.bashrc" "bashrc"
                ;;
            zsh)
                install_loader "zsh" "$HOME/.zshrc" "zshrc"
                ;;
            fish)
                install_loader "fish" "$HOME/.config/fish/config.fish" "config.fish"
                ;;
            vim)
                install_loader "vim" "$HOME/.vimrc" "vimrc"
                ;;
            nvim)
                install_loader "nvim" "$HOME/.config/nvim/init.lua" "init.lua"
                ;;
            git)
                install_loader "git" "$HOME/.gitconfig" "gitconfig"
                ;;
            tmux)
                install_loader "tmux" "$HOME/.tmux.conf" "tmux.conf"
                ;;
            starship)
                # Starship doesn't support file inclusion, so we copy the config
                log_info "  → Starship uses direct copy (no file inclusion support)"
                if [ -f "$DOTFILES_DIR/common/starship/.config/starship.toml" ]; then
                    mkdir -p "$HOME/.config"
                    backup_existing_config "$HOME/.config/starship.toml"
                    cp "$DOTFILES_DIR/common/starship/.config/starship.toml" "$HOME/.config/starship.toml"
                    log_success "  → Copied starship config"
                fi
                ;;
            hg)
                # Mercurial config can use %include directive
                if [ -f "$DOTFILES_DIR/common/hg/.hgrc" ]; then
                    backup_existing_config "$HOME/.hgrc"
                    echo "%include $DOTFILES_DIR/common/hg/.hgrc" > "$HOME/.hgrc"
                    log_success "  → Installed hg config with %include"
                fi
                ;;
            jj)
                # Jujutsu config - copy for now
                if [ -f "$DOTFILES_DIR/common/jj/.jjconfig.toml" ]; then
                    mkdir -p "$HOME/.config/jj"
                    backup_existing_config "$HOME/.config/jj/config.toml"
                    cp "$DOTFILES_DIR/common/jj/.jjconfig.toml" "$HOME/.config/jj/config.toml"
                    log_success "  → Copied jj config"
                fi
                ;;
            *)
                log_warn "Unknown module: $module"
                ;;
        esac
    done

    log_success "Configuration loaders installed"
    log_info ""
    log_info "${CYAN}Note: Your old configs have been backed up to ~/.dotfiles_backup_*${NC}"
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

    # NOTE: With the new loader pattern, personal configs go directly in the config files
    # (e.g., ~/.bashrc, ~/.zshrc, ~/.config/fish/config.fish) after the dotfiles source line
    # We no longer create separate .bash_profile, .zsh_profile, personal.fish files

    log_info ""
    log_info "${CYAN}Local Customizations:${NC}"
    log_info "Add your personal configs directly to your config files:"
    log_info "  • ~/.bashrc    - bash customizations"
    log_info "  • ~/.zshrc     - zsh customizations"
    log_info "  • ~/.config/fish/config.fish - fish customizations"
    log_info "  • ~/.vimrc     - vim customizations"
    log_info "  • ~/.gitconfig - git customizations"
    log_info ""
    log_info "All files have a section for local customizations after the dotfiles source."

    # VCS personal configs
    if [ ! -f "$HOME/.hgrc_personal" ] && [ -f "$HOME/.hgrc" ]; then
        cat > "$HOME/.hgrc_personal" <<EOF
# Personal Mercurial configuration
[ui]
username = Your Name <your@email.com>
EOF
        log_success "Created ~/.hgrc_personal"
    fi
}

# ============================================================================
# Setup Vim and Vundle
# ============================================================================

setup_vim() {
    log_header "Vim Plugin Manager Setup"

    # Check if vim config was installed
    if [ ! -f "$HOME/.vimrc" ]; then
        log_info "Vim config not installed, skipping Vundle setup"
        return
    fi

    # Check if Vundle is already installed
    if [ -d "$HOME/.vim/bundle/Vundle.vim" ]; then
        log_info "Vundle already installed"
        if ask_user "Update Vundle plugins?"; then
            log_step "Updating Vundle plugins..."
            vim +PluginUpdate +qall
            log_success "Vundle plugins updated"

            # Compile YouCompleteMe if it was installed/updated
            if [ -d "$HOME/.vim/bundle/YouCompleteMe" ] && [ -f "$HOME/.vim/bundle/YouCompleteMe/install.py" ]; then
                # Check if already compiled
                if compgen -G "$HOME/.vim/bundle/YouCompleteMe/third_party/ycmd/ycm_core*.so" > /dev/null; then
                    log_info "YouCompleteMe already compiled, skipping"
                elif ! command -v cmake >/dev/null 2>&1; then
                    log_warn "cmake not found - skipping YouCompleteMe compilation"
                    log_info "Install cmake: brew install cmake (macOS) or apt install cmake (Linux)"
                else
                    log_step "Compiling YouCompleteMe..."
                    # Use --ts-completer --clangd-completer instead of --all (Go support is broken)
                    if (cd "$HOME/.vim/bundle/YouCompleteMe" && python3 install.py --ts-completer --clangd-completer 2>&1); then
                        log_success "YouCompleteMe compiled successfully"
                    else
                        log_warn "YouCompleteMe compilation failed - you may need to run it manually"
                    fi
                fi
            fi
        fi
    else
        if ask_user "Install Vundle (Vim plugin manager)?"; then
            log_step "Installing Vundle..."

            # Create bundle directory
            mkdir -p "$HOME/.vim/bundle"

            # Clone Vundle
            git clone https://github.com/VundleVim/Vundle.vim.git "$HOME/.vim/bundle/Vundle.vim"

            if [ $? -eq 0 ]; then
                log_success "Vundle installed successfully"

                # Install plugins
                log_step "Installing Vim plugins (this may take a few minutes)..."
                vim +PluginInstall +qall
                log_success "Vim plugins installed"

                # Compile YouCompleteMe if it was installed
                if [ -d "$HOME/.vim/bundle/YouCompleteMe" ] && [ -f "$HOME/.vim/bundle/YouCompleteMe/install.py" ]; then
                    # Check if already compiled
                    if compgen -G "$HOME/.vim/bundle/YouCompleteMe/third_party/ycmd/ycm_core*.so" > /dev/null; then
                        log_info "YouCompleteMe already compiled, skipping"
                    elif ! command -v cmake >/dev/null 2>&1; then
                        log_warn "cmake not found - skipping YouCompleteMe compilation"
                        log_info "Install cmake: brew install cmake (macOS) or apt install cmake (Linux)"
                    else
                        log_step "Compiling YouCompleteMe (this may take a few minutes)..."
                        # Use --ts-completer --clangd-completer instead of --all (Go support is broken)
                        if (cd "$HOME/.vim/bundle/YouCompleteMe" && python3 install.py --ts-completer --clangd-completer 2>&1); then
                            log_success "YouCompleteMe compiled successfully"
                        else
                            log_warn "YouCompleteMe compilation failed - you may need to run it manually"
                        fi
                    fi
                fi

                log_info "Run ':PluginUpdate' in Vim to update plugins"
            else
                log_error "Failed to install Vundle"
                return 1
            fi
        else
            log_warn "Skipping Vundle installation"
            log_warn "Note: .vimrc expects Vundle to be installed. Vim may show errors."
        fi
    fi
}

# ============================================================================
# Setup Ollama AI Code Completion
# ============================================================================

setup_ollama() {
    log_header "Ollama AI Code Completion Setup"

    # Check if vim-ollama plugin is configured
    if [ ! -f "$HOME/.vimrc" ] || ! grep -q "vim-ollama" "$HOME/.vimrc" 2>/dev/null; then
        log_info "vim-ollama not configured, skipping Ollama setup"
        return
    fi

    # Check if ollama is installed
    if ! command -v ollama >/dev/null 2>&1; then
        log_warn "Ollama not installed. Install it via Brewfile first."
        return
    fi

    log_info "Setting up Ollama for local AI code completion"

    # Start Ollama service (macOS with Homebrew)
    if [ "$OS_TYPE" = "macos" ]; then
        if ask_user "Start Ollama service automatically on boot?"; then
            log_step "Starting Ollama service..."
            brew services start ollama
            log_success "Ollama service started and enabled on boot"

            # Wait for service to be ready
            log_step "Waiting for Ollama to be ready..."
            sleep 2
        else
            log_warn "You'll need to start Ollama manually with: ollama serve"
            if ask_user "Start Ollama now for model download?"; then
                ollama serve &
                sleep 2
            else
                log_info "Skipping model download (Ollama not running)"
                return
            fi
        fi
    fi

    # Download recommended model
    if ask_user "Download qwen2.5-coder:7b model (~4.7GB)?"; then
        log_step "Downloading qwen2.5-coder:7b (this may take a few minutes)..."
        ollama pull qwen2.5-coder:7b
        log_success "Model downloaded successfully"

        log_info "AI code completion is now ready in Vim!"
        log_info "Press Tab to accept suggestions while typing"
    else
        log_info "Skipping model download"
        log_info "To download later, run: ollama pull qwen2.5-coder:7b"
    fi

    log_success "Ollama setup complete"
}

# ============================================================================
# Setup Shell
# ============================================================================

setup_shell() {
    log_header "Shell Configuration"

    local desired_shell=""

    # Ask user which shell they want as default
    log_info "Which shell would you like to use as your default?"
    echo "  1) bash (default)"
    echo "  2) zsh"
    echo "  3) fish"
    echo ""
    printf "${BLUE}[?]${NC} Enter choice [1-3]: "
    read shell_choice

    case $shell_choice in
        2)
            if command -v zsh >/dev/null 2>&1; then
                desired_shell="zsh"
            else
                log_warn "zsh not installed, falling back to bash"
                desired_shell="bash"
            fi
            ;;
        3)
            if command -v fish >/dev/null 2>&1; then
                desired_shell="fish"
            else
                log_warn "fish not installed, falling back to bash"
                desired_shell="bash"
            fi
            ;;
        *)
            desired_shell="bash"
            ;;
    esac

    # Change default shell if needed
    if [ -n "$desired_shell" ] && [ "$desired_shell" != "bash" ]; then
        local shell_path=$(command -v $desired_shell)

        # Add shell to /etc/shells if not present
        if ! grep -q "$shell_path" /etc/shells 2>/dev/null; then
            log_info "Adding $desired_shell to /etc/shells..."
            echo "$shell_path" | sudo tee -a /etc/shells
        fi

        # Change default shell
        if [ "$SHELL" != "$shell_path" ]; then
            log_info "Changing default shell to $desired_shell..."
            chsh -s "$shell_path"
            log_success "Default shell changed to $desired_shell"
            log_info "Please restart your terminal for changes to take effect"
        else
            log_info "$desired_shell is already your default shell"
        fi
    else
        log_info "Using bash as default shell"
    fi

    # Give instructions for current session
    case $desired_shell in
        bash)
            log_info "To activate config in this session: source ~/.bashrc"
            ;;
        zsh)
            log_info "To activate config in this session: source ~/.zshrc"
            ;;
        fish)
            log_info "To activate config in this session: restart your terminal or run 'exec fish'"
            ;;
    esac
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

        # Check shepherd dependencies
        log_step "Checking agent shepherd dependencies..."
        local missing_deps=()

        if ! command -v gh >/dev/null 2>&1; then
            missing_deps+=("gh (GitHub CLI)")
        fi

        if ! command -v jq >/dev/null 2>&1; then
            missing_deps+=("jq (JSON processor)")
        fi

        if [ ${#missing_deps[@]} -gt 0 ]; then
            log_warn "Some shepherd dependencies are missing:"
            for dep in "${missing_deps[@]}"; do
                echo "  - $dep"
            done
            echo ""
            log_info "These will be installed when you run the package installation step."
            log_info "Or install manually:"
            case "$PKG_MANAGER" in
                apt)
                    log_info "  sudo apt install gh jq"
                    ;;
                brew)
                    log_info "  brew install gh jq"
                    ;;
                pacman)
                    log_info "  sudo pacman -S github-cli jq"
                    ;;
            esac
            echo ""
            log_info "After installing dependencies, run: gh auth login"
        else
            log_success "All shepherd dependencies are installed"

            # Check gh authentication
            if ! gh auth status >/dev/null 2>&1; then
                log_warn "GitHub CLI is not authenticated"
                log_info "Run 'gh auth login' to authenticate for shepherd to work"
            else
                log_success "GitHub CLI is authenticated"
            fi
        fi

        log_success "Agent tools installed"
        log_info "Available commands: agent, agent-shepherd-analyze, worktree-clean, context-sync"
        log_info "Run 'agent help' to get started with multi-agent workflows"
        log_info "Run 'agent shepherd --help' to learn about PR review automation"
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

    # Shell-specific activation instructions
    echo -e "  1. ${CYAN}Restart your terminal${NC} or activate your shell config:"
    if [ -f "$HOME/.config/fish/config.fish" ]; then
        echo -e "     ${GREEN}exec fish${NC}                    (fish shell - recommended: just restart terminal)"
    fi
    if [ -f "$HOME/.zshrc" ]; then
        echo -e "     ${GREEN}source ~/.zshrc${NC}              (zsh shell)"
    fi
    if [ -f "$HOME/.bashrc" ]; then
        echo -e "     ${GREEN}source ~/.bashrc${NC}             (bash shell)"
    fi
    echo ""

    echo -e "  2. ${CYAN}Edit your personal configs:${NC}"
    echo -e "     ${YELLOW}~/.gitprofile${NC}                - Git name/email"
    if [ -f "$HOME/.bash_profile" ]; then
        echo -e "     ${YELLOW}~/.bash_profile${NC}              - Personal bash config"
    fi
    if [ -f "$HOME/.zsh_profile" ]; then
        echo -e "     ${YELLOW}~/.zsh_profile${NC}               - Personal zsh config"
    fi
    if [ -f "$HOME/.config/fish/personal.fish" ]; then
        echo -e "     ${YELLOW}~/.config/fish/personal.fish${NC} - Personal fish config"
    fi
    echo ""

    echo -e "  3. ${CYAN}Try the AI agent tools:${NC}"
    echo -e "     ${GREEN}agent new my-feature${NC}    - Create a new agent session"
    echo -e "     ${GREEN}agent list${NC}              - List active sessions"
    echo -e "     ${GREEN}agent shepherd${NC}          - Address PR review comments"
    echo -e "     ${GREEN}agent help${NC}              - Show all commands"
    echo ""

    echo -e "  4. ${CYAN}Explore the navigation system:${NC}"
    echo -e "     ${GREEN}al myproj${NC}               - Alias current directory"
    echo -e "     ${GREEN}fal myproj${NC}              - Jump to aliased directory"
    echo -e "     ${GREEN}lal${NC}                     - List all aliases"
    echo ""

    echo -e "${BOLD}Documentation:${NC}"
    echo -e "  ${CYAN}$DOTFILES_DIR/README.md${NC}             - Getting started"
    echo -e "  ${CYAN}$DOTFILES_DIR/ARCHITECTURE.md${NC}       - System design"
    echo -e "  ${CYAN}$DOTFILES_DIR/docs/AGENT_WORKFLOWS.md${NC} - AI agent workflows"
    echo -e "  ${CYAN}$DOTFILES_DIR/docs/SHEPHERD.md${NC}      - PR review automation"
    echo ""

    echo -e "${BOLD}Troubleshooting:${NC}"
    echo -e "  ${CYAN}If 'agent' command not found:${NC}"
    echo -e "  - Restart your terminal (recommended)"
    echo -e "  - Or check: ${GREEN}echo \$PATH${NC} should include ${YELLOW}$DOTFILES_DIR/bin${NC}"
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
    echo -e "${MAGENTA}${BOLD}Dotfiles Installer${NC}"
    echo ""

    if $DRY_RUN; then
        log_warn "DRY RUN MODE - No changes will be made"
        echo ""
    fi

    # Run installation steps
    sync_dotfiles
    detect_os
    check_existing_dotfiles
    install_packages
    install_configs  # NEW: Use loader pattern instead of stow
    setup_personal_configs
    setup_vim
    setup_ollama
    setup_agent_tools
    setup_shell
    post_install
}

main "$@"
