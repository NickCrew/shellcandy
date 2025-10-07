#!/usr/bin/env bash
# ultimate-dashboard.sh - THE ULTIMATE ShellCandy Showcase
# Demonstrates ALL modules working together in a production-quality application
#
# This is a complete, interactive system monitoring dashboard that showcases:
# - Colors: Full theme support
# - Logging: Multi-level logging with file output
# - Progress: Real-time progress indicators
# - Icons: Status symbols and emojis
# - Boxes: Beautiful information panels
# - Tables: Data display with formatting
# - Prompts: Interactive configuration
# - Menus: Full keyboard navigation
# - Charts: Data visualization
#
# USAGE:
#   ./ultimate-dashboard.sh
#   ./ultimate-dashboard.sh --auto     # Auto-refresh mode
#   ./ultimate-dashboard.sh --config   # Configuration wizard

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "${SCRIPT_DIR}/../lib" && pwd)"

# Load ShellCandy
source "${LIB_DIR}/shellcandy.sh"
source "${LIB_DIR}/menus.sh"
source "${LIB_DIR}/charts.sh"

# ============================================================================
# Configuration
# ============================================================================

APP_NAME="UltimateDash"
APP_VERSION="2.0.0"
REFRESH_INTERVAL=5

# Mock data (in real app, these would come from actual system metrics)
declare -a CPU_HISTORY=(30 35 40 38 42 45 43 48 50 52)
declare -a MEM_HISTORY=(55 57 58 60 59 61 63 62 65 67)
declare -a NET_HISTORY=(120 140 135 160 180 170 190 185 200 210)

CURRENT_CPU=52
CURRENT_MEM=67
CURRENT_DISK=45
CURRENT_NET=210

SERVICE_WEB="running"
SERVICE_DB="running"
SERVICE_CACHE="degraded"
SERVICE_QUEUE="running"
SERVICE_API="running"

# ============================================================================
# Utility Functions
# ============================================================================

# Simulate data changes (for demo purposes)
update_metrics() {
    # Update CPU
    CURRENT_CPU=$((CURRENT_CPU + RANDOM % 10 - 5))
    [[ $CURRENT_CPU -lt 10 ]] && CURRENT_CPU=10
    [[ $CURRENT_CPU -gt 95 ]] && CURRENT_CPU=95
    CPU_HISTORY=(${CPU_HISTORY[@]:1} $CURRENT_CPU)

    # Update Memory
    CURRENT_MEM=$((CURRENT_MEM + RANDOM % 8 - 4))
    [[ $CURRENT_MEM -lt 30 ]] && CURRENT_MEM=30
    [[ $CURRENT_MEM -gt 90 ]] && CURRENT_MEM=90
    MEM_HISTORY=(${MEM_HISTORY[@]:1} $CURRENT_MEM)

    # Update Network
    CURRENT_NET=$((CURRENT_NET + RANDOM % 40 - 20))
    [[ $CURRENT_NET -lt 50 ]] && CURRENT_NET=50
    [[ $CURRENT_NET -gt 500 ]] && CURRENT_NET=500
    NET_HISTORY=(${NET_HISTORY[@]:1} $CURRENT_NET)

    # Occasionally change service status
    if [[ $((RANDOM % 20)) -eq 0 ]]; then
        local services=("SERVICE_CACHE" "SERVICE_QUEUE")
        local service=${services[$((RANDOM % 2))]}
        local statuses=("running" "degraded")
        eval "$service=${statuses[$((RANDOM % 2))]}"
    fi
}

# Format uptime
format_uptime() {
    local seconds=$1
    local days=$((seconds / 86400))
    local hours=$(( (seconds % 86400) / 3600 ))
    local mins=$(( (seconds % 3600) / 60 ))

    printf "%dd %dh %dm" "$days" "$hours" "$mins"
}

# ============================================================================
# Dashboard Views
# ============================================================================

