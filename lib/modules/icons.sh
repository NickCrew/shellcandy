#!/bin/bash
# icons.sh - Icon and symbol library for ShellCandy
# Version: 1.0.0
#
# Provides:
# - Status symbols (✓ ✗ ⚠ ℹ)
# - Directional arrows
# - UI elements
# - Emoji collections
# - Colored icon functions

# Prevent multiple sourcing
[[ -n "${SHELLCANDY_ICONS_LOADED}" ]] && return 0
export SHELLCANDY_ICONS_LOADED=1

# Source colors module if available
if [[ -f "$(dirname "${BASH_SOURCE[0]}")/colors.sh" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/colors.sh"
else
    # Fallback colors
    SC_GREEN='\033[0;32m'
    SC_RED='\033[0;31m'
    SC_YELLOW='\033[0;33m'
    SC_BLUE='\033[0;34m'
    SC_CYAN='\033[0;36m'
    SC_MAGENTA='\033[0;35m'
    SC_RESET='\033[0m'
fi

# ============================================================================
# Status Icons
# ============================================================================

# Success/Check
export SC_ICON_SUCCESS="✓"
export SC_ICON_CHECK="✓"
export SC_ICON_CHECKMARK="✔"
export SC_ICON_TICK="✓"
export SC_ICON_OK="✓"

# Failure/Error
export SC_ICON_FAILURE="✗"
export SC_ICON_ERROR="✗"
export SC_ICON_CROSS="✗"
export SC_ICON_FAIL="✗"
export SC_ICON_NO="✗"

# Warning/Alert
export SC_ICON_WARNING="⚠"
export SC_ICON_ALERT="⚠"
export SC_ICON_CAUTION="⚠"

# Info/Help
export SC_ICON_INFO="ℹ"
export SC_ICON_HELP="?"
export SC_ICON_QUESTION="?"

# In Progress
export SC_ICON_PROGRESS="→"
export SC_ICON_WORKING="⟳"
export SC_ICON_LOADING="⌛"

# Special Status
export SC_ICON_SKIPPED="○"
export SC_ICON_DISABLED="⊘"
export SC_ICON_LOCKED="🔒"
export SC_ICON_UNLOCKED="🔓"

# ============================================================================
# Arrows and Pointers
# ============================================================================

# Basic arrows
export SC_ICON_RIGHT="→"
export SC_ICON_LEFT="←"
export SC_ICON_UP="↑"
export SC_ICON_DOWN="↓"

# Double arrows
export SC_ICON_RIGHT_DOUBLE="⇒"
export SC_ICON_LEFT_DOUBLE="⇐"
export SC_ICON_UP_DOUBLE="⇑"
export SC_ICON_DOWN_DOUBLE="⇓"

# Curved arrows
export SC_ICON_RETURN="↵"
export SC_ICON_UNDO="↶"
export SC_ICON_REDO="↷"

# Special arrows
export SC_ICON_POINTER="▸"
export SC_ICON_BULLET="•"
export SC_ICON_TRIANGLE="▸"

# ============================================================================
# Shapes and Markers
# ============================================================================

# Circles
export SC_ICON_CIRCLE_FILLED="●"
export SC_ICON_CIRCLE_EMPTY="○"
export SC_ICON_CIRCLE_DOTTED="◌"
export SC_ICON_DOT="•"

# Squares
export SC_ICON_SQUARE_FILLED="■"
export SC_ICON_SQUARE_EMPTY="□"
export SC_ICON_CHECKBOX_CHECKED="☑"
export SC_ICON_CHECKBOX_UNCHECKED="☐"

# Triangles
export SC_ICON_TRIANGLE_RIGHT="▸"
export SC_ICON_TRIANGLE_LEFT="◂"
export SC_ICON_TRIANGLE_UP="▴"
export SC_ICON_TRIANGLE_DOWN="▾"

# Stars
export SC_ICON_STAR="★"
export SC_ICON_STAR_EMPTY="☆"

# ============================================================================
# UI Elements
# ============================================================================

# Separators
export SC_ICON_SEP_VERTICAL="│"
export SC_ICON_SEP_HORIZONTAL="─"
export SC_ICON_SEP_CROSS="┼"

# Corners
export SC_ICON_CORNER_TL="┌"
export SC_ICON_CORNER_TR="┐"
export SC_ICON_CORNER_BL="└"
export SC_ICON_CORNER_BR="┘"

# Menu items
export SC_ICON_MENU="☰"
export SC_ICON_MORE="⋯"
export SC_ICON_ELLIPSIS="…"

# ============================================================================
# Emoji Collections
# ============================================================================

# Technology
export SC_ICON_COMPUTER="💻"
export SC_ICON_SERVER="🖥"
export SC_ICON_DATABASE="🗄"
export SC_ICON_CLOUD="☁"
export SC_ICON_NETWORK="🌐"
export SC_ICON_GEAR="⚙"
export SC_ICON_TOOL="🔧"
export SC_ICON_WRENCH="🔧"

# Files and Folders
export SC_ICON_FILE="📄"
export SC_ICON_FOLDER="📁"
export SC_ICON_FOLDER_OPEN="📂"
export SC_ICON_DOCUMENT="📋"
export SC_ICON_PAGE="📃"
export SC_ICON_PACKAGE="📦"

# Actions
export SC_ICON_SEARCH="🔍"
export SC_ICON_ZOOM="🔎"
export SC_ICON_DOWNLOAD="⬇"
export SC_ICON_UPLOAD="⬆"
export SC_ICON_TRASH="🗑"
export SC_ICON_DELETE="🗑"

# Security
export SC_ICON_SHIELD="🛡"
export SC_ICON_KEY="🔑"
export SC_ICON_LOCK="🔒"
export SC_ICON_UNLOCK="🔓"
export SC_ICON_SECURITY="🔐"

# Communication
export SC_ICON_EMAIL="📧"
export SC_ICON_MESSAGE="💬"
export SC_ICON_BELL="🔔"
export SC_ICON_NOTIFICATION="🔔"

# Time
export SC_ICON_CLOCK="🕐"
export SC_ICON_TIME="⏰"
export SC_ICON_TIMER="⏱"
export SC_ICON_HOURGLASS="⌛"

# Charts and Data
export SC_ICON_CHART="📊"
export SC_ICON_GRAPH="📈"
export SC_ICON_REPORT="📉"
export SC_ICON_STATS="📊"

# Development
export SC_ICON_CODE="💻"
export SC_ICON_BUG="🐛"
export SC_ICON_ROCKET="🚀"
export SC_ICON_FIRE="🔥"
export SC_ICON_ZAP="⚡"
export SC_ICON_BULB="💡"

# Status Emoji
export SC_ICON_PARTY="🎉"
export SC_ICON_TADA="🎉"
export SC_ICON_THUMB_UP="👍"
export SC_ICON_THUMB_DOWN="👎"

# ============================================================================
# Colored Icon Functions
# ============================================================================

# Success icon (green checkmark)
# Usage: sc_icon_success [text]
sc_icon_success() {
    local text=${1:-""}
    if [[ -n "$text" ]]; then
        echo -e "${SC_GREEN}${SC_ICON_SUCCESS}${SC_RESET} ${text}"
    else
        echo -e "${SC_GREEN}${SC_ICON_SUCCESS}${SC_RESET}"
    fi
}

# Error icon (red cross)
# Usage: sc_icon_error [text]
sc_icon_error() {
    local text=${1:-""}
    if [[ -n "$text" ]]; then
        echo -e "${SC_RED}${SC_ICON_ERROR}${SC_RESET} ${text}"
    else
        echo -e "${SC_RED}${SC_ICON_ERROR}${SC_RESET}"
    fi
}

# Warning icon (yellow warning)
# Usage: sc_icon_warning [text]
sc_icon_warning() {
    local text=${1:-""}
    if [[ -n "$text" ]]; then
        echo -e "${SC_YELLOW}${SC_ICON_WARNING}${SC_RESET} ${text}"
    else
        echo -e "${SC_YELLOW}${SC_ICON_WARNING}${SC_RESET}"
    fi
}

# Info icon (blue info)
# Usage: sc_icon_info [text]
sc_icon_info() {
    local text=${1:-""}
    if [[ -n "$text" ]]; then
        echo -e "${SC_BLUE}${SC_ICON_INFO}${SC_RESET} ${text}"
    else
        echo -e "${SC_BLUE}${SC_ICON_INFO}${SC_RESET}"
    fi
}

# Progress icon (cyan arrow)
# Usage: sc_icon_progress [text]
sc_icon_progress() {
    local text=${1:-""}
    if [[ -n "$text" ]]; then
        echo -e "${SC_CYAN}${SC_ICON_PROGRESS}${SC_RESET} ${text}"
    else
        echo -e "${SC_CYAN}${SC_ICON_PROGRESS}${SC_RESET}"
    fi
}

# ============================================================================
# Status Line Functions
# ============================================================================

# Print status line with icon
# Usage: sc_status <status> <message>
# Status: success, error, warning, info, progress
sc_status() {
    local status=$1
    shift
    local message="$*"

    case "$status" in
        success|ok|pass)
            sc_icon_success "$message"
            ;;
        error|fail|failure)
            sc_icon_error "$message"
            ;;
        warning|warn|alert)
            sc_icon_warning "$message"
            ;;
        info|help)
            sc_icon_info "$message"
            ;;
        progress|working)
            sc_icon_progress "$message"
            ;;
        *)
            echo "$message"
            ;;
    esac
}

