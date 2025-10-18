#!/bin/bash
# examples.sh - Practical examples for the box drawing library

# Load ShellCandy from parent directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../shellcandy.sh"

# Clear screen for clean output
clear

echo "╔════════════════════════════════════════════════════════════════════════════════╗"
echo "║                    Terminal Box Drawing Library - Examples                    ║"
echo "╚════════════════════════════════════════════════════════════════════════════════╝"
echo

# ============================================================================
# Example 1: Simple Messages
# ============================================================================

echo "Example 1: Simple Message Boxes"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

box_info "Welcome" "This is an informational message" "Multiple lines are supported"
echo

box_success "Operation Complete" "All files processed successfully" "Total: 42 files"
echo

box_warning "Low Disk Space" "Only 5GB remaining" "Consider cleaning up old files"
echo

box_error "Connection Failed" "Unable to reach database" "Retrying in 30 seconds..."
echo
echo "Press Enter to continue..."; read -r
clear

# ============================================================================
# Example 2: System Dashboard
# ============================================================================

echo "Example 2: System Status Dashboard"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

box_header "System Status Dashboard" "$CYAN" 78
box_empty "$CYAN" 78
box_line "${BOLD}🌐 Services:${NC}" "$CYAN" 78
box_line "  ✅ Web Server        Running      Port 8080" "$CYAN" 78
box_line "  ✅ API Server        Running      Port 3000" "$CYAN" 78
box_line "  ✅ Database          Running      Port 5432" "$CYAN" 78
box_line "  ⚠️  Cache            Degraded     Port 6379" "$CYAN" 78
box_empty "$CYAN" 78
box_line "${BOLD}📊 Resources:${NC}" "$CYAN" 78
box_line "  CPU Usage:           45%          [████████░░]" "$CYAN" 78
box_line "  Memory:              2.1GB/8GB    [███░░░░░░░]" "$CYAN" 78
box_line "  Disk:                120GB/500GB  [██░░░░░░░░]" "$CYAN" 78
box_empty "$CYAN" 78
box_line "${BOLD}🔧 Last Updated:${NC} 2025-01-06 14:30:00" "$CYAN" 78
box_footer "$CYAN" 78

echo
echo "Press Enter to continue..."; read -r
clear

# ============================================================================
# Example 3: Deployment Report
# ============================================================================

echo "Example 3: Deployment Report"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

box_header "Deployment Report - Production" "$GREEN" 80
box_line "${BOLD}📋 Deployment Summary${NC}" "$GREEN" 80
box_line "  Application:  myapp" "$GREEN" 80
box_line "  Version:      v2.0.1" "$GREEN" 80
box_line "  Environment:  production" "$GREEN" 80
box_line "  Deployed by:  jenkins" "$GREEN" 80
box_line "  Time:         2025-01-06 14:15:30 UTC" "$GREEN" 80
box_empty "$GREEN" 80
box_line "${BOLD}🚀 Changes Deployed${NC}" "$GREEN" 80
box_line "  ✅ Added user authentication system" "$GREEN" 80
box_line "  ✅ Fixed memory leak in worker process" "$GREEN" 80
box_line "  ✅ Updated React to v18.2.0" "$GREEN" 80
box_line "  ✅ Improved API response times by 40%" "$GREEN" 80
box_empty "$GREEN" 80
box_line "${BOLD}🔍 Validation Results${NC}" "$GREEN" 80
box_line "  Health Check:     ✅ Passed" "$GREEN" 80
box_line "  Smoke Tests:      ✅ 25/25 passed" "$GREEN" 80
box_line "  Load Test:        ✅ 1000 req/s sustained" "$GREEN" 80
box_empty "$GREEN" 80
box_line "${BOLD}✅ Status:${NC} Deployment successful" "$GREEN" 80
box_footer "$GREEN" 80

echo
echo "Press Enter to continue..."; read -r
clear

# ============================================================================
# Example 4: Configuration Display
# ============================================================================

echo "Example 4: Configuration Display"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

box "Application Configuration" \
    "${BOLD}Server Settings${NC}" \
    "  Host: localhost" \
    "  Port: 8080" \
    "  Protocol: https" \
    "" \
    "${BOLD}Database${NC}" \
    "  Type: PostgreSQL" \
    "  Host: db.example.com:5432" \
    "  Database: myapp_production" \
    "  Pool Size: 20" \
    "" \
    "${BOLD}Features${NC}" \
    "  ✅ Authentication enabled" \
    "  ✅ Rate limiting enabled" \
    "  ❌ Debug mode disabled" \
    --color="$MAGENTA" \
    --width=70

echo
echo "Press Enter to continue..."; read -r
clear

# ============================================================================
# Example 5: Interactive Menu
# ============================================================================

echo "Example 5: Interactive Menu"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

