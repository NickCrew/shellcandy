#!/bin/bash
# progress.sh - Progress indicators for ShellCandy
# Version: 1.0.0
#
# Provides:
# - Animated spinners
# - Progress bars
# - Percentage indicators
# - ETA calculations
# - Multi-line progress displays

# Prevent multiple sourcing
[[ -n "${SHELLCANDY_PROGRESS_LOADED}" ]] && return 0
export SHELLCANDY_PROGRESS_LOADED=1

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

# Spinner styles (arrays cannot be exported, defined locally in functions)
SC_SPINNER_DOTS=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
SC_SPINNER_LINE=("⠋" "⠙" "⠚" "⠞" "⠖" "⠦" "⠴" "⠲" "⠳" "⠓")
SC_SPINNER_ARROW=("←" "↖" "↑" "↗" "→" "↘" "↓" "↙")
SC_SPINNER_CIRCLE=("◴" "◷" "◶" "◵")
SC_SPINNER_BOUNCE=("⠁" "⠂" "⠄" "⡀" "⢀" "⠠" "⠐" "⠈")
SC_SPINNER_CLASSIC=("|" "/" "-" "\\")

# Progress bar styles
export SC_PROGRESS_BAR_CHAR="█"
export SC_PROGRESS_EMPTY_CHAR="░"
export SC_PROGRESS_BAR_WIDTH=50

# ============================================================================
# Spinner Functions
# ============================================================================

# Start a spinner
# Usage: sc_spinner_start "Loading..." [style]
# Returns: PID of spinner process
sc_spinner_start() {
    local message=${1:-"Loading..."}
    local style=${2:-"dots"}

    # Hide cursor
    tput civis 2>/dev/null

    # Start spinner in background
    # Output to stderr to avoid blocking command substitution
    (
        # Define spinner frames directly in subshell (arrays can't be exported)
        local spinner_frames
        case "$style" in
            dots)    spinner_frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏") ;;
            line)    spinner_frames=("⠋" "⠙" "⠚" "⠞" "⠖" "⠦" "⠴" "⠲" "⠳" "⠓") ;;
            arrow)   spinner_frames=("←" "↖" "↑" "↗" "→" "↘" "↓" "↙") ;;
            circle)  spinner_frames=("◴" "◷" "◶" "◵") ;;
            bounce)  spinner_frames=("⠁" "⠂" "⠄" "⡀" "⢀" "⠠" "⠐" "⠈") ;;
            classic) spinner_frames=("|" "/" "-" "\\") ;;
            *)       spinner_frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏") ;;
        esac

        local i=0
        local frame_count=${#spinner_frames[@]}
        while true; do
            local frame="${spinner_frames[$i]}"
            printf "\r${SC_CYAN}${frame}${SC_RESET} ${message}" >&2
            i=$(( (i + 1) % frame_count ))
            sleep 0.1
        done
    ) &

    echo $!
}

# Stop a spinner
# Usage: sc_spinner_stop <pid> [message]
sc_spinner_stop() {
    local pid=$1
    local message=${2:-""}

    # Kill spinner process
    kill "$pid" 2>/dev/null
    wait "$pid" 2>/dev/null

    # Clear line
    printf "\r\033[K"

    # Show success message if provided
    if [[ -n "$message" ]]; then
        echo -e "${SC_GREEN}✓${SC_RESET} ${message}"
    fi

    # Show cursor
    tput cnorm 2>/dev/null
}

# Run command with spinner
# Usage: sc_spinner_run "Loading..." <command>
sc_spinner_run() {
    local message=$1
    shift
    local command="$*"

    local spinner_pid
    spinner_pid=$(sc_spinner_start "$message")

    # Run command (capture output)
    local output
    local exit_code
    if output=$($command 2>&1); then
        exit_code=0
        sc_spinner_stop "$spinner_pid" "$message"
    else
        exit_code=$?
        sc_spinner_stop "$spinner_pid"
        echo -e "${SC_RED}✗${SC_RESET} ${message} (failed)"
    fi

    return $exit_code
}

# ============================================================================
# Progress Bar Functions
# ============================================================================