# Print colored bullet point
# Usage: sc_bullet <color> <text>
sc_bullet() {
    local color=$1
    shift
    local text="$*"

    echo -e "${color}${SC_ICON_BULLET}${SC_RESET} ${text}"
}

# Print pointer with text
# Usage: sc_pointer <text>
sc_pointer() {
    echo -e "${SC_CYAN}${SC_ICON_POINTER}${SC_RESET} $*"
}

# ============================================================================
# List Functions
# ============================================================================

# Create a checklist item
# Usage: sc_checkbox <checked> <text>
sc_checkbox() {
    local checked=$1
    shift
    local text="$*"

    if [[ "$checked" == "true" || "$checked" == "1" || "$checked" == "yes" ]]; then
        echo -e "${SC_GREEN}${SC_ICON_CHECKBOX_CHECKED}${SC_RESET} ${text}"
    else
        echo -e "${SC_ICON_CHECKBOX_UNCHECKED} ${text}"
    fi
}

# Create a numbered list item
# Usage: sc_list_item <number> <text>
sc_list_item() {
    local number=$1
    shift
    local text="$*"

    echo -e "${SC_CYAN}${number}.${SC_RESET} ${text}"
}

# ============================================================================
# Progress Indicators
# ============================================================================

# Show step indicator
# Usage: sc_step <current> <total> <text>
sc_step() {
    local current=$1
    local total=$2
    shift 2
    local text="$*"

    echo -e "${SC_BLUE}[${current}/${total}]${SC_RESET} ${text}"
}

