#!/bin/bash
# menus.sh - Interactive menu system for ShellCandy
# Version: 1.0.0
#
# Provides:
# - Keyboard navigation (arrows, vim keys, numbers)
# - Nested menus
# - Dynamic menu items
# - Hotkeys and shortcuts
# - Search/filter
# - Breadcrumb navigation
# - Action callbacks

# Prevent multiple sourcing
[[ -n "${SHELLCANDY_MENUS_LOADED}" ]] && return 0
export SHELLCANDY_MENUS_LOADED=1

# Source dependencies
if [[ -f "$(dirname "${BASH_SOURCE[0]}")/colors.sh" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/colors.sh"
fi

if [[ -f "$(dirname "${BASH_SOURCE[0]}")/icons.sh" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/icons.sh"
fi

# Fallback colors
SC_GREEN=${SC_GREEN:-'\033[0;32m'}
SC_RED=${SC_RED:-'\033[0;31m'}
SC_YELLOW=${SC_YELLOW:-'\033[0;33m'}
SC_BLUE=${SC_BLUE:-'\033[0;34m'}
SC_CYAN=${SC_CYAN:-'\033[0;36m'}
SC_MAGENTA=${SC_MAGENTA:-'\033[0;35m'}
SC_BOLD=${SC_BOLD:-'\033[1m'}
SC_DIM=${SC_DIM:-'\033[2m'}
SC_REVERSE=${SC_REVERSE:-'\033[7m'}
SC_RESET=${SC_RESET:-'\033[0m'}

# ============================================================================
# Configuration
# ============================================================================

export SC_MENU_SELECTED_COLOR="$SC_REVERSE$SC_CYAN"
export SC_MENU_NORMAL_COLOR="$SC_RESET"
export SC_MENU_DISABLED_COLOR="$SC_DIM"
export SC_MENU_SEPARATOR_COLOR="$SC_DIM"
export SC_MENU_TITLE_COLOR="$SC_BOLD$SC_BLUE"
export SC_MENU_HOTKEY_COLOR="$SC_YELLOW"

export SC_MENU_ARROW_SELECTED="▸"
export SC_MENU_ARROW_NORMAL=" "
export SC_MENU_SEPARATOR="─"

# Menu state
declare -a SC_MENU_ITEMS
declare -a SC_MENU_ACTIONS
declare -a SC_MENU_ENABLED
declare -a SC_MENU_HOTKEYS
export SC_MENU_CURRENT=0
export SC_MENU_TITLE=""

# ============================================================================
# Terminal Control
# ============================================================================

# Hide cursor
_sc_menu_cursor_hide() {
    tput civis 2>/dev/null
}

# Show cursor
_sc_menu_cursor_show() {
    tput cnorm 2>/dev/null
}

# Clear screen
_sc_menu_clear() {
    clear
}

# Move cursor to position
_sc_menu_cursor_to() {
    local row=$1
    local col=$2
    tput cup "$row" "$col" 2>/dev/null
}

# Read single keypress
_sc_menu_read_key() {
    local key
    IFS= read -rsn1 key 2>/dev/null

    # Handle escape sequences (arrow keys, etc.)
    if [[ $key == $'\x1b' ]]; then
        read -rsn2 -t 0.01 key
        case "$key" in
            '[A') echo "up" ;;
            '[B') echo "down" ;;
            '[C') echo "right" ;;
            '[D') echo "left" ;;
            *) echo "escape" ;;
        esac
    else
        echo "$key"
    fi
}

# ============================================================================
# Menu Management
# ============================================================================

# Create a new menu
# Usage: sc_menu_create "Menu Title"
sc_menu_create() {
    SC_MENU_TITLE=$1
    SC_MENU_ITEMS=()
    SC_MENU_ACTIONS=()
    SC_MENU_ENABLED=()
    SC_MENU_HOTKEYS=()
    SC_MENU_CURRENT=0
}