# Draw a progress bar
# Usage: sc_progress_bar <current> <total> [label] [width]
sc_progress_bar() {
    local current=$1
    local total=$2
    local label=${3:-""}
    local width=${4:-$SC_PROGRESS_BAR_WIDTH}

    # Calculate percentage
    local percentage=0
    if [[ $total -gt 0 ]]; then
        percentage=$(( current * 100 / total ))
    fi

    # Calculate filled width
    local filled=$(( current * width / total ))
    [[ $filled -gt $width ]] && filled=$width

    # Build progress bar
    local bar=""
    for ((i=0; i<filled; i++)); do
        bar="${bar}${SC_PROGRESS_BAR_CHAR}"
    done
    for ((i=filled; i<width; i++)); do
        bar="${bar}${SC_PROGRESS_EMPTY_CHAR}"
    done

    # Choose color based on progress
    local color=$SC_CYAN
    if [[ $percentage -ge 100 ]]; then
        color=$SC_GREEN
    elif [[ $percentage -ge 75 ]]; then
        color=$SC_BLUE
    elif [[ $percentage -ge 50 ]]; then
        color=$SC_YELLOW
    fi

    # Print progress bar
    printf "\r%s ${color}[%s]${SC_RESET} %3d%% (%d/%d)" \
        "$label" "$bar" "$percentage" "$current" "$total"
}

# Progress bar with completion
# Usage: sc_progress_bar_done <total> [label]
sc_progress_bar_done() {
    local total=$1
    local label=${2:-""}

    sc_progress_bar "$total" "$total" "$label"
    echo ""
}

# ============================================================================
# Advanced Progress Display
# ============================================================================

# Start progress tracking
# Usage: sc_progress_start <total> [label]
sc_progress_start() {
    export SC_PROGRESS_TOTAL=$1
    export SC_PROGRESS_CURRENT=0
    export SC_PROGRESS_LABEL=${2:-"Progress"}
    export SC_PROGRESS_START_TIME=$(date +%s)

    sc_progress_bar 0 "$SC_PROGRESS_TOTAL" "$SC_PROGRESS_LABEL"
}

# Update progress
# Usage: sc_progress_update [increment]
sc_progress_update() {
    local increment=${1:-1}
    SC_PROGRESS_CURRENT=$((SC_PROGRESS_CURRENT + increment))

    # Calculate ETA
    local elapsed=$(($(date +%s) - SC_PROGRESS_START_TIME))
    local eta=""
    if [[ $SC_PROGRESS_CURRENT -gt 0 && $elapsed -gt 0 ]]; then
        local rate=$((SC_PROGRESS_CURRENT * 100 / elapsed))
        local remaining=$((SC_PROGRESS_TOTAL - SC_PROGRESS_CURRENT))
        if [[ $rate -gt 0 ]]; then
            local eta_seconds=$((remaining * 100 / rate))
            eta=" ETA: ${eta_seconds}s"
        fi
    fi

    sc_progress_bar "$SC_PROGRESS_CURRENT" "$SC_PROGRESS_TOTAL" "${SC_PROGRESS_LABEL}${eta}"
}

# Finish progress
# Usage: sc_progress_finish [message]
sc_progress_finish() {
    local message=${1:-"Complete"}

    sc_progress_bar_done "$SC_PROGRESS_TOTAL" "$SC_PROGRESS_LABEL"
    echo -e "${SC_GREEN}✓${SC_RESET} ${message}"

    # Cleanup
    unset SC_PROGRESS_TOTAL SC_PROGRESS_CURRENT SC_PROGRESS_LABEL SC_PROGRESS_START_TIME
}

# ============================================================================
# Simple Progress Functions
# ============================================================================

