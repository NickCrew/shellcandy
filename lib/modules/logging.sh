#!/bin/bash
# logging.sh - Advanced logging system for ShellCandy
# Version: 1.0.0
#
# Provides comprehensive logging with:
# - Multiple log levels (DEBUG, INFO, WARN, ERROR, FATAL)
# - Colored console output
# - Optional file logging
# - Timestamp formatting
# - Structured log formatting
# - Log rotation support

# Prevent multiple sourcing
[[ -n "${SHELLCANDY_LOGGING_LOADED}" ]] && return 0
export SHELLCANDY_LOGGING_LOADED=1

# Source colors module if available
if [[ -f "$(dirname "${BASH_SOURCE[0]}")/colors.sh" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/colors.sh"
else
    # Fallback colors if colors.sh not available
    SC_RED='\033[0;31m'
    SC_GREEN='\033[0;32m'
    SC_YELLOW='\033[0;33m'
    SC_BLUE='\033[0;34m'
    SC_CYAN='\033[0;36m'
    SC_BRIGHT_RED='\033[0;91m'
    SC_DIM='\033[2m'
    SC_BOLD='\033[1m'
    SC_RESET='\033[0m'
    SC_NC='\033[0m'
fi

# ============================================================================
# Configuration
# ============================================================================

# Log levels (numerical values for comparison)
export SC_LOG_LEVEL_DEBUG=0
export SC_LOG_LEVEL_INFO=1
export SC_LOG_LEVEL_WARN=2
export SC_LOG_LEVEL_ERROR=3
export SC_LOG_LEVEL_FATAL=4

# Default log level (INFO)
export SC_LOG_LEVEL=${SC_LOG_LEVEL:-$SC_LOG_LEVEL_INFO}

# Log file configuration
export SC_LOG_FILE=${SC_LOG_FILE:-""}
export SC_LOG_TO_FILE=${SC_LOG_TO_FILE:-false}
export SC_LOG_TO_CONSOLE=${SC_LOG_TO_CONSOLE:-true}

# Log format options
export SC_LOG_TIMESTAMP=${SC_LOG_TIMESTAMP:-true}
export SC_LOG_COLORS=${SC_LOG_COLORS:-true}
export SC_LOG_PREFIX=${SC_LOG_PREFIX:-""}
export SC_LOG_DATE_FORMAT=${SC_LOG_DATE_FORMAT:-"%Y-%m-%d %H:%M:%S"}

# Log rotation
export SC_LOG_MAX_SIZE=${SC_LOG_MAX_SIZE:-10485760}  # 10MB
export SC_LOG_MAX_FILES=${SC_LOG_MAX_FILES:-5}

# ============================================================================
# Level Configuration
# ============================================================================

# Set log level
# Usage: sc_log_set_level <DEBUG|INFO|WARN|ERROR|FATAL>
sc_log_set_level() {
    local level=$1
    case "${level^^}" in
        DEBUG) export SC_LOG_LEVEL=$SC_LOG_LEVEL_DEBUG ;;
        INFO)  export SC_LOG_LEVEL=$SC_LOG_LEVEL_INFO ;;
        WARN)  export SC_LOG_LEVEL=$SC_LOG_LEVEL_WARN ;;
        ERROR) export SC_LOG_LEVEL=$SC_LOG_LEVEL_ERROR ;;
        FATAL) export SC_LOG_LEVEL=$SC_LOG_LEVEL_FATAL ;;
        *) echo "Invalid log level: $level" >&2; return 1 ;;
    esac
}

# Set log file
# Usage: sc_log_set_file <path>
sc_log_set_file() {
    export SC_LOG_FILE=$1
    export SC_LOG_TO_FILE=true

    # Create log directory if needed
    local log_dir=$(dirname "$SC_LOG_FILE")
    mkdir -p "$log_dir" 2>/dev/null
}

# ============================================================================
# Core Logging Functions
# ============================================================================

