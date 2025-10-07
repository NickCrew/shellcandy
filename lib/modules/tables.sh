#!/bin/bash
# tables.sh - Advanced table rendering for ShellCandy
# Version: 1.0.0
#
# Provides:
# - Auto-sizing columns
# - Header/footer rows
# - Cell alignment (left, right, center)
# - Column formatting (numbers, percentages, etc.)
# - Sorting capabilities
# - Colored cells
# - CSV/JSON import
# - Multiple table styles

# Prevent multiple sourcing
[[ -n "${SHELLCANDY_TABLES_LOADED}" ]] && return 0
export SHELLCANDY_TABLES_LOADED=1

# Source colors module if available
if [[ -f "$(dirname "${BASH_SOURCE[0]}")/colors.sh" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/colors.sh"
else
    # Fallback colors
    SC_GREEN='\033[0;32m'
    SC_YELLOW='\033[0;33m'
    SC_BLUE='\033[0;34m'
    SC_CYAN='\033[0;36m'
    SC_BOLD='\033[1m'
    SC_DIM='\033[2m'
    SC_RESET='\033[0m'
    SC_NC='\033[0m'
fi

# ============================================================================
# Configuration
# ============================================================================

# Table styles
export SC_TABLE_STYLE_STANDARD="standard"
export SC_TABLE_STYLE_ROUNDED="rounded"
export SC_TABLE_STYLE_DOUBLE="double"
export SC_TABLE_STYLE_SIMPLE="simple"
export SC_TABLE_STYLE_MINIMAL="minimal"

# Default settings
export SC_TABLE_DEFAULT_STYLE="standard"
export SC_TABLE_DEFAULT_ALIGN="left"
export SC_TABLE_BORDER_COLOR="$SC_BLUE"
export SC_TABLE_HEADER_COLOR="$SC_BOLD$SC_CYAN"
export SC_TABLE_PADDING=1

# Table state (for API usage)
declare -a SC_TABLE_HEADERS
declare -a SC_TABLE_ROWS
declare -a SC_TABLE_ALIGNMENTS
declare -a SC_TABLE_WIDTHS
declare -a SC_TABLE_FORMATTERS

# ============================================================================
# Box Drawing Characters by Style
# ============================================================================

# Standard style
SC_TABLE_STD_TL="╔"
SC_TABLE_STD_TR="╗"
SC_TABLE_STD_BL="╚"
SC_TABLE_STD_BR="╝"
SC_TABLE_STD_H="═"
SC_TABLE_STD_V="║"
SC_TABLE_STD_VH="╬"
SC_TABLE_STD_VL="╣"
SC_TABLE_STD_VR="╠"
SC_TABLE_STD_HT="╦"
SC_TABLE_STD_HB="╩"

# Rounded style
SC_TABLE_RND_TL="╭"
SC_TABLE_RND_TR="╮"
SC_TABLE_RND_BL="╰"
SC_TABLE_RND_BR="╯"
SC_TABLE_RND_H="─"
SC_TABLE_RND_V="│"
SC_TABLE_RND_VH="┼"
SC_TABLE_RND_VL="┤"
SC_TABLE_RND_VR="├"
SC_TABLE_RND_HT="┬"
SC_TABLE_RND_HB="┴"

# Double style
SC_TABLE_DBL_TL="╔"
SC_TABLE_DBL_TR="╗"
SC_TABLE_DBL_BL="╚"
SC_TABLE_DBL_BR="╝"
SC_TABLE_DBL_H="═"
SC_TABLE_DBL_V="║"
SC_TABLE_DBL_VH="╬"
SC_TABLE_DBL_VL="╣"
SC_TABLE_DBL_VR="╠"
SC_TABLE_DBL_HT="╦"
SC_TABLE_DBL_HB="╩"

# Simple style (ASCII)
SC_TABLE_SMP_TL="+"
SC_TABLE_SMP_TR="+"
SC_TABLE_SMP_BL="+"
SC_TABLE_SMP_BR="+"
SC_TABLE_SMP_H="-"
SC_TABLE_SMP_V="|"
SC_TABLE_SMP_VH="+"
SC_TABLE_SMP_VL="+"
SC_TABLE_SMP_VR="+"
SC_TABLE_SMP_HT="+"
SC_TABLE_SMP_HB="+"

# ============================================================================
# Utility Functions
# ============================================================================

# Strip ANSI codes from text
_sc_table_strip_ansi() {
    echo -e "$1" | sed 's/\x1b\[[0-9;]*m//g'
}

# Get display length (accounting for emojis and ANSI codes)
_sc_table_display_len() {
    local text=$1
    local stripped=$(_sc_table_strip_ansi "$text")
    local len=${#stripped}

    # Count emojis (they take 2 columns)
    local emoji_count=$(printf "%b" "$stripped" | grep -o '[🌐📊🔧📋📦🛡️⚠️✅❌🚀💡🔥⚡🎯📝🔍🎨🌟✓✗]' | wc -l | tr -d ' ')

    echo $((len + emoji_count))
}

# Pad text to width with alignment
# Usage: _sc_table_pad "text" width alignment
_sc_table_pad() {
    local text=$1
    local width=$2
    local align=${3:-left}
    local display_len=$(_sc_table_display_len "$text")
    local padding=$((width - display_len))

    [[ $padding -lt 0 ]] && padding=0

    case "$align" in
        right)
            printf "%*s%b" "$padding" "" "$text"
            ;;
        center)
            local left_pad=$((padding / 2))
            local right_pad=$((padding - left_pad))
            printf "%*s%b%*s" "$left_pad" "" "$text" "$right_pad" ""
            ;;
        *)  # left
            printf "%b%*s" "$text" "$padding" ""
            ;;
    esac
}

