# Contributing to Primaviz

Thanks for your interest in contributing! This document covers the local dev setup, project layout, and helper scripts that aren't shipped with the published package.

## Development

Dev commands via [just](https://github.com/casey/just):

```bash
just demos           # Compile all per-chart demos
just demo            # Compile the comprehensive demo
just showcase        # Compile the showcase
just watch           # Live-reload during development
just watch-demo bar  # Watch a specific demo (e.g., bar, pie, scatter)
just test            # Run all compilation tests
just check           # Full CI check (demo + demos + showcase + tests)
just screenshots     # Regenerate screenshots (screenshots/demo/ + screenshots/showcase/)
just open            # Compile and open the demo PDF
just dev             # Watch with live-reload and open PDF
just clean           # Clean generated artifacts
just release         # Full release prep (check + screenshots)
just extract-theme   # Extract CSS tokens → JSON theme via Python (e.g., just extract-theme src/index.css)
just extract-theme-ts # Extract CSS tokens → JSON theme via Bun/TS (same options)
just stats           # Show project stats
```

Issue tracking with [beads](https://github.com/steveyegge/beads).

## Project Structure

```text
primaviz/
  src/
    lib.typ                  # Public entrypoint — re-exports everything
    theme.typ                # Theme system and preset themes
    util.typ                 # Shared utilities (colour ramps, WCAG contrast-text, number formatting, nice ticks)
    validate.typ             # Input validation helpers
    charts/                  # One module per chart family
      bar.typ                # bar, horizontal, grouped, stacked, grouped-stacked
      line.typ               # line, multi-line
      dual-axis.typ          # dual Y-axis
      area.typ               # area, stacked-area
      pie.typ                # pie, donut
      radar.typ              # spider/radar chart
      scatter.typ            # scatter, multi-scatter, bubble, multi-bubble
      gauge.typ              # gauge, progress-bar, circular-progress, progress-bars
      rings.typ              # ring-progress (fitness rings)
      heatmap.typ            # heatmap, calendar-heatmap, correlation-matrix
      sparkline.typ          # sparkline, sparkbar, sparkdot
      waterfall.typ          # bridge/waterfall chart
      funnel.typ             # conversion funnel
      boxplot.typ            # box-and-whisker plot
      histogram.typ          # auto-binned frequency distribution
      treemap.typ            # nested rectangles
      lollipop.typ           # lollipop, horizontal-lollipop
      sankey.typ             # flow diagram
      bullet.typ             # bullet-chart, bullet-charts
      slope.typ              # two-period comparison
      diverging.typ          # left/right diverging bars
      gantt.typ              # project timeline
      waffle.typ             # proportional grid
      bump.typ               # ranking chart
      dumbbell.typ           # before/after comparison
      radial-bar.typ         # circular bars
      sunburst.typ           # multi-level hierarchical pie
      metric.typ             # metric-card, metric-row
      dashboard.typ          # card, compact-table, alert, badge, separator, dashboard-layout
      violin.typ             # kernel density estimation
      timeline.typ           # vertical event timeline
      parliament.typ         # semicircle seat chart
      chord.typ              # circular flow diagram
      wordcloud.typ          # spiral-placement word cloud
    primitives/              # Low-level drawing helpers; a fix here lands in every chart that uses it
      frame.typ              # cartesian-frame: measured margins, ticks, grid, axis titles, annotations (every cartesian chart)
      axes.typ               # value/category axis specs, tick selection, category label policy, scales
      annotations.typ        # reference lines, bands, labels, content (spread apart, never overlapping)
      rows.typ               # row-layout, draw-x-axis, end labels: label column + value axis of horizontal charts
      row-chart.typ          # scaffold of horizontal-bar-chart / horizontal-lollipop-chart
      matrix.typ             # row/column-labelled grids (heatmap family)
      container.typ          # chart container: measures its own title, subtitle and legend
      legend.typ             # horizontal / vertical / gradient / size legends (pin their own type size)
      title.typ              # title rendering
      fonts.typ              # text measuring, size fitting, label stride, spread-labels (the one 1-D label spreader)
      sizing.typ             # resolve-size (rows: true grows with the row count), page-grid
      layout.typ             # re-export hub for sizing.typ + fonts.typ
      paths.typ              # polylines with round joins
      polar.typ              # wedges, arc bands, polar points
      polar-labels.typ       # label ink and contrast, wedge-label fitting, outside labels with leaders
      radial.typ             # side legend (multi-column), width split for the radial charts
      status.typ             # semantic colours of the dashboard pieces
  examples/
    demos/                   # Per-chart demo files (21 files, 2×2 grids)
      demo-bar.typ           # bar-chart, horizontal-bar-chart
      demo-bar-multi.typ     # grouped-bar, stacked-bar
      demo-bar-advanced.typ  # grouped-stacked, diverging
      demo-line.typ          # line-chart, multi-line-chart
      demo-area.typ          # area-chart, stacked-area-chart
      demo-dual-axis.typ     # dual-axis-chart (4 themes)
      demo-pie.typ           # pie-chart, donut
      demo-radar.typ         # radar-chart (4 variants)
      demo-scatter.typ       # scatter, multi-scatter, bubble
      demo-gauge.typ         # gauge, progress-bar, circular-progress
      demo-heatmap.typ       # heatmap, calendar-heatmap, correlation-matrix
      demo-statistical.typ   # histogram, box-plot, violin, waterfall
      demo-comparison.typ    # slope, dumbbell, lollipop, bullet
      demo-flow.typ          # sankey, gantt, timeline, chord
      demo-misc.typ          # waffle, parliament, radial-bar, sunburst
      demo-dashboard.typ     # metric-row, word-cloud, sparklines, progress-bars
      demo-rings.typ         # ring-progress, treemap
      demo-bump.typ          # bump-chart, funnel-chart
      demo-themes.typ        # theme comparison (all 7 presets + with-theme)
      demo-scaling.typ       # φ-scaling from base-size/base-gap seeds
      demo-annotations.typ   # content, point, errorbar, rect overlays; native errors + outliers
    showcase.typ             # 8-page compact showcase (dark theme)
    demo.typ                 # Comprehensive demo with JSON data loading
  data/                      # Sample JSON data files
  screenshots/
    demo/                    # Per-chart demo screenshots (demo-*.png)
    showcase/                # Showcase page screenshots (showcase-*.png)
  scripts/
    extract-theme.py         # CSS → primaviz theme extractor (uv script, zero-install, coloraide)
    extract-theme.ts         # CSS → primaviz theme extractor (bun script, culori)
  justfile                   # Common dev commands
```

## Extracting themes from CSS

The repo includes two scripts for converting CSS design tokens into primaviz theme files (both `.typ` and `.json`). They parse CSS custom properties from `:root` and dark-mode blocks, convert colors (oklch, hsl, rgb, hex) to hex with alpha blending, and map `--chart-1`..N to a palette array and semantic properties (`--foreground`, `--background`, `--border`, `--radius`, etc.) to primaviz theme keys.

> ⚠️ **Security note:** These scripts are not part of the published Typst package and pull third-party dependencies (`coloraide` / `culori`). Read the source before running them on untrusted input.

**Python** ([`scripts/extract-theme.py`](https://github.com/phiat/primaviz/blob/main/scripts/extract-theme.py)) — the most sophisticated tool in the repo. Uses `uv run` for zero-install execution (dependencies are declared inline). Powered by `coloraide` for color space conversion:

```bash
just extract-theme src/index.css                          # default: outputs typst + json to ./typst/
just extract-theme styles.css --name shadcn --format json  # json only, custom name
just extract-theme globals.css --dark-selector '[data-theme="dark"]'
```

**TypeScript** ([`scripts/extract-theme.ts`](https://github.com/phiat/primaviz/blob/main/scripts/extract-theme.ts)) — equivalent functionality using Bun and `culori`. Extracts additional semantic tokens (card, accent, destructive, etc.) in an `all` field:

```bash
just extract-theme-ts src/index.css
just extract-theme-ts styles.css --name shadcn --format typst
```

Both scripts accept the same flags: `--out-dir`, `--format` (typst/json/both), `--name`, and `--dark-selector`. Run either with `--help` for full usage.
