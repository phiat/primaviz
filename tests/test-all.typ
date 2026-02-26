// test-all.typ — Compilation test for all chart types and theme presets
// Verifies that every exported chart function works with minimal inline data.

#import "../src/lib.typ": *

#set page(margin: 0.5cm)

// ── Test Data ──────────────────────────────────────────────────────────────

#let simple-data = (labels: ("A", "B", "C"), values: (10, 20, 15))

#let multi-data = (
  labels: ("A", "B"),
  series: (
    (name: "X", values: (10, 20)),
    (name: "Y", values: (15, 25)),
  ),
)

#let scatter-data = (x: (1, 2, 3), y: (10, 20, 15))

#let bubble-data = (x: (1, 2, 3), y: (10, 20, 15), size: (5, 10, 8))

#let heatmap-data = (
  rows: ("R1", "R2"),
  cols: ("C1", "C2"),
  values: ((1, 2), (3, 4)),
)

#let calendar-data = (
  dates: ("2024-01-01", "2024-01-02", "2024-01-03", "2024-01-04", "2024-01-05", "2024-01-06", "2024-01-07"),
  values: (1, 3, 0, 5, 2, 4, 1),
)

#let correlation-data = (
  labels: ("A", "B"),
  values: ((1.0, 0.5), (0.5, 1.0)),
)

#let radar-data = (
  labels: ("A", "B", "C", "D"),
  series: ((name: "S1", values: (5, 8, 6, 7)),),
)

#let multi-scatter-data = (
  series: (
    (name: "G1", points: ((1, 2), (3, 4))),
    (name: "G2", points: ((2, 3), (4, 5))),
  ),
)

// ── Bar Charts ─────────────────────────────────────────────────────────────

= Bar Charts

#bar-chart(simple-data, title: "bar-chart")

#horizontal-bar-chart(simple-data, title: "horizontal-bar-chart")

#grouped-bar-chart(multi-data, title: "grouped-bar-chart")

#stacked-bar-chart(multi-data, title: "stacked-bar-chart")

#pagebreak()

// ── Line Charts ────────────────────────────────────────────────────────────

= Line Charts

#line-chart(simple-data, title: "line-chart")

#multi-line-chart(multi-data, title: "multi-line-chart")

#pagebreak()

// ── Area Charts ────────────────────────────────────────────────────────────

= Area Charts

#area-chart(simple-data, title: "area-chart")

#stacked-area-chart(multi-data, title: "stacked-area-chart")

#pagebreak()

// ── Pie Chart ──────────────────────────────────────────────────────────────

= Pie Chart

#pie-chart(simple-data, title: "pie-chart")

#pie-chart(simple-data, title: "pie-chart (donut)", donut: true)

#pagebreak()

// ── Radar Chart ────────────────────────────────────────────────────────────

= Radar Chart

#radar-chart(radar-data, title: "radar-chart")

#pagebreak()

// ── Scatter & Bubble ───────────────────────────────────────────────────────

= Scatter & Bubble Charts

#scatter-plot(scatter-data, title: "scatter-plot")

#multi-scatter-plot(multi-scatter-data, title: "multi-scatter-plot")

#bubble-chart(bubble-data, title: "bubble-chart")

#pagebreak()

// ── Gauge & Progress ───────────────────────────────────────────────────────

= Gauge & Progress Charts

#gauge-chart(65, title: "gauge-chart")

#progress-bar(72, title: "progress-bar")

#circular-progress(45, title: "circular-progress")

#progress-bars(simple-data, title: "progress-bars")

#pagebreak()

// ── Heatmap Charts ─────────────────────────────────────────────────────────

= Heatmap Charts

#heatmap(heatmap-data, title: "heatmap")

#calendar-heatmap(calendar-data, title: "calendar-heatmap")

#correlation-matrix(correlation-data, title: "correlation-matrix")

#pagebreak()

// ── Theme Presets ──────────────────────────────────────────────────────────

= Theme Presets

== themes.default
#bar-chart(simple-data, title: "default theme", theme: themes.default)

== themes.minimal
#bar-chart(simple-data, title: "minimal theme", theme: themes.minimal)

== themes.dark
#bar-chart(simple-data, title: "dark theme", theme: themes.dark)

== themes.presentation
#bar-chart(simple-data, title: "presentation theme", theme: themes.presentation)

== themes.print
#bar-chart(simple-data, title: "print theme", theme: themes.print)

#pagebreak()

// ── Sparklines ───────────────────────────────────────────────────────────

= Sparklines

#let spark-data = (4, 7, 2, 9, 5, 8, 3, 6, 1, 8)

== sparkline (basic)
Inline: #sparkline(spark-data) — sits right in text.

== sparkline (fill-area)
Filled: #sparkline(spark-data, fill-area: true)

== sparkbar
Bars: #sparkbar(spark-data)

== sparkdot
Dots: #sparkdot(spark-data)

== Sparklines in a table

#table(
  columns: (auto, auto),
  align: (left, center),
  [*Metric*], [*Trend*],
  [Revenue], [#sparkline((3, 5, 4, 7, 6, 9, 8), color: rgb("#59a14f"))],
  [Users],   [#sparkbar((2, 4, 3, 6, 5, 8, 7), color: rgb("#4e79a7"))],
  [Errors],  [#sparkdot((8, 6, 7, 4, 5, 2, 3), color: rgb("#e15759"))],
)