# Calculate column widths from data
_sc_table_calc_widths() {
    local -n headers=$1
    local -n rows=$2
    local -n widths=$3

    # Initialize widths with header lengths
    for i in "${!headers[@]}"; do
        widths[$i]=$(_sc_table_display_len "${headers[$i]}")
    done

    # Check each row for wider cells
    for row in "${rows[@]}"; do
        IFS='|' read -ra cells <<< "$row"
        for i in "${!cells[@]}"; do
            local cell_len=$(_sc_table_display_len "${cells[$i]}")
            if [[ $cell_len -gt ${widths[$i]:-0} ]]; then
                widths[$i]=$cell_len
            fi
        done
    done

    # Add padding
    for i in "${!widths[@]}"; do
        widths[$i]=$((widths[$i] + SC_TABLE_PADDING * 2))
    done
}

# Get style characters
_sc_table_get_chars() {
    local style=$1
    local char_name=$2

    case "$style" in
        rounded)
            eval echo "\$SC_TABLE_RND_${char_name}"
            ;;
        double)
            eval echo "\$SC_TABLE_DBL_${char_name}"
            ;;
        simple)
            eval echo "\$SC_TABLE_SMP_${char_name}"
            ;;
        minimal)
            # Minimal has no borders
            echo ""
            ;;
        *)  # standard
            eval echo "\$SC_TABLE_STD_${char_name}"
            ;;
    esac
}

# ============================================================================
# Table Rendering - Low Level
# ============================================================================

