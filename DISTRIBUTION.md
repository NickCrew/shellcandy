# ShellCandy Distribution Guide

Complete guide for distributing ShellCandy to users across multiple platforms.

## Distribution Methods

ShellCandy can be distributed via:

1. **One-line installer** (recommended for most users)
2. **Homebrew** (macOS and Linux)
3. **Git clone** (developers)
4. **Manual download** (offline installations)
5. **Package managers** (future: apt, yum, pacman)

---

## 1. One-Line Installer (Recommended)

### Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_ORG/shellcandy/main/install.sh | bash
```

### What It Does

- ✅ Checks Bash version (requires 4.0+)
- ✅ Clones repository to `~/.shellcandy`
- ✅ Creates symlinks in `~/.local/bin`
- ✅ Adds shell integration to `.bashrc`/`.zshrc`
- ✅ Runs validation tests
- ✅ Shows quick start guide

### Custom Installation

```bash
# Custom install directory
export SHELLCANDY_INSTALL_DIR="$HOME/tools/shellcandy"
curl -fsSL https://raw.githubusercontent.com/YOUR_ORG/shellcandy/main/install.sh | bash

# Custom binary directory
export SHELLCANDY_BIN_DIR="/usr/local/bin"
curl -fsSL https://raw.githubusercontent.com/YOUR_ORG/shellcandy/main/install.sh | bash
```

---

## 2. Homebrew (macOS and Linux)

### For Users

```bash
# Add tap
brew tap YOUR_ORG/shellcandy

# Install
brew install shellcandy

# Update
brew upgrade shellcandy

# Uninstall
brew uninstall shellcandy
```

### Formula Location

Create `homebrew-shellcandy` repository with:

```ruby
# Formula/shellcandy.rb
class Shellcandy < Formula
  desc "Beautiful terminal UI framework for shell scripts"
  homepage "https://github.com/YOUR_ORG/shellcandy"
  url "https://github.com/YOUR_ORG/shellcandy/archive/v2.0.0.tar.gz"
  sha256 "SHA256_HASH_HERE"
  license "MIT"

  depends_on "bash" => :build

  def install
    # Install library files
    lib.install "lib"

    # Install binary tools
    bin.install "bin/shellcandy" if File.exist?("bin/shellcandy")

    # Install examples
    pkgshare.install "examples"

    # Install documentation
    doc.install "README.md"
    doc.install "lib/TESTING.md"
    doc.install "lib/OPTIMIZATION.md"
    doc.install "lib/CHANGELOG.md"
  end

  def caveats
    <<~EOS
      ShellCandy has been installed!

      To use in your scripts:
        source #{lib}/shellcandy.sh

      Or add to your shell RC:
        export SHELLCANDY_HOME=#{lib}
        alias shellcandy='source $SHELLCANDY_HOME/shellcandy.sh'

      Examples: #{opt_pkgshare}/examples/
      Documentation: #{doc}/
    EOS
  end

  test do
    system lib/"validate.sh"
  end
end
```

### Publishing Homebrew Formula

```bash
# 1. Create tap repository
gh repo create YOUR_ORG/homebrew-shellcandy --public

# 2. Add formula
cd homebrew-shellcandy
mkdir Formula
cp ../Formula/shellcandy.rb Formula/
git add Formula/shellcandy.rb
git commit -m "Add ShellCandy formula"
git push

# 3. Create release
cd ../shellcandy
git tag v2.0.0
git push origin v2.0.0

# 4. Update formula with SHA256
shasum -a 256 shellcandy-2.0.0.tar.gz
# Update formula with hash

# 5. Test formula
brew install --build-from-source YOUR_ORG/shellcandy/shellcandy
```

---

## 3. Git Clone (Developers)

### Installation

```bash
# Clone repository
git clone https://github.com/YOUR_ORG/shellcandy.git ~/.shellcandy

# Add to shell RC
echo 'export SHELLCANDY_HOME="$HOME/.shellcandy"' >> ~/.bashrc
echo 'export PATH="$PATH:$SHELLCANDY_HOME/bin"' >> ~/.bashrc
echo 'alias shellcandy="source $SHELLCANDY_HOME/lib/shellcandy.sh"' >> ~/.bashrc

# Reload shell
source ~/.bashrc

# Verify
shellcandy-validate
```

### Updating

```bash
cd ~/.shellcandy
git pull origin main
shellcandy-validate  # Verify update
```

---

## 4. Manual Download

### For Offline Installations

```bash
# 1. Download latest release
wget https://github.com/YOUR_ORG/shellcandy/archive/v2.0.0.tar.gz

# 2. Extract
tar -xzf v2.0.0.tar.gz