# Internal logging function
# Usage: _sc_log <level_num> <level_name> <color> <message...>
_sc_log() {
    local level_num=$1
    local level_name=$2
    local color=$3
    shift 3
    local message="$*"

    # Check if we should log this level
    [[ $level_num -lt $SC_LOG_LEVEL ]] && return 0

    # Build timestamp
    local timestamp=""
    if [[ "$SC_LOG_TIMESTAMP" == "true" ]]; then
        timestamp=$(date +"$SC_LOG_DATE_FORMAT")
    fi

    # Build log line for console
    local console_line=""
    local file_line=""

    if [[ -n "$timestamp" ]]; then
        if [[ "$SC_LOG_COLORS" == "true" && "$SC_LOG_TO_CONSOLE" == "true" ]]; then
            console_line="${SC_DIM}${timestamp}${SC_RESET} ${color}[${level_name}]${SC_RESET}"
        else
            console_line="${timestamp} [${level_name}]"
        fi
        file_line="${timestamp} [${level_name}]"
    else
        if [[ "$SC_LOG_COLORS" == "true" && "$SC_LOG_TO_CONSOLE" == "true" ]]; then
            console_line="${color}[${level_name}]${SC_RESET}"
        else
            console_line="[${level_name}]"
        fi
        file_line="[${level_name}]"
    fi

    # Add prefix if set
    if [[ -n "$SC_LOG_PREFIX" ]]; then
        console_line="${console_line} ${SC_LOG_PREFIX}"
        file_line="${file_line} ${SC_LOG_PREFIX}"
    fi

    # Add message
    console_line="${console_line} ${message}"
    file_line="${file_line} ${message}"

    # Output to console
    if [[ "$SC_LOG_TO_CONSOLE" == "true" ]]; then
        if [[ $level_num -ge $SC_LOG_LEVEL_ERROR ]]; then
            echo -e "$console_line" >&2
        else
            echo -e "$console_line"
        fi
    fi

    # Output to file
    if [[ "$SC_LOG_TO_FILE" == "true" && -n "$SC_LOG_FILE" ]]; then
        # Check if rotation needed
        if [[ -f "$SC_LOG_FILE" ]]; then
            local file_size=$(stat -f%z "$SC_LOG_FILE" 2>/dev/null || stat -c%s "$SC_LOG_FILE" 2>/dev/null || echo 0)
            if [[ $file_size -ge $SC_LOG_MAX_SIZE ]]; then
                _sc_log_rotate
            fi
        fi

        # Write to file (strip ANSI codes)
        echo "$file_line" | sed 's/\x1b\[[0-9;]*m//g' >> "$SC_LOG_FILE"
    fi
}

# Rotate log files
_sc_log_rotate() {
    [[ -z "$SC_LOG_FILE" || ! -f "$SC_LOG_FILE" ]] && return 0

    # Rotate existing logs
    for ((i=$SC_LOG_MAX_FILES-1; i>=1; i--)); do
        local old="${SC_LOG_FILE}.${i}"
        local new="${SC_LOG_FILE}.$((i+1))"
        [[ -f "$old" ]] && mv "$old" "$new"
    done

    # Move current log
    [[ -f "$SC_LOG_FILE" ]] && mv "$SC_LOG_FILE" "${SC_LOG_FILE}.1"
}

# ============================================================================
# Public Logging Functions
# ============================================================================

# Debug level logging
# Usage: sc_log_debug "message"
sc_log_debug() {
    _sc_log $SC_LOG_LEVEL_DEBUG "DEBUG" "$SC_CYAN" "$*"
}

# Info level logging
# Usage: sc_log_info "message"
sc_log_info() {
    _sc_log $SC_LOG_LEVEL_INFO "INFO" "$SC_GREEN" "$*"
}

# Warning level logging
# Usage: sc_log_warn "message"
sc_log_warn() {
    _sc_log $SC_LOG_LEVEL_WARN "WARN" "$SC_YELLOW" "$*"
}

# Error level logging
# Usage: sc_log_error "message"
sc_log_error() {
    _sc_log $SC_LOG_LEVEL_ERROR "ERROR" "$SC_RED" "$*"
}

# Fatal level logging (and exit)
# Usage: sc_log_fatal "message" [exit_code]
sc_log_fatal() {
    local message=$1
    local exit_code=${2:-1}
    _sc_log $SC_LOG_LEVEL_FATAL "FATAL" "$SC_BRIGHT_RED" "$message"
    exit "$exit_code"
}

# ============================================================================
# Structured Logging
# ============================================================================

# Log with custom fields
# Usage: sc_log_structured <level> <key1=value1> <key2=value2> ...
sc_log_structured() {
    local level=$1
    shift

    local message=""
    for field in "$@"; do
        message="${message} ${field}"
    done

    case "${level^^}" in
        DEBUG) sc_log_debug "$message" ;;
        INFO)  sc_log_info "$message" ;;
        WARN)  sc_log_warn "$message" ;;
        ERROR) sc_log_error "$message" ;;
        FATAL) sc_log_fatal "$message" ;;
        *) sc_log_error "Invalid log level: $level" ;;
    esac
}

# ============================================================================
# Convenience Functions
# ============================================================================

# Log success message
# Usage: sc_log_success "message"
sc_log_success() {
    _sc_log $SC_LOG_LEVEL_INFO "SUCCESS" "$SC_GREEN" "✓ $*"
}

# Log failure message
# Usage: sc_log_failure "message"
sc_log_failure() {
    _sc_log $SC_LOG_LEVEL_ERROR "FAILURE" "$SC_RED" "✗ $*"
}

# Log with custom level name and color
# Usage: sc_log_custom <level_num> <level_name> <color> <message>
sc_log_custom() {
    local level_num=$1
    local level_name=$2
    local color=$3
    shift 3
    _sc_log "$level_num" "$level_name" "$color" "$*"
}

# ============================================================================
# Section Logging
# ============================================================================

# Log section header
# Usage: sc_log_section "Section Name"
sc_log_section() {
    local title=$1
    echo ""
    echo -e "${SC_BOLD}${SC_BLUE}▓▓▓ ${title} ▓▓▓${SC_RESET}"
    echo ""
}

