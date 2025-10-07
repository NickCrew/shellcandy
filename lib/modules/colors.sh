#!/bin/bash
# colors.sh - Extended color system for ShellCandy
# Version: 1.0.0
#
# Provides comprehensive color support including:
# - Standard 16 colors
# - 256-color palette
# - RGB true color (24-bit)
# - Color themes
# - Gradient generation

# Prevent multiple sourcing
[[ -n "${SHELLCANDY_COLORS_LOADED}" ]] && return 0
export SHELLCANDY_COLORS_LOADED=1

# ============================================================================
# Standard Colors (16-color support)
# ============================================================================

# Regular colors
export SC_BLACK='\033[0;30m'
export SC_RED='\033[0;31m'
export SC_GREEN='\033[0;32m'
export SC_YELLOW='\033[0;33m'
export SC_BLUE='\033[0;34m'
export SC_MAGENTA='\033[0;35m'
export SC_CYAN='\033[0;36m'
export SC_WHITE='\033[0;37m'

# Bright/Bold colors
export SC_BRIGHT_BLACK='\033[0;90m'     # Gray
export SC_BRIGHT_RED='\033[0;91m'
export SC_BRIGHT_GREEN='\033[0;92m'
export SC_BRIGHT_YELLOW='\033[0;93m'
export SC_BRIGHT_BLUE='\033[0;94m'
export SC_BRIGHT_MAGENTA='\033[0;95m'
export SC_BRIGHT_CYAN='\033[0;96m'
export SC_BRIGHT_WHITE='\033[0;97m'

# Background colors
export SC_BG_BLACK='\033[40m'
export SC_BG_RED='\033[41m'
export SC_BG_GREEN='\033[42m'
export SC_BG_YELLOW='\033[43m'
export SC_BG_BLUE='\033[44m'
export SC_BG_MAGENTA='\033[45m'
export SC_BG_CYAN='\033[46m'
export SC_BG_WHITE='\033[47m'

# Text formatting
export SC_BOLD='\033[1m'
export SC_DIM='\033[2m'
export SC_ITALIC='\033[3m'
export SC_UNDERLINE='\033[4m'
export SC_BLINK='\033[5m'
export SC_REVERSE='\033[7m'
export SC_HIDDEN='\033[8m'
export SC_STRIKETHROUGH='\033[9m'

# Reset
export SC_RESET='\033[0m'
export SC_NC='\033[0m'  # No Color (alias)

# Backward compatibility aliases
export RED="$SC_RED"
export GREEN="$SC_GREEN"
export YELLOW="$SC_YELLOW"
export BLUE="$SC_BLUE"
export MAGENTA="$SC_MAGENTA"
export CYAN="$SC_CYAN"
export WHITE="$SC_WHITE"
export BOLD="$SC_BOLD"
export DIM="$SC_DIM"
export UNDERLINE="$SC_UNDERLINE"
export NC="$SC_NC"

# ============================================================================
# Named Color Palette (semantic colors)
# ============================================================================

export SC_SUCCESS="$SC_GREEN"
export SC_ERROR="$SC_RED"
export SC_WARNING="$SC_YELLOW"
export SC_INFO="$SC_BLUE"
export SC_DEBUG="$SC_CYAN"
export SC_MUTED="$SC_DIM"
export SC_HIGHLIGHT="$SC_BRIGHT_YELLOW"
export SC_PRIMARY="$SC_BLUE"
export SC_SECONDARY="$SC_MAGENTA"
export SC_DANGER="$SC_RED"

# ============================================================================
# 256-Color Support
# ============================================================================

# Generate 256-color foreground
# Usage: sc_color_256 <color_number>
sc_color_256() {
    printf '\033[38;5;%dm' "$1"
}

# Generate 256-color background
# Usage: sc_bg_256 <color_number>
sc_bg_256() {
    printf '\033[48;5;%dm' "$1"
}

# Common 256-colors (pre-defined for convenience)
export SC_ORANGE="$(sc_color_256 208)"
export SC_PINK="$(sc_color_256 205)"
export SC_PURPLE="$(sc_color_256 135)"
export SC_BROWN="$(sc_color_256 130)"
export SC_GRAY="$(sc_color_256 245)"
export SC_LIGHT_GRAY="$(sc_color_256 250)"
export SC_DARK_GRAY="$(sc_color_256 240)"

# ============================================================================
# RGB True Color (24-bit support)
# ============================================================================

