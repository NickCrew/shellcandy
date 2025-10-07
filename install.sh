#!/usr/bin/env bash
# ShellCandy Installation Script
#
# Quick install: curl -fsSL https://raw.githubusercontent.com/YOUR_ORG/shellcandy/main/install.sh | bash
#
# Manual install:
#   wget https://raw.githubusercontent.com/YOUR_ORG/shellcandy/main/install.sh
#   bash install.sh

set -e

# Configuration
SHELLCANDY_VERSION="2.0.0"
SHELLCANDY_REPO="YOUR_ORG/shellcandy"
INSTALL_DIR="${SHELLCANDY_INSTALL_DIR:-$HOME/.shellcandy}"
BIN_DIR="${SHELLCANDY_BIN_DIR:-$HOME/.local/bin}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ============================================================================
# Helper Functions
# ============================================================================

info() {
    echo -e "${BLUE}ℹ${NC} $*"
}

success() {
    echo -e "${GREEN}✓${NC} $*"
}

error() {
    echo -e "${RED}✗${NC} $*" >&2
}

warning() {
    echo -e "${YELLOW}⚠${NC} $*"
}

header() {
    echo ""
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}${BOLD}  $*${NC}"
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# ============================================================================
# Pre-flight Checks
# ============================================================================

check_bash_version() {
    if [ -z "$BASH_VERSION" ]; then
        error "This script requires Bash"
        exit 1
    fi

    local major="${BASH_VERSINFO[0]}"
    local minor="${BASH_VERSINFO[1]}"

    if [ "$major" -lt 4 ]; then
        error "ShellCandy requires Bash 4.0 or later (you have $BASH_VERSION)"
        warning "On macOS: brew install bash"
        exit 1
    fi

    success "Bash version: $BASH_VERSION"
}

check_commands() {
    local missing=()

    for cmd in git curl tar; do
        if ! command -v "$cmd" &> /dev/null; then
            missing+=("$cmd")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        error "Missing required commands: ${missing[*]}"
        exit 1
    fi

    success "All required commands available"
}

# ============================================================================
# Installation Methods
# ============================================================================

install_from_git() {
    info "Installing from Git repository..."

    if [ -d "$INSTALL_DIR" ]; then
        warning "Installation directory already exists: $INSTALL_DIR"
        read -p "Overwrite? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            error "Installation cancelled"
            exit 1
        fi
        rm -rf "$INSTALL_DIR"
    fi

    info "Cloning repository to $INSTALL_DIR..."
    git clone --depth 1 "https://github.com/${SHELLCANDY_REPO}.git" "$INSTALL_DIR"

    success "Repository cloned"
}

install_from_tarball() {
    info "Installing from release tarball..."

    local tarball_url="https://github.com/${SHELLCANDY_REPO}/archive/refs/tags/v${SHELLCANDY_VERSION}.tar.gz"
    local temp_dir=$(mktemp -d)

    info "Downloading ShellCandy v${SHELLCANDY_VERSION}..."
    curl -fsSL "$tarball_url" | tar -xz -C "$temp_dir"

    if [ -d "$INSTALL_DIR" ]; then
        rm -rf "$INSTALL_DIR"
    fi

    mv "$temp_dir/shellcandy-${SHELLCANDY_VERSION}" "$INSTALL_DIR"
    rm -rf "$temp_dir"

    success "Downloaded and extracted"
}

# ============================================================================
# Setup
# ============================================================================

setup_symlinks() {
    info "Setting up command-line tools..."

    mkdir -p "$BIN_DIR"

    # Link shellcandy CLI tool if it exists
    if [ -f "$INSTALL_DIR/bin/shellcandy" ]; then
        ln -sf "$INSTALL_DIR/bin/shellcandy" "$BIN_DIR/shellcandy"
        chmod +x "$BIN_DIR/shellcandy"
        success "Linked: shellcandy CLI tool"
    fi

    # Link validation and benchmark tools
    ln -sf "$INSTALL_DIR/lib/tools/validate.sh" "$BIN_DIR/shellcandy-validate"
    ln -sf "$INSTALL_DIR/lib/tools/benchmark.sh" "$BIN_DIR/shellcandy-benchmark"
    chmod +x "$BIN_DIR/shellcandy-validate"
    chmod +x "$BIN_DIR/shellcandy-benchmark"

    success "Linked: validation and benchmark tools"
}

setup_shell_integration() {
    info "Setting up shell integration..."

    local shell_rc=""
    local shell_name=$(basename "$SHELL")

    case "$shell_name" in
        bash)
            shell_rc="$HOME/.bashrc"
            ;;
        zsh)
            shell_rc="$HOME/.zshrc"
            ;;
        fish)
            shell_rc="$HOME/.config/fish/config.fish"
            ;;
        *)
            warning "Unknown shell: $shell_name (skipping shell integration)"
            return
            ;;
    esac

    if [ ! -f "$shell_rc" ]; then
        warning "Shell RC file not found: $shell_rc (skipping)"
        return
    fi

    # Check if already added
    if grep -q "SHELLCANDY_HOME" "$shell_rc" 2>/dev/null; then
        info "Shell integration already configured in $shell_rc"
        return
    fi

    # Add to shell RC
    cat >> "$shell_rc" << EOF

