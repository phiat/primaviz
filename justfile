# chartypst development commands

# Default: show available recipes
default:
    @just --list

# Compile the demo showcase
demo:
    typst compile --root . examples/demo.typ

# Compile the compact 3-page showcase
showcase:
    typst compile --root . examples/showcase.typ

# Watch demo for live reload during development
watch:
    typst watch --root . examples/demo.typ

# Run all compilation tests
test:
    typst compile --root . tests/test-all.typ

# Regenerate all gallery screenshots from demo and showcase
screenshots:
    typst compile --root . examples/demo.typ screenshots/page-{n}.png
    typst compile --root . examples/showcase.typ screenshots/showcase-{n}.png
    @echo "Generated $(ls screenshots/*.png | wc -l) screenshots"

# Compile demo + showcase + tests (full CI check)
check: demo showcase test
    @echo "All compilations passed"

# Open the demo PDF (uses xdg-open on Linux)
open: demo
    xdg-open examples/demo.pdf 2>/dev/null || open examples/demo.pdf

# Watch and open demo
dev:
    typst watch --root . examples/demo.typ &
    sleep 1
    xdg-open examples/demo.pdf 2>/dev/null || open examples/demo.pdf

# Clean generated artifacts
clean:
    rm -f examples/demo.pdf tests/test-all.pdf

# Full release prep: test, screenshots, clean build artifacts
release: check screenshots
    @echo "Release artifacts ready"

# Show project stats
stats:
    @echo "Chart modules:"
    @ls src/charts/*.typ | wc -l
    @echo "Primitive modules:"
    @ls src/primitives/*.typ | wc -l
    @echo "Total .typ files:"
    @find src/ -name '*.typ' | wc -l
    @echo "Screenshot pages:"
    @ls screenshots/*.png | wc -l

# Compile a specific chart file for quick iteration (e.g., just compile-chart bar)
compile-chart name:
    @echo '#import "../src/lib.typ": *' > /tmp/test-chart.typ
    @echo '#import "../src/lib.typ": *\n// Quick test for {{name}}' > /tmp/test-chart.typ
    typst compile --root . /tmp/test-chart.typ
