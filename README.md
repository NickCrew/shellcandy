# 🍭 ShellCandy

### _Beautiful Terminal UIs for Shell Scripts_

<p align="center">
  <strong>A comprehensive framework for creating stunning terminal interfaces in pure Bash</strong>
</p>

<p align="center">
  <a href="#-quick-start">Quick Start</a> •
  <a href="#-features">Features</a> •
  <a href="#-installation">Installation</a> •
  <a href="#-examples">Examples</a> •
  <a href="#-documentation">Documentation</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/bash-4.0+-blue.svg" alt="Bash 4.0+">
  <img src="https://img.shields.io/badge/dependencies-zero-green.svg" alt="Zero Dependencies">
  <img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT License">
  <img src="https://img.shields.io/badge/version-2.0.0-brightgreen.svg" alt="Version 2.0.0">
</p>

---

## 🎯 What is ShellCandy?

ShellCandy transforms ordinary shell scripts into **beautiful, interactive terminal applications**. With **9 powerful modules** and **60+ functions**, you can create professional UIs with:

✨ **Interactive menus** with keyboard navigation  
📊 **Data visualization** with charts and sparklines  
📋 **Auto-sizing tables** with perfect alignment  
🎨 **Rich colors** (256-color, RGB, themes)  
⚡ **Progress indicators** (bars, spinners, gauges)  
📝 **Interactive forms** with validation  
🎯 **Zero dependencies** - Pure Bash 4.0+

---

## 🚀 Quick Start

### Install

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/shellcandy/main/install.sh | bash
```

### Your First Script

```bash
#!/usr/bin/env bash
source ~/.shellcandy/lib/shellcandy.sh

# Beautiful boxes
box_success "Welcome!" \
    "ShellCandy makes terminals beautiful" \
    "🎨 Colors  📊 Charts  🎯 Menus  ⚡ Progress"

# Data visualization
declare -a data=(45 52 68 73 81 76 84 92)
echo "Trend: $(sc_sparkline data) 📈"

# Progress bar
sc_progress_bar 75 100 "Processing"
```

---

## ✨ Features

### 9 Complete Modules

| Module | Description |
|--------|-------------|
| **colors** | 256-color, RGB, themes, gradients |
| **logging** | Multi-level logging with file output |
| **progress** | Spinners, bars, ETA calculations |
| **icons** | 50+ status symbols and emojis |
| **boxes** | Perfect alignment with ANSI/emoji support |
| **tables** | Auto-sizing, CSV import, formatting |
| **prompts** | Interactive forms with validation |
| **menus** | Keyboard navigation, nested menus |
| **charts** | Sparklines, bar charts, gauges, histograms |

---

## 📦 Installation

### One-Line Install (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/shellcandy/main/install.sh | bash
```

### Manual Install

```bash
git clone https://github.com/YOUR_USERNAME/shellcandy.git ~/.shellcandy
echo 'export SHELLCANDY_HOME="$HOME/.shellcandy"' >> ~/.bashrc
echo 'source $SHELLCANDY_HOME/lib/shellcandy.sh' >> ~/.bashrc
source ~/.bashrc
```

---

## 🎓 Examples

### Interactive Menu

```bash
#!/usr/bin/env bash
source ~/.shellcandy/lib/shellcandy.sh

sc_menu_create "Main Menu"
sc_menu_add "Deploy" "deploy_app" "true" "d"
sc_menu_add "Status" "show_status" "true" "s"
sc_menu_add "Logs" "view_logs" "true" "l"
sc_menu_add "Exit" "exit" "true" "q"
sc_menu_show
```

### Data Visualization

```bash
#!/usr/bin/env bash
source ~/.shellcandy/lib/shellcandy.sh

# System metrics
declare -a cpu=(30 35 42 45 50 48 52)
sc_gauge 52 100 "CPU Usage" 40
echo "Trend: $(sc_sparkline cpu)"

# Table
sc_table_create "rounded"
sc_table_header "Service" "Status" "CPU"
sc_table_row "Web" "✓ OK" "23%"
sc_table_row "DB" "✓ OK" "45%"
sc_table_render
```

---

## 📚 Documentation

- **[Complete Documentation](lib/docs/README.md)** - Full API reference
- **[Testing Guide](lib/docs/TESTING.md)** - Validation and benchmarks
- **[Optimization Guide](lib/docs/OPTIMIZATION.md)** - Performance tips
- **[Changelog](lib/docs/CHANGELOG.md)** - Version history

---

## ⚡ Performance

ShellCandy is **highly optimized**:

| Metric | Performance | Status |
|--------|-------------|--------|
| Core functions | 40-70µs/call | ✅ |
| Box rendering | 2-4ms | ✅ |
| Table (10 rows) | 15-25ms | ✅ |
| Sparklines | 1-2ms | ✅ |

**Run tests:**
```bash
shellcandy-validate   # 68 tests
shellcandy-benchmark  # 13 benchmarks
```

---

## 🤝 Contributing

Contributions welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Make changes and test: `./lib/validate.sh`
4. Commit: `git commit -m 'Add amazing feature'`
5. Push: `git push origin feature/amazing-feature`
6. Open a Pull Request

---

## 📊 Project Stats

- **9 modules** with 60+ functions
- **10,100 lines** of code
- **68 validation tests** (100% passing)
- **13 performance benchmarks**
- **Zero dependencies**
- **Pure Bash 4.0+**

---

## 📝 License

MIT License - See [LICENSE](LICENSE) for details

Copyright (c) 2025 ShellCandy Project

---

## 🔗 Links

- **Issues**: https://github.com/YOUR_USERNAME/shellcandy/issues
- **Discussions**: https://github.com/YOUR_USERNAME/shellcandy/discussions

---

<p align="center">
  <strong>Made with 🍭 ShellCandy</strong>
  <br>
  <sub>Making terminals beautiful, one script at a time</sub>
</p>

<p align="center">
  ⭐ Star us on GitHub if you find ShellCandy useful!
</p>
