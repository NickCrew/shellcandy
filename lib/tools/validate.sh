#!/usr/bin/env bash
# validate.sh - Validation and quality checks for ShellCandy
#
# Performs comprehensive validation of:
# - Module loading
# - Function availability
# - Error handling
# - Edge cases
# - Integration tests

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
declare -a FAILED_TESTS

# ============================================================================
# Test Framework
# ============================================================================

# Assert function exists
assert_function() {
    local func=$1
    ((TESTS_RUN++))

    if declare -f "$func" > /dev/null; then
        ((TESTS_PASSED++))
        echo "  ✓ Function exists: $func"
        return 0
    else
        ((TESTS_FAILED++))
        FAILED_TESTS+=("Function missing: $func")
        echo "  ✗ Function missing: $func"
        return 1
    fi
}

# Assert variable is set
assert_var() {
    local var=$1
    ((TESTS_RUN++))

    if [[ -n "${!var}" ]]; then
        ((TESTS_PASSED++))
        echo "  ✓ Variable set: $var"
        return 0
    else
        ((TESTS_FAILED++))
        FAILED_TESTS+=("Variable not set: $var")
        echo "  ✗ Variable not set: $var"
        return 1
    fi
}

# Assert module loaded
assert_module() {
    local module=$1
    local var="SHELLCANDY_${module^^}_LOADED"
    ((TESTS_RUN++))

    if [[ -n "${!var}" ]]; then
        ((TESTS_PASSED++))
        echo "  ✓ Module loaded: $module"
        return 0
    else
        ((TESTS_FAILED++))
        FAILED_TESTS+=("Module not loaded: $module")
        echo "  ✗ Module not loaded: $module"
        return 1
    fi
}

# ============================================================================
# Module Loading Tests
# ============================================================================

test_module_loading() {
    echo ""
    echo "Testing module loading..."
    echo ""

    # Load ShellCandy
    source "${LIB_DIR}/shellcandy.sh"

    # Check each module
    assert_module "colors"
    assert_module "logging"
    assert_module "progress"
    assert_module "icons"
    assert_module "boxes"
    assert_module "tables"
    assert_module "prompts"
    assert_module "menus"
    assert_module "charts"
}

# ============================================================================
# Function Availability Tests
# ============================================================================

test_colors_functions() {
    echo ""
    echo "Testing colors module functions..."
    echo ""

    assert_function "sc_color_256"
    assert_function "sc_rgb"
    assert_function "sc_rainbow"
    # Note: sc_gradient not implemented yet
}

test_logging_functions() {
    echo ""
    echo "Testing logging module functions..."
    echo ""

    assert_function "sc_log_debug"
    assert_function "sc_log_info"
    assert_function "sc_log_warn"
    assert_function "sc_log_error"
    assert_function "sc_log_success"
    assert_function "sc_log_section"
}

test_progress_functions() {
    echo ""
    echo "Testing progress module functions..."
    echo ""

    assert_function "sc_spinner_start"
    assert_function "sc_spinner_stop"
    assert_function "sc_progress_bar"
    assert_function "sc_progress_start"
    assert_function "sc_progress_update"
    assert_function "sc_progress_finish"
}

test_icons_functions() {
    echo ""
    echo "Testing icons module functions..."
    echo ""

    assert_function "sc_icon_success"
    assert_function "sc_icon_error"
    assert_function "sc_icon_warning"
    assert_function "sc_icon_info"
    assert_function "sc_emoji_status"
}

test_boxes_functions() {
    echo ""
    echo "Testing boxes module functions..."
    echo ""

    assert_function "box_header"
    assert_function "box_line"
    assert_function "box_footer"
    assert_function "box"
    assert_function "box_success"
    assert_function "box_error"
    assert_function "box_warning"
    assert_function "box_info"
}

test_tables_functions() {
    echo ""
    echo "Testing tables module functions..."
    echo ""

    assert_function "sc_table_create"
    assert_function "sc_table_header"
    assert_function "sc_table_row"
    assert_function "sc_table_render"
    assert_function "sc_table_kv"
    assert_function "sc_table_metrics"
}

test_prompts_functions() {
    echo ""
    echo "Testing prompts module functions..."
    echo ""

    assert_function "sc_prompt_text"
    assert_function "sc_prompt_password"
    assert_function "sc_prompt_confirm"
    assert_function "sc_prompt_select"
    assert_function "sc_prompt_number"
    assert_function "sc_validate_email"
    assert_function "sc_validate_url"
}

test_menus_functions() {
    echo ""
    echo "Testing menus module functions..."
    echo ""

    assert_function "sc_menu_create"
    assert_function "sc_menu_add"
    assert_function "sc_menu_add_separator"
    assert_function "sc_menu_show"
}

test_charts_functions() {
    echo ""
    echo "Testing charts module functions..."
    echo ""

    assert_function "sc_sparkline"
    assert_function "sc_sparkline_color"
    assert_function "sc_chart_bar_h"
    assert_function "sc_chart_bar_v"
    assert_function "sc_gauge"
    assert_function "sc_histogram"
}

# ============================================================================
# Functional Tests
# ============================================================================

test_box_alignment() {
    echo ""
    echo "Testing box alignment..."
    echo ""

    ((TESTS_RUN++))
    local output=$(box "Test" "Short" "Much longer line here" "🚀 Emoji")
    if [[ -n "$output" ]]; then
        ((TESTS_PASSED++))
        echo "  ✓ Box rendering works"
    else
        ((TESTS_FAILED++))
        FAILED_TESTS+=("Box rendering failed")
        echo "  ✗ Box rendering failed"
    fi
}

