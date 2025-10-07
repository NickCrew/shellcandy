# ShellCandy Testing Guide

Comprehensive testing and validation tools for the ShellCandy terminal UI framework.

## Overview

ShellCandy includes two testing utilities:
- **validate.sh**: Validates framework installation and functionality
- **benchmark.sh**: Measures performance of core functions

## Quick Start

```bash
# Validate ShellCandy installation
./lib/validate.sh

# Run performance benchmarks
./lib/benchmark.sh

# Both (validate first, then benchmark)
./lib/validate.sh && ./lib/benchmark.sh
```

## validate.sh

### Purpose
Comprehensive validation of ShellCandy framework to ensure all modules load correctly and functions work as expected.

### What It Tests

**Module Loading (9 tests)**
- ✅ colors module loaded
- ✅ logging module loaded
- ✅ progress module loaded
- ✅ icons module loaded
- ✅ boxes module loaded
- ✅ tables module loaded
- ✅ prompts module loaded
- ✅ menus module loaded
- ✅ charts module loaded

**Function Availability (~50 tests)**
- All public API functions (sc_* and box_*)
- Helper functions (_* are internal, not tested directly)

**Functional Tests (5 tests)**
- Box rendering with alignment
- Table rendering with auto-sizing
- Sparkline generation
- Color output
- ANSI code handling

**Edge Cases (3 tests)**
- Empty boxes
- Very long lines (200+ characters)
- Unicode characters (Chinese, Arabic, Russian)

**Performance Smoke Test (1 test)**
- 100 boxes should render in < 5 seconds

### Usage

```bash
# Basic run
./lib/validate.sh

# Capture output
./lib/validate.sh > validation_results.txt 2>&1

# CI/CD integration
./lib/validate.sh
if [ $? -ne 0 ]; then
    echo "Validation failed"
    exit 1
fi
```

### Output Format

```
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║              ShellCandy Validation Suite                      ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝

Testing module loading...

  ✓ Module loaded: colors
  ✓ Module loaded: logging
  ...

Testing colors module functions...

  ✓ Function exists: sc_color_256
  ✓ Function exists: sc_rgb
  ...

==========================================
           VALIDATION RESULTS
==========================================

Tests run:    68
Tests passed: 68
Tests failed: 0

✓ ALL TESTS PASSED!
```

### Exit Codes
- **0**: All tests passed
- **1**: One or more tests failed

---

## benchmark.sh

### Purpose
Performance benchmarking of ShellCandy core functions to identify optimization opportunities and track performance over time.

### What It Benchmarks

**Core Functions (high iteration count)**
- ANSI code stripping (10,000 iterations)
- Emoji width calculation (10,000 iterations)
- Logging output (5,000 iterations)
- Progress bars (1,000 iterations)

**UI Components (moderate iteration count)**
- Box drawing (500 iterations)
- Table rendering (200 iterations)
- Sparkline generation (500 iterations)
- Gauge rendering (500 iterations)
- Menu creation (500 iterations)
- Chart generation (200 iterations)

**Stress Tests (low iteration count)**
- Large table with 50 rows (50 iterations)
- 20 boxes in sequence (50 iterations)
- Long sparkline with 100 points (100 iterations)

### Usage

```bash
# Basic run
./lib/benchmark.sh

# Review saved results
cat benchmark_results.txt

# Compare before/after optimization
./lib/benchmark.sh > before.txt
# ... make optimizations ...
./lib/benchmark.sh > after.txt
diff before.txt after.txt
```

### Output Format

```
╔════════════════════════════════════════════════════════════════╗
║         ShellCandy Performance Benchmark Suite                ║
╚════════════════════════════════════════════════════════════════╝

Testing core function performance...

Running: ANSI Strip (10000 iterations)... 450ms total (45µs per iteration)
Running: Emoji Width (10000 iterations)... 520ms total (52µs per iteration)
...

Running stress tests...

Running: Large Table (50 rows) (50 iterations)... 8500ms total (170000µs per iteration)
...

==========================================
           BENCHMARK RESULTS
==========================================

╭─────────────────────────────────────╮
│ Benchmark            │ Iterations  │
│ Total Time           │ Per Iteration│
├─────────────────────────────────────┤
│ ANSI Strip           │ 10000       │
│ 450ms                │ 45µs        │
...
╰─────────────────────────────────────╯

Total benchmark time: 15320ms
```

### Performance Baselines