box_rounded_header "Main Menu" "$BLUE" 60
box_rounded_line "" "$BLUE" 60
box_rounded_line "  ${BOLD}1.${NC} Start Service" "$BLUE" 60
box_rounded_line "  ${BOLD}2.${NC} Stop Service" "$BLUE" 60
box_rounded_line "  ${BOLD}3.${NC} View Status" "$BLUE" 60
box_rounded_line "  ${BOLD}4.${NC} Configuration" "$BLUE" 60
box_rounded_line "  ${BOLD}5.${NC} Logs" "$BLUE" 60
box_rounded_line "  ${BOLD}6.${NC} Help" "$BLUE" 60
box_rounded_line "  ${BOLD}Q.${NC} Quit" "$BLUE" 60
box_rounded_line "" "$BLUE" 60
box_rounded_line "  ${DIM}Enter your choice [1-6, Q]:${NC}" "$BLUE" 60
box_rounded_footer "$BLUE" 60

echo
echo "Press Enter to continue..."; read -r
clear

# ============================================================================
# Example 6: Progress Indication
# ============================================================================

echo "Example 6: Progress Indication"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

for i in {1..5}; do
    clear
    echo "Example 6: Progress Indication"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo

    box_info "Processing Data" \
        "Step $i of 5" \
        "" \
        "Current operation: Processing batch $i" \
        "Files processed: $((i * 20))/100" \
        "" \
        "[$(printf '█%.0s' $(seq 1 $i))$(printf '░%.0s' $(seq 1 $((5-i))))] $((i * 20))%"

    sleep 0.5
done

box_success "Complete!" \
    "All steps finished successfully" \
    "" \
    "Total files processed: 100" \
    "Time elapsed: 2.5 seconds"

echo
echo "Press Enter to continue..."; read -r
clear

# ============================================================================
# Example 7: Error Report
# ============================================================================

echo "Example 7: Error Report with Stack Trace"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

box_header "Application Error" "$RED" 78
box_line "❌ ${BOLD}Error:${NC} Database connection failed" "$RED" 78
box_empty "$RED" 78
box_line "${BOLD}Details:${NC}" "$RED" 78
box_line "  Type:     ConnectionError" "$RED" 78
box_line "  Message:  Connection refused" "$RED" 78
box_line "  Host:     db.example.com:5432" "$RED" 78
box_line "  Time:     2025-01-06 14:30:45" "$RED" 78
box_empty "$RED" 78
box_line "${BOLD}Stack Trace:${NC}" "$RED" 78
box_line "  at connectToDatabase (db.js:42:15)" "$RED" 78
box_line "  at startServer (server.js:23:8)" "$RED" 78
box_line "  at main (index.js:5:3)" "$RED" 78
box_empty "$RED" 78
box_line "${BOLD}💡 Suggested Actions:${NC}" "$RED" 78
box_line "  1. Check database server is running" "$RED" 78
box_line "  2. Verify network connectivity" "$RED" 78
box_line "  3. Check credentials in config" "$RED" 78
box_footer "$RED" 78

echo
echo "Press Enter to continue..."; read -r
clear

# ============================================================================
# Example 8: Comparison of Styles
# ============================================================================

echo "Example 8: Different Box Styles"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

echo "Standard Box:"
box_header "Standard Style" "$BLUE" 60
box_line "Clean, professional appearance" "$BLUE" 60
box_footer "$BLUE" 60

echo
echo "Rounded Box:"
box_rounded_header "Rounded Style" "$GREEN" 60
box_rounded_line "Softer, friendlier appearance" "$GREEN" 60
box_rounded_footer "$GREEN" 60

echo
echo "Double-Line Box:"
box_double_header "Double-Line Style" "$MAGENTA" 60
box_line "Emphasized, important content" "$MAGENTA" 60
box_double_footer "$MAGENTA" 60

echo
echo "Press Enter to continue..."; read -r
clear

# ============================================================================
# Final Example: All Together
# ============================================================================

echo "Example 9: Complete Application Output"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

box_info "Starting Application" \
    "Initializing components..." \
    "Loading configuration..." \
    "Connecting to database..."

sleep 1

box_success "Application Started" \
    "All services running" \
    "Ready to accept connections"

echo

box_header "Service Information" "$CYAN" 70
box_line "🌐 ${BOLD}Access Points${NC}" "$CYAN" 70
box_line "  Web:     http://localhost:8080" "$CYAN" 70
box_line "  API:     http://localhost:3000/api" "$CYAN" 70
box_line "  Admin:   http://localhost:8080/admin" "$CYAN" 70
box_empty "$CYAN" 70
box_line "📊 ${BOLD}Metrics${NC}" "$CYAN" 70
box_line "  Uptime:  < 1 minute" "$CYAN" 70
box_line "  Memory:  450 MB" "$CYAN" 70
box_line "  CPU:     2%" "$CYAN" 70
box_footer "$CYAN" 70

echo
echo
echo "All examples completed! Check lib/boxes.sh for more details."