# Generate RGB foreground color
# Usage: sc_rgb <red> <green> <blue>
sc_rgb() {
    printf '\033[38;2;%d;%d;%dm' "$1" "$2" "$3"
}

# Generate RGB background color
# Usage: sc_rgb_bg <red> <green> <blue>
sc_rgb_bg() {
    printf '\033[48;2;%d;%d;%dm' "$1" "$2" "$3"
}

# ============================================================================
# Color Themes
# ============================================================================

# Load a color theme
# Usage: sc_theme_load <theme_name>
sc_theme_load() {
    local theme=$1

    case "$theme" in
        dark|default)
            export SC_THEME_BG="$SC_BLACK"
            export SC_THEME_FG="$SC_WHITE"
            export SC_THEME_PRIMARY="$SC_BLUE"
            export SC_THEME_ACCENT="$SC_CYAN"
            ;;
        light)
            export SC_THEME_BG="$SC_WHITE"
            export SC_THEME_FG="$SC_BLACK"
            export SC_THEME_PRIMARY="$SC_BLUE"
            export SC_THEME_ACCENT="$SC_MAGENTA"
            ;;
        solarized)
            export SC_THEME_BG="$(sc_rgb 0 43 54)"
            export SC_THEME_FG="$(sc_rgb 131 148 150)"
            export SC_THEME_PRIMARY="$(sc_rgb 38 139 210)"
            export SC_THEME_ACCENT="$(sc_rgb 42 161 152)"
            ;;
        nord)
            export SC_THEME_BG="$(sc_rgb 46 52 64)"
            export SC_THEME_FG="$(sc_rgb 216 222 233)"
            export SC_THEME_PRIMARY="$(sc_rgb 136 192 208)"
            export SC_THEME_ACCENT="$(sc_rgb 163 190 140)"
            ;;
        dracula)
            export SC_THEME_BG="$(sc_rgb 40 42 54)"
            export SC_THEME_FG="$(sc_rgb 248 248 242)"
            export SC_THEME_PRIMARY="$(sc_rgb 189 147 249)"
            export SC_THEME_ACCENT="$(sc_rgb 255 121 198)"
            ;;
        *)
            echo "Unknown theme: $theme" >&2
            return 1
            ;;
    esac
}

# Default theme
sc_theme_load dark

# ============================================================================
# Color Utilities
# ============================================================================

# Strip ANSI color codes from text
# Usage: sc_strip_colors "text"
sc_strip_colors() {
    echo -e "$1" | sed 's/\x1b\[[0-9;]*m//g'
}

# Get length of string without color codes
# Usage: length=$(sc_strlen "colored text")
sc_strlen() {
    local stripped=$(sc_strip_colors "$1")
    echo "${#stripped}"
}

# Colorize text
# Usage: sc_colorize "text" "$SC_RED"
sc_colorize() {
    printf "${2}%s${SC_RESET}" "$1"
}

# ============================================================================
# Gradient Generation
# ============================================================================

