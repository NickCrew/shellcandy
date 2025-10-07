#!/bin/bash
# boxes.sh - Reusable terminal box drawing library
# Version: 1.0.0
#
# A lightweight library for drawing beautiful, aligned boxes in the terminal
# with support for ANSI colors, emojis, and dynamic content.
#
# Usage:
#   source lib/boxes.sh
#   box "Title" "Content line 1" "Content line 2"
#
# Features:
#   - Perfect alignment with variable content lengths
#   - ANSI color code support
#   - Emoji width handling (🌐 📊 🔧 etc.)
#   - Customizable width and colors
#   - Multiple box styles

# Prevent multiple sourcing
[[ -n "${SHELLCANDY_BOXES_LOADED}" ]] && return 0
export SHELLCANDY_BOXES_LOADED=1

# ============================================================================
# Color Definitions (optional - can be overridden)
# ============================================================================

if [[ -z "${BOX_COLORS_DEFINED}" ]]; then
    export BOX_COLORS_DEFINED=1

    # Standard colors
    export RED='\033[0;31m'
    export GREEN='\033[0;32m'
    export YELLOW='\033[0;33m'
    export BLUE='\033[0;34m'
    export MAGENTA='\033[0;35m'
    export CYAN='\033[0;36m'
    export WHITE='\033[0;37m'

    # Bright colors
    export BRIGHT_RED='\033[0;91m'
    export BRIGHT_GREEN='\033[0;92m'
    export BRIGHT_YELLOW='\033[0;93m'
    export BRIGHT_BLUE='\033[0;94m'
    export BRIGHT_MAGENTA='\033[0;95m'
    export BRIGHT_CYAN='\033[0;96m'

    # Text formatting
    export BOLD='\033[1m'
    export DIM='\033[2m'
    export UNDERLINE='\033[4m'
    export NC='\033[0m'  # No Color / Reset
fi

# Default box color
BOX_DEFAULT_COLOR="${BOX_DEFAULT_COLOR:-$BLUE}"
BOX_DEFAULT_WIDTH="${BOX_DEFAULT_WIDTH:-80}"

# ============================================================================
# Core Box Drawing Functions
# ============================================================================

