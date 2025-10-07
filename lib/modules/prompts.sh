#!/bin/bash
# prompts.sh - Interactive input prompts for ShellCandy
# Version: 1.0.0
#
# Provides:
# - Text input with validation
# - Password input (masked)
# - Yes/No confirmation
# - Select from list (single/multi)
# - Number input with range validation
# - File/directory picker
# - Input history
# - Default values

# Prevent multiple sourcing
[[ -n "${SHELLCANDY_PROMPTS_LOADED}" ]] && return 0
export SHELLCANDY_PROMPTS_LOADED=1

# Source dependencies
if [[ -f "$(dirname "${BASH_SOURCE[0]}")/colors.sh" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/colors.sh"
fi

if [[ -f "$(dirname "${BASH_SOURCE[0]}")/icons.sh" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/icons.sh"
fi

# Fallback if modules not available
SC_GREEN=${SC_GREEN:-'\033[0;32m'}
SC_RED=${SC_RED:-'\033[0;31m'}
SC_YELLOW=${SC_YELLOW:-'\033[0;33m'}
SC_BLUE=${SC_BLUE:-'\033[0;34m'}
SC_CYAN=${SC_CYAN:-'\033[0;36m'}
SC_BOLD=${SC_BOLD:-'\033[1m'}
SC_DIM=${SC_DIM:-'\033[2m'}
SC_RESET=${SC_RESET:-'\033[0m'}

# ============================================================================
# Configuration
# ============================================================================

export SC_PROMPT_PREFIX="${SC_CYAN}?${SC_RESET}"
export SC_PROMPT_SUCCESS="${SC_GREEN}✓${SC_RESET}"
export SC_PROMPT_ERROR="${SC_RED}✗${SC_RESET}"
export SC_PROMPT_ARROW="${SC_CYAN}›${SC_RESET}"

# Input history
export SC_PROMPT_HISTORY_FILE="${HOME}/.shellcandy_history"
export SC_PROMPT_HISTORY_MAX=100

# ============================================================================
# Utility Functions
# ============================================================================

# Print prompt with prefix
_sc_prompt_print() {
    local message=$1
    local default=${2:-""}

    if [[ -n "$default" ]]; then
        printf "${SC_PROMPT_PREFIX} ${SC_BOLD}%s${SC_RESET} ${SC_DIM}(%s)${SC_RESET} ${SC_PROMPT_ARROW} " "$message" "$default"
    else
        printf "${SC_PROMPT_PREFIX} ${SC_BOLD}%s${SC_RESET} ${SC_PROMPT_ARROW} " "$message"
    fi
}

# Print error message
_sc_prompt_error() {
    printf "\r${SC_PROMPT_ERROR} ${SC_RED}%s${SC_RESET}\n" "$1"
}

# Print success message
_sc_prompt_success() {
    printf "\r${SC_PROMPT_SUCCESS} ${SC_GREEN}%s${SC_RESET}\n" "$1"
}

# Save to history
_sc_prompt_save_history() {
    local value=$1
    [[ -z "$value" ]] && return

    # Append to history file
    echo "$value" >> "$SC_PROMPT_HISTORY_FILE"

    # Trim to max size
    if [[ -f "$SC_PROMPT_HISTORY_FILE" ]]; then
        tail -n "$SC_PROMPT_HISTORY_MAX" "$SC_PROMPT_HISTORY_FILE" > "${SC_PROMPT_HISTORY_FILE}.tmp"
        mv "${SC_PROMPT_HISTORY_FILE}.tmp" "$SC_PROMPT_HISTORY_FILE"
    fi
}

# ============================================================================
# Text Input
# ============================================================================

# Prompt for text input
# Usage: value=$(sc_prompt_text "Enter name:" [default] [validator_function])
sc_prompt_text() {
    local message=$1
    local default=${2:-""}
    local validator=${3:-""}

    while true; do
        _sc_prompt_print "$message" "$default"
        read -r input

        # Use default if empty
        [[ -z "$input" && -n "$default" ]] && input="$default"

        # Validate if validator provided
        if [[ -n "$validator" ]]; then
            if $validator "$input"; then
                _sc_prompt_save_history "$input"
                echo "$input"
                return 0
            else
                _sc_prompt_error "Invalid input. Please try again."
                continue
            fi
        fi

        # No validator, accept any non-empty input
        if [[ -n "$input" ]]; then
            _sc_prompt_save_history "$input"
            echo "$input"
            return 0
        else
            _sc_prompt_error "Input cannot be empty."
        fi
    done
}

# Prompt for password (masked input)
# Usage: password=$(sc_prompt_password "Enter password:")
sc_prompt_password() {
    local message=$1
    local password=""

    _sc_prompt_print "$message"

    # Read password without echoing
    while IFS= read -r -s -n1 char; do
        # Handle backspace
        if [[ $char == $'\177' ]]; then
            if [[ -n "$password" ]]; then
                password="${password%?}"
                printf "\b \b"
            fi
        # Handle Enter
        elif [[ $char == $'\n' || $char == $'\r' || -z "$char" ]]; then
            break
        # Normal character
        else
            password+="$char"
            printf "*"
        fi
    done

    echo ""
    echo "$password"
}

# ============================================================================
# Confirmation
# ============================================================================

# Prompt for yes/no confirmation
# Usage: if sc_prompt_confirm "Continue?"; then ...; fi
# Usage: if sc_prompt_confirm "Delete?" "n"; then ...; fi  # default no
sc_prompt_confirm() {
    local message=$1
    local default=${2:-"y"}  # y or n

    local prompt_text="Y/n"
    [[ "${default,,}" == "n" ]] && prompt_text="y/N"

    while true; do
        printf "${SC_PROMPT_PREFIX} ${SC_BOLD}%s${SC_RESET} ${SC_DIM}(%s)${SC_RESET} ${SC_PROMPT_ARROW} " "$message" "$prompt_text"
        read -r response

        # Use default if empty
        [[ -z "$response" ]] && response="$default"

        case "${response,,}" in
            y|yes)
                return 0
                ;;
            n|no)
                return 1
                ;;
            *)
                _sc_prompt_error "Please answer y or n."
                ;;
        esac
    done
}

# ============================================================================
# Select from List
# ============================================================================

# Prompt to select from list
# Usage: choice=$(sc_prompt_select "Choose option:" "Option 1" "Option 2" "Option 3")
sc_prompt_select() {
    local message=$1
    shift
    local options=("$@")

    if [[ ${#options[@]} -eq 0 ]]; then
        _sc_prompt_error "No options provided"
        return 1
    fi

    # Print header
    echo -e "${SC_PROMPT_PREFIX} ${SC_BOLD}${message}${SC_RESET}"
    echo ""

    # Print options
    for i in "${!options[@]}"; do
        printf "  ${SC_DIM}%d)${SC_RESET} %s\n" "$((i+1))" "${options[$i]}"
    done
    echo ""

    # Get selection
    while true; do
        printf "${SC_PROMPT_ARROW} Enter choice ${SC_DIM}(1-${#options[@]})${SC_RESET}: "
        read -r choice

        # Validate numeric input
        if [[ ! "$choice" =~ ^[0-9]+$ ]]; then
            _sc_prompt_error "Please enter a number."
            continue
        fi

        # Validate range
        if [[ $choice -lt 1 || $choice -gt ${#options[@]} ]]; then
            _sc_prompt_error "Please enter a number between 1 and ${#options[@]}."
            continue
        fi

        # Return selected option
        echo "${options[$((choice-1))]}"
        return 0
    done
}

# Prompt to select multiple from list
# Usage: sc_prompt_multiselect "Select items:" selected_array "Item1" "Item2" "Item3"
sc_prompt_multiselect() {
    local message=$1
    local -n result_array=$2
    shift 2
    local options=("$@")

    if [[ ${#options[@]} -eq 0 ]]; then
        _sc_prompt_error "No options provided"
        return 1
    fi

    # Initialize selection state
    local -a selected
    for ((i=0; i<${#options[@]}; i++)); do
        selected[$i]=0
    done

    # Print instructions
    echo -e "${SC_PROMPT_PREFIX} ${SC_BOLD}${message}${SC_RESET}"
    echo -e "${SC_DIM}Enter numbers separated by spaces (e.g., 1 3 5) or 'all' or 'none'${SC_RESET}"
    echo ""

    # Print options
    for i in "${!options[@]}"; do
        printf "  ${SC_DIM}%d)${SC_RESET} %s\n" "$((i+1))" "${options[$i]}"
    done
    echo ""

    # Get selections
    while true; do
        printf "${SC_PROMPT_ARROW} Enter choices: "
        read -r input

        # Handle special commands
        if [[ "${input,,}" == "all" ]]; then
            for i in "${!selected[@]}"; do
                selected[$i]=1
            done
            break
        elif [[ "${input,,}" == "none" ]]; then
            break
        fi

        # Parse numbers
        local valid=true
        local -a choices
        read -ra choices <<< "$input"

        for choice in "${choices[@]}"; do
            if [[ ! "$choice" =~ ^[0-9]+$ ]]; then
                _sc_prompt_error "Invalid input: $choice"
                valid=false
                break
            fi

            if [[ $choice -lt 1 || $choice -gt ${#options[@]} ]]; then
                _sc_prompt_error "Number out of range: $choice"
                valid=false
                break
            fi

            selected[$((choice-1))]=1
        done

        [[ "$valid" == true ]] && break
    done

    # Build result array
    result_array=()
    for i in "${!selected[@]}"; do
        if [[ ${selected[$i]} -eq 1 ]]; then
            result_array+=("${options[$i]}")
        fi
    done

    return 0
}

# ============================================================================
# Number Input
# ============================================================================

# Prompt for number input with optional range validation
# Usage: num=$(sc_prompt_number "Enter age:" [min] [max] [default])
sc_prompt_number() {
    local message=$1
    local min=${2:-""}
    local max=${3:-""}
    local default=${4:-""}

    # Build validation message
    local validation=""
    if [[ -n "$min" && -n "$max" ]]; then
        validation=" (${min}-${max})"
    elif [[ -n "$min" ]]; then
        validation=" (>=${min})"
    elif [[ -n "$max" ]]; then
        validation=" (<=${max})"
    fi

    while true; do
        _sc_prompt_print "${message}${validation}" "$default"
        read -r input

        # Use default if empty
        [[ -z "$input" && -n "$default" ]] && input="$default"

        # Check if numeric
        if [[ ! "$input" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
            _sc_prompt_error "Please enter a valid number."
            continue
        fi

        # Check min
        if [[ -n "$min" ]] && (( $(echo "$input < $min" | bc -l 2>/dev/null || echo 0) )); then
            _sc_prompt_error "Number must be >= $min"
            continue
        fi

        # Check max
        if [[ -n "$max" ]] && (( $(echo "$input > $max" | bc -l 2>/dev/null || echo 0) )); then
            _sc_prompt_error "Number must be <= $max"
            continue
        fi

        echo "$input"
        return 0
    done
}

# ============================================================================
# File/Directory Picker
# ============================================================================

# Prompt for file selection
# Usage: file=$(sc_prompt_file "Select file:" [pattern])
sc_prompt_file() {
    local message=$1
    local pattern=${2:-"*"}

    while true; do
        _sc_prompt_print "$message"
        read -e -r file  # -e enables tab completion

        # Check if file exists
        if [[ -f "$file" ]]; then
            # Check pattern if provided
            if [[ "$pattern" != "*" ]]; then
                if [[ ! "$file" == $pattern ]]; then
                    _sc_prompt_error "File must match pattern: $pattern"
                    continue
                fi
            fi

            echo "$file"
            return 0
        else
            _sc_prompt_error "File not found: $file"
        fi
    done
}

# Prompt for directory selection
# Usage: dir=$(sc_prompt_directory "Select directory:")
sc_prompt_directory() {
    local message=$1

    while true; do
        _sc_prompt_print "$message"
        read -e -r dir  # -e enables tab completion

        # Check if directory exists
        if [[ -d "$dir" ]]; then
            echo "$dir"
            return 0
        else
            _sc_prompt_error "Directory not found: $dir"
        fi
    done
}

# ============================================================================
# Advanced Validators
# ============================================================================

# Email validator
sc_validate_email() {
    local email=$1
    if [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        return 0
    fi
    return 1
}

# URL validator
sc_validate_url() {
    local url=$1
    if [[ "$url" =~ ^https?://[a-zA-Z0-9.-]+\.[a-zA-Z]{2,} ]]; then
        return 0
    fi
    return 1
}

# IP address validator
sc_validate_ip() {
    local ip=$1
    if [[ "$ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        # Check each octet is <= 255
        IFS='.' read -ra octets <<< "$ip"
        for octet in "${octets[@]}"; do
            if [[ $octet -gt 255 ]]; then
                return 1
            fi
        done
        return 0
    fi
    return 1
}

# Non-empty validator
sc_validate_nonempty() {
    local value=$1
    [[ -n "$value" ]]
}

# Alphanumeric validator
sc_validate_alphanumeric() {
    local value=$1
    [[ "$value" =~ ^[a-zA-Z0-9]+$ ]]
}

# ============================================================================
# Composite Prompts
# ============================================================================

# Prompt for email
# Usage: email=$(sc_prompt_email "Enter email:")
sc_prompt_email() {
    local message=$1
    sc_prompt_text "$message" "" sc_validate_email
}

# Prompt for URL
# Usage: url=$(sc_prompt_url "Enter URL:")
sc_prompt_url() {
    local message=$1
    sc_prompt_text "$message" "" sc_validate_url
}

# Prompt for IP address
# Usage: ip=$(sc_prompt_ip "Enter IP:")
sc_prompt_ip() {
    local message=$1
    sc_prompt_text "$message" "" sc_validate_ip
}

# ============================================================================
# Form Builder
# ============================================================================

# Create a form with multiple prompts
# Usage: sc_prompt_form
sc_prompt_form() {
    local form_title=$1
    shift

    echo ""
    echo -e "${SC_BOLD}${SC_CYAN}╔══════════════════════════════════════════════╗${SC_RESET}"
    echo -e "${SC_BOLD}${SC_CYAN}║${SC_RESET}  ${SC_BOLD}${form_title}${SC_RESET}"
    echo -e "${SC_BOLD}${SC_CYAN}╚══════════════════════════════════════════════╝${SC_RESET}"
    echo ""
}

# ============================================================================
# Example Usage
# ============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "ShellCandy Prompts Module"
    echo "========================="
    echo ""

    # Example 1: Text input
    echo "Example 1: Text Input"
    echo "─────────────────────────────────────"
    name=$(sc_prompt_text "What is your name?" "John Doe")
    echo "Hello, $name!"
    echo ""

    # Example 2: Confirmation
    echo "Example 2: Confirmation"
    echo "─────────────────────────────────────"
    if sc_prompt_confirm "Do you want to continue?"; then
        echo "Great! Continuing..."
    else
        echo "Operation cancelled."
    fi
    echo ""

    # Example 3: Select from list
    echo "Example 3: Select from List"
    echo "─────────────────────────────────────"
    env=$(sc_prompt_select "Select environment:" "development" "staging" "production")
    echo "You selected: $env"
    echo ""

    # Example 4: Number input
    echo "Example 4: Number Input"
    echo "─────────────────────────────────────"
    age=$(sc_prompt_number "Enter your age:" 0 120)
    echo "Your age: $age"
    echo ""

    # Example 5: Email validation
    echo "Example 5: Email Validation"
    echo "─────────────────────────────────────"
    email=$(sc_prompt_email "Enter your email:")
    echo "Email: $email"
    echo ""

    # Example 6: Password input
    echo "Example 6: Password Input"
    echo "─────────────────────────────────────"
    password=$(sc_prompt_password "Enter password:")
    echo "Password length: ${#password} characters"
    echo ""

    # Example 7: Multi-select
    echo "Example 7: Multi-Select"
    echo "─────────────────────────────────────"
    declare -a features
    sc_prompt_multiselect "Select features to install:" features \
        "Authentication" "Logging" "Caching" "Monitoring" "API"
    echo "Selected features:"
    for feature in "${features[@]}"; do
        echo "  - $feature"
    done
    echo ""

    # Example 8: Complete form
    echo "Example 8: Complete Form"
    echo "─────────────────────────────────────"
    sc_prompt_form "User Registration"

    username=$(sc_prompt_text "Username:" "" sc_validate_alphanumeric)
    email=$(sc_prompt_email "Email:")
    password=$(sc_prompt_password "Password:")
    age=$(sc_prompt_number "Age:" 18 120)

    echo ""
    echo "Registration complete!"
    echo "  Username: $username"
    echo "  Email: $email"
    echo "  Age: $age"
    echo ""

    echo "Examples complete!"
fi