# Log subsection header
# Usage: sc_log_subsection "Subsection Name"
sc_log_subsection() {
    local title=$1
    echo -e "${SC_BOLD}${SC_CYAN}▸ ${title}${SC_RESET}"
}

# ============================================================================
# Progress Logging
# ============================================================================

# Log step in a process
# Usage: sc_log_step <current> <total> <message>
sc_log_step() {
    local current=$1
    local total=$2
    local message=$3

    local progress="[${current}/${total}]"
    _sc_log $SC_LOG_LEVEL_INFO "STEP" "$SC_BLUE" "${progress} ${message}"
}

# Log task start
# Usage: sc_log_task_start "Task name"
sc_log_task_start() {
    _sc_log $SC_LOG_LEVEL_INFO "START" "$SC_CYAN" "→ $*"
}

# Log task end
# Usage: sc_log_task_end "Task name"
sc_log_task_end() {
    _sc_log $SC_LOG_LEVEL_INFO "END" "$SC_GREEN" "✓ $*"
}

# ============================================================================
# Utility Functions
# ============================================================================

# Get current log level name
sc_log_get_level() {
    case $SC_LOG_LEVEL in
        $SC_LOG_LEVEL_DEBUG) echo "DEBUG" ;;
        $SC_LOG_LEVEL_INFO)  echo "INFO" ;;
        $SC_LOG_LEVEL_WARN)  echo "WARN" ;;
        $SC_LOG_LEVEL_ERROR) echo "ERROR" ;;
        $SC_LOG_LEVEL_FATAL) echo "FATAL" ;;
        *) echo "UNKNOWN" ;;
    esac
}

# Show current logging configuration
sc_log_config() {
    echo "ShellCandy Logging Configuration:"
    echo "  Log Level:      $(sc_log_get_level)"
    echo "  Log to Console: $SC_LOG_TO_CONSOLE"
    echo "  Log to File:    $SC_LOG_TO_FILE"
    [[ -n "$SC_LOG_FILE" ]] && echo "  Log File:       $SC_LOG_FILE"
    echo "  Timestamps:     $SC_LOG_TIMESTAMP"
    echo "  Colors:         $SC_LOG_COLORS"
    [[ -n "$SC_LOG_PREFIX" ]] && echo "  Prefix:         $SC_LOG_PREFIX"
}

# Clear log file
sc_log_clear() {
    if [[ -n "$SC_LOG_FILE" && -f "$SC_LOG_FILE" ]]; then
        > "$SC_LOG_FILE"
        sc_log_info "Log file cleared: $SC_LOG_FILE"
    fi
}

# ============================================================================
# Example Usage
# ============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "ShellCandy Logging Module"
    echo "========================="
    echo ""

    # Show configuration
    sc_log_config
    echo ""

    # Basic logging
    echo "Basic Logging:"
    sc_log_debug "This is a debug message"
    sc_log_info "This is an info message"
    sc_log_warn "This is a warning message"
    sc_log_error "This is an error message"
    echo ""

    # Convenience functions
    echo "Convenience Functions:"
    sc_log_success "Operation completed successfully"
    sc_log_failure "Operation failed"
    echo ""

    # Section logging
    sc_log_section "Main Section"
    sc_log_subsection "Subsection 1"
    sc_log_info "Content in subsection 1"
    sc_log_subsection "Subsection 2"
    sc_log_info "Content in subsection 2"
    echo ""

    # Progress logging
    echo "Progress Logging:"
    sc_log_task_start "Processing data"
    sc_log_step 1 3 "Loading configuration"
    sleep 0.5
    sc_log_step 2 3 "Processing records"
    sleep 0.5
    sc_log_step 3 3 "Saving results"
    sleep 0.5
    sc_log_task_end "Processing data"
    echo ""

    # Structured logging
    echo "Structured Logging:"
    sc_log_structured INFO "user=admin" "action=login" "status=success"
    sc_log_structured WARN "disk_usage=85%" "threshold=80%" "action=cleanup_needed"
    echo ""

    # Different log levels
    echo "Testing different log levels:"
    echo "Setting level to WARN..."
    sc_log_set_level WARN
    sc_log_debug "This won't show (DEBUG < WARN)"
    sc_log_info "This won't show (INFO < WARN)"
    sc_log_warn "This will show (WARN = WARN)"
    sc_log_error "This will show (ERROR > WARN)"
    echo ""

    # Reset to INFO
    sc_log_set_level INFO

    # File logging example
    echo "File Logging:"
    sc_log_set_file "/tmp/shellcandy-test.log"
    sc_log_info "This message goes to both console and file"
    sc_log_success "Check /tmp/shellcandy-test.log for file output"
    echo ""

    # Custom logging
    echo "Custom Logging:"
    sc_log_custom $SC_LOG_LEVEL_INFO "CUSTOM" "$SC_MAGENTA" "Custom level with magenta color"
    echo ""

    echo "Examples complete! Check the source code for more details."
fi
