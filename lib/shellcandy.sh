#!/bin/bash
# shellcandy.sh - ShellCandy Framework Main Orchestrator
# Version: 1.0.0
#
# A comprehensive terminal UI framework for beautiful shell scripts
#
# Usage:
#   source lib/shellcandy.sh              # Load all modules
#   source lib/shellcandy.sh --minimal    # Load only essential modules
#   source lib/shellcandy.sh --help       # Show help
#
# Modules:
#   - colors:   Extended color system (256-color, RGB, themes)
#   - logging:  Multi-level logging with file output
#   - progress: Spinners and progress bars
#   - icons:    Status symbols and emoji collections
#   - boxes:    Beautiful aligned terminal boxes

# Prevent multiple sourcing
[[ -n "${SHELLCANDY_LOADED}" ]] && return 0

# ============================================================================
# Framework Information
# ============================================================================

export SHELLCANDY_VERSION="1.0.0"
export SHELLCANDY_AUTHOR="ThreatX WAF Demo Project"
export SHELLCANDY_LOADED=1

# Get ShellCandy lib directory
export SHELLCANDY_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ============================================================================
# Configuration
# ============================================================================

# Module loading configuration
export SHELLCANDY_LOAD_COLORS=${SHELLCANDY_LOAD_COLORS:-true}
export SHELLCANDY_LOAD_LOGGING=${SHELLCANDY_LOAD_LOGGING:-true}
export SHELLCANDY_LOAD_PROGRESS=${SHELLCANDY_LOAD_PROGRESS:-true}
export SHELLCANDY_LOAD_ICONS=${SHELLCANDY_LOAD_ICONS:-true}
export SHELLCANDY_LOAD_BOXES=${SHELLCANDY_LOAD_BOXES:-true}
export SHELLCANDY_LOAD_TABLES=${SHELLCANDY_LOAD_TABLES:-true}
export SHELLCANDY_LOAD_PROMPTS=${SHELLCANDY_LOAD_PROMPTS:-true}
export SHELLCANDY_LOAD_MENUS=${SHELLCANDY_LOAD_MENUS:-true}
export SHELLCANDY_LOAD_CHARTS=${SHELLCANDY_LOAD_CHARTS:-true}

# Check for minimal mode
if [[ "$1" == "--minimal" ]]; then
    export SHELLCANDY_LOAD_PROGRESS=false
    export SHELLCANDY_LOAD_BOXES=false
    export SHELLCANDY_LOAD_TABLES=false
    export SHELLCANDY_LOAD_PROMPTS=false
fi

# ============================================================================
# Help and Info
# ============================================================================

shellcandy_help() {
    cat << 'EOF'
╔════════════════════════════════════════════════════════════════════════════╗
║                            ShellCandy Framework                            ║
║                    Beautiful Terminal UI for Shell Scripts                ║
╚════════════════════════════════════════════════════════════════════════════╝

VERSION: 1.0.0

USAGE:
  source lib/shellcandy.sh              # Load all modules
  source lib/shellcandy.sh --minimal    # Load only essential modules
  source lib/shellcandy.sh --help       # Show this help

MODULES:
  colors    - Extended color system
              • Standard 16 colors
              • 256-color palette
              • RGB true color (24-bit)
              • Color themes
              • Gradient generation

  logging   - Multi-level logging
              • DEBUG, INFO, WARN, ERROR, FATAL levels
              • Colored console output
              • File logging with rotation
              • Timestamp support
              • Structured logging

  progress  - Progress indicators
              • Animated spinners (6 styles)
              • Progress bars
              • Percentage displays
              • ETA calculations
              • Multi-line progress

  icons     - Status symbols and emoji
              • Status icons (✓ ✗ ⚠ ℹ)
              • Arrows and pointers
              • Emoji collections
              • Colored icon functions

  boxes     - Terminal box drawing
              • Perfect alignment
              • Multiple styles
              • Emoji support
              • ANSI color support

QUICK START:
  #!/bin/bash
  source lib/shellcandy.sh

  # Use logging
  sc_log_info "Application started"

  # Show progress
  sc_progress_start 100 "Processing"
  for i in {1..100}; do
    sc_progress_update
    sleep 0.1
  done
  sc_progress_finish

  # Display status
  sc_icon_success "Operation complete"

  # Draw boxes
  box_success "Done!" "All tasks completed successfully"

ENVIRONMENT VARIABLES:
  SHELLCANDY_LOAD_COLORS    - Load colors module (default: true)
  SHELLCANDY_LOAD_LOGGING   - Load logging module (default: true)
  SHELLCANDY_LOAD_PROGRESS  - Load progress module (default: true)
  SHELLCANDY_LOAD_ICONS     - Load icons module (default: true)
  SHELLCANDY_LOAD_BOXES     - Load boxes module (default: true)

  SC_LOG_LEVEL              - Set log level (DEBUG|INFO|WARN|ERROR|FATAL)
  SC_LOG_FILE               - Set log file path
  SC_LOG_COLORS             - Enable colored output (default: true)

EXAMPLES:
  # Load only essential modules
  SHELLCANDY_LOAD_PROGRESS=false SHELLCANDY_LOAD_BOXES=false \\
    source lib/shellcandy.sh

  # Set log level to DEBUG
  SC_LOG_LEVEL=DEBUG source lib/shellcandy.sh

  # Enable file logging
  SC_LOG_FILE=/var/log/myapp.log source lib/shellcandy.sh

DOCUMENTATION:
  lib/README.md           - Box drawing documentation
  lib/colors.sh           - Color system reference
  lib/logging.sh          - Logging guide
  lib/progress.sh         - Progress indicators
  lib/icons.sh            - Icon reference

  Run individual modules directly to see examples:
    bash lib/colors.sh
    bash lib/logging.sh
    bash lib/progress.sh
    bash lib/icons.sh
    bash lib/boxes.sh

WEBSITE:
  https://github.com/YOUR_ORG/shellcandy

LICENSE:
  MIT License - Free to use in any project

EOF
}