# Main dashboard view
show_dashboard() {
    clear

    # Header with branding
    box_header "${APP_NAME} - System Monitoring Dashboard v${APP_VERSION}" "$SC_CYAN" 100
    box_line "Host: $(hostname)  |  Time: $(date '+%Y-%m-%d %H:%M:%S')  |  Uptime: $(format_uptime 432000)" "$SC_CYAN" 100
    box_footer "$SC_CYAN" 100
    echo ""

    # Resource Overview with Gauges
    echo -e "${SC_BOLD}${SC_BLUE}█${SC_RESET} ${SC_BOLD}Resource Overview${SC_RESET}"
    echo ""
    sc_gauge $CURRENT_CPU 100 "CPU Usage" 50
    sc_gauge $CURRENT_MEM 100 "Memory" 50
    sc_gauge $CURRENT_DISK 100 "Disk" 50
    sc_gauge $CURRENT_NET 500 "Network (Mbps)" 50
    echo ""

    # Sparkline trends
    echo -e "${SC_BOLD}${SC_GREEN}█${SC_RESET} ${SC_BOLD}Trends (Last 10 intervals)${SC_RESET}"
    echo ""
    printf "  CPU:     "
    sc_sparkline_color CPU_HISTORY
    printf "  (%d%% current)\n" "$CURRENT_CPU"

    printf "  Memory:  "
    sc_sparkline_color MEM_HISTORY
    printf "  (%d%% current)\n" "$CURRENT_MEM"

    printf "  Network: "
    sc_sparkline_color NET_HISTORY
    printf "  (%d Mbps current)\n" "$CURRENT_NET"
    echo ""

    # Services Status Table
    echo -e "${SC_BOLD}${SC_YELLOW}█${SC_RESET} ${SC_BOLD}Services Status${SC_RESET}"
    echo ""

    local web_status="$(sc_icon_success) Running"
    local db_status="$(sc_icon_success) Running"
    local cache_status="$(sc_icon_warning) Degraded"
    local queue_status="$(sc_icon_success) Running"
    local api_status="$(sc_icon_success) Running"

    [[ "$SERVICE_WEB" == "running" ]] && web_status="$(sc_icon_success) Running" || web_status="$(sc_icon_error) Stopped"
    [[ "$SERVICE_DB" == "running" ]] && db_status="$(sc_icon_success) Running" || db_status="$(sc_icon_error) Stopped"
    [[ "$SERVICE_CACHE" == "running" ]] && cache_status="$(sc_icon_success) Running" || cache_status="$(sc_icon_warning) Degraded"
    [[ "$SERVICE_QUEUE" == "running" ]] && queue_status="$(sc_icon_success) Running" || queue_status="$(sc_icon_error) Stopped"
    [[ "$SERVICE_API" == "running" ]] && api_status="$(sc_icon_success) Running" || api_status="$(sc_icon_error) Stopped"

    sc_table_create "rounded"
    sc_table_header "Service" "Status" "Port" "CPU" "Memory" "Requests/s"
    sc_table_row "Web Server" "$web_status" "8080" "12%" "450MB" "234"
    sc_table_row "Database" "$db_status" "5432" "25%" "1.2GB" "-"
    sc_table_row "Cache" "$cache_status" "6379" "8%" "250MB" "1.2K"
    sc_table_row "Queue" "$queue_status" "5672" "5%" "180MB" "45"
    sc_table_row "API Server" "$api_status" "3000" "18%" "680MB" "567"
    sc_table_render "$SC_BLUE"
    echo ""

    # Recent metrics comparison
    echo -e "${SC_BOLD}${SC_MAGENTA}█${SC_RESET} ${SC_BOLD}Performance Metrics${SC_RESET}"
    echo ""

    sc_table_metrics "Metric:Current:Target:Status" \
        "Response Time:45ms:50ms:$(sc_icon_success) OK" \
        "Error Rate:0.02%:0.5%:$(sc_icon_success) OK" \
        "Throughput:1.2K req/s:1K req/s:$(sc_icon_success) OK" \
        "Uptime:99.95%:99.9%:$(sc_icon_success) OK"

    echo ""

    # Footer with controls
    echo -e "${SC_DIM}Press 'm' for menu | 'r' to refresh | 'q' to quit${SC_RESET}"
}

