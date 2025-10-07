#!/bin/bash
# charts.sh - Data visualization and charts for ShellCandy
# Version: 1.0.0
#
# Provides:
# - Bar charts (horizontal/vertical)
# - Sparklines (inline mini-charts)
# - Histograms
# - Progress gauges
# - Trend indicators
# - Data labeling

# Prevent multiple sourcing
[[ -n "${SHELLCANDY_CHARTS_LOADED}" ]] && return 0
export SHELLCANDY_CHARTS_LOADED=1

# Source colors
if [[ -f "$(dirname "${BASH_SOURCE[0]}")/colors.sh" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/colors.sh"
fi

# Fallback colors
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

# Chart characters
export SC_CHART_BAR_CHAR="█"
export SC_CHART_EMPTY_CHAR="░"
export SC_CHART_SPARK_CHARS=("▁" "▂" "▃" "▄" "▅" "▆" "▇" "█")

# Default colors for multi-series
export SC_CHART_COLORS=("$SC_BLUE" "$SC_GREEN" "$SC_YELLOW" "$SC_MAGENTA" "$SC_CYAN")

# ============================================================================
# Utility Functions
# ============================================================================

# Find min value in array
_sc_chart_min() {
    local -n arr=$1
    local min=${arr[0]}
    for val in "${arr[@]}"; do
        (( $(echo "$val < $min" | bc -l 2>/dev/null || echo 0) )) && min=$val
    done
    echo "$min"
}

# Find max value in array
_sc_chart_max() {
    local -n arr=$1
    local max=${arr[0]}
    for val in "${arr[@]}"; do
        (( $(echo "$val > $max" | bc -l 2>/dev/null || echo 0) )) && max=$val
    done
    echo "$max"
}

# Scale value to range
# Usage: scaled=$(_sc_chart_scale value min max new_max)
_sc_chart_scale() {
    local value=$1
    local min=$2
    local max=$3
    local new_max=$4

    if [[ "$max" == "$min" ]]; then
        echo "$new_max"
        return
    fi

    local scaled=$(echo "scale=2; ($value - $min) / ($max - $min) * $new_max" | bc -l 2>/dev/null || echo 0)
    printf "%.0f" "$scaled"
}

# ============================================================================
# Horizontal Bar Chart
# ============================================================================

# Draw horizontal bar chart
# Usage: sc_chart_bar_h "Title" data[@] [labels[@]] [width] [color]
sc_chart_bar_h() {
    local title=$1
    local -n data=$2
    local -n labels=${3:-""}
    local width=${4:-50}
    local color=${5:-$SC_BLUE}

    # Find max for scaling
    local max=$(_sc_chart_max data)

    # Print title
    if [[ -n "$title" ]]; then
        echo -e "${SC_BOLD}${title}${SC_RESET}"
        echo ""
    fi

    # Find max label length for alignment
    local max_label_len=0
    if [[ -n "$labels" ]]; then
        for label in "${labels[@]}"; do
            [[ ${#label} -gt $max_label_len ]] && max_label_len=${#label}
        done
    fi

    # Draw bars
    for i in "${!data[@]}"; do
        local value=${data[$i]}
        local label=""

        # Get label if available
        if [[ -n "$labels" ]]; then
            label="${labels[$i]}"
            printf "%-${max_label_len}s " "$label"
        fi

        # Calculate bar length
        local bar_len=$(_sc_chart_scale "$value" 0 "$max" "$width")

        # Choose color based on value
        local bar_color="$color"
        local percent=$(echo "scale=2; $value / $max * 100" | bc -l 2>/dev/null || echo 0)
        if (( $(echo "$percent < 33" | bc -l 2>/dev/null || echo 0) )); then
            bar_color="$SC_RED"
        elif (( $(echo "$percent < 66" | bc -l 2>/dev/null || echo 0) )); then
            bar_color="$SC_YELLOW"
        else
            bar_color="$SC_GREEN"
        fi

        # Draw bar
        printf "${bar_color}"
        for ((j=0; j<bar_len; j++)); do
            printf "%s" "$SC_CHART_BAR_CHAR"
        done
        printf "${SC_RESET}"

        # Print value
        printf " %s\n" "$value"
    done
}

# ============================================================================
# Vertical Bar Chart
# ============================================================================

# Draw vertical bar chart
# Usage: sc_chart_bar_v "Title" data[@] [labels[@]] [height] [color]
sc_chart_bar_v() {
    local title=$1
    local -n data=$2
    local -n labels=${3:-""}
    local height=${4:-20}
    local color=${5:-$SC_BLUE}

    # Find max for scaling
    local max=$(_sc_chart_max data)

    # Print title
    if [[ -n "$title" ]]; then
        echo -e "${SC_BOLD}${title}${SC_RESET}"
        echo ""
    fi

    # Scale all values
    local -a scaled
    for value in "${data[@]}"; do
        scaled+=($(_sc_chart_scale "$value" 0 "$max" "$height"))
    done

    # Draw from top to bottom
    for ((row=height; row>0; row--)); do
        # Y-axis label
        local y_val=$(echo "scale=1; $max * $row / $height" | bc -l 2>/dev/null || echo 0)
        printf "%6.1f │ " "$y_val"

        # Draw bars for this row
        for i in "${!scaled[@]}"; do
            if [[ ${scaled[$i]} -ge $row ]]; then
                printf "${color}%s${SC_RESET} " "$SC_CHART_BAR_CHAR"
            else
                printf "  "
            fi
        done
        echo ""
    done

    # X-axis
    printf "       └"
    for ((i=0; i<${#data[@]}; i++)); do
        printf "──"
    done
    echo ""

    # Labels
    if [[ -n "$labels" ]]; then
        printf "         "
        for label in "${labels[@]}"; do
            printf "%-2s" "${label:0:1}"
        done
        echo ""
    fi
}

# ============================================================================
# Sparklines
# ============================================================================

# Generate sparkline (mini inline chart)
# Usage: sc_sparkline data[@] [height]
sc_sparkline() {
    local -n data=$1
    local levels=${2:-8}

    if [[ ${#data[@]} -eq 0 ]]; then
        return 1
    fi

    # Find min and max
    local min=$(_sc_chart_min data)
    local max=$(_sc_chart_max data)

    # Generate sparkline
    for value in "${data[@]}"; do
        local scaled=$(_sc_chart_scale "$value" "$min" "$max" $((levels - 1)))
        printf "%s" "${SC_CHART_SPARK_CHARS[$scaled]}"
    done
}

# Sparkline with color gradient
# Usage: sc_sparkline_color data[@]
sc_sparkline_color() {
    local -n data=$1

    if [[ ${#data[@]} -eq 0 ]]; then
        return 1
    fi

    local min=$(_sc_chart_min data)
    local max=$(_sc_chart_max data)

    for value in "${data[@]}"; do
        local scaled=$(_sc_chart_scale "$value" "$min" "$max" 7)
        local char="${SC_CHART_SPARK_CHARS[$scaled]}"

        # Color based on value
        if [[ $scaled -lt 3 ]]; then
            printf "${SC_RED}%s${SC_RESET}" "$char"
        elif [[ $scaled -lt 5 ]]; then
            printf "${SC_YELLOW}%s${SC_RESET}" "$char"
        else
            printf "${SC_GREEN}%s${SC_RESET}" "$char"
        fi
    done
}

# ============================================================================
# Histogram
# ============================================================================

# Draw histogram
# Usage: sc_histogram data[@] [bins] [width]
sc_histogram() {
    local -n data=$1
    local bins=${2:-10}
    local width=${3:-50}

    if [[ ${#data[@]} -eq 0 ]]; then
        return 1
    fi

    # Find min and max
    local min=$(_sc_chart_min data)
    local max=$(_sc_chart_max data)
    local range=$(echo "$max - $min" | bc -l 2>/dev/null || echo 1)
    local bin_width=$(echo "scale=4; $range / $bins" | bc -l 2>/dev/null || echo 1)

    # Initialize bin counts
    local -a bin_counts
    for ((i=0; i<bins; i++)); do
        bin_counts[$i]=0
    done

    # Count values in each bin
    for value in "${data[@]}"; do
        local bin_idx=$(echo "scale=0; ($value - $min) / $bin_width" | bc 2>/dev/null || echo 0)
        [[ $bin_idx -ge $bins ]] && bin_idx=$((bins - 1))
        ((bin_counts[$bin_idx]++))
    done

    # Find max bin count for scaling
    local max_count=0
    for count in "${bin_counts[@]}"; do
        [[ $count -gt $max_count ]] && max_count=$count
    done

    # Draw histogram
    echo -e "${SC_BOLD}Histogram${SC_RESET}"
    echo ""

    for i in "${!bin_counts[@]}"; do
        local count=${bin_counts[$i]}
        local bin_start=$(echo "scale=2; $min + $i * $bin_width" | bc -l 2>/dev/null || echo 0)
        local bin_end=$(echo "scale=2; $bin_start + $bin_width" | bc -l 2>/dev/null || echo 0)

        # Label
        printf "%6.2f-%6.2f │ " "$bin_start" "$bin_end"

        # Bar
        local bar_len=$(_sc_chart_scale "$count" 0 "$max_count" "$width")
        printf "${SC_BLUE}"
        for ((j=0; j<bar_len; j++)); do
            printf "%s" "$SC_CHART_BAR_CHAR"
        done
        printf "${SC_RESET} %d\n" "$count"
    done
}

# ============================================================================
# Gauge / Progress Indicator
# ============================================================================

# Draw circular gauge
# Usage: sc_gauge value max [label] [width]
sc_gauge() {
    local value=$1
    local max=$2
    local label=${3:-""}
    local width=${4:-30}

    local percent=$(echo "scale=2; $value / $max * 100" | bc -l 2>/dev/null || echo 0)
    local filled=$(_sc_chart_scale "$value" 0 "$max" "$width")

    # Choose color
    local color="$SC_GREEN"
    if (( $(echo "$percent < 33" | bc -l 2>/dev/null || echo 0) )); then
        color="$SC_RED"
    elif (( $(echo "$percent < 66" | bc -l 2>/dev/null || echo 0) )); then
        color="$SC_YELLOW"
    fi

    # Label
    if [[ -n "$label" ]]; then
        printf "%s: " "$label"
    fi

    # Gauge
    printf "["
    printf "${color}"
    for ((i=0; i<filled; i++)); do
        printf "%s" "$SC_CHART_BAR_CHAR"
    done
    printf "${SC_RESET}"
    for ((i=filled; i<width; i++)); do
        printf "%s" "$SC_CHART_EMPTY_CHAR"
    done
    printf "] "

    # Percentage
    printf "${color}%.1f%%${SC_RESET} (%s/%s)\n" "$percent" "$value" "$max"
}

# ============================================================================
# Trend Indicators
# ============================================================================

# Show trend arrow
# Usage: sc_trend_arrow value1 value2
sc_trend_arrow() {
    local old=$1
    local new=$2

    local diff=$(echo "$new - $old" | bc -l 2>/dev/null || echo 0)
    local percent=0

    if (( $(echo "$old != 0" | bc -l 2>/dev/null || echo 1) )); then
        percent=$(echo "scale=2; ($diff / $old) * 100" | bc -l 2>/dev/null || echo 0)
    fi

    if (( $(echo "$diff > 0" | bc -l 2>/dev/null || echo 0) )); then
        printf "${SC_GREEN}↑ +%.1f%%${SC_RESET}" "$percent"
    elif (( $(echo "$diff < 0" | bc -l 2>/dev/null || echo 0) )); then
        printf "${SC_RED}↓ %.1f%%${SC_RESET}" "$percent"
    else
        printf "${SC_DIM}→ 0%%${SC_RESET}"
    fi
}

# Show trend with value
# Usage: sc_trend value1 value2 [label]
sc_trend() {
    local old=$1
    local new=$2
    local label=${3:-""}

    if [[ -n "$label" ]]; then
        printf "%s: " "$label"
    fi

    printf "%s " "$new"
    sc_trend_arrow "$old" "$new"
    echo ""
}

# ============================================================================
# Multi-series Charts
# ============================================================================

# Draw multi-series bar chart
# Usage: sc_chart_multi "Title" series1[@] series2[@] [labels[@]] [width]
sc_chart_multi() {
    local title=$1
    local -n series1=$2
    local -n series2=$3
    local -n labels=${4:-""}
    local width=${5:-40}

    echo -e "${SC_BOLD}${title}${SC_RESET}"
    echo ""

    # Find global max
    local max1=$(_sc_chart_max series1)
    local max2=$(_sc_chart_max series2)
    local max=$max1
    (( $(echo "$max2 > $max" | bc -l 2>/dev/null || echo 0) )) && max=$max2

    # Find max label length
    local max_label_len=0
    if [[ -n "$labels" ]]; then
        for label in "${labels[@]}"; do
            [[ ${#label} -gt $max_label_len ]] && max_label_len=${#label}
        done
    fi

    # Draw bars for each data point
    for i in "${!series1[@]}"; do
        local val1=${series1[$i]}
        local val2=${series2[$i]:-0}
        local label=""

        # Print label
        if [[ -n "$labels" ]]; then
            label="${labels[$i]}"
            printf "%-${max_label_len}s " "$label"
        fi

        # Series 1
        local len1=$(_sc_chart_scale "$val1" 0 "$max" "$width")
        printf "${SC_BLUE}"
        for ((j=0; j<len1; j++)); do
            printf "%s" "$SC_CHART_BAR_CHAR"
        done
        printf "${SC_RESET} %s   " "$val1"

        # Series 2
        local len2=$(_sc_chart_scale "$val2" 0 "$max" "$width")
        printf "${SC_GREEN}"
        for ((j=0; j<len2; j++)); do
            printf "%s" "$SC_CHART_BAR_CHAR"
        done
        printf "${SC_RESET} %s\n" "$val2"
    done

    echo ""
    printf "Legend: ${SC_BLUE}█${SC_RESET} Series 1   ${SC_GREEN}█${SC_RESET} Series 2\n"
}

# ============================================================================
# Example Usage
# ============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "ShellCandy Charts Module"
    echo "========================"
    echo ""

    # Example 1: Horizontal bar chart
    echo "Example 1: Horizontal Bar Chart"
    echo "────────────────────────────────────────"
    declare -a cpu_data=(45 78 32 90 56)
    declare -a cpu_labels=("Web" "DB" "Cache" "Worker" "API")
    sc_chart_bar_h "CPU Usage by Service (%)" cpu_data cpu_labels 40
    echo ""

    # Example 2: Sparklines
    echo "Example 2: Sparklines"
    echo "────────────────────────────────────────"
    declare -a traffic=(100 120 115 140 180 160 190 175 200 220)
    printf "Traffic (last 10min): "
    sc_sparkline traffic
    echo ""
    printf "With color:           "
    sc_sparkline_color traffic
    echo ""
    echo ""

    # Example 3: Gauges
    echo "Example 3: Resource Gauges"
    echo "────────────────────────────────────────"
    sc_gauge 45 100 "CPU" 30
    sc_gauge 6200 8000 "Memory (MB)" 30
    sc_gauge 120 500 "Disk (GB)" 30
    echo ""

    # Example 4: Trends
    echo "Example 4: Trend Indicators"
    echo "────────────────────────────────────────"
    sc_trend 1000 1234 "Requests"
    sc_trend 45.2 42.8 "Response Time (ms)"
    sc_trend 99.5 99.5 "Uptime (%)"
    echo ""

    # Example 5: Histogram
    echo "Example 5: Response Time Distribution"
    echo "────────────────────────────────────────"
    declare -a response_times=(45 52 48 51 49 150 47 53 200 50 48 52 49 51 48)
    sc_histogram response_times 5 40
    echo ""

    # Example 6: Multi-series
    echo "Example 6: Multi-series Comparison"
    echo "────────────────────────────────────────"
    declare -a last_week=(1200 1350 1280 1420 1500)
    declare -a this_week=(1400 1520 1380 1650 1720)
    declare -a days=("Mon" "Tue" "Wed" "Thu" "Fri")
    sc_chart_multi "Daily Users" last_week this_week days 30
    echo ""

    # Example 7: Vertical bar chart
    echo "Example 7: Vertical Bar Chart"
    echo "────────────────────────────────────────"
    declare -a monthly=(45 52 48 60 58 65 70)
    declare -a months=("Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul")
    sc_chart_bar_v "Growth (%)" monthly months 15
    echo ""

    echo "Examples complete!"
fi
