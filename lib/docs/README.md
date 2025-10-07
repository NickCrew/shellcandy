# 🍭 ShellCandy Framework Documentation

**Version:** 2.0.0 "Super Saiyan God Edition"

Beautiful terminal UI framework for Bash scripts with zero dependencies.

---

## 📚 Complete Documentation

This is the main documentation hub for ShellCandy. All documentation files are located in the `lib/` directory.

### Core Documentation

| Document | Description |
|----------|-------------|
| **[TESTING.md](TESTING.md)** | Testing, validation, and benchmarking guide |
| **[OPTIMIZATION.md](OPTIMIZATION.md)** | Performance optimization and best practices |
| **[CHANGELOG.md](CHANGELOG.md)** | Version history and release notes |

### Quick Links

- 🚀 [Quick Start](#quick-start)
- ✨ [Features](#features)
- 📦 [Modules](#modules)
- 🎓 [Examples](#examples)
- ⚡ [Performance](#performance)

---

## 🚀 Quick Start

### Installation

```bash
# One-line install
curl -fsSL https://shellcandy.sh/install.sh | bash

# Manual install
git clone https://github.com/YOUR_ORG/shellcandy.git ~/.shellcandy
source ~/.shellcandy/lib/shellcandy.sh
```

### Your First Script

```bash
#!/usr/bin/env bash
source ~/.shellcandy/lib/shellcandy.sh

# Beautiful box
box_success "Welcome!" "ShellCandy makes terminals beautiful"

# Progress bar
sc_progress_bar 75 100 "Processing"

# Sparkline
declare -a data=(10 20 30 25 35 40)
echo "Trend: $(sc_sparkline data)"
```

---

## ✨ Features

ShellCandy provides **9 complete modules** with **60+ functions**:

### 🎨 Core Modules

1. **colors** - 256-color, RGB, themes
2. **logging** - Multi-level logging with file output
3. **progress** - Spinners, progress bars, ETAssc_gauge 75 100 "CPU Usage" 30
4. **icons** - 50+ status symbols and emojis
5. **boxes** - Perfect alignment with ANSI/emoji support

### 🚀 Advanced Modules

6. **tables** - Auto-sizing tables with CSV support
7. **prompts** - Interactive forms with validation
8. **menus** - Keyboard navigation, nested menus
9. **charts** - Sparklines, bar charts, gauges, histograms

---

## 📦 Modules

### 1. Colors Module (`colors.sh`)

Extended color system with 256-color and RGB support.

**Key Functions:**
- `sc_color_256(N)` - Use 256-color palette
- `sc_rgb(R, G, B)` - True color (24-bit)
- `sc_rainbow(text)` - Rainbow text effect

**Example:**
```bash
echo -e "$(sc_color_256 196)Red text${SC_RESET}"
echo -e "$(sc_rgb 255 128 0)Orange${SC_RESET}"
sc_rainbow "Beautiful colors!"
```

**Variables:**
- `SC_RED`, `SC_GREEN`, `SC_BLUE`, etc. - Standard colors
- `SC_BOLD`, `SC_DIM`, `SC_UNDERLINE` - Text formatting
- `SC_RESET` - Reset all formatting

---

### 2. Logging Module (`logging.sh`)

Multi-level logging with colored output and file support.

**Key Functions:**
- `sc_log_debug(msg)` - Debug level
- `sc_log_info(msg)` - Info level
- `sc_log_warn(msg)` - Warning level
- `sc_log_error(msg)` - Error level
- `sc_log_success(msg)` - Success level
- `sc_log_section(title)` - Section header

**Example:**
```bash
sc_log_info "Starting application..."
sc_log_success "Connected to database"
sc_log_warn "Disk space low"
sc_log_error "Failed to load config"
```

**Configuration:**
```bash
export SC_LOG_LEVEL=DEBUG
export SC_LOG_FILE="/var/log/myapp.log"
sc_log_set_level INFO
```

---

### 3. Progress Module (`progress.sh`)

Progress indicators with spinners and bars.

**Key Functions:**
- `sc_spinner_start(msg, [style])` - Start spinner
- `sc_spinner_stop(pid, [msg])` - Stop spinner
- `sc_progress_bar(current, total, label)` - Show progress bar
- `sc_progress_start(total, label)` - Start progress tracking
- `sc_progress_update()` - Update progress
- `sc_progress_finish([msg])` - Finish progress

**Example:**
```bash
# Spinner
spinner_pid=$(sc_spinner_start "Loading..." "dots")
sleep 3
sc_spinner_stop "$spinner_pid" "Done!"

# Progress bar
for i in {1..100}; do
    sc_progress_bar $i 100 "Processing"
    sleep 0.05
done
```

**Spinner Styles:**
- `dots`, `line`, `arrow`, `circle`, `bounce`, `classic`

---

### 4. Icons Module (`icons.sh`)

Status symbols and emoji collections.

**Key Functions:**
- `sc_icon_success()` - ✓ Success icon
- `sc_icon_error()` - ✗ Error icon
- `sc_icon_warning()` - ⚠ Warning icon
- `sc_icon_info()` - ℹ Info icon
- `sc_emoji_status(name, msg)` - Emoji with message

**Example:**
```bash
sc_icon_success "Operation completed"
sc_icon_error "Failed to connect"
sc_emoji_status rocket "Deployment started"
sc_emoji_status shield "Security scan passed"
```

---

### 5. Boxes Module (`boxes.sh`)

Beautiful box drawing with perfect alignment.

**Key Functions:**
- `box(title, lines...)` - General purpose box
- `box_success(title, lines...)` - Success box (green)
- `box_error(title, lines...)` - Error box (red)
- `box_warning(title, lines...)` - Warning box (yellow)
- `box_info(title, lines...)` - Info box (blue)
- `box_header(title, [color], [width])` - Box header only
- `box_footer([color], [width])` - Box footer only
- `box_line(content, [color], [width])` - Single line

**Example:**
```bash
box_success "Deployment Complete" \
    "Environment: production" \
    "Version: v2.1.0" \
    "Time: $(date)"

box_error "Build Failed" \
    "Exit code: 1" \
    "Duration: 5m 23s"
```

---

### 6. Tables Module (`tables.sh`)

Auto-sizing tables with CSV support and formatting.

**Key Functions:**
- `sc_table_create([style])` - Initialize table
- `sc_table_header(cols...)` - Set headers
- `sc_table_row(cols...)` - Add row
- `sc_table_render([color])` - Render table
- `sc_table_kv(key, value, ...)` - Key-value table
- `sc_table_metrics(data...)` - Metrics table

**Example:**
```bash
sc_table_create "rounded"
sc_table_header "Service" "Status" "CPU" "Memory"
sc_table_row "Web" "✓ Running" "23%" "450MB"
sc_table_row "DB" "✓ Running" "45%" "1.2GB"
sc_table_row "Cache" "⚠ Degraded" "8%" "250MB"
sc_table_render "$SC_BLUE"
```

**Table Styles:**
- `standard`, `rounded`, `double`, `simple`, `minimal`

---

### 7. Prompts Module (`prompts.sh`)

Interactive forms with validation.

**Key Functions:**
- `sc_prompt_text(msg, [default])` - Text input
- `sc_prompt_password(msg)` - Password input (masked)
- `sc_prompt_confirm(msg, [default])` - Yes/No confirmation
- `sc_prompt_select(msg, options...)` - Select from list
- `sc_prompt_number(msg, min, max, [default])` - Number input
- `sc_prompt_email(msg)` - Email with validation
- `sc_validate_email(email)` - Email validator
- `sc_validate_url(url)` - URL validator

**Example:**
```bash
name=$(sc_prompt_text "Your name:")
email=$(sc_prompt_email "Email address:")
port=$(sc_prompt_number "Port:" 1 65535 8080)

if sc_prompt_confirm "Continue with deployment?"; then
    deploy
fi
```

---

### 8. Menus Module (`menus.sh`)

Interactive menus with full keyboard navigation.

**Key Functions:**
- `sc_menu_create(title)` - Initialize menu
- `sc_menu_add(label, action, enabled, [hotkey])` - Add item
- `sc_menu_add_separator()` - Add visual separator
- `sc_menu_add_submenu(label, submenu_fn, [hotkey])` - Add submenu
- `sc_menu_show()` - Display and handle menu

**Example:**
```bash
sc_menu_create "Main Menu"
sc_menu_add "Deploy" "cmd_deploy" "true" "d"
sc_menu_add "Status" "cmd_status" "true" "s"
sc_menu_add_separator
sc_menu_add "Settings" "cmd_settings" "true" "c"
sc_menu_add "Exit" "exit" "true" "q"
sc_menu_show
```

**Navigation:**
- ↑↓ or j/k - Move selection
- Enter - Select item
- Hotkeys - Quick access
- Numbers - Jump to item
- q - Quit

---

### 9. Charts Module (`charts.sh`)

Data visualization with multiple chart types.

**Key Functions:**
- `sc_sparkline(data_array)` - ASCII sparkline
- `sc_sparkline_color(data_array)` - Colored sparkline
- `sc_chart_bar_h(title, data, labels, width)` - Horizontal bar chart
- `sc_chart_bar_v(title, data, labels, height)` - Vertical bar chart
- `sc_gauge(value, max, label, width)` - Progress gauge
- `sc_histogram(data, buckets, width)` - Histogram
- `sc_trend(value1, value2)` - Trend indicator (↑↓→)

**Example:**
```bash
# Sparkline
declare -a cpu=(30 35 42 45 50 48 52)
echo "CPU: $(sc_sparkline cpu)"  # ▂▃▄▅▆▅▇

# Gauge
sc_gauge 75 100 "CPU Usage" 40

# Bar chart
declare -a values=(42 67 89 54)
declare -a labels=("Q1" "Q2" "Q3" "Q4")
sc_chart_bar_h "Sales" values labels 50
```

---

## 🎓 Examples

### Example 1: System Monitoring

```bash
#!/usr/bin/env bash
source ~/.shellcandy/lib/shellcandy.sh

# Display system metrics
declare -a cpu_hist=(30 32 35 38 40 42 45)
declare -a mem_hist=(55 57 60 62 63 65 67)

box_header "System Dashboard" "$SC_CYAN" 70
box_footer "$SC_CYAN" 70
echo ""

sc_gauge 45 100 "CPU Usage" 40
sc_gauge 67 100 "Memory" 40
echo ""

echo "CPU Trend: $(sc_sparkline cpu_hist)"
echo "Mem Trend: $(sc_sparkline mem_hist)"
```

### Example 2: Interactive Tool

```bash
#!/usr/bin/env bash
source ~/.shellcandy/lib/shellcandy.sh

deploy() {
    env=$(sc_prompt_select "Environment:" "dev" "staging" "prod")

    if sc_prompt_confirm "Deploy to $env?"; then
        sc_progress_start 100 "Deploying"
        for i in {1..100}; do
            sc_progress_update
            sleep 0.05
        done
        sc_progress_finish

        box_success "Deployed!" "Environment: $env"
    fi
}

sc_menu_create "DevOps Menu"
sc_menu_add "Deploy" "deploy" "true" "d"
sc_menu_add "Exit" "exit" "true" "q"
sc_menu_show
```

---

## ⚡ Performance

ShellCandy is highly optimized:

| Operation | Time | Target |
|-----------|------|--------|
| Core functions | 40-70µs | <100µs ✅ |
| Box rendering | 2-4ms | <10ms ✅ |
| Table (10 rows) | 15-25ms | <50ms ✅ |
| Sparklines | 1-2ms | <5ms ✅ |

**Run benchmarks:**
```bash
./lib/benchmark.sh
```

**Run validation:**
```bash
./lib/validate.sh  # 68 tests
```

See [OPTIMIZATION.md](OPTIMIZATION.md) for details.

---

## 🔧 Configuration

### Module Loading

```bash
# Load only needed modules
export SHELLCANDY_LOAD_TABLES=false
export SHELLCANDY_LOAD_CHARTS=false
source lib/shellcandy.sh

# Minimal mode (4 essential modules)
source lib/shellcandy.sh --minimal
```

### Logging Configuration

```bash
export SC_LOG_LEVEL=DEBUG
export SC_LOG_FILE="/var/log/app.log"
export SC_LOG_TIMESTAMP=true
```

### Color Configuration

```bash
export SC_LOG_COLORS=false  # Disable colors
export BOX_DEFAULT_WIDTH=100  # Default box width
```

---

## 📊 API Reference

### Naming Conventions

- `sc_*` - Public ShellCandy functions
- `_sc_*` - Internal helper functions (don't use directly)
- `box_*` - Box drawing functions
- `SC_*` - Color and configuration variables

### Return Values

- Functions generally output to stdout
- Use command substitution: `result=$(sc_function args)`
- Exit codes: 0 = success, non-zero = error

### Parameter Patterns

```bash
# Named reference for arrays
declare -a data=(1 2 3)
sc_sparkline data  # Pass array name, not ${data[@]}

# Multiple variadic arguments
box "Title" "Line 1" "Line 2" "Line 3"

# Optional parameters with defaults
sc_progress_bar 50 100 "Label"  # width defaults to 50
```

---

## 🧪 Testing

ShellCandy includes comprehensive testing:

**Validation Tests (68 tests):**
- Module loading verification
- Function availability checks
- Functional tests (rendering, alignment)
- Edge cases (empty, long lines, Unicode)

**Performance Benchmarks (13 benchmarks):**
- Core function performance
- UI component rendering
- Stress tests

```bash
# Run all tests
./lib/validate.sh
./lib/benchmark.sh

# Or use shortcuts (if installed)
shellcandy-validate
shellcandy-benchmark
```

See [TESTING.md](TESTING.md) for complete testing guide.

---

## 🤝 Contributing

Contributions welcome! See main repository for guidelines.

**Code Style:**
- Use `sc_` prefix for public functions
- Add inline documentation
- Include usage examples
- Run tests before committing

---

## 📝 License

MIT License - Free to use in any project

Copyright (c) 2025 ShellCandy Project

---

## 🔗 Resources

- **GitHub**: https://github.com/YOUR_ORG/shellcandy
- **Issues**: https://github.com/YOUR_ORG/shellcandy/issues
- **Changelog**: [CHANGELOG.md](CHANGELOG.md)
- **Testing**: [TESTING.md](TESTING.md)
- **Optimization**: [OPTIMIZATION.md](OPTIMIZATION.md)

---

<p align="center">
  <strong>Made with 🍭 ShellCandy v2.0.0</strong>
  <br>
  <sub>Making terminals beautiful, one script at a time</sub>
</p>
