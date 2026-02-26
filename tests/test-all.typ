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

== themes.accessible
#bar-chart(simple-data, title: "accessible theme", theme: themes.accessible)

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

// ── Funnel Chart ───────────────────────────────────────────────────────────

= Funnel Chart

#funnel-chart(
  (
    labels: ("Visitors", "Leads", "Qualified", "Proposals", "Closed"),
    values: (10000, 5000, 2500, 1200, 500),
  ),
  width: 300pt,
  height: 250pt,
  title: "Sales Funnel",
)

#pagebreak()

// ── Annotations ──────────────────────────────────────────────────────────

= Annotations

#line-chart(
  (labels: ("Jan", "Feb", "Mar", "Apr", "May", "Jun"),
   values: (30, 45, 35, 60, 50, 70)),
  width: 400pt,
  height: 200pt,
  title: "Sales with Annotations",
  annotations: (
    (type: "h-line", value: 50, label: "Target", color: rgb("#e15759"), dash: "dashed"),
    (type: "h-band", from: 40, to: 60, label: "Goal Zone", color: rgb("#59a14f")),
  ),
)

#bar-chart(
  (labels: ("A", "B", "C", "D", "E"), values: (20, 45, 30, 55, 40)),
  width: 350pt,
  height: 200pt,
  title: "Bar Chart with Target Line",
  annotations: (
    (type: "h-line", value: 35, label: "Avg", color: rgb("#4e79a7"), dash: "dashed"),
  ),
)

#scatter-plot(
  (x: (1, 2, 3, 4, 5), y: (10, 25, 15, 30, 20)),
  width: 350pt,
  height: 250pt,
  title: "Scatter with Annotations",
  annotations: (
    (type: "h-line", value: 20, label: "Threshold", color: rgb("#e15759"), dash: "dotted"),
    (type: "v-line", value: 3, label: "Midpoint", color: rgb("#4e79a7"), dash: "dashed"),
    (type: "label", x: 4, y: 30, text: "Peak!", color: rgb("#e15759")),
  ),
)

#pagebreak()

== Sparklines in a table

#table(
  columns: (auto, auto),
  align: (left, center),
  [*Metric*], [*Trend*],
  [Revenue], [#sparkline((3, 5, 4, 7, 6, 9, 8), color: rgb("#59a14f"))],
  [Users],   [#sparkbar((2, 4, 3, 6, 5, 8, 7), color: rgb("#4e79a7"))],
  [Errors],  [#sparkdot((8, 6, 7, 4, 5, 2, 3), color: rgb("#e15759"))],
)

#pagebreak()

// ── Waterfall Chart ──────────────────────────────────────────────────────────

= Waterfall Chart

#waterfall-chart(
  (
    labels: ("Start", "+Sales", "+Service", "-COGS", "-OpEx", "Total"),
    values: (1000, 400, 150, -300, -200, 1050),
  ),
  width: 400pt,
  height: 200pt,
  title: "Revenue Waterfall",
)

#pagebreak()

// ── Box Plot ──────────────────────────────────────────────────────────────

= Data Helpers

#let raw = (labels: ("C", "A", "D", "B"), values: (30, 10, 40, 20))

#bar-chart(sort-data(raw), title: "sort-data (ascending)")

#bar-chart(top-n(raw, 2), title: "top-n(2)")

#bar-chart(percent-of-total(raw), title: "percent-of-total")

#let multi = (
  labels: ("A", "B", "C"),
  series: (
    (name: "X", values: (10, 20, 30)),
    (name: "Y", values: (5, 15, 25)),
  ),
)
#bar-chart(aggregate(multi, fn: "sum"), title: "aggregate(sum)")

#pagebreak()

= Box Plot

#box-plot(
  (
    labels: ("Group A", "Group B", "Group C", "Group D"),
    boxes: (
      (min: 10, q1: 25, median: 35, q3: 50, max: 70),
      (min: 15, q1: 30, median: 42, q3: 55, max: 65),
      (min: 5, q1: 20, median: 28, q3: 40, max: 60),
      (min: 20, q1: 35, median: 45, q3: 58, max: 75),
    ),
  ),
  width: 350pt,
  height: 200pt,
  title: "Distribution Comparison",
)

#pagebreak()

// ── Histogram ────────────────────────────────────────────────────────────

= Histogram

#let histogram-data = (2.1, 3.5, 4.2, 4.8, 5.1, 5.3, 5.7, 6.0, 6.2, 6.5, 6.8, 7.1, 7.3, 7.5, 7.8, 8.0, 8.2, 8.5, 9.0, 9.5)

#histogram(histogram-data, title: "Basic Histogram", show-values: true)

#histogram(histogram-data, title: "Histogram (10 bins)", bins: 10)

#histogram(histogram-data, title: "Density Histogram", density: true, color: rgb("#76b7b2"))