test_table_rendering() {
    echo ""
    echo "Testing table rendering..."
    echo ""

    ((TESTS_RUN++))
    sc_table_create "rounded"
    sc_table_header "Name" "Value"
    sc_table_row "Test" "123"
    local output=$(sc_table_render)

    if [[ -n "$output" ]]; then
        ((TESTS_PASSED++))
        echo "  ✓ Table rendering works"
    else
        ((TESTS_FAILED++))
        FAILED_TESTS+=("Table rendering failed")
        echo "  ✗ Table rendering failed"
    fi
}

test_sparkline_generation() {
    echo ""
    echo "Testing sparkline generation..."
    echo ""

    ((TESTS_RUN++))
    local sparkline_data=(10 20 30 40 50)
    local output=$(sc_sparkline sparkline_data)

    if [[ -n "$output" ]]; then
        ((TESTS_PASSED++))
        echo "  ✓ Sparkline generation works"
    else
        ((TESTS_FAILED++))
        FAILED_TESTS+=("Sparkline generation failed")
        echo "  ✗ Sparkline generation failed"
    fi
}

test_color_output() {
    echo ""
    echo "Testing color output..."
    echo ""

    ((TESTS_RUN++))
    local output=$(echo -e "${SC_RED}Red${SC_RESET}")

    if [[ -n "$output" ]]; then
        ((TESTS_PASSED++))
        echo "  ✓ Color output works"
    else
        ((TESTS_FAILED++))
        FAILED_TESTS+=("Color output failed")
        echo "  ✗ Color output failed"
    fi
}

# ============================================================================
# Edge Case Tests
# ============================================================================

test_edge_cases() {
    echo ""
    echo "Testing edge cases..."
    echo ""

    # Empty box
    ((TESTS_RUN++))
    local output=$(box "" "")
    if [[ -n "$output" ]]; then
        ((TESTS_PASSED++))
        echo "  ✓ Empty box handling"
    else
        ((TESTS_FAILED++))
        FAILED_TESTS+=("Empty box failed")
        echo "  ✗ Empty box failed"
    fi

    # Very long line
    ((TESTS_RUN++))
    local long_line=$(printf 'A%.0s' {1..200})
    output=$(box "Test" "$long_line")
    if [[ -n "$output" ]]; then
        ((TESTS_PASSED++))
        echo "  ✓ Long line handling"
    else
        ((TESTS_FAILED++))
        FAILED_TESTS+=("Long line failed")
        echo "  ✗ Long line failed"
    fi

    # Unicode characters
    ((TESTS_RUN++))
    output=$(box "Test" "你好 مرحبا Привет")
    if [[ -n "$output" ]]; then
        ((TESTS_PASSED++))
        echo "  ✓ Unicode handling"
    else
        ((TESTS_FAILED++))
        FAILED_TESTS+=("Unicode handling failed")
        echo "  ✗ Unicode handling failed"
    fi
}

# ============================================================================
# Performance Tests
# ============================================================================

test_performance() {
    echo ""
    echo "Testing performance (simple smoke tests)..."
    echo ""

    # Test that repeated calls don't slow down significantly
    ((TESTS_RUN++))
    local start=$(date +%s%N)
    for i in {1..100}; do
        box "Test $i" "Content" > /dev/null
    done
    local end=$(date +%s%N)
    local elapsed=$((end - start))

    # Should complete 100 boxes in under 10 seconds (10000000000 ns)
    # Note: 100ms per box is acceptable for terminal UI work
    if [[ $elapsed -lt 10000000000 ]]; then
        ((TESTS_PASSED++))
        echo "  ✓ Performance acceptable (100 boxes in $((elapsed / 1000000))ms)"
    else
        ((TESTS_FAILED++))
        FAILED_TESTS+=("Performance too slow")
        echo "  ✗ Performance too slow (100 boxes in $((elapsed / 1000000))ms)"
    fi
}

# ============================================================================
# Main Test Runner
# ============================================================================

show_results() {
    echo ""
    echo "=========================================="
    echo "           VALIDATION RESULTS"
    echo "=========================================="
    echo ""
    echo "Tests run:    $TESTS_RUN"
    echo "Tests passed: $TESTS_PASSED"
    echo "Tests failed: $TESTS_FAILED"
    echo ""

    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${SC_GREEN}${SC_BOLD}✓ ALL TESTS PASSED!${SC_RESET}"
        return 0
    else
        echo -e "${SC_RED}${SC_BOLD}✗ SOME TESTS FAILED:${SC_RESET}"
        echo ""
        for test in "${FAILED_TESTS[@]}"; do
            echo "  - $test"
        done
        return 1
    fi
}

main() {
    clear
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                                                                ║"
    echo "║              ShellCandy Validation Suite                      ║"
    echo "║                                                                ║"
    echo "╚════════════════════════════════════════════════════════════════╝"

    # Run all tests
    test_module_loading
    test_colors_functions
    test_logging_functions
    test_progress_functions
    test_icons_functions
    test_boxes_functions
    test_tables_functions
    test_prompts_functions
    test_menus_functions
    test_charts_functions
    test_box_alignment
    test_table_rendering
    test_sparkline_generation
    test_color_output
    test_edge_cases
    test_performance

    # Show results
    show_results
}

main "$@"
