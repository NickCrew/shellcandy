#!/bin/bash
# showcase.sh - Complete ShellCandy Framework Demonstration
# Shows all modules working together in realistic scenarios

# Load ShellCandy from parent directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../shellcandy.sh"

# Configuration
DEMO_SPEED=1  # Adjust for faster/slower demos (1=normal, 0.5=fast, 2=slow)
AUTO_PLAY=false  # Auto-play mode (no waiting for Enter)

# Parse arguments
for arg in "$@"; do
    case "$arg" in
        --auto|--non-interactive|-a)
            AUTO_PLAY=true
            DEMO_SPEED=0.1  # Much faster in auto-play mode
            ;;
        --fast)
            DEMO_SPEED=0.5
            ;;
        --slow)
            DEMO_SPEED=2
            ;;
    esac
done

# Helper function for demo pacing
demo_pause() {
    local duration=${1:-2}
    sleep $(echo "$duration * $DEMO_SPEED" | bc)
}

demo_wait_key() {
    if [[ "$AUTO_PLAY" == "true" ]]; then
        echo ""
        demo_pause 0.5  # Just a brief pause in auto mode
    else
        echo ""
        echo -e "${SC_DIM}Press Enter to continue...${SC_RESET}"
        read -r
    fi
}

# ============================================================================
# Demo Header
# ============================================================================

clear
echo -e "${SC_BOLD}${SC_CYAN}"
cat << 'EOF'
╔════════════════════════════════════════════════════════════════════════════╗
║                                                                            ║
║                       ShellCandy Framework Showcase                        ║
║                       Complete Feature Demonstration                       ║
║                                                                            ║
║                              Version 1.0.0                                 ║
║                                                                            ║
╚════════════════════════════════════════════════════════════════════════════╝
EOF
echo -e "${SC_RESET}"
echo ""
echo -e "${SC_DIM}This showcase demonstrates all ShellCandy modules working together${SC_RESET}"
echo -e "${SC_DIM}in realistic scenarios.${SC_RESET}"
demo_wait_key
clear

# ============================================================================
# Scenario 1: Application Startup
# ============================================================================

echo -e "${SC_BOLD}Scenario 1: Application Startup${SC_RESET}"
sc_separator "─" 80
echo ""

box_header "Application Initializing" "$SC_CYAN" 78
box_line "Name: ShellCandy Demo App" "$SC_CYAN" 78
box_line "Version: 2.0.1" "$SC_CYAN" 78
box_line "Environment: Production" "$SC_CYAN" 78
box_footer "$SC_CYAN" 78
echo ""

sc_log_section "Initialization"

# Load configuration
sc_log_task_start "Loading configuration"
spinner_pid=$(sc_spinner_start "Reading config files..." "dots")
demo_pause 1.5
sc_spinner_stop "$spinner_pid"
sc_icon_success "Configuration loaded"

# Initialize database
sc_log_task_start "Connecting to database"
spinner_pid=$(sc_spinner_start "Establishing connection..." "line")
demo_pause 1.5
sc_spinner_stop "$spinner_pid"
sc_icon_success "Database connected"

