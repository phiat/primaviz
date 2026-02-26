// Compact showcase — All 27 chart types on 3 pages (dark theme)
#import "../src/lib.typ": *

#set page(margin: (x: 0.6cm, y: 0.6cm), paper: "a4", fill: rgb("#1a1a2e"))
#set text(size: 7pt, fill: rgb("#e0e0e0"))

#let dk = themes.dark

// ── Page 1: Bar, Line, Area ──────────────────────────────────────────────────

#grid(
  columns: (1fr, 1fr),
  column-gutter: 8pt,
  row-gutter: 4pt,

  bar-chart(
    (labels: ("net", "fs", "drivers", "mm", "arch", "kernel"),
     values: (4820, 3150, 8930, 2710, 2340, 1890)),
    width: 250pt, height: 100pt,
    title: "bar-chart",
    theme: dk,
  ),

  horizontal-bar-chart(
    (labels: ("drivers", "net", "fs", "arch", "sound", "crypto"),
     values: (312, 187, 145, 98, 67, 42)),
    width: 250pt, height: 100pt,
    title: "horizontal-bar-chart",
    theme: dk,
  ),

  grouped-bar-chart(
    (labels: ("Q1", "Q2", "Q3", "Q4"),
     series: (
       (name: "net", values: (1240, 1380, 1150, 1050)),
       (name: "fs", values: (780, 820, 910, 640)),
       (name: "mm", values: (620, 710, 680, 700)),
     )),
    width: 250pt, height: 100pt,
    title: "grouped-bar-chart",
    theme: dk,
  ),

  stacked-bar-chart(
    (labels: ("6.1", "6.2", "6.3", "6.4", "6.5"),
     series: (
       (name: "Memory", values: (42, 38, 35, 31, 28)),
       (name: "Concurrency", values: (28, 32, 25, 22, 19)),
       (name: "Logic", values: (55, 48, 52, 45, 40)),
     )),
    width: 250pt, height: 100pt,
    title: "stacked-bar-chart",
    theme: dk,
  ),

  line-chart(
    (labels: ("5.15", "5.19", "6.1", "6.3", "6.5", "6.7", "6.9"),
     values: (11.2, 11.8, 12.1, 12.5, 12.9, 13.2, 13.6)),
    width: 250pt, height: 95pt,
    title: "line-chart",
    show-points: true,
    theme: dk,
  ),

  multi-line-chart(
    (labels: ("5.15", "6.0", "6.3", "6.6", "6.9"),
     series: (
       (name: "defconfig", values: (85, 92, 98, 105, 112)),
       (name: "allmodconfig", values: (340, 365, 390, 420, 445)),
       (name: "tinyconfig", values: (18, 19, 20, 21, 22)),
     )),
    width: 250pt, height: 95pt,
    title: "multi-line-chart",
    theme: dk,
  ),

  area-chart(
    (labels: ("5.0", "5.5", "5.10", "5.15", "6.0", "6.5", "6.9"),
     values: (26.1, 27.8, 29.2, 30.5, 31.4, 33.1, 35.2)),
    width: 250pt, height: 95pt,
    title: "area-chart",
    fill-opacity: 40%,
    theme: dk,
  ),

  stacked-area-chart(
    (labels: ("2020", "2021", "2022", "2023", "2024"),
     series: (
       (name: "Corporate", values: (1850, 1920, 2050, 2180, 2310)),
       (name: "Independent", values: (620, 580, 550, 510, 480)),
       (name: "Academic", values: (180, 195, 210, 230, 250)),
     )),
    width: 250pt, height: 95pt,
    title: "stacked-area-chart",
    theme: dk,
  ),
)

#pagebreak()

// ── Page 2: Circular, Scatter, Gauge, Progress ───────────────────────────────