# Show indeterminate progress (for unknown duration)
# Usage: sc_progress_indeterminate "Processing..." &
# PID=$!
# ... do work ...
# kill $PID; wait $PID 2>/dev/null
sc_progress_indeterminate() {
    local message=${1:-"Processing..."}
    local chars=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    local i=0

    tput civis 2>/dev/null
    while true; do
        printf "\r${SC_CYAN}%s${SC_RESET} %s" "${chars[$i]}" "$message"
        i=$(( (i + 1) % ${#chars[@]} ))
        sleep 0.1
    done
}

# Show percentage progress (simple)
# Usage: sc_progress_percent <percent> [label]
sc_progress_percent() {
    local percent=$1
    local label=${2:-"Progress"}

    # Choose color
    local color=$SC_CYAN
    if [[ $percent -ge 100 ]]; then
        color=$SC_GREEN
    elif [[ $percent -ge 75 ]]; then
        color=$SC_BLUE
    fi

    printf "\r%s: ${color}%3d%%${SC_RESET}" "$label" "$percent"
}

# ============================================================================
# Multi-line Progress Display
# ============================================================================

# Initialize multi-line progress display
# Usage: sc_progress_multi_init <lines>
sc_progress_multi_init() {
    local lines=$1
    export SC_PROGRESS_MULTI_LINES=$lines

    # Reserve space for progress lines
    for ((i=0; i<lines; i++)); do
        echo ""
    done
}

# Update a line in multi-line progress
# Usage: sc_progress_multi_update <line_num> <message>
sc_progress_multi_update() {
    local line=$1
    local message=$2

    # Move cursor up to target line
    local up=$((SC_PROGRESS_MULTI_LINES - line))
    tput cuu $up 2>/dev/null

    # Clear and write line
    printf "\r\033[K%s" "$message"

    # Move cursor back down
    tput cud $up 2>/dev/null
}

# Clear multi-line progress display
sc_progress_multi_clear() {
    local lines=${SC_PROGRESS_MULTI_LINES:-1}

    # Move up and clear each line
    for ((i=0; i<lines; i++)); do
        tput cuu 1 2>/dev/null
        printf "\r\033[K"
    done

    unset SC_PROGRESS_MULTI_LINES
}

# ============================================================================
# Utility Functions
# ============================================================================

# Format bytes for progress display
# Usage: sc_progress_format_bytes <bytes>
sc_progress_format_bytes() {
    local bytes=$1

    if [[ $bytes -lt 1024 ]]; then
        echo "${bytes}B"
    elif [[ $bytes -lt 1048576 ]]; then
        echo "$((bytes / 1024))KB"
    elif [[ $bytes -lt 1073741824 ]]; then
        echo "$((bytes / 1048576))MB"
    else
        echo "$((bytes / 1073741824))GB"
    fi
}

# Format time for progress display
# Usage: sc_progress_format_time <seconds>
sc_progress_format_time() {
    local seconds=$1

    if [[ $seconds -lt 60 ]]; then
        echo "${seconds}s"
    elif [[ $seconds -lt 3600 ]]; then
        echo "$((seconds / 60))m $((seconds % 60))s"
    else
        echo "$((seconds / 3600))h $((seconds % 3600 / 60))m"
    fi
}

# ============================================================================
# Example Usage
# ============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "ShellCandy Progress Module"
    echo "=========================="
    echo ""

    # Example 1: Spinner
    echo "Example 1: Spinner"
    spinner_pid=$(sc_spinner_start "Loading data...")
    sleep 2
    sc_spinner_stop "$spinner_pid" "Data loaded successfully"
    echo ""

    # Example 2: Different spinner styles
    echo "Example 2: Spinner Styles"
    for style in dots line arrow circle bounce classic; do
        spinner_pid=$(sc_spinner_start "Testing $style style..." "$style")
        sleep 1
        sc_spinner_stop "$spinner_pid"
    done
    echo ""

    # Example 3: Progress bar
    echo "Example 3: Progress Bar"
    for i in {0..100..10}; do
        sc_progress_bar $i 100 "Downloading"
        sleep 0.2
    done
    echo ""
    echo ""

    # Example 4: Progress tracking
    echo "Example 4: Progress Tracking with ETA"
    sc_progress_start 50 "Processing items"
    for i in {1..50}; do
        sc_progress_update
        sleep 0.05
    done
    sc_progress_finish "All items processed"
    echo ""

    # Example 5: Percentage progress
    echo "Example 5: Percentage Display"
    for p in {0..100..20}; do
        sc_progress_percent $p "Upload"
        sleep 0.3
    done
    echo ""
    echo ""

    # Example 6: Multi-line progress
    echo "Example 6: Multi-line Progress"
    sc_progress_multi_init 3
    for i in {1..10}; do
        sc_progress_multi_update 0 "${SC_CYAN}Task 1:${SC_RESET} Processing file $i"
        sc_progress_multi_update 1 "${SC_YELLOW}Task 2:${SC_RESET} Analyzing data $i"
        sc_progress_multi_update 2 "${SC_GREEN}Task 3:${SC_RESET} Saving results $i"
        sleep 0.3
    done
    sc_progress_multi_clear
    echo -e "${SC_GREEN}✓${SC_RESET} All tasks complete"
    echo ""

    echo "Examples complete!"
fi