# Load modules
sc_log_task_start "Loading application modules"
modules=("authentication" "authorization" "api" "web" "background-jobs")
sc_progress_start ${#modules[@]} "Loading modules"
for module in "${modules[@]}"; do
    demo_pause 0.3
    sc_progress_update
done
sc_progress_finish
sc_icon_success "All modules loaded"

echo ""
box_success "Startup Complete" \
    "Application ready to accept connections" \
    "" \
    "🌐 Web Server: http://localhost:8080" \
    "📊 API Server: http://localhost:3000" \
    "⏱  Startup time: 4.5 seconds"

demo_wait_key
clear

# ============================================================================
# Scenario 2: Data Processing Pipeline
# ============================================================================

echo -e "${SC_BOLD}Scenario 2: Data Processing Pipeline${SC_RESET}"
sc_separator "─" 80
echo ""

sc_log_section "Data Processing"

# Stage 1: Download
sc_log_subsection "Stage 1: Download Data"
sc_emoji_status network "Connecting to data source"
for i in {0..100..20}; do
    sc_progress_bar $i 100 "Downloading (256MB)"
    demo_pause 0.2
done
echo ""
sc_icon_success "Download complete"
echo ""

# Stage 2: Validation
sc_log_subsection "Stage 2: Validate Data"
sc_emoji_status shield "Running validation checks"
checks=("Schema validation" "Data integrity" "Format check" "Duplicate detection")
for check in "${checks[@]}"; do
    spinner_pid=$(sc_spinner_start "$check..." "circle")
    demo_pause 0.8
    sc_spinner_stop "$spinner_pid" "$check complete"
done
echo ""

# Stage 3: Transform
sc_log_subsection "Stage 3: Transform Data"
sc_emoji_status tool "Applying transformations"
sc_progress_start 1000 "Processing records"
for i in {1..50}; do
    demo_pause 0.03
    sc_progress_update 20
done
sc_progress_finish
sc_icon_success "Transformation complete"
echo ""

# Stage 4: Load
sc_log_subsection "Stage 4: Load to Database"
sc_emoji_status database "Inserting records"
for i in {0..100..25}; do
    sc_progress_bar $i 100 "Loading"
    demo_pause 0.3
done
echo ""
sc_icon_success "Load complete"
echo ""

# Results
box_success "Pipeline Complete" \
    "Successfully processed data" \
    "" \
    "📊 Records processed: 1,000" \
    "✓ Validation: Passed" \
    "✓ Transformations: Applied" \
    "✓ Database: Updated" \
    "⏱  Total time: 8.2 seconds"

demo_wait_key
clear

# ============================================================================
# Scenario 3: System Monitoring
# ============================================================================

echo -e "${SC_BOLD}Scenario 3: Real-time System Monitor${SC_RESET}"
sc_separator "─" 80
echo ""

for iteration in {1..3}; do
    # Clear previous display
    [[ $iteration -gt 1 ]] && tput cuu 20 && tput ed

    box_header "System Status - $(date '+%H:%M:%S')" "$SC_CYAN" 78
    box_empty "$SC_CYAN" 78

    # Services status
    box_line "${SC_BOLD}🌐 Services${SC_RESET}" "$SC_CYAN" 78
    services=(
        "Web Server:8080:Running"
        "API Server:3000:Running"
        "Database:5432:Running"
        "Cache:6379:$([ $iteration -eq 3 ] && echo 'Degraded' || echo 'Running')"
        "Queue:5672:Running"
    )
    for service in "${services[@]}"; do
        IFS=':' read -r name port status <<< "$service"
        if [[ "$status" == "Running" ]]; then
            box_line "  $(sc_icon_success) ${name}$(printf '%20s' '')${status}$(printf '%15s' '')Port ${port}" "$SC_CYAN" 78
        else
            box_line "  $(sc_icon_warning) ${name}$(printf '%20s' '')${status}$(printf '%12s' '')Port ${port}" "$SC_CYAN" 78
        fi
    done
    box_empty "$SC_CYAN" 78

    # Resources
    box_line "${SC_BOLD}📊 Resources${SC_RESET}" "$SC_CYAN" 78
    cpu=$((40 + RANDOM % 20))
    mem=$((2000 + RANDOM % 500))
    disk=$((120 + iteration * 5))

    box_line "  CPU Usage:           ${cpu}%          [$(printf '█%.0s' $(seq 1 $((cpu/10))))$(printf '░%.0s' $(seq 1 $((10-cpu/10))))]" "$SC_CYAN" 78
    box_line "  Memory:              ${mem}MB/8GB    [$(printf '█%.0s' $(seq 1 3))$(printf '░%.0s' $(seq 1 7))]" "$SC_CYAN" 78
    box_line "  Disk:                ${disk}GB/500GB [$(printf '█%.0s' $(seq 1 2))$(printf '░%.0s' $(seq 1 8))]" "$SC_CYAN" 78
    box_empty "$SC_CYAN" 78

    # Network
    box_line "${SC_BOLD}📡 Network${SC_RESET}" "$SC_CYAN" 78
    requests=$((500 + RANDOM % 200))
    box_line "  Active Connections:  $((50 + RANDOM % 50))" "$SC_CYAN" 78
    box_line "  Requests/sec:        ${requests}" "$SC_CYAN" 78
    box_line "  Bandwidth:           $((10 + RANDOM % 5))Mbps" "$SC_CYAN" 78
    box_empty "$SC_CYAN" 78

    box_line "${SC_BOLD}🔧 Last Updated:${SC_RESET} $(date '+%Y-%m-%d %H:%M:%S')" "$SC_CYAN" 78
    box_footer "$SC_CYAN" 78

    [[ $iteration -lt 3 ]] && demo_pause 2
done

demo_wait_key
clear

# ============================================================================
# Scenario 4: Deployment Process
# ============================================================================

echo -e "${SC_BOLD}Scenario 4: Application Deployment${SC_RESET}"
sc_separator "─" 80
echo ""

box_header "Deployment Starting" "$SC_BLUE" 78
box_line "Application: myapp" "$SC_BLUE" 78
box_line "Version: 2.0.1 → 2.1.0" "$SC_BLUE" 78
box_line "Environment: production" "$SC_BLUE" 78
box_line "Deployed by: admin" "$SC_BLUE" 78
box_footer "$SC_BLUE" 78
echo ""

# Pre-deployment checks
sc_log_section "Pre-deployment Checks"
checks=(
    "Checking permissions"
    "Validating configuration"
    "Testing database connection"
    "Verifying disk space"
    "Checking dependencies"
)
for check in "${checks[@]}"; do
    spinner_pid=$(sc_spinner_start "$check..." "dots")
    demo_pause 0.5
    sc_spinner_stop "$spinner_pid"
    sc_icon_success "$check"
done
echo ""

# Build
sc_log_section "Build Phase"
sc_emoji_status rocket "Starting build process"
sc_progress_start 100 "Building"
for i in {1..100}; do
    demo_pause 0.02
    sc_progress_update
done
sc_progress_finish
sc_icon_success "Build complete"
echo ""

# Tests
sc_log_section "Test Phase"
sc_emoji_status bug "Running test suite"
test_categories=("Unit tests" "Integration tests" "E2E tests")
total_tests=0
passed_tests=0
for category in "${test_categories[@]}"; do
    count=$((RANDOM % 20 + 10))
    total_tests=$((total_tests + count))
    passed_tests=$((passed_tests + count))
    sc_log_step $((passed_tests)) $total_tests "$category ($count/$count passed)"
    demo_pause 0.5
done
sc_icon_success "All tests passed ($passed_tests/$total_tests)"
echo ""

# Deploy
sc_log_section "Deployment Phase"
sc_emoji_status package "Deploying application"

steps=("Stopping old version" "Uploading files" "Running migrations" "Starting new version" "Running health checks")
for i in "${!steps[@]}"; do
    sc_log_step $((i+1)) ${#steps[@]} "${steps[$i]}"
    spinner_pid=$(sc_spinner_start "${steps[$i]}..." "line")
    demo_pause 1
    sc_spinner_stop "$spinner_pid"
    sc_icon_success "${steps[$i]} complete"
done
echo ""

# Results
box_success "Deployment Successful" \
    "Application updated to v2.1.0" \
    "" \
    "✓ Build: Success" \
    "✓ Tests: ${passed_tests}/${total_tests} passed" \
    "✓ Deploy: Success" \
    "✓ Health Check: Passed" \
    "" \
    "🚀 Application is now live" \
    "⏱  Total time: 12.5 seconds"

demo_wait_key
clear

# ============================================================================
# Scenario 5: Error Handling
# ============================================================================

echo -e "${SC_BOLD}Scenario 5: Error Detection and Reporting${SC_RESET}"
sc_separator "─" 80
echo ""

sc_log_section "Running Background Jobs"

# Simulate some successful jobs
sc_log_info "Processing batch 1/5"
sc_progress_bar 100 100 "Batch 1"
echo ""
sc_icon_success "Batch 1 complete"

sc_log_info "Processing batch 2/5"
sc_progress_bar 100 100 "Batch 2"
echo ""
sc_icon_success "Batch 2 complete"

# Simulate an error
sc_log_info "Processing batch 3/5"
for i in {0..60..20}; do
    sc_progress_bar $i 100 "Batch 3"
    demo_pause 0.3
done
echo ""
sc_icon_error "Batch 3 failed"
echo ""

# Error report
box_header "Error Report" "$SC_RED" 78
box_line "❌ ${SC_BOLD}Error:${SC_RESET} Database connection timeout" "$SC_RED" 78
box_empty "$SC_RESET" 78
box_line "${SC_BOLD}Details:${SC_RESET}" "$SC_RED" 78
box_line "  Type:     ConnectionTimeout" "$SC_RED" 78
box_line "  Message:  Operation timed out after 30s" "$SC_RED" 78
box_line "  Host:     db.example.com:5432" "$SC_RED" 78
box_line "  Time:     $(date '+%Y-%m-%d %H:%M:%S')" "$SC_RED" 78
box_empty "$SC_RED" 78
box_line "${SC_BOLD}Stack Trace:${SC_RESET}" "$SC_RED" 78
box_line "  at executeBatch (processor.js:142:15)" "$SC_RED" 78
box_line "  at processBatches (worker.js:67:8)" "$SC_RED" 78
box_line "  at main (index.js:23:3)" "$SC_RED" 78
box_empty "$SC_RED" 78
box_line "${SC_BOLD}💡 Suggested Actions:${SC_RESET}" "$SC_RED" 78
box_line "  1. Check database server is responsive" "$SC_RED" 78
box_line "  2. Verify network connectivity" "$SC_RED" 78
box_line "  3. Increase connection timeout" "$SC_RED" 78
box_line "  4. Retry failed batch" "$SC_RED" 78
box_footer "$SC_RED" 78
echo ""

# Recovery
sc_log_section "Error Recovery"
sc_emoji_status tool "Attempting automatic recovery"
spinner_pid=$(sc_spinner_start "Reconnecting to database..." "dots")
demo_pause 2
sc_spinner_stop "$spinner_pid"
sc_icon_success "Connection restored"

sc_log_info "Retrying batch 3/5"
sc_progress_bar 100 100 "Batch 3 (retry)"
echo ""
sc_icon_success "Batch 3 complete"
echo ""

box_warning "Partial Success" \
    "Batch processing completed with recovery" \
    "" \
    "✓ Batch 1: Success" \
    "✓ Batch 2: Success" \
    "⚠ Batch 3: Failed → Recovered" \
    "" \
    "💡 Review logs for error details"

demo_wait_key
clear

# ============================================================================
# Finale: All Modules Together
# ============================================================================

echo -e "${SC_BOLD}Finale: Complete Framework Integration${SC_RESET}"
sc_separator "─" 80
echo ""

# Show all icon types
sc_log_section "Icons & Status Indicators"
sc_icon_success "Success indicator"
sc_icon_error "Error indicator"
sc_icon_warning "Warning indicator"
sc_icon_info "Info indicator"
sc_emoji_status rocket "Rocket emoji status"
sc_emoji_status chart "Chart emoji status"
sc_emoji_status shield "Shield emoji status"
echo ""

# Show color capabilities
sc_log_section "Color System"
echo -e "Standard colors: ${SC_RED}Red${SC_RESET} ${SC_GREEN}Green${SC_RESET} ${SC_BLUE}Blue${SC_RESET} ${SC_YELLOW}Yellow${SC_RESET}"
echo -e "256-color: $(sc_color_256 208)Orange${SC_RESET} $(sc_color_256 205)Pink${SC_RESET} $(sc_color_256 135)Purple${SC_RESET}"
echo -e "RGB color: $(sc_rgb 255 105 180)Hot Pink${SC_RESET} $(sc_rgb 50 205 50)Lime${SC_RESET}"
echo -e "Rainbow: $(sc_rainbow "ShellCandy makes terminals beautiful!")"
echo ""

# Show different box styles
sc_log_section "Box Styles"

box_info "Standard Box" "Clean, professional appearance"
echo ""

box_rounded_header "Rounded Box" "$SC_GREEN" 60
box_rounded_line "Softer, friendlier appearance" "$SC_GREEN" 60
box_rounded_footer "$SC_GREEN" 60
echo ""

box_double_header "Double-Line Box" "$SC_MAGENTA" 60
box_line "Emphasized, important content" "$SC_MAGENTA" 60
box_double_footer "$SC_MAGENTA" 60
echo ""

# Final message
box_success "ShellCandy Showcase Complete!" \
    "" \
    "You've seen all major features:" \
    "" \
    "✓ Colors: 16 standard + 256-color + RGB" \
    "✓ Logging: Multi-level with file output" \
    "✓ Progress: Spinners, bars, ETAs" \
    "✓ Icons: Status symbols and emojis" \
    "✓ Boxes: Perfect alignment and styles" \
    "" \
    "🚀 Ready to beautify your shell scripts!" \
    "📚 See SHELLCANDY.md for full documentation"

echo ""
echo -e "${SC_CYAN}${SC_BOLD}Thank you for exploring ShellCandy!${SC_RESET}"
echo ""
echo -e "${SC_DIM}Get started: source lib/shellcandy.sh${SC_RESET}"
echo -e "${SC_DIM}Learn more: cat lib/SHELLCANDY.md${SC_RESET}"
echo ""