# ShellCandy Framework
export SHELLCANDY_HOME="$INSTALL_DIR"
export PATH="\$PATH:$BIN_DIR"

# Quick alias to load ShellCandy
alias shellcandy='source "\$SHELLCANDY_HOME/lib/shellcandy.sh"'
EOF

    success "Added to $shell_rc"
    warning "Run 'source $shell_rc' or restart your shell to apply changes"
}

# ============================================================================
# Verification
# ============================================================================

verify_installation() {
    info "Verifying installation..."

    # Check installation directory
    if [ ! -d "$INSTALL_DIR/lib" ]; then
        error "Installation failed: lib directory not found"
        exit 1
    fi

    # Check modules
    local modules=(colors logging progress icons boxes tables prompts menus charts)
    for module in "${modules[@]}"; do
        if [ ! -f "$INSTALL_DIR/lib/modules/${module}.sh" ]; then
            error "Module missing: ${module}.sh"
            exit 1
        fi
    done

    success "All modules present"

    # Run validation tests
    if [ -x "$INSTALL_DIR/lib/tools/validate.sh" ]; then
        info "Running validation tests..."
        if "$INSTALL_DIR/lib/tools/validate.sh" > /dev/null 2>&1; then
            success "Validation tests passed"
        else
            warning "Some validation tests failed (this may be normal)"
        fi
    fi
}

# ============================================================================
# Post-install
# ============================================================================

show_completion_message() {
    header "🎉 ShellCandy Installed Successfully!"

    cat << EOF
${GREEN}Installation Details:${NC}
  📁 Install directory: ${CYAN}$INSTALL_DIR${NC}
  🔧 Binary directory:  ${CYAN}$BIN_DIR${NC}
  📚 Version:          ${CYAN}$SHELLCANDY_VERSION${NC}

${GREEN}Quick Start:${NC}
  ${BOLD}1. Load ShellCandy in your script:${NC}
     ${CYAN}source $INSTALL_DIR/lib/shellcandy.sh${NC}

  ${BOLD}2. Or use the alias:${NC}
     ${CYAN}shellcandy${NC}

  ${BOLD}3. Try an example:${NC}
     ${CYAN}$INSTALL_DIR/examples/ultimate-dashboard.sh${NC}

${GREEN}Available Commands:${NC}
  ${CYAN}shellcandy${NC}          - CLI tool for project scaffolding
  ${CYAN}shellcandy-validate${NC}  - Run validation tests
  ${CYAN}shellcandy-benchmark${NC} - Run performance benchmarks

${GREEN}Documentation:${NC}
  📖 Main README:     ${CYAN}$INSTALL_DIR/lib/README.md${NC}
  📊 Testing Guide:   ${CYAN}$INSTALL_DIR/lib/TESTING.md${NC}
  ⚡ Optimization:    ${CYAN}$INSTALL_DIR/lib/OPTIMIZATION.md${NC}
  📝 Changelog:       ${CYAN}$INSTALL_DIR/lib/CHANGELOG.md${NC}

${GREEN}Example Usage:${NC}
  ${CYAN}#!/usr/bin/env bash
  source $INSTALL_DIR/lib/shellcandy.sh

  box_success "Hello" "Welcome to ShellCandy!"
  sc_log_info "Starting application..."
  sc_progress_bar 75 100 "Progress"${NC}

${YELLOW}⚠ Don't forget to reload your shell:${NC}
  ${CYAN}source ~/.bashrc${NC}  # or ~/.zshrc

${BLUE}For more info:${NC}
  🌐 Documentation: https://github.com/${SHELLCANDY_REPO}
  💬 Issues: https://github.com/${SHELLCANDY_REPO}/issues

${BOLD}Happy scripting! 🍭✨${NC}
EOF
}

# ============================================================================
# Main Installation
# ============================================================================

main() {
    clear

    cat << 'EOF'
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║                   ShellCandy Installation                      ║
║            Beautiful Terminal UI for Shell Scripts            ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
EOF

    echo ""
    info "Version: $SHELLCANDY_VERSION"
    info "Install directory: $INSTALL_DIR"
    info "Binary directory: $BIN_DIR"
    echo ""

    # Pre-flight checks
    header "Pre-flight Checks"
    check_bash_version
    check_commands

    # Installation
    header "Installing ShellCandy"

    # Try git first, fall back to tarball
    if command -v git &> /dev/null; then
        install_from_git
    else
        install_from_tarball
    fi

    # Setup
    header "Setting Up"
    setup_symlinks
    setup_shell_integration

    # Verification
    header "Verifying Installation"
    verify_installation

    # Done!
    show_completion_message
}

# Run main installation
main "$@"
