#!/usr/bin/env bash
# benchmark.sh - Performance benchmarking suite for ShellCandy
#
# Measures performance of core functions to identify optimization opportunities
# and track improvements over time.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Load ShellCandy
source "${LIB_DIR}/shellcandy.sh"

# ============================================================================
# Benchmark Framework
# ============================================================================

BENCHMARK_RESULTS=()
BENCHMARK_TOTAL_TIME=0

# Run a benchmark
# Usage: benchmark "Name" iterations function [args...]
benchmark() {
    local name=$1
    local iterations=$2
    local func=$3
    shift 3
    local args=("$@")

    echo -n "Running: $name ($iterations iterations)... "

    local start=$(date +%s%N)
    for ((i=0; i<iterations; i++)); do
        "$func" "${args[@]}" > /dev/null 2>&1
    done
    local end=$(date +%s%N)

    local elapsed=$((end - start))
    local elapsed_ms=$((elapsed / 1000000))
    local per_iter=$((elapsed / iterations / 1000))  # microseconds

    echo "${elapsed_ms}ms total (${per_iter}µs per iteration)"

    BENCHMARK_RESULTS+=("$name|$iterations|$elapsed_ms|$per_iter")
    BENCHMARK_TOTAL_TIME=$((BENCHMARK_TOTAL_TIME + elapsed_ms))
}

# Show benchmark results
show_results() {
    echo ""
    echo "=========================================="
    echo "           BENCHMARK RESULTS"
    echo "=========================================="
    echo ""

    sc_table_create "rounded"
    sc_table_header "Benchmark" "Iterations" "Total Time" "Per Iteration"

    for result in "${BENCHMARK_RESULTS[@]}"; do
        IFS='|' read -r name iters total per <<< "$result"
        sc_table_row "$name" "$iters" "${total}ms" "${per}µs"
    done

    sc_table_render "$SC_BLUE"

    echo ""
    echo "Total benchmark time: ${BENCHMARK_TOTAL_TIME}ms"
}

# ============================================================================
# Test Functions
# ============================================================================

# Test box drawing
test_box() {
    box "Test" "This is a test message" "With multiple lines" "And emoji 🚀" >/dev/null
}

# Test table rendering
test_table() {
    sc_table_create "rounded"
    sc_table_header "Name" "Value" "Status"
    sc_table_row "Test1" "100" "✓ OK"
    sc_table_row "Test2" "200" "✓ OK"
    sc_table_row "Test3" "300" "✓ OK"
    sc_table_render >/dev/null
}

# Test logging
test_logging() {
    sc_log_info "Test message" >/dev/null
}

# Test progress bar
test_progress() {
    sc_progress_bar 50 100 "Testing" >/dev/null
}

# Test sparkline
test_sparkline() {
    local data=(10 20 30 25 35 40 30 45 50 55)
    sc_sparkline data >/dev/null
}

# Test gauge
test_gauge() {
    sc_gauge 75 100 "CPU" 30 >/dev/null
}

# Test ANSI stripping (core function)
test_ansi_strip() {
    local text="${SC_RED}${SC_BOLD}Test${SC_RESET} with ${SC_GREEN}colors${SC_RESET}"
    _strip_ansi "$text" >/dev/null
}

# Test emoji width calculation
test_emoji_width() {
    local text="Test 🚀 emoji 📊 width 🔥"
    _calculate_emoji_width "$text" >/dev/null
}

# Test menu rendering (without interaction)
test_menu() {
    sc_menu_create "Test Menu"
    sc_menu_add "Option 1" "true" "true" "1"
    sc_menu_add "Option 2" "true" "true" "2"
    sc_menu_add "Option 3" "true" "true" "3"
    # Don't show, just creation overhead
}

# Test chart generation
test_chart() {
    local data=(10 20 30 40 50)
    local labels=("A" "B" "C" "D" "E")
    sc_chart_bar_h "Test" data labels 20 "$SC_BLUE" >/dev/null
}

# ============================================================================
# Stress Tests
# ============================================================================

# Stress test: Large table
test_large_table() {
    sc_table_create "rounded"
    sc_table_header "Col1" "Col2" "Col3" "Col4" "Col5"
    for i in {1..50}; do
        sc_table_row "Row$i" "Value$i" "Status$i" "Data$i" "Info$i"
    done
    sc_table_render >/dev/null
}

# Stress test: Many boxes
test_many_boxes() {
    for i in {1..20}; do
        box_info "Message $i" "Content for message $i" >/dev/null
    done
}

# Stress test: Long sparkline
test_long_sparkline() {
    local data=()
    for i in {1..100}; do
        data+=($((RANDOM % 100)))
    done
    sc_sparkline data >/dev/null
}

# ============================================================================
# Main Benchmark Suite
# ============================================================================

main() {
    clear
    box_header "ShellCandy Performance Benchmark Suite" "$SC_CYAN" 80
    box_footer "$SC_CYAN" 80
    echo ""
    echo "Testing core function performance..."
    echo ""

    # Core function benchmarks (high iteration count)
    benchmark "ANSI Strip" 10000 test_ansi_strip
    benchmark "Emoji Width" 10000 test_emoji_width
    benchmark "Logging" 5000 test_logging
    benchmark "Progress Bar" 1000 test_progress

    # UI component benchmarks (moderate iteration count)
    benchmark "Box Drawing" 500 test_box
    benchmark "Table Rendering" 200 test_table
    benchmark "Sparkline" 500 test_sparkline
    benchmark "Gauge" 500 test_gauge
    benchmark "Menu Creation" 500 test_menu
    benchmark "Chart Generation" 200 test_chart

    # Stress test benchmarks (low iteration count)
    echo ""
    echo "Running stress tests..."
    echo ""
    benchmark "Large Table (50 rows)" 50 test_large_table
    benchmark "Many Boxes (20)" 50 test_many_boxes
    benchmark "Long Sparkline (100 points)" 100 test_long_sparkline

    # Display results
    show_results

    echo ""
    box_success "Benchmark Complete" \
        "All tests completed successfully" \
        "" \
        "Results saved to: benchmark_results.txt"
    echo ""

    # Save results
    {
        echo "ShellCandy Benchmark Results"
        echo "Date: $(date)"
        echo "=============================="
        echo ""
        for result in "${BENCHMARK_RESULTS[@]}"; do
            IFS='|' read -r name iters total per <<< "$result"
            printf "%-35s %8s iterations | %10s total | %10s per iter\n" \
                "$name" "$iters" "${total}ms" "${per}µs"
        done
        echo ""
        echo "Total: ${BENCHMARK_TOTAL_TIME}ms"
    } > benchmark_results.txt
}

main "$@"