# Show version
shellcandy_version() {
    echo "ShellCandy v${SHELLCANDY_VERSION}"
}

# Show loaded modules
shellcandy_status() {
    echo "ShellCandy Framework Status"
    echo "============================"
    echo ""
    echo "Version: $SHELLCANDY_VERSION"
    echo "Library: $SHELLCANDY_LIB_DIR"
    echo ""
    echo "Loaded Modules:"
    [[ -n "$SHELLCANDY_COLORS_LOADED" ]] && echo "  ✓ colors" || echo "  ✗ colors"
    [[ -n "$SHELLCANDY_LOGGING_LOADED" ]] && echo "  ✓ logging" || echo "  ✗ logging"
    [[ -n "$SHELLCANDY_PROGRESS_LOADED" ]] && echo "  ✓ progress" || echo "  ✗ progress"
    [[ -n "$SHELLCANDY_ICONS_LOADED" ]] && echo "  ✓ icons" || echo "  ✗ icons"
    [[ -n "$SHELLCANDY_BOXES_LOADED" ]] && echo "  ✓ boxes" || echo "  ✗ boxes"
    [[ -n "$SHELLCANDY_TABLES_LOADED" ]] && echo "  ✓ tables" || echo "  ✗ tables"
    [[ -n "$SHELLCANDY_PROMPTS_LOADED" ]] && echo "  ✓ prompts" || echo "  ✗ prompts"
    [[ -n "$SHELLCANDY_MENUS_LOADED" ]] && echo "  ✓ menus" || echo "  ✗ menus"
    [[ -n "$SHELLCANDY_CHARTS_LOADED" ]] && echo "  ✓ charts" || echo "  ✗ charts"
}

# ============================================================================
# Module Loading
# ============================================================================

# Load a module with error handling
_shellcandy_load_module() {
    local module=$1
    local module_path="${SHELLCANDY_LIB_DIR}/modules/${module}.sh"

    if [[ -f "$module_path" ]]; then
        source "$module_path"
        return 0
    else
        echo "Warning: ShellCandy module '${module}' not found at ${module_path}" >&2
        return 1
    fi
}

# Load modules based on configuration
_shellcandy_init() {
    local errors=0

    # Load colors first (other modules may depend on it)
    if [[ "$SHELLCANDY_LOAD_COLORS" == "true" ]]; then
        _shellcandy_load_module "colors" || ((errors++))
    fi

    # Load logging (may depend on colors)
    if [[ "$SHELLCANDY_LOAD_LOGGING" == "true" ]]; then
        _shellcandy_load_module "logging" || ((errors++))
    fi

    # Load icons (may depend on colors)
    if [[ "$SHELLCANDY_LOAD_ICONS" == "true" ]]; then
        _shellcandy_load_module "icons" || ((errors++))
    fi

    # Load progress (may depend on colors)
    if [[ "$SHELLCANDY_LOAD_PROGRESS" == "true" ]]; then
        _shellcandy_load_module "progress" || ((errors++))
    fi

    # Load boxes (may depend on colors)
    if [[ "$SHELLCANDY_LOAD_BOXES" == "true" ]]; then
        _shellcandy_load_module "boxes" || ((errors++))
    fi

    # Load tables (may depend on colors)
    if [[ "$SHELLCANDY_LOAD_TABLES" == "true" ]]; then
        _shellcandy_load_module "tables" || ((errors++))
    fi

    # Load prompts (may depend on colors and icons)
    if [[ "$SHELLCANDY_LOAD_PROMPTS" == "true" ]]; then
        _shellcandy_load_module "prompts" || ((errors++))
    fi

    # Load menus (may depend on colors and icons)
    if [[ "$SHELLCANDY_LOAD_MENUS" == "true" ]]; then
        _shellcandy_load_module "menus" || ((errors++))
    fi

    # Load charts (may depend on colors)
    if [[ "$SHELLCANDY_LOAD_CHARTS" == "true" ]]; then
        _shellcandy_load_module "charts" || ((errors++))
    fi

    return $errors
}