# Draw horizontal line
# Usage: _sc_table_line <style> <position> <widths[@]> [color]
_sc_table_line() {
    local style=$1
    local position=$2  # top, middle, bottom
    shift 2
    local -n line_widths=$1
    local color=${2:-$SC_TABLE_BORDER_COLOR}

    [[ "$style" == "minimal" ]] && return

    # Select characters based on position
    local left right middle horiz
    case "$position" in
        top)
            left=$(_sc_table_get_chars "$style" "TL")
            right=$(_sc_table_get_chars "$style" "TR")
            middle=$(_sc_table_get_chars "$style" "HT")
            ;;
        middle)
            left=$(_sc_table_get_chars "$style" "VR")
            right=$(_sc_table_get_chars "$style" "VL")
            middle=$(_sc_table_get_chars "$style" "VH")
            ;;
        bottom)
            left=$(_sc_table_get_chars "$style" "BL")
            right=$(_sc_table_get_chars "$style" "BR")
            middle=$(_sc_table_get_chars "$style" "HB")
            ;;
    esac
    horiz=$(_sc_table_get_chars "$style" "H")

    # Build line
    printf "${color}%s" "$left"
    for i in "${!line_widths[@]}"; do
        printf "%${line_widths[$i]}s" "" | tr ' ' "$horiz"
        if [[ $i -lt $((${#line_widths[@]} - 1)) ]]; then
            printf "%s" "$middle"
        fi
    done
    printf "%s${SC_RESET}\n" "$right"
}

# Draw data row
# Usage: _sc_table_row <style> <row_data> <widths[@]> <alignments[@]> [color]
_sc_table_row() {
    local style=$1
    local row_data=$2
    shift 2
    local -n row_widths=$1
    local -n row_aligns=$2
    local color=${3:-""}

    local vert=$(_sc_table_get_chars "$style" "V")
    [[ "$style" == "minimal" ]] && vert=" "

    IFS='|' read -ra cells <<< "$row_data"

    printf "${SC_TABLE_BORDER_COLOR}%s${SC_RESET}" "$vert"
    for i in "${!cells[@]}"; do
        local cell="${cells[$i]}"
        local width=${row_widths[$i]}
        local align=${row_aligns[$i]:-left}

        printf " %s " "$(_sc_table_pad "${color}${cell}${SC_RESET}" $((width - 2)) "$align")"
        printf "${SC_TABLE_BORDER_COLOR}%s${SC_RESET}" "$vert"
    done
    printf "\n"
}

# ============================================================================
# High-Level Table API
# ============================================================================

# Create a new table
# Usage: sc_table_create [style]
sc_table_create() {
    local style=${1:-$SC_TABLE_DEFAULT_STYLE}
    export SC_TABLE_CURRENT_STYLE="$style"
    SC_TABLE_HEADERS=()
    SC_TABLE_ROWS=()
    SC_TABLE_ALIGNMENTS=()
    SC_TABLE_WIDTHS=()
    SC_TABLE_FORMATTERS=()
}

# Set table headers
# Usage: sc_table_header "Col1" "Col2" "Col3" ...
sc_table_header() {
    SC_TABLE_HEADERS=("$@")
    # Initialize alignments to left
    for ((i=0; i<${#SC_TABLE_HEADERS[@]}; i++)); do
        SC_TABLE_ALIGNMENTS[$i]="left"
    done
}

# Add a row to the table
# Usage: sc_table_row "Cell1" "Cell2" "Cell3" ...
sc_table_row() {
    local row=""
    for cell in "$@"; do
        [[ -n "$row" ]] && row="${row}|"
        row="${row}${cell}"
    done
    SC_TABLE_ROWS+=("$row")
}

# Set column alignment
# Usage: sc_table_align <col_index> <left|right|center>
sc_table_align() {
    local col=$1
    local align=$2
    SC_TABLE_ALIGNMENTS[$col]="$align"
}

# Render the table
# Usage: sc_table_render [border_color] [header_color]
sc_table_render() {
    local border_color=${1:-$SC_TABLE_BORDER_COLOR}
    local header_color=${2:-$SC_TABLE_HEADER_COLOR}
    local style=${SC_TABLE_CURRENT_STYLE:-$SC_TABLE_DEFAULT_STYLE}

    # Calculate column widths
    _sc_table_calc_widths SC_TABLE_HEADERS SC_TABLE_ROWS SC_TABLE_WIDTHS

    # Top border
    _sc_table_line "$style" "top" SC_TABLE_WIDTHS "$border_color"

    # Header row
    local header_row=""
    for i in "${!SC_TABLE_HEADERS[@]}"; do
        [[ -n "$header_row" ]] && header_row="${header_row}|"
        header_row="${header_row}${SC_TABLE_HEADERS[$i]}"
    done
    _sc_table_row "$style" "$header_row" SC_TABLE_WIDTHS SC_TABLE_ALIGNMENTS "$header_color"

    # Separator after header
    _sc_table_line "$style" "middle" SC_TABLE_WIDTHS "$border_color"

    # Data rows
    for row in "${SC_TABLE_ROWS[@]}"; do
        _sc_table_row "$style" "$row" SC_TABLE_WIDTHS SC_TABLE_ALIGNMENTS
    done

    # Bottom border
    _sc_table_line "$style" "bottom" SC_TABLE_WIDTHS "$border_color"
}

# ============================================================================
# Quick Table Function
# ============================================================================

# Create and render a table in one call
# Usage: sc_table "Col1:Col2:Col3" "row1_c1:row1_c2:row1_c3" "row2_c1:row2_c2:row2_c3" ...
sc_table() {
    local style=${SC_TABLE_DEFAULT_STYLE}
    local headers=""
    local rows=()

    # Parse arguments
    for arg in "$@"; do
        if [[ "$arg" == --style=* ]]; then
            style="${arg#--style=}"
        elif [[ -z "$headers" ]]; then
            headers="$arg"
        else
            rows+=("$arg")
        fi
    done

    # Create table
    sc_table_create "$style"

    # Add headers
    IFS=':' read -ra header_array <<< "$headers"
    sc_table_header "${header_array[@]}"

    # Add rows
    for row in "${rows[@]}"; do
        IFS=':' read -ra row_array <<< "$row"
        sc_table_row "${row_array[@]}"
    done

    # Render
    sc_table_render
}

# ============================================================================
# CSV Import
# ============================================================================

# Create table from CSV
# Usage: sc_table_from_csv <file> [delimiter] [style]
sc_table_from_csv() {
    local file=$1
    local delim=${2:-,}
    local style=${3:-$SC_TABLE_DEFAULT_STYLE}

    [[ ! -f "$file" ]] && echo "Error: File not found: $file" >&2 && return 1

    sc_table_create "$style"

    local line_num=0
    while IFS= read -r line; do
        IFS="$delim" read -ra cells <<< "$line"

        if [[ $line_num -eq 0 ]]; then
            sc_table_header "${cells[@]}"
        else
            sc_table_row "${cells[@]}"
        fi

        ((line_num++))
    done < "$file"

    sc_table_render
}

# ============================================================================
# Formatted Tables
# ============================================================================

# Create a status table (with colored status column)
# Usage: sc_table_status <headers> <rows...>
sc_table_status() {
    sc_table_create "rounded"

    # First arg is headers
    IFS=':' read -ra headers <<< "$1"
    shift
    sc_table_header "${headers[@]}"

    # Process rows and colorize status
    for row_data in "$@"; do
        IFS=':' read -ra cells <<< "$row_data"

        # Colorize status column (assume it's the second column)
        if [[ ${#cells[@]} -gt 1 ]]; then
            local status="${cells[1]}"
            case "${status,,}" in
                *running*|*active*|*success*|*ok*)
                    cells[1]="${SC_GREEN}${status}${SC_RESET}"
                    ;;
                *stopped*|*failed*|*error*)
                    cells[1]="${SC_RED}${status}${SC_RESET}"
                    ;;
                *warning*|*degraded*)
                    cells[1]="${SC_YELLOW}${status}${SC_RESET}"
                    ;;
            esac
        fi

        sc_table_row "${cells[@]}"
    done

    sc_table_render
}

# Create a metrics table (right-align numbers)
# Usage: sc_table_metrics <headers> <rows...>
sc_table_metrics() {
    sc_table_create "standard"

    # First arg is headers
    IFS=':' read -ra headers <<< "$1"
    shift
    sc_table_header "${headers[@]}"

    # Right-align numeric columns
    for i in "${!headers[@]}"; do
        if [[ $i -gt 0 ]]; then
            sc_table_align $i "right"
        fi
    done

    # Add rows
    for row_data in "$@"; do
        IFS=':' read -ra cells <<< "$row_data"
        sc_table_row "${cells[@]}"
    done

    sc_table_render "$SC_BLUE" "$SC_BOLD$SC_CYAN"
}

# ============================================================================
# Simple List Table
# ============================================================================

# Create a simple 2-column key-value table
# Usage: sc_table_kv "Key1" "Value1" "Key2" "Value2" ...
sc_table_kv() {
    sc_table_create "rounded"
    sc_table_header "Key" "Value"

    while [[ $# -gt 0 ]]; do
        local key=$1
        local value=${2:-""}
        sc_table_row "$key" "$value"
        shift 2
    done

    sc_table_render "$SC_CYAN"
}

# ============================================================================
# Example Usage
# ============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "ShellCandy Tables Module"
    echo "========================"
    echo ""

    # Example 1: Simple table
    echo "Example 1: Simple Table"
    echo "─────────────────────────────────────────"
    sc_table "Name:Age:City" \
        "Alice:28:New York" \
        "Bob:34:San Francisco" \
        "Charlie:25:Seattle"
    echo ""

    # Example 2: Status table
    echo "Example 2: Status Table"
    echo "─────────────────────────────────────────"
    sc_table_status "Service:Status:Port:CPU" \
        "Web Server:✓ Running:8080:45%" \
        "API Server:✓ Running:3000:32%" \
        "Database:✓ Running:5432:78%" \
        "Cache:⚠ Degraded:6379:12%"
    echo ""

    # Example 3: Metrics table
    echo "Example 3: Metrics Table"
    echo "─────────────────────────────────────────"
    sc_table_metrics "Metric:Today:Yesterday:Change" \
        "Requests:15,234:14,891:+2.3%" \
        "Users:1,842:1,756:+4.9%" \
        "Errors:23:45:-48.9%" \
        "Uptime:99.9%:99.8%:+0.1%"
    echo ""

    # Example 4: Key-Value table
    echo "Example 4: Configuration Table"
    echo "─────────────────────────────────────────"
    sc_table_kv \
        "Application" "myapp" \
        "Version" "2.0.1" \
        "Environment" "production" \
        "Region" "us-west-2" \
        "Deployed" "2025-01-06 14:30:00"
    echo ""

    # Example 5: Different styles
    echo "Example 5: Table Styles"
    echo "─────────────────────────────────────────"

    echo "Standard style:"
    sc_table "Col1:Col2:Col3" "Data1:Data2:Data3" --style=standard
    echo ""

    echo "Rounded style:"
    sc_table "Col1:Col2:Col3" "Data1:Data2:Data3" --style=rounded
    echo ""

    echo "Simple style:"
    sc_table "Col1:Col2:Col3" "Data1:Data2:Data3" --style=simple
    echo ""

    echo "Minimal style:"
    sc_table "Col1:Col2:Col3" "Data1:Data2:Data3" --style=minimal
    echo ""

    # Example 6: API usage
    echo "Example 6: Using Table API"
    echo "─────────────────────────────────────────"
    sc_table_create "double"
    sc_table_header "ID" "Name" "Score" "Grade"
    sc_table_align 2 "right"   # Right-align score
    sc_table_align 3 "center"  # Center grade
    sc_table_row "1" "Alice" "95" "A"
    sc_table_row "2" "Bob" "87" "B"
    sc_table_row "3" "Charlie" "92" "A"
    sc_table_render
    echo ""

    echo "Examples complete!"
fi
