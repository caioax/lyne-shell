#!/bin/bash
# =============================================================================
# Stow Setup - Symlink Dotfiles
# =============================================================================
# Uses GNU Stow to create dotfile symlinks
# =============================================================================

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${CYAN}[>>]${NC} $1"; }

# =============================================================================
# Directories to stow
# =============================================================================
STOW_DIRS=(
    "hyprland"      # Hyprland config
    "quickshell"    # QuickShell bar
    "kitty"         # Terminal
    "nvim"          # Editor
    "zsh"           # Shell
    "tmux"          # Multiplexer
    "local"         # Local scripts
    "fastfetch"     # System info
    "kde"           # KDE globals (terminal, fonts, icons)
    "theming"       # Qt5/Qt6/GTK theme configuration
)

# =============================================================================
# Check if stow is installed
# =============================================================================
check_stow() {
    if ! command -v stow &>/dev/null; then
        log_error "GNU Stow is not installed!"
        log_info "Install with: sudo pacman -S stow"
        return 1
    fi
    return 0
}

# =============================================================================
# Create required directories
# =============================================================================
create_dirs() {
    log_info "Creating required directories..."
    mkdir -p "$HOME/.config"
    mkdir -p "$HOME/.local/scripts"
    mkdir -p "$HOME/.local/bin"
}

# =============================================================================
# Get stow targets for each directory
# =============================================================================
get_stow_targets() {
    local dir=$1
    local targets=()

    case "$dir" in
        "hyprland")
            targets+=("$HOME/.config/hypr" "$HOME/.config/uwsm")
            ;;
        "zsh")
            targets+=("$HOME/.zshrc" "$HOME/.p10k.zsh")
            ;;
        "tmux")
            targets+=("$HOME/.tmux.conf")
            ;;
        "local")
            targets+=("$HOME/.local/scripts" "$HOME/.local/wallpapers" "$HOME/.local/themes")
            ;;
        "kde")
            targets+=("$HOME/.config/kdeglobals")
            ;;
        "theming")
            targets+=("$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0" "$HOME/.config/qt5ct" "$HOME/.config/qt6ct")
            ;;
        *)
            targets+=("$HOME/.config/${dir}")
            ;;
    esac

    echo "${targets[@]}"
}

# =============================================================================
# Remove existing targets with confirmation
# =============================================================================
remove_existing_targets() {
    log_info "Checking existing targets..."

    local ITEMS_TO_REMOVE=()

    # Collect all existing items
    for dir in "${STOW_DIRS[@]}"; do
        local targets
        targets=($(get_stow_targets "$dir"))

        for target in "${targets[@]}"; do
            if [[ -e "$target" || -L "$target" ]]; then
                ITEMS_TO_REMOVE+=("$target")
            fi
        done
    done

    # If no items to remove, return
    if [[ ${#ITEMS_TO_REMOVE[@]} -eq 0 ]]; then
        log_info "No existing targets found. Ready for stow!"
        return 0
    fi

    # Show found items
    echo ""
    log_warn "The following target files/directories were found:"
    echo ""
    for item in "${ITEMS_TO_REMOVE[@]}"; do
        if [[ -L "$item" ]]; then
            echo -e "  ${CYAN}[symlink]${NC} $item"
        elif [[ -d "$item" ]]; then
            echo -e "  ${YELLOW}[dir]${NC}     $item"
        else
            echo -e "  ${GREEN}[file]${NC}    $item"
        fi
    done
    echo ""

    # Ask for confirmation
    echo -ne "${RED}Do you want to REMOVE these items to create new symlinks? [Y/n]: ${NC}"
    read -r confirm

    if [[ ! $confirm =~ ^[Nn]$ ]]; then
        log_info "Removing existing targets..."
        for item in "${ITEMS_TO_REMOVE[@]}"; do
            if [[ -e "$item" || -L "$item" ]]; then
                log_step "  Removing: $item"
                rm -rf "$item"
            fi
        done
        log_info "Targets removed successfully!"
    else
        log_error "Removal cancelled. Stow cannot create symlinks over existing files."
        log_info "Remove the files manually or run the script again."
        return 1
    fi
}

# =============================================================================
# Execute stow
# =============================================================================
execute_stow() {
    log_info "Running stow to create symlinks..."

    cd "$DOTFILES_DIR"

    for dir in "${STOW_DIRS[@]}"; do
        if [[ -d "$dir" ]]; then
            log_step "  Stowing: $dir"
            if ! stow -R "$dir" 2>&1; then
                log_error "    Failed to stow $dir"
                log_info "    Check for conflicts and try again."
            fi
        else
            log_warn "  Directory not found: $dir"
        fi
    done

    log_info "Symlinks created successfully!"
}

# =============================================================================
# Main (for direct execution)
# =============================================================================
run_stow_main() {
    echo ""
    echo "=================================================="
    echo "       Stow Setup - Symlink Dotfiles"
    echo "=================================================="
    echo ""

    if ! check_stow; then
        return 1
    fi

    create_dirs

    if ! remove_existing_targets; then
        return 1
    fi

    execute_stow

    echo ""
    log_info "Stow completed successfully!"
    echo ""
}

# Run if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_stow_main "$@"
fi