# Draw box header with optional title
# Usage: box_header "Title" [color] [width]
box_header() {
    local title=$1
    local color=${2:-$BOX_DEFAULT_COLOR}
    local width=${3:-$BOX_DEFAULT_WIDTH}

    # Top border
    printf "${color}╔"
    printf '═%.0s' $(seq 1 $((width-2)))
    printf "╗${NC}\n"

    # Title line (if provided)
    if [ -n "$title" ]; then
        local title_len=${#title}
        local padding=$(( (width - title_len - 2) / 2 ))
        local right_padding=$((width - padding - title_len - 2))

        printf "${color}║${NC}"
        printf ' %.0s' $(seq 1 $padding)
        printf "${BOLD}${title}${NC}"
        printf ' %.0s' $(seq 1 $right_padding)
        printf "${color}║${NC}\n"

        # Separator after title
        printf "${color}╠"
        printf '═%.0s' $(seq 1 $((width-2)))
        printf "╣${NC}\n"
    fi
}

# Draw box content line with automatic alignment
# Usage: box_line "Content" [color] [width]
box_line() {
    local content=$1
    local color=${2:-$BOX_DEFAULT_COLOR}
    local width=${3:-$BOX_DEFAULT_WIDTH}

    # Strip ANSI codes to get actual character count
    local stripped=$(printf "%b" "$content" | sed 's/\x1b\[[0-9;]*m//g')
    local content_len=${#stripped}

    # Count emojis (they display as 2 columns but count as 1 character)
    # Common emojis: 🌐 📊 🔧 📋 📦 🛡️ ⚠️ ✅ ❌ 🚀 💡 🔥 ⚡ 🎯 📝 🔍 🎨 🌟
    local emoji_count=$(printf "%b" "$stripped" | grep -o '[🌐📊🔧📋📦🛡️⚠️✅❌🚀💡🔥⚡🎯📝🔍🎨🌟]' | wc -l | tr -d ' ')

    # Adjust content length for emoji display width
    local display_len=$((content_len + emoji_count))
    local padding=$((width - display_len - 3))

    printf "${color}║${NC} %b%*s${color}║${NC}\n" "$content" "$padding" ""
}

# Draw box footer
# Usage: box_footer [color] [width]
box_footer() {
    local color=${1:-$BOX_DEFAULT_COLOR}
    local width=${2:-$BOX_DEFAULT_WIDTH}

    printf "${color}╚"
    printf '═%.0s' $(seq 1 $((width-2)))
    printf "╝${NC}\n"
}

# Draw empty line (for spacing)
# Usage: box_empty [color] [width]
box_empty() {
    box_line "" "$@"
}

# ============================================================================
# Convenience Functions
# ============================================================================

# Draw complete box with title and content lines
# Usage: box "Title" "Line 1" "Line 2" ... [--color=COLOR] [--width=WIDTH]
box() {
    local color=$BOX_DEFAULT_COLOR
    local width=$BOX_DEFAULT_WIDTH
    local lines=()
    local title=""

    # Parse arguments
    for arg in "$@"; do
        case "$arg" in
            --color=*)
                color="${arg#*=}"
                ;;
            --width=*)
                width="${arg#*=}"
                ;;
            *)
                if [ -z "$title" ]; then
                    title="$arg"
                else
                    lines+=("$arg")
                fi
                ;;
        esac
    done

    # Draw box
    box_header "$title" "$color" "$width"

    if [ ${#lines[@]} -gt 0 ]; then
        for line in "${lines[@]}"; do
            box_line "$line" "$color" "$width"
        done
    fi

    box_footer "$color" "$width"
}

# Draw info box (blue)
# Usage: box_info "Title" "Content lines..."
box_info() {
    box "$@" --color="$BLUE"
}

# Draw success box (green)
# Usage: box_success "Title" "Content lines..."
box_success() {
    box "$@" --color="$GREEN"
}

# Draw warning box (yellow)
# Usage: box_warning "Title" "Content lines..."
box_warning() {
    box "$@" --color="$YELLOW"
}

# Draw error box (red)
# Usage: box_error "Title" "Content lines..."
box_error() {
    box "$@" --color="$RED"
}

# ============================================================================
# Advanced Box Styles
# ============================================================================

# Draw rounded box (alternative style)
# Usage: box_rounded "Title" [color] [width]
box_rounded_header() {
    local title=$1
    local color=${2:-$BOX_DEFAULT_COLOR}
    local width=${3:-$BOX_DEFAULT_WIDTH}

    # Top border with rounded corners
    printf "${color}╭"
    printf '─%.0s' $(seq 1 $((width-2)))
    printf "╮${NC}\n"

    # Title
    if [ -n "$title" ]; then
        local title_len=${#title}
        local padding=$(( (width - title_len - 2) / 2 ))
        local right_padding=$((width - padding - title_len - 2))

        printf "${color}│${NC}"
        printf ' %.0s' $(seq 1 $padding)
        printf "${BOLD}${title}${NC}"
        printf ' %.0s' $(seq 1 $right_padding)
        printf "${color}│${NC}\n"

        printf "${color}├"
        printf '─%.0s' $(seq 1 $((width-2)))
        printf "┤${NC}\n"
    fi
}

box_rounded_line() {
    local content=$1
    local color=${2:-$BOX_DEFAULT_COLOR}
    local width=${3:-$BOX_DEFAULT_WIDTH}

    local stripped=$(printf "%b" "$content" | sed 's/\x1b\[[0-9;]*m//g')
    local content_len=${#stripped}
    local emoji_count=$(printf "%b" "$stripped" | grep -o '[🌐📊🔧📋📦🛡️⚠️✅❌🚀💡🔥⚡🎯📝🔍🎨🌟]' | wc -l | tr -d ' ')
    local display_len=$((content_len + emoji_count))
    local padding=$((width - display_len - 3))

    printf "${color}│${NC} %b%*s${color}│${NC}\n" "$content" "$padding" ""
}

box_rounded_footer() {
    local color=${1:-$BOX_DEFAULT_COLOR}
    local width=${2:-$BOX_DEFAULT_WIDTH}

    printf "${color}╰"
    printf '─%.0s' $(seq 1 $((width-2)))
    printf "╯${NC}\n"
}

# Draw double-line box (emphasis style)
box_double_header() {
    local title=$1
    local color=${2:-$BOX_DEFAULT_COLOR}
    local width=${3:-$BOX_DEFAULT_WIDTH}

    printf "${color}╔"
    printf '═%.0s' $(seq 1 $((width-2)))
    printf "╗${NC}\n"

    if [ -n "$title" ]; then
        local title_len=${#title}
        local padding=$(( (width - title_len - 2) / 2 ))
        local right_padding=$((width - padding - title_len - 2))

        printf "${color}║${NC}"
        printf ' %.0s' $(seq 1 $padding)
        printf "${BOLD}${title}${NC}"
        printf ' %.0s' $(seq 1 $right_padding)
        printf "${color}║${NC}\n"

        printf "${color}╠"
        printf '═%.0s' $(seq 1 $((width-2)))
        printf "╣${NC}\n"
    fi
}

box_double_footer() {
    local color=${1:-$BOX_DEFAULT_COLOR}
    local width=${2:-$BOX_DEFAULT_WIDTH}

    printf "${color}╚"
    printf '═%.0s' $(seq 1 $((width-2)))
    printf "╝${NC}\n"
}

# ============================================================================
# Utility Functions
# ============================================================================

# Draw horizontal separator
# Usage: box_separator [color] [width] [char]
box_separator() {
    local color=${1:-$BOX_DEFAULT_COLOR}
    local width=${2:-$BOX_DEFAULT_WIDTH}
    local char=${3:-─}

    printf "${color}"
    printf "${char}%.0s" $(seq 1 $width)
    printf "${NC}\n"
}

# Print centered text without box
# Usage: box_center "Text" [color] [width]
box_center() {
    local text=$1
    local color=${2:-$NC}
    local width=${3:-$BOX_DEFAULT_WIDTH}

    local stripped=$(printf "%b" "$text" | sed 's/\x1b\[[0-9;]*m//g')
    local text_len=${#stripped}
    local emoji_count=$(printf "%b" "$stripped" | grep -o '[🌐📊🔧📋📦🛡️⚠️✅❌🚀💡🔥⚡🎯📝🔍🎨🌟]' | wc -l | tr -d ' ')
    local display_len=$((text_len + emoji_count))
    local padding=$(( (width - display_len) / 2 ))

    printf "%*s${color}%b${NC}\n" "$padding" "" "$text"
}

# ============================================================================
# Example Usage
# ============================================================================

# Uncomment to run examples when sourcing this file
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo
    echo "Box Drawing Library - Examples"
    echo

    # Example 1: Simple box
    box "Simple Box" "This is a simple box" "with multiple lines"
    echo

    # Example 2: Colored boxes
    box_info "Info Box" "This is informational content"
    echo
    box_success "Success!" "Operation completed successfully"
    echo
    box_warning "Warning" "Please review this carefully"
    echo
    box_error "Error" "Something went wrong"
    echo

    # Example 3: Custom width and color
    box "Custom Box" "Custom width and color" "" --width=60 --color="$MAGENTA"
    echo

    # Example 4: With emojis
    box "Emoji Support" "🌐 Network status: Online" "📊 Stats: 100% uptime" "🔧 Config: Ready"
    echo

    # Example 5: Manual construction
    box_header "Manual Box" "$CYAN" 70
    box_line "You can build boxes line by line" "$CYAN" 70
    box_empty "$CYAN" 70
    box_line "${BOLD}Bold text${NC} and ${UNDERLINE}underlined${NC}" "$CYAN" 70
    box_footer "$CYAN" 70
    echo

    # Example 6: Rounded style
    box_rounded_header "Rounded Box" "$GREEN" 60
    box_rounded_line "Softer appearance" "$GREEN" 60
    box_rounded_line "Perfect for notifications" "$GREEN" 60
    box_rounded_footer "$GREEN" 60
    echo
fi