# Generate a color gradient between two colors
# Usage: sc_gradient_text "text" <start_r> <start_g> <start_b> <end_r> <end_g> <end_b>
sc_gradient_text() {
    local text=$1
    local sr=$2 sg=$3 sb=$4
    local er=$5 eg=$6 eb=$7
    local len=${#text}

    for ((i=0; i<len; i++)); do
        local ratio=$(bc <<< "scale=2; $i / ($len - 1)" 2>/dev/null || echo "0")
        local r=$(printf "%.0f" $(bc <<< "$sr + ($er - $sr) * $ratio" 2>/dev/null || echo "$sr"))
        local g=$(printf "%.0f" $(bc <<< "$sg + ($eg - $sg) * $ratio" 2>/dev/null || echo "$sg"))
        local b=$(printf "%.0f" $(bc <<< "$sb + ($eb - $sb) * $ratio" 2>/dev/null || echo "$sb"))

        printf "$(sc_rgb $r $g $b)${text:$i:1}"
    done
    printf "${SC_RESET}"
}

# Rainbow text (simple version without bc dependency)
# Usage: sc_rainbow "text"
sc_rainbow() {
    local text=$1
    local colors=("$SC_RED" "$SC_YELLOW" "$SC_GREEN" "$SC_CYAN" "$SC_BLUE" "$SC_MAGENTA")
    local len=${#text}
    local color_count=${#colors[@]}

    for ((i=0; i<len; i++)); do
        local color_idx=$((i % color_count))
        printf "${colors[$color_idx]}${text:$i:1}"
    done
    printf "${SC_RESET}"
}

# ============================================================================
# Color Testing & Detection
# ============================================================================

# Check if terminal supports colors
# Usage: sc_has_color && echo "Colors supported"
sc_has_color() {
    [[ -t 1 ]] && [[ -n "${TERM}" ]] && [[ "${TERM}" != "dumb" ]]
}

# Check if terminal supports 256 colors
# Usage: sc_has_256_color && echo "256 colors supported"
sc_has_256_color() {
    [[ $(tput colors 2>/dev/null) -ge 256 ]]
}

# Check if terminal supports true color
# Usage: sc_has_truecolor && echo "True color supported"
sc_has_truecolor() {
    [[ -n "${COLORTERM}" ]] && [[ "${COLORTERM}" == "truecolor" || "${COLORTERM}" == "24bit" ]]
}

# Show color capabilities
sc_color_info() {
    echo "Terminal Color Capabilities:"
    echo "  Basic colors:  $(sc_has_color && echo "✓ Yes" || echo "✗ No")"
    echo "  256 colors:    $(sc_has_256_color && echo "✓ Yes" || echo "✗ No")"
    echo "  True color:    $(sc_has_truecolor && echo "✓ Yes" || echo "✗ No")"
    echo "  TERM:          ${TERM:-not set}"
    echo "  COLORTERM:     ${COLORTERM:-not set}"
}

# ============================================================================
# Color Palette Display
# ============================================================================

# Show 16-color palette
sc_show_colors() {
    echo "Basic Colors:"
    printf "${SC_BLACK}■${SC_RESET} Black    "
    printf "${SC_RED}■${SC_RESET} Red      "
    printf "${SC_GREEN}■${SC_RESET} Green    "
    printf "${SC_YELLOW}■${SC_RESET} Yellow\n"
    printf "${SC_BLUE}■${SC_RESET} Blue     "
    printf "${SC_MAGENTA}■${SC_RESET} Magenta  "
    printf "${SC_CYAN}■${SC_RESET} Cyan     "
    printf "${SC_WHITE}■${SC_RESET} White\n"

    echo ""
    echo "Bright Colors:"
    printf "${SC_BRIGHT_BLACK}■${SC_RESET} Gray     "
    printf "${SC_BRIGHT_RED}■${SC_RESET} Red      "
    printf "${SC_BRIGHT_GREEN}■${SC_RESET} Green    "
    printf "${SC_BRIGHT_YELLOW}■${SC_RESET} Yellow\n"
    printf "${SC_BRIGHT_BLUE}■${SC_RESET} Blue     "
    printf "${SC_BRIGHT_MAGENTA}■${SC_RESET} Magenta  "
    printf "${SC_BRIGHT_CYAN}■${SC_RESET} Cyan     "
    printf "${SC_BRIGHT_WHITE}■${SC_RESET} White\n"
}

# Show 256-color palette
sc_show_256_colors() {
    echo "256 Color Palette:"
    for i in {0..255}; do
        printf "$(sc_color_256 $i)█${SC_RESET}"
        [[ $((($i + 1) % 16)) -eq 0 ]] && echo
    done
}

# ============================================================================
# Example Usage
# ============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "ShellCandy Colors Module"
    echo "========================"
    echo ""

    sc_color_info
    echo ""

    sc_show_colors
    echo ""

    echo "Semantic Colors:"
    printf "${SC_SUCCESS}■${SC_RESET} Success  "
    printf "${SC_ERROR}■${SC_RESET} Error    "
    printf "${SC_WARNING}■${SC_RESET} Warning  "
    printf "${SC_INFO}■${SC_RESET} Info\n"
    echo ""

    echo "Text Formatting:"
    printf "${SC_BOLD}Bold${SC_RESET} "
    printf "${SC_DIM}Dim${SC_RESET} "
    printf "${SC_ITALIC}Italic${SC_RESET} "
    printf "${SC_UNDERLINE}Underline${SC_RESET} "
    printf "${SC_STRIKETHROUGH}Strikethrough${SC_RESET}\n"
    echo ""

    echo "Rainbow Text:"
    sc_rainbow "ShellCandy is awesome!"
    echo ""
    echo ""

    if sc_has_256_color; then
        echo "Extended Palette:"
        printf "${SC_ORANGE}■${SC_RESET} Orange   "
        printf "${SC_PINK}■${SC_RESET} Pink     "
        printf "${SC_PURPLE}■${SC_RESET} Purple   "
        printf "${SC_BROWN}■${SC_RESET} Brown\n"
    fi
fi