# 3. Move to install location
mv shellcandy-2.0.0 ~/.shellcandy

# 4. Make executable
chmod +x ~/.shellcandy/lib/*.sh
chmod +x ~/.shellcandy/bin/*

# 5. Add to PATH
export SHELLCANDY_HOME="$HOME/.shellcandy"
export PATH="$PATH:$SHELLCANDY_HOME/bin"

# 6. Verify
~/.shellcandy/lib/validate.sh
```

---

## 5. Package Managers (Future)

### Debian/Ubuntu (apt)

**TODO: Create .deb package**

```bash
# Future:
sudo apt-get install shellcandy
```

### RedHat/CentOS (yum)

**TODO: Create .rpm package**

```bash
# Future:
sudo yum install shellcandy
```

### Arch Linux (pacman)

**TODO: Create PKGBUILD**

```bash
# Future:
yay -S shellcandy
```

---

## GitHub Release Process

### Automated with GitHub Actions

Create `.github/workflows/release.yml`:

```yaml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Validate
        run: ./lib/validate.sh

      - name: Benchmark
        run: ./lib/benchmark.sh

      - name: Create Release Archive
        run: |
          tar -czf shellcandy-${{ github.ref_name }}.tar.gz \
            lib/ bin/ examples/ README.md LICENSE

      - name: Generate Release Notes
        id: notes
        run: |
          echo "## What's New" > notes.md
          sed -n "/## \[${{ github.ref_name }}\]/,/## \[/p" lib/CHANGELOG.md >> notes.md

      - name: Create Release
        uses: softprops/action-gh-release@v1
        with:
          files: shellcandy-${{ github.ref_name }}.tar.gz
          body_path: notes.md
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Manual Release

```bash
# 1. Update version in files
VERSION="2.0.0"
sed -i '' "s/SHELLCANDY_VERSION=.*/SHELLCANDY_VERSION=\"$VERSION\"/" lib/shellcandy.sh
sed -i '' "s/SHELLCANDY_VERSION=.*/SHELLCANDY_VERSION=\"$VERSION\"/" install.sh

# 2. Update CHANGELOG.md
vim lib/CHANGELOG.md  # Add release notes

# 3. Commit changes
git add -A
git commit -m "Release v$VERSION"

# 4. Create tag
git tag -a "v$VERSION" -m "ShellCandy v$VERSION"

# 5. Push
git push origin main
git push origin "v$VERSION"

# 6. Create GitHub release
gh release create "v$VERSION" \
  --title "ShellCandy v$VERSION" \
  --notes-file lib/CHANGELOG.md \
  --latest

# 7. Upload assets
tar -czf "shellcandy-v$VERSION.tar.gz" lib/ bin/ examples/ README.md LICENSE
gh release upload "v$VERSION" "shellcandy-v$VERSION.tar.gz"
```

---

## Distribution Checklist

Before releasing:

- [ ] Update version in all files
  - [ ] `lib/shellcandy.sh` - `SHELLCANDY_VERSION`
  - [ ] `install.sh` - `SHELLCANDY_VERSION`
  - [ ] `Formula/shellcandy.rb` - version and url
- [ ] Update CHANGELOG.md with release notes
- [ ] Run validation tests: `./lib/validate.sh`
- [ ] Run benchmarks: `./lib/benchmark.sh`
- [ ] Test installation script locally
- [ ] Update documentation if needed
- [ ] Commit all changes
- [ ] Create git tag
- [ ] Push to GitHub
- [ ] Create GitHub release
- [ ] Update Homebrew formula (if using)
- [ ] Announce release (Twitter, Reddit, etc.)

---

## Installation Locations

### Default Paths

| Item | Default Location | Customizable Via |
|------|------------------|------------------|
| Library | `~/.shellcandy` | `SHELLCANDY_INSTALL_DIR` |
| Binaries | `~/.local/bin` | `SHELLCANDY_BIN_DIR` |
| Homebrew | `/usr/local/Cellar/shellcandy` | N/A |

### Files Installed

```
~/.shellcandy/
├── lib/
│   ├── shellcandy.sh          # Main orchestrator
│   ├── colors.sh              # Color system
│   ├── logging.sh             # Logging module
│   ├── progress.sh            # Progress indicators
│   ├── icons.sh               # Icons and emojis
│   ├── boxes.sh               # Box drawing
│   ├── tables.sh              # Table rendering
│   ├── prompts.sh             # Interactive prompts
│   ├── menus.sh               # Menu system
│   ├── charts.sh              # Data visualization
│   ├── validate.sh            # Validation tests
│   ├── benchmark.sh           # Performance tests
│   ├── README.md              # Documentation
│   ├── TESTING.md             # Testing guide
│   ├── OPTIMIZATION.md        # Performance guide
│   └── CHANGELOG.md           # Version history
├── bin/
│   └── shellcandy             # CLI tool
└── examples/
    ├── ultimate-dashboard.sh  # Full demo
    └── ...                    # Other examples