# Show status with emoji
# Usage: sc_emoji_status <type> <text>
# Types: rocket, fire, chart, shield, package, bug, bulb
sc_emoji_status() {
    local type=$1
    shift
    local text="$*"

    local emoji=""
    case "$type" in
        rocket) emoji="$SC_ICON_ROCKET" ;;
        fire) emoji="$SC_ICON_FIRE" ;;
        chart) emoji="$SC_ICON_CHART" ;;
        shield) emoji="$SC_ICON_SHIELD" ;;
        package) emoji="$SC_ICON_PACKAGE" ;;
        bug) emoji="$SC_ICON_BUG" ;;
        bulb|idea) emoji="$SC_ICON_BULB" ;;
        network) emoji="$SC_ICON_NETWORK" ;;
        tool) emoji="$SC_ICON_TOOL" ;;
        *) emoji="$SC_ICON_INFO" ;;
    esac

    echo -e "${emoji} ${text}"
}

# ============================================================================
# Header Functions
# ============================================================================

# Create section header with icon
# Usage: sc_header <icon_name> <text>
sc_header() {
    local icon=$1
    shift
    local text="$*"

    echo ""
    echo -e "${SC_BOLD}${icon} ${text}${SC_RESET}"
    echo ""
}

# Create subsection header
# Usage: sc_subheader <text>
sc_subheader() {
    echo -e "${SC_CYAN}${SC_ICON_POINTER}${SC_RESET} ${SC_BOLD}$*${SC_RESET}"
}

# ============================================================================
# Separator Functions
# ============================================================================

# Print separator line
# Usage: sc_separator [char] [length]
sc_separator() {
    local char=${1:-"─"}
    local length=${2:-80}

    printf "%${length}s\n" | tr ' ' "$char"
}