# Detailed charts view
show_charts_view() {
    clear

    box_header "Detailed Performance Charts" "$SC_CYAN" 100
    box_footer "$SC_CYAN" 100
    echo ""

    # CPU Distribution
    echo -e "${SC_BOLD}CPU Usage by Service${SC_RESET}"
    echo ""
    declare -a cpu_by_service=(12 25 8 5 18)
    declare -a service_names=("Web" "Database" "Cache" "Queue" "API")
    sc_chart_bar_h "" cpu_by_service service_names 50
    echo ""

    # Multi-series comparison
    echo -e "${SC_BOLD}Traffic Comparison (This Week vs Last Week)${SC_RESET}"
    echo ""
    declare -a last_week=(180 195 210 205 220 230 215)
    declare -a this_week=(210 225 240 235 250 260 245)
    declare -a days=("Mon" "Tue" "Wed" "Thu" "Fri" "Sat" "Sun")
    sc_chart_multi "" last_week this_week days 40
    echo ""

    # Response time histogram
    echo -e "${SC_BOLD}Response Time Distribution${SC_RESET}"
    echo ""
    declare -a response_times=(35 42 38 45 40 150 43 48 200 41 39 44 42 46 40 38 44 42 45 250)
    sc_histogram response_times 8 40
    echo ""

    read -p "Press Enter to return to dashboard..."
}

# Logs view
show_logs_view() {
    clear

    box_header "System Logs" "$SC_CYAN" 100
    box_footer "$SC_CYAN" 100
    echo ""

    sc_log_info "Web server request processed successfully - 200 OK"
    sc_log_debug "Database query executed in 12ms"
    sc_log_success "Deployment completed successfully"
    sc_log_warn "Cache hit rate below threshold (75%)"
    sc_log_error "Failed to connect to external API - retrying..."
    sc_log_info "Background job completed: cleanup-old-sessions"
    sc_log_debug "Memory usage: 1.2GB / 8GB (15%)"
    sc_log_info "New user registered: user@example.com"
    sc_log_warn "Rate limit approaching for IP 192.168.1.100"
    sc_log_success "Health check passed - all systems operational"

    echo ""
    read -p "Press Enter to return to dashboard..."
}

# Settings view with prompts
show_settings() {
    clear

    sc_prompt_form "Dashboard Settings"

    local refresh=$(sc_prompt_number "Refresh interval (seconds):" 1 60 $REFRESH_INTERVAL)
    REFRESH_INTERVAL=$refresh

    local theme=$(sc_prompt_select "Color theme:" "default" "nord" "solarized" "dracula")

    if sc_prompt_confirm "Save settings?"; then
        box_success "Settings Saved" \
            "Refresh interval: ${refresh}s" \
            "Theme: $theme"
        sleep 2
    fi
}

# Alert configuration with forms
configure_alerts() {
    clear

    sc_prompt_form "Alert Configuration"

    local cpu_threshold=$(sc_prompt_number "CPU alert threshold (%):" 0 100 80)
    local mem_threshold=$(sc_prompt_number "Memory alert threshold (%):" 0 100 85)
    local email=$(sc_prompt_email "Alert email address:")

    declare -a alert_types
    sc_prompt_multiselect "Alert channels:" alert_types "Email" "Slack" "PagerDuty" "SMS"

    echo ""
    sc_table_kv \
        "CPU Threshold" "${cpu_threshold}%" \
        "Memory Threshold" "${mem_threshold}%" \
        "Email" "$email" \
        "Channels" "${alert_types[*]}"

    if sc_prompt_confirm "Save alert configuration?"; then
        box_success "Alerts Configured" \
            "Configuration saved successfully" \
            "Alerts are now active"
        sleep 2
    fi
}

# ============================================================================
# Menu Actions
# ============================================================================

action_refresh() {
    update_metrics
    show_dashboard
    sleep 1
}

action_charts() {
    show_charts_view
}

action_logs() {
    show_logs_view
}

action_settings() {
    show_settings
}

action_alerts() {
    configure_alerts
}

action_export() {
    echo "Exporting data..."
    sc_progress_start 100 "Generating report"
    for i in {1..100}; do
        sc_progress_update
        sleep 0.02
    done
    sc_progress_finish "Export complete"

    box_success "Report Exported" \
        "File: dashboard-report.csv" \
        "Size: 2.4MB" \
        "Time: $(date)"

    read -p "Press Enter to continue..."
}