#grid(
  columns: (1fr, 1fr),
  column-gutter: 8pt,
  row-gutter: 4pt,

  pie-chart(
    (labels: ("drivers", "arch", "fs", "net", "sound", "other"),
     values: (42, 16, 12, 10, 5, 15)),
    size: 85pt,
    title: "pie-chart",
    theme: dk,
  ),

  pie-chart(
    (labels: ("merged", "rejected", "pending", "deferred"),
     values: (65, 15, 12, 8)),
    size: 85pt,
    title: "pie-chart (donut)",
    donut: true,
    donut-ratio: 0.5,
    theme: dk,
  ),

  radar-chart(
    (labels: ("Test Cov", "Doc", "Review", "Latency", "Churn", "Bugs"),
     series: (
       (name: "net", values: (85, 70, 92, 78, 65, 80)),
       (name: "mm", values: (72, 55, 88, 90, 45, 70)),
     )),
    size: 115pt,
    title: "radar-chart",
    fill-opacity: 25%,
    theme: dk,
  ),

  scatter-plot(
    (x: (12, 28, 45, 8, 35, 18, 52),
     y: (3, 12, 22, 2, 18, 8, 28)),
    width: 250pt, height: 105pt,
    title: "scatter-plot",
    x-label: "Complexity",
    y-label: "Bugs",
    annotations: (
      (type: "h-line", value: 15, label: "Threshold", color: rgb("#ff6b6b"), dash: "dashed"),
    ),
    theme: dk,
  ),

  multi-scatter-plot(
    (series: (
       (name: "net", points: ((5, 12), (8, 18), (12, 25), (15, 30))),
       (name: "fs", points: ((4, 8), (7, 14), (11, 16), (14, 22))),
       (name: "mm", points: ((3, 5), (6, 10), (10, 13), (13, 18))),
     )),
    width: 250pt, height: 105pt,
    title: "multi-scatter-plot",
    x-label: "Commits (K)",
    y-label: "Churn (K LoC)",
    theme: dk,
  ),

  bubble-chart(
    (x: (45, 85, 120, 65, 95),
     y: (12, 18, 8, 22, 15),
     size: (300, 180, 450, 120, 250),
     labels: ("net", "fs", "drv", "mm", "arch")),
    width: 250pt, height: 105pt,
    title: "bubble-chart",
    x-label: "Files (K)",
    y-label: "Open Bugs",
    show-labels: true,
    labels: ("net", "fs", "drv", "mm", "arch"),
    theme: dk,
  ),

  // Gauges
  [
    #text(size: 8pt, weight: "bold", fill: rgb("#e0e0e0"))[gauge-chart]
    #v(2pt)
    #grid(
      columns: (1fr, 1fr, 1fr),
      gauge-chart(78, size: 55pt, title: "Build", label: "pass", theme: dk),
      gauge-chart(94, size: 55pt, title: "Boot", label: "pass", theme: dk),
      gauge-chart(61, size: 55pt, title: "Perf", label: "score", theme: dk),
    )
  ],

  // Progress indicators
  [
    #text(size: 8pt, weight: "bold", fill: rgb("#e0e0e0"))[progress-bar · circular-progress]
    #v(3pt)
    #progress-bar(87, width: 230pt, title: "Test Coverage", theme: dk)
    #v(3pt)
    #grid(
      columns: (1fr, 1fr, 1fr),
      circular-progress(85, size: 50pt, title: "net", theme: dk),
      circular-progress(62, size: 50pt, title: "fs", color: rgb("#ff6b6b"), theme: dk),
      circular-progress(78, size: 50pt, title: "mm", color: rgb("#0be881"), theme: dk),
    )
  ],
)

#pagebreak()

// ── Page 3: Statistical, Heatmaps, Sparklines ────────────────────────────────