**Typical Performance (MacBook Pro M1, 16GB RAM)**
| Function | Per Iteration | Notes |
|----------|--------------|-------|
| ANSI Strip | 40-60µs | Core alignment function |
| Emoji Width | 50-70µs | Unicode width calculation |
| Logging | 150-200µs | With timestamp formatting |
| Progress Bar | 800-1200µs | Full bar rendering |
| Box Drawing | 2-4ms | With alignment |
| Table (10 rows) | 15-25ms | With auto-sizing |
| Sparkline (50 pts) | 1-2ms | ASCII chart |
| Large Table (50 rows) | 150-200ms | Stress test |

**Performance Targets**
- ✅ Core functions < 100µs per call
- ✅ UI components < 10ms per render
- ✅ Stress tests < 500ms
- ✅ Total benchmark < 30 seconds

---

## CI/CD Integration

### GitHub Actions Example

```yaml
name: ShellCandy Tests

on: [push, pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Validate ShellCandy
        run: ./lib/validate.sh

      - name: Benchmark ShellCandy
        run: ./lib/benchmark.sh

      - name: Upload Results
        uses: actions/upload-artifact@v3
        with:
          name: benchmark-results
          path: benchmark_results.txt
```

### GitLab CI Example

```yaml
test:shellcandy:
  script:
    - ./lib/validate.sh
    - ./lib/benchmark.sh
  artifacts:
    paths:
      - benchmark_results.txt
    expire_in: 1 week
```

---

## Pre-commit Hook

Create `.git/hooks/pre-commit`:

```bash
#!/bin/bash
# ShellCandy validation pre-commit hook

echo "Running ShellCandy validation..."
./lib/validate.sh

if [ $? -ne 0 ]; then
    echo "❌ ShellCandy validation failed - commit aborted"
    echo "Run './lib/validate.sh' to see details"
    exit 1
fi

echo "✅ ShellCandy validation passed"
exit 0
```

```bash
chmod +x .git/hooks/pre-commit
```

---

## Adding New Tests

### Adding to validate.sh

**1. Add function availability test:**

```bash
test_mymodule_functions() {
    echo ""
    echo "Testing mymodule module functions..."
    echo ""

    assert_function "sc_mymodule_init"
    assert_function "sc_mymodule_render"
}
```

**2. Add to main():**

```bash
main() {
    # ...existing tests...
    test_mymodule_functions
    # ...
}
```

### Adding to benchmark.sh

**1. Create test function:**

```bash
test_my_function() {
    sc_my_function arg1 arg2 >/dev/null
}
```

**2. Add benchmark call:**

```bash
benchmark "My Function" 1000 test_my_function
```

---

## Troubleshooting

### Validation Fails

**Problem:** "Module not loaded: xyz"
```bash
# Check if module file exists
ls -l lib/xyz.sh

# Check shellcandy.sh loads it
grep -n "SHELLCANDY_LOAD_XYZ" lib/shellcandy.sh

# Ensure loading is enabled
SHELLCANDY_LOAD_XYZ=true ./lib/validate.sh
```

**Problem:** "Function missing: sc_xyz"
```bash
# Check function is exported
grep -n "^sc_xyz()" lib/xyz.sh

# Ensure function is not in conditional block
# Functions should be defined at module load time
```

### Benchmarks Slow

**Problem:** Benchmarks take > 60 seconds
```bash
# Check system load
top

# Reduce iteration counts for quick test
# Edit benchmark.sh and lower iteration values temporarily

# Check for resource-intensive background processes
```

**Problem:** Inconsistent performance
```bash
# Run multiple times to average
for i in {1..5}; do
    echo "Run $i"
    ./lib/benchmark.sh
    sleep 5
done

# Check thermal throttling (laptops)
# Let machine cool down between runs
```

---

## Future Enhancements

Planned testing improvements:

- [ ] **BATS Integration**: Full BATS test suite for automated testing
- [ ] **Code Coverage**: Track which functions are tested
- [ ] **Property-based Testing**: Fuzzing with random inputs
- [ ] **Memory Profiling**: Track memory usage patterns
- [ ] **Cross-platform Tests**: Linux, macOS, BSD validation
- [ ] **Visual Regression**: Screenshot comparison tests
- [ ] **Load Testing**: Test with 1000+ concurrent renders
- [ ] **Comparison Tests**: Compare against similar frameworks

---

## Resources

- **Main README**: `lib/README.md` - ShellCandy documentation
- **API Reference**: Each module file has inline documentation
- **Examples**: `examples/ultimate-dashboard.sh` - Full framework showcase
- **Changelog**: `lib/CHANGELOG.md` - Version history

---

## License

MIT License - Same as ShellCandy framework