action_about() {
    clear

    box "About ${APP_NAME}" \
        "" \
        "${SC_BOLD}${APP_NAME}${SC_RESET} - The Ultimate ShellCandy Showcase" \
        "" \
        "Version: ${APP_VERSION}" \
        "Framework: ShellCandy v2.0.0 (Super Saiyan God Edition)" \
        "" \
        "${SC_BOLD}Features Demonstrated:${SC_RESET}" \
        "  $(sc_icon_success) Interactive menus with keyboard navigation" \
        "  $(sc_icon_success) Real-time data visualization" \
        "  $(sc_icon_success) Progress indicators and sparklines" \
        "  $(sc_icon_success) Tables with formatting and colors" \
        "  $(sc_icon_success) Interactive prompts and forms" \
        "  $(sc_icon_success) Multi-level logging" \
        "  $(sc_icon_success) Status icons and emojis" \
        "  $(sc_icon_success) Beautiful boxes and layouts" \
        "" \
        "$(sc_emoji_status rocket) Built with ShellCandy" \
        "$(sc_emoji_status shield) Production-ready code" \
        "$(sc_emoji_status bulb) Zero external dependencies" \
        "" \
        "Created to showcase what's possible with shell scripts!" \
        --width=70 \
        --color="$SC_MAGENTA"

    read -p "Press Enter to continue..."
}

# ============================================================================
# Main Menu
# ============================================================================

show_main_menu() {
    sc_menu_create "${APP_NAME} - Main Menu"
    sc_menu_add "Dashboard View" "action_refresh" "true" "d"
    sc_menu_add "Detailed Charts" "action_charts" "true" "c"
    sc_menu_add "View Logs" "action_logs" "true" "l"
    sc_menu_add_separator
    sc_menu_add "Settings" "action_settings" "true" "s"
    sc_menu_add "Configure Alerts" "action_alerts" "true" "a"
    sc_menu_add "Export Data" "action_export" "true" "e"
    sc_menu_add_separator
    sc_menu_add "About" "action_about" "true" "?"
    sc_menu_add "Exit" "exit" "true" "q"
    sc_menu_show
}

# ============================================================================
# Main Application
# ============================================================================

main() {
    # Check for arguments
    case "${1:-}" in
        --auto)
            # Auto-refresh mode
            while true; do
                update_metrics
                show_dashboard
                sleep $REFRESH_INTERVAL
            done
            ;;
        --config)
            # Configuration wizard
            configure_alerts
            show_settings
            ;;
        --help|-h)
            cat << EOF
${APP_NAME} v${APP_VERSION} - Ultimate ShellCandy Showcase

USAGE:
  $0                Start interactive dashboard
  $0 --auto         Auto-refresh mode
  $0 --config       Configuration wizard
  $0 --help         Show this help

FEATURES:
  - Real-time system monitoring
  - Interactive menus and navigation
  - Data visualization with charts
  - Multi-level logging
  - Configuration management
  - Alert configuration
  - Data export

NAVIGATION:
  - Use arrow keys or j/k to navigate menus
  - Press Enter to select
  - Press hotkeys for quick access
  - Press 'q' to quit

Powered by ShellCandy v2.0.0 🍭✨
EOF
            ;;
        *)
            # Interactive mode with menu
            clear

            # Splash screen
            echo -e "${SC_CYAN}"
            cat << 'EOF'
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║              🚀 ULTIMATE SHELLCANDY DASHBOARD 🚀              ║
║                                                                ║
║          Showcasing ALL Modules in Production Quality         ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
EOF
            echo -e "${SC_RESET}"
            echo ""
            echo "Loading modules..."
            sleep 0.5

            spinner_pid=$(sc_spinner_start "Initializing dashboard..." "dots")
            sleep 1.5
            sc_spinner_stop "$spinner_pid" "Dashboard ready!"

            echo ""
            sleep 1

            # Show menu
            show_main_menu
            ;;
    esac
}

main "$@"