# Print section separator with text
# Usage: sc_section_separator <text> [length]
sc_section_separator() {
    local text=$1
    local length=${2:-80}
    local text_len=${#text}
    local side_len=$(( (length - text_len - 2) / 2 ))

    printf "%${side_len}s" | tr ' ' '─'
    printf " %s " "$text"
    printf "%${side_len}s\n" | tr ' ' '─'
}

# ============================================================================
# Utility Functions
# ============================================================================

# Get icon by name
# Usage: icon=$(sc_get_icon "success")
sc_get_icon() {
    local name=$1

    case "$name" in
        success|check|ok) echo "$SC_ICON_SUCCESS" ;;
        error|fail|cross) echo "$SC_ICON_ERROR" ;;
        warning|alert) echo "$SC_ICON_WARNING" ;;
        info|help) echo "$SC_ICON_INFO" ;;
        progress|arrow) echo "$SC_ICON_PROGRESS" ;;
        bullet|dot) echo "$SC_ICON_BULLET" ;;
        pointer|triangle) echo "$SC_ICON_POINTER" ;;
        *) echo "$name" ;;
    esac
}

# List all available icons
sc_list_icons() {
    echo "ShellCandy Icon Library"
    echo "======================="
    echo ""

    echo "Status Icons:"
    echo "  Success:   $SC_ICON_SUCCESS"
    echo "  Error:     $SC_ICON_ERROR"
    echo "  Warning:   $SC_ICON_WARNING"
    echo "  Info:      $SC_ICON_INFO"
    echo "  Progress:  $SC_ICON_PROGRESS"
    echo ""

    echo "Arrows:"
    echo "  Right:     $SC_ICON_RIGHT"
    echo "  Left:      $SC_ICON_LEFT"
    echo "  Up:        $SC_ICON_UP"
    echo "  Down:      $SC_ICON_DOWN"
    echo "  Pointer:   $SC_ICON_POINTER"
    echo ""

    echo "Shapes:"
    echo "  Bullet:    $SC_ICON_BULLET"
    echo "  Circle:    $SC_ICON_CIRCLE_FILLED"
    echo "  Square:    $SC_ICON_SQUARE_FILLED"
    echo "  Star:      $SC_ICON_STAR"
    echo ""

    echo "Emoji:"
    echo "  Rocket:    $SC_ICON_ROCKET"
    echo "  Fire:      $SC_ICON_FIRE"
    echo "  Chart:     $SC_ICON_CHART"
    echo "  Shield:    $SC_ICON_SHIELD"
    echo "  Package:   $SC_ICON_PACKAGE"
    echo "  Network:   $SC_ICON_NETWORK"
    echo "  Tool:      $SC_ICON_TOOL"
    echo "  Bug:       $SC_ICON_BUG"
    echo "  Bulb:      $SC_ICON_BULB"
}

# ============================================================================
# Example Usage
# ============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "ShellCandy Icons Module"
    echo "======================="
    echo ""

    # Status icons
    echo "Status Icons:"
    sc_icon_success "Operation completed"
    sc_icon_error "Operation failed"
    sc_icon_warning "Disk space low"
    sc_icon_info "Server running on port 8080"
    sc_icon_progress "Processing data..."
    echo ""

    # Bullet lists
    echo "Bullet Lists:"
    sc_bullet "$SC_GREEN" "First item"
    sc_bullet "$SC_BLUE" "Second item"
    sc_bullet "$SC_YELLOW" "Third item"
    echo ""

    # Checkboxes
    echo "Checklist:"
    sc_checkbox true "Install dependencies"
    sc_checkbox true "Run tests"
    sc_checkbox false "Deploy to production"
    echo ""

    # Steps
    echo "Progress Steps:"
    sc_step 1 3 "Initializing"
    sc_step 2 3 "Processing"
    sc_step 3 3 "Complete"
    echo ""

    # Emoji status
    echo "Emoji Status:"
    sc_emoji_status rocket "Deployment started"
    sc_emoji_status chart "Analytics updated"
    sc_emoji_status shield "Security scan passed"
    sc_emoji_status bug "Issue detected"
    echo ""

    # Headers
    sc_header "$SC_ICON_ROCKET" "Deployment Report"
    sc_subheader "Build Information"
    echo "  Version: 2.0.1"
    echo "  Time: 2025-01-06"
    echo ""

    # Separators
    sc_separator
    sc_section_separator "RESULTS"
    sc_separator
    echo ""

    # Icon reference
    sc_list_icons
fi