~/.local/bin/
├── shellcandy                 # CLI tool (symlink)
├── shellcandy-validate        # Validation (symlink)
└── shellcandy-benchmark       # Benchmarks (symlink)
```

---

## Uninstallation

### One-liner Install

```bash
# Remove installation
rm -rf ~/.shellcandy ~/.local/bin/shellcandy*

# Remove shell integration
# Edit ~/.bashrc or ~/.zshrc and remove ShellCandy section
```

### Homebrew

```bash
brew uninstall shellcandy
brew untap YOUR_ORG/shellcandy
```

### Manual

```bash
# Remove files
rm -rf $SHELLCANDY_HOME
rm -f $SHELLCANDY_BIN_DIR/shellcandy*

# Remove from shell RC
# Edit ~/.bashrc or ~/.zshrc and remove ShellCandy lines
```

---

## Platform Support

### Tested Platforms

| Platform | Bash Version | Status | Notes |
|----------|--------------|--------|-------|
| **macOS** | 5.2+ | ✅ Fully Supported | Default in macOS 13+ |
| **macOS** | 3.2 (system) | ⚠️ Not Supported | Use Homebrew Bash |
| **Ubuntu 22.04** | 5.1+ | ✅ Fully Supported | Default |
| **Debian 11** | 5.1+ | ✅ Fully Supported | Default |
| **RHEL 9** | 5.1+ | ✅ Fully Supported | Default |
| **FreeBSD** | 5.2+ | ✅ Should Work | Not tested |
| **WSL 2** | 5.1+ | ✅ Fully Supported | Windows Subsystem for Linux |
| **Git Bash** | 5.0+ | ⚠️ Limited | Windows, terminal limitations |

### Requirements

- **Bash 4.0+** (required)
- **Terminal with UTF-8** (for emojis and box characters)
- **Terminal with ANSI colors** (for color output)
- **Git** (for clone-based installation)
- **curl or wget** (for one-line installer)

---

## Marketing and Announcement

### Release Announcement Template

```markdown
🎉 **ShellCandy v2.0.0 Released!**

Beautiful terminal UI framework for Bash scripts with ZERO dependencies.

**New in v2.0:**
- 🎨 Interactive menus with keyboard navigation
- 📊 Data visualization (sparklines, charts, gauges)
- 🚀 Production-ready monitoring dashboard example
- ✅ Comprehensive testing suite (68 tests)
- ⚡ Optimized performance (<100µs core functions)

**Install:**
```bash
curl -fsSL https://shellcandy.sh/install.sh | bash
```

**Features:**
- 9 complete modules (colors, logging, tables, charts, menus, etc.)
- 60+ public API functions
- Pure Bash 4.0+ (no external dependencies)
- Auto-sizing tables, interactive forms, data visualization
- Production-ready examples included

**Docs:** https://github.com/YOUR_ORG/shellcandy
**Demo:** `shellcandy-demo`

#bash #shell #terminal #cli #opensource
```

### Where to Announce

- [ ] GitHub Release
- [ ] Hacker News (Show HN)
- [ ] Reddit r/bash
- [ ] Reddit r/commandline
- [ ] Twitter/X
- [ ] Dev.to
- [ ] Lobsters
- [ ] Product Hunt
- [ ] awesome-bash list

---

## Metrics and Analytics

Track adoption via:

1. **GitHub Stars** - Repository popularity
2. **Releases Downloads** - Installation count
3. **Homebrew Analytics** - `brew info --analytics`
4. **Issues/PRs** - Community engagement
5. **Forks** - Developer interest

---

## Support and Documentation

After distribution:

1. **README.md** - First stop for users
2. **GitHub Wiki** - Extended documentation
3. **GitHub Discussions** - Community Q&A
4. **GitHub Issues** - Bug reports and feature requests
5. **Examples** - Working code samples

---

## Future Distribution Channels

- [ ] Docker Hub (container with ShellCandy pre-installed)
- [ ] Snapcraft (universal Linux packages)
- [ ] NPM (as bash module)
- [ ] Awesome Lists (awesome-bash, awesome-shell, etc.)
- [ ] Framework comparisons (vs bashful, dialog, whiptail)

---

**🍭 Ready to distribute ShellCandy to the world! ✨**