# ============================================================================
# Convenience Aliases
# ============================================================================

# Create short aliases for common functions (only if modules loaded)
_shellcandy_create_aliases() {
    # Logging aliases
    if [[ -n "$SHELLCANDY_LOGGING_LOADED" ]]; then
        alias log_debug='sc_log_debug'
        alias log_info='sc_log_info'
        alias log_warn='sc_log_warn'
        alias log_error='sc_log_error'
        alias log_success='sc_log_success'
    fi

    # Icon aliases
    if [[ -n "$SHELLCANDY_ICONS_LOADED" ]]; then
        alias icon_ok='sc_icon_success'
        alias icon_fail='sc_icon_error'
        alias icon_warn='sc_icon_warning'
    fi
}

# ============================================================================
# Handle command-line arguments when sourced
# ============================================================================

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    shellcandy_help
    return 0
fi

if [[ "$1" == "--version" || "$1" == "-v" ]]; then
    shellcandy_version
    return 0
fi

# ============================================================================
# Initialize Framework
# ============================================================================

# Load all modules
_shellcandy_init

# Create convenience aliases
# _shellcandy_create_aliases  # Commented out by default to avoid conflicts

# ============================================================================
# Example Usage (when executed directly)
# ============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    clear

    # Show header
    echo -e "${SC_BOLD}${SC_CYAN}"
    cat << 'EOF'
╔════════════════════════════════════════════════════════════════════════════╗
║                                                                            ║
║                            ShellCandy Framework                            ║
║                    Beautiful Terminal UI for Shell Scripts                ║
║                                                                            ║
║                              Version 1.0.0                                 ║
║                                                                            ║
╚════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${SC_RESET}"
    echo ""

    # Show status
    shellcandy_status
    echo ""

    # Demo each module
    echo -e "${SC_BOLD}Module Demonstrations${SC_RESET}"
    echo -e "${SC_DIM}────────────────────────────────────────────────────────────────────────────${SC_RESET}"
    echo ""

    # 1. Colors demo
    if [[ -n "$SHELLCANDY_COLORS_LOADED" ]]; then
        sc_log_section "Colors Module"
        echo -e "Standard colors: ${SC_RED}Red${SC_RESET} ${SC_GREEN}Green${SC_RESET} ${SC_BLUE}Blue${SC_RESET} ${SC_YELLOW}Yellow${SC_RESET}"
        echo -e "Formatting: ${SC_BOLD}Bold${SC_RESET} ${SC_DIM}Dim${SC_RESET} ${SC_UNDERLINE}Underline${SC_RESET}"
        echo -e "Rainbow: $(sc_rainbow "ShellCandy makes terminals beautiful!")"
        echo ""
    fi

    # 2. Logging demo
    if [[ -n "$SHELLCANDY_LOGGING_LOADED" ]]; then
        sc_log_section "Logging Module"
        sc_log_debug "Debug message example"
        sc_log_info "Info message example"
        sc_log_warn "Warning message example"
        sc_log_error "Error message example"
        sc_log_success "Success message example"
        echo ""
    fi

    # 3. Icons demo
    if [[ -n "$SHELLCANDY_ICONS_LOADED" ]]; then
        sc_log_section "Icons Module"
        sc_icon_success "Operation completed"
        sc_icon_warning "Disk space low"
        sc_icon_info "Server running on port 8080"
        sc_emoji_status rocket "Deployment started"
        sc_emoji_status shield "Security scan passed"
        echo ""
    fi

    # 4. Progress demo
    if [[ -n "$SHELLCANDY_PROGRESS_LOADED" ]]; then
        sc_log_section "Progress Module"
        echo "Spinner demo:"
        spinner_pid=$(sc_spinner_start "Loading data..." "dots")
        sleep 2
        sc_spinner_stop "$spinner_pid" "Data loaded"
        echo ""

        echo "Progress bar demo:"
        for i in {0..100..10}; do
            sc_progress_bar $i 100 "Processing"
            sleep 0.1
        done
        echo ""
        echo ""
    fi

    # 5. Boxes demo
    if [[ -n "$SHELLCANDY_BOXES_LOADED" ]]; then
        sc_log_section "Boxes Module"

        box_info "Information" "This is an informational message"
        echo ""

        box_success "Success" "Operation completed successfully"
        echo ""

        box_warning "Warning" "Please review the following items"
        echo ""
    fi

    # Complete
    echo ""
    box_success "Demo Complete" \
        "ShellCandy framework successfully demonstrated" \
        "" \
        "📚 Documentation: lib/README.md" \
        "🚀 Get started: source lib/shellcandy.sh" \
        "💡 Examples: bash lib/examples.sh"

    echo ""
    echo -e "${SC_DIM}For more information, run: bash lib/shellcandy.sh --help${SC_RESET}"
    echo ""
fi