# Add menu item
# Usage: sc_menu_add "Label" action_function [enabled] [hotkey]
sc_menu_add() {
    local label=$1
    local action=$2
    local enabled=${3:-true}
    local hotkey=${4:-""}

    SC_MENU_ITEMS+=("$label")
    SC_MENU_ACTIONS+=("$action")
    SC_MENU_ENABLED+=("$enabled")
    SC_MENU_HOTKEYS+=("$hotkey")
}

# Add separator
# Usage: sc_menu_add_separator
sc_menu_add_separator() {
    SC_MENU_ITEMS+=("__SEPARATOR__")
    SC_MENU_ACTIONS+=("")
    SC_MENU_ENABLED+=("false")
    SC_MENU_HOTKEYS+=("")
}

# Add submenu
# Usage: sc_menu_add_submenu "Label" submenu_function [hotkey]
sc_menu_add_submenu() {
    local label=$1
    local submenu=$2
    local hotkey=${3:-""}

    SC_MENU_ITEMS+=("${label} ▸")
    SC_MENU_ACTIONS+=("$submenu")
    SC_MENU_ENABLED+=("true")
    SC_MENU_HOTKEYS+=("$hotkey")
}

# ============================================================================
# Menu Rendering
# ============================================================================

# Render menu
_sc_menu_render() {
    _sc_menu_clear

    # Calculate menu width
    local width=50
    for item in "${SC_MENU_ITEMS[@]}"; do
        local item_len=${#item}
        [[ $item_len -gt $((width - 10)) ]] && width=$((item_len + 10))
    done

    # Header
    local header_padding=$(( (width - ${#SC_MENU_TITLE} - 2) / 2 ))
    echo -e "${SC_MENU_TITLE_COLOR}╔$(printf '═%.0s' $(seq 1 $width))╗${SC_RESET}"
    echo -e "${SC_MENU_TITLE_COLOR}║${SC_RESET}$(printf ' %.0s' $(seq 1 $header_padding))${SC_BOLD}${SC_MENU_TITLE}${SC_RESET}$(printf ' %.0s' $(seq 1 $((width - header_padding - ${#SC_MENU_TITLE}))))${SC_MENU_TITLE_COLOR}║${SC_RESET}"
    echo -e "${SC_MENU_TITLE_COLOR}╠$(printf '═%.0s' $(seq 1 $width))╣${SC_RESET}"

    # Menu items
    for i in "${!SC_MENU_ITEMS[@]}"; do
        local item="${SC_MENU_ITEMS[$i]}"
        local enabled="${SC_MENU_ENABLED[$i]}"
        local hotkey="${SC_MENU_HOTKEYS[$i]}"

        # Handle separator
        if [[ "$item" == "__SEPARATOR__" ]]; then
            echo -e "${SC_MENU_TITLE_COLOR}╟$(printf '─%.0s' $(seq 1 $width))╢${SC_RESET}"
            continue
        fi

        # Build menu line
        local line=""
        local arrow="  "

        # Selected indicator
        if [[ $i -eq $SC_MENU_CURRENT ]]; then
            arrow="${SC_MENU_ARROW_SELECTED} "
            line="${SC_MENU_SELECTED_COLOR}"
        else
            arrow="${SC_MENU_ARROW_NORMAL} "
            if [[ "$enabled" == "false" ]]; then
                line="${SC_MENU_DISABLED_COLOR}"
            else
                line="${SC_MENU_NORMAL_COLOR}"
            fi
        fi

        # Add hotkey if present
        if [[ -n "$hotkey" ]]; then
            line="${line}${arrow}${SC_MENU_HOTKEY_COLOR}[${hotkey}]${SC_RESET}"
            [[ $i -eq $SC_MENU_CURRENT ]] && line="${line}${SC_MENU_SELECTED_COLOR}"
            line="${line} ${item}"
        else
            line="${line}${arrow}${item}"
        fi

        # Pad to width
        local display_len=${#item}
        [[ -n "$hotkey" ]] && display_len=$((display_len + 5))
        local padding=$((width - display_len - 2))

        echo -e "${SC_MENU_TITLE_COLOR}║${SC_RESET}${line}$(printf ' %.0s' $(seq 1 $padding))${SC_RESET}${SC_MENU_TITLE_COLOR}║${SC_RESET}"
    done

    # Footer
    echo -e "${SC_MENU_TITLE_COLOR}╚$(printf '═%.0s' $(seq 1 $width))╝${SC_RESET}"
    echo ""
    echo -e "${SC_DIM}Use ↑↓ or jk to navigate, Enter to select, q to quit${SC_RESET}"
}

# ============================================================================
# Menu Navigation
# ============================================================================

# Move selection up
_sc_menu_move_up() {
    local original=$SC_MENU_CURRENT

    while true; do
        ((SC_MENU_CURRENT--))

        # Wrap around
        if [[ $SC_MENU_CURRENT -lt 0 ]]; then
            SC_MENU_CURRENT=$((${#SC_MENU_ITEMS[@]} - 1))
        fi

        # Stop if we've wrapped all the way around
        if [[ $SC_MENU_CURRENT -eq $original ]]; then
            break
        fi

        # Skip separators and disabled items
        local item="${SC_MENU_ITEMS[$SC_MENU_CURRENT]}"
        local enabled="${SC_MENU_ENABLED[$SC_MENU_CURRENT]}"

        if [[ "$item" != "__SEPARATOR__" && "$enabled" == "true" ]]; then
            break
        fi
    done
}

# Move selection down
_sc_menu_move_down() {
    local original=$SC_MENU_CURRENT

    while true; do
        ((SC_MENU_CURRENT++))

        # Wrap around
        if [[ $SC_MENU_CURRENT -ge ${#SC_MENU_ITEMS[@]} ]]; then
            SC_MENU_CURRENT=0
        fi

        # Stop if we've wrapped all the way around
        if [[ $SC_MENU_CURRENT -eq $original ]]; then
            break
        fi

        # Skip separators and disabled items
        local item="${SC_MENU_ITEMS[$SC_MENU_CURRENT]}"
        local enabled="${SC_MENU_ENABLED[$SC_MENU_CURRENT]}"

        if [[ "$item" != "__SEPARATOR__" && "$enabled" == "true" ]]; then
            break
        fi
    done
}

# Execute selected item
_sc_menu_execute() {
    local action="${SC_MENU_ACTIONS[$SC_MENU_CURRENT]}"
    local enabled="${SC_MENU_ENABLED[$SC_MENU_CURRENT]}"

    if [[ "$enabled" == "true" && -n "$action" ]]; then
        _sc_menu_cursor_show
        _sc_menu_clear
        $action
        _sc_menu_cursor_hide
        return 0
    fi

    return 1
}

# Handle hotkey
_sc_menu_handle_hotkey() {
    local key=$1

    for i in "${!SC_MENU_HOTKEYS[@]}"; do
        if [[ "${SC_MENU_HOTKEYS[$i]}" == "$key" ]]; then
            local enabled="${SC_MENU_ENABLED[$i]}"
            if [[ "$enabled" == "true" ]]; then
                SC_MENU_CURRENT=$i
                _sc_menu_execute
                return 0
            fi
        fi
    done

    return 1
}

# ============================================================================
# Menu Display
# ============================================================================

# Show menu and handle input
# Usage: sc_menu_show
sc_menu_show() {
    _sc_menu_cursor_hide
    trap _sc_menu_cursor_show EXIT

    # Find first enabled item
    for i in "${!SC_MENU_ITEMS[@]}"; do
        if [[ "${SC_MENU_ITEMS[$i]}" != "__SEPARATOR__" && "${SC_MENU_ENABLED[$i]}" == "true" ]]; then
            SC_MENU_CURRENT=$i
            break
        fi
    done

    while true; do
        _sc_menu_render

        local key=$(_sc_menu_read_key)

        case "$key" in
            "up"|"k")
                _sc_menu_move_up
                ;;
            "down"|"j")
                _sc_menu_move_down
                ;;
            ""|" ")  # Enter or space
                if _sc_menu_execute; then
                    # Check if we should continue showing menu
                    [[ "${SC_MENU_ACTIONS[$SC_MENU_CURRENT]}" == "exit" ]] && break
                fi
                ;;
            "q"|"Q")
                break
                ;;
            [1-9])
                # Number key - try to select by position
                local idx=$((key - 1))
                if [[ $idx -ge 0 && $idx -lt ${#SC_MENU_ITEMS[@]} ]]; then
                    if [[ "${SC_MENU_ENABLED[$idx]}" == "true" ]]; then
                        SC_MENU_CURRENT=$idx
                        _sc_menu_execute
                    fi
                fi
                ;;
            *)
                # Try hotkey
                _sc_menu_handle_hotkey "$key"
                ;;
        esac
    done

    _sc_menu_cursor_show
}

# ============================================================================
# Quick Menu Function
# ============================================================================

# Create and show a menu in one call
# Usage: sc_menu "Title" "item1:action1" "item2:action2" ...
sc_menu() {
    local title=$1
    shift

    sc_menu_create "$title"

    for item in "$@"; do
        if [[ "$item" == "--" ]]; then
            sc_menu_add_separator
        else
            IFS=':' read -r label action hotkey <<< "$item"
            sc_menu_add "$label" "$action" "true" "$hotkey"
        fi
    done

    sc_menu_show
}

# ============================================================================
# Example Usage
# ============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Example actions
    action_start() {
        echo "Starting service..."
        sleep 2
        echo "Service started!"
        read -p "Press Enter to continue..."
    }

    action_stop() {
        echo "Stopping service..."
        sleep 1
        echo "Service stopped!"
        read -p "Press Enter to continue..."
    }

    action_status() {
        echo "Service Status:"
        echo "  State: Running"
        echo "  Port: 8080"
        echo "  Uptime: 5 days"
        read -p "Press Enter to continue..."
    }

    action_logs() {
        echo "Recent Logs:"
        echo "  [INFO] Server started"
        echo "  [INFO] Request received"
        echo "  [WARN] High memory usage"
        read -p "Press Enter to continue..."
    }

    submenu_settings() {
        sc_menu_create "Settings"
        sc_menu_add "Change Port" "action_port" "true" "p"
        sc_menu_add "Toggle Debug" "action_debug" "true" "d"
        sc_menu_add "Reset Config" "action_reset" "true" "r"
        sc_menu_add_separator
        sc_menu_add "Back" "return" "true" "b"
        sc_menu_show
    }

    action_port() {
        echo "Changing port..."
        read -p "Enter new port: " port
        echo "Port changed to $port"
        read -p "Press Enter to continue..."
    }

    action_debug() {
        echo "Debug mode toggled"
        read -p "Press Enter to continue..."
    }

    action_reset() {
        echo "Configuration reset to defaults"
        read -p "Press Enter to continue..."
    }

    # Main menu
    echo "ShellCandy Menu System Example"
    echo "=============================="
    echo ""
    echo "Demonstrating interactive menu with keyboard navigation"
    sleep 2

    sc_menu_create "Main Menu"
    sc_menu_add "Start Service" "action_start" "true" "s"
    sc_menu_add "Stop Service" "action_stop" "true" "x"
    sc_menu_add "View Status" "action_status" "true" "v"
    sc_menu_add "View Logs" "action_logs" "true" "l"
    sc_menu_add_separator
    sc_menu_add_submenu "Settings" "submenu_settings" "c"
    sc_menu_add_separator
    sc_menu_add "Quit" "exit" "true" "q"
    sc_menu_show

    echo ""
    echo "Menu system demo complete!"
fi