#grid(
  columns: (1fr, 1fr),
  column-gutter: 8pt,
  row-gutter: 4pt,

  histogram(
    (2, 3, 3, 4, 4, 4, 5, 5, 5, 5, 6, 6, 6, 6, 6, 7, 7, 7, 7, 8, 8, 8,
     9, 9, 10, 10, 11, 12, 14, 15, 18, 22, 25, 30, 35, 42, 55, 70, 95),
    width: 250pt, height: 105pt,
    title: "histogram",
    bins: 12,
    theme: dk,
  ),

  waterfall-chart(
    (labels: ("Start", "+Sales", "+Svc", "-COGS", "-OpEx", "Total"),
     values: (1200, 350, 180, -280, -150, 1300)),
    width: 250pt, height: 105pt,
    title: "waterfall-chart",
    theme: dk,
  ),

  funnel-chart(
    (labels: ("Submitted", "Reviewed", "Acked", "Applied", "Released"),
     values: (5000, 3200, 2100, 1800, 1650)),
    width: 250pt, height: 120pt,
    title: "funnel-chart",
    theme: dk,
  ),

  box-plot(
    (labels: ("CFS", "EEVDF", "BPF", "RT"),
     boxes: (
       (min: 5, q1: 12, median: 18, q3: 28, max: 45),
       (min: 3, q1: 8, median: 14, q3: 22, max: 38),
       (min: 2, q1: 6, median: 11, q3: 18, max: 30),
       (min: 1, q1: 3, median: 5, q3: 8, max: 15),
     )),
    width: 250pt, height: 120pt,
    title: "box-plot",
    show-grid: true,
    theme: dk,
  ),

  heatmap(
    (rows: ("net", "fs", "mm", "drv"),
     cols: ("Mon", "Tue", "Wed", "Thu", "Fri"),
     values: (
       (82, 95, 78, 88, 65),
       (45, 52, 68, 71, 38),
       (33, 41, 55, 48, 29),
       (91, 87, 93, 85, 72),
     )),
    cell-size: 22pt,
    title: "heatmap",
    palette: "viridis",
    theme: dk,
  ),

  correlation-matrix(
    (labels: ("net", "fs", "mm", "drv", "arch"),
     values: (
       (1.0, 0.7, 0.4, 0.8, 0.3),
       (0.7, 1.0, 0.5, 0.6, 0.4),
       (0.4, 0.5, 1.0, 0.3, 0.6),
       (0.8, 0.6, 0.3, 1.0, 0.5),
       (0.3, 0.4, 0.6, 0.5, 1.0),
     )),
    cell-size: 22pt,
    title: "correlation-matrix",
    theme: dk,
  ),

  calendar-heatmap(
    (dates: ("2024-03-01", "2024-03-02", "2024-03-03", "2024-03-04", "2024-03-05",
             "2024-03-06", "2024-03-07", "2024-03-08", "2024-03-09", "2024-03-10",
             "2024-03-11", "2024-03-12", "2024-03-13", "2024-03-14", "2024-03-15",
             "2024-03-16", "2024-03-17", "2024-03-18", "2024-03-19", "2024-03-20",
             "2024-03-21", "2024-03-22", "2024-03-23", "2024-03-24", "2024-03-25",
             "2024-03-26", "2024-03-27", "2024-03-28"),
     values: (12, 8, 3, 15, 22, 18, 5, 9, 14, 2, 20, 25, 11, 7, 16, 4, 1, 19, 23, 13, 10, 6, 17, 8, 21, 15, 12, 9)),
    cell-size: 10pt,
    title: "calendar-heatmap",
    palette: "heat",
    theme: dk,
  ),

  progress-bars(
    (labels: ("net", "fs", "mm", "drivers", "arch"),
     values: (87, 72, 65, 91, 58)),
    width: 250pt,
    title: "progress-bars",
    theme: dk,
  ),
)

// Sparkline row at bottom
#v(4pt)
#text(size: 8pt, weight: "bold", fill: rgb("#e0e0e0"))[sparkline · sparkbar · sparkdot]
#v(2pt)
#table(
  columns: (auto, auto, auto, auto),
  align: (left, center, center, center),
  inset: 3pt,
  stroke: rgb("#333355"),
  fill: rgb("#1a1a2e"),
  [*Subsystem*], [*sparkline*], [*sparkbar*], [*sparkdot*],
  [networking], [#sparkline((45, 52, 48, 61, 58, 72, 68), color: rgb("#00d2ff"), width: 50pt, height: 12pt)], [#sparkbar((8, 12, 9, 15, 11, 18, 14), color: rgb("#ff9f43"), width: 50pt, height: 12pt)], [#sparkdot((5, 3, 4, 2, 3, 1, 2), color: rgb("#ff6b6b"), width: 50pt, height: 12pt)],
  [memory], [#sparkline((32, 28, 35, 31, 38, 42, 40), color: rgb("#00d2ff"), width: 50pt, height: 12pt)], [#sparkbar((6, 8, 5, 10, 7, 12, 9), color: rgb("#ff9f43"), width: 50pt, height: 12pt)], [#sparkdot((8, 6, 7, 5, 4, 3, 2), color: rgb("#0be881"), width: 50pt, height: 12pt)],
  [filesystems], [#sparkline((22, 25, 19, 28, 24, 30, 27), color: rgb("#00d2ff"), width: 50pt, height: 12pt)], [#sparkbar((4, 6, 3, 8, 5, 9, 7), color: rgb("#ff9f43"), width: 50pt, height: 12pt)], [#sparkdot((3, 4, 2, 3, 2, 1, 1), color: rgb("#0be881"), width: 50pt, height: 12pt)],
)
