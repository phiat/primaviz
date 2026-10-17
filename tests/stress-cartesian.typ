// Stress matrix for the cartesian charts (bar, line, area, scatter, dual-axis,
// histogram, lollipop, boxplot, violin, waterfall, bump).
//
// Not a pass/fail test: it must compile, and the pages are meant to be looked at.
// Every cell is a case that used to collide, clip or lie:
//   page 1  themes: default, dark, minimal, presentation, compact
//   page 2  long category labels, 20+ categories
//   page 3  negatives, a single point, all-equal values, 1e6 and 0.001 magnitudes
//   page 4  legend positions: bottom, right, top, left
//   page 5  surrounding `#set text(size: 14pt)`
#import "../src/lib.typ": *

#set page(paper: "a3", flipped: true, margin: 14pt)
#set text(size: 8pt)

#let (W, H) = (270pt, 150pt)
#let rows(..items, cols: 4) = grid(columns: (1fr,) * cols, column-gutter: 8pt, row-gutter: 10pt, ..items)

// Deterministic wiggle so the data look real without a random source
#let wave(n, base: 50, amp: 30, phase: 0) = range(n).map(i => calc.round(base + amp * calc.sin(i * 1.7 + phase), digits: 1))
#let months = ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug")
#let simple(labels, values) = (labels: labels, values: values)
#let series2(labels, a: 0, b: 1, base: 50, amp: 30) = (
  labels: labels,
  series: (
    (name: "North", values: wave(labels.len(), base: base, amp: amp, phase: a)),
    (name: "South", values: wave(labels.len(), base: base, amp: amp, phase: b)),
  ),
)
#let xy(n, scale: 1, shift: 0) = (
  x: range(n).map(i => (i * 3.1 + 2) * scale + shift),
  y: range(n).map(i => (30 + 20 * calc.sin(i * 1.3)) * scale + shift),
)
#let boxes(n, scale: 1) = (
  labels: range(n).map(i => "G" + str(i + 1)),
  boxes: range(n).map(i => (
    min: (10 + i) * scale, q1: (30 + 2 * i) * scale, median: (45 + 3 * i) * scale,
    q3: (60 + 2 * i) * scale, max: (85 + i) * scale,
  )),
)
#let violins(n, scale: 1, shift: 0) = (
  labels: range(n).map(i => "G" + str(i + 1)),
  datasets: range(n).map(i => range(24).map(k => (40 + 12 * calc.sin(k * 0.9 + i) + k * 0.8) * scale + shift)),
)
#let dual(labels, scale: 1) = (
  labels: labels,
  left: (name: "Revenue", values: wave(labels.len(), base: 400, amp: 150).map(v => v * scale)),
  right: (name: "Users", values: wave(labels.len(), base: 20, amp: 8, phase: 2).map(v => v * scale / 30)),
)
#let grouped-stacked(labels) = (
  labels: labels,
  groups: (
    (name: "Online", segments: (
      (name: "Direct", values: wave(labels.len(), base: 20, amp: 8)),
      (name: "Search", values: wave(labels.len(), base: 15, amp: 6, phase: 1)),
    )),
    (name: "Retail", segments: (
      (name: "Store", values: wave(labels.len(), base: 25, amp: 9, phase: 2)),
      (name: "Outlet", values: wave(labels.len(), base: 10, amp: 4, phase: 3)),
    )),
  ),
)
#let ranks(labels) = (
  labels: labels,
  // each period is a permutation of 1..4: s -> (a s + i) mod 4 with a odd
  series: range(4).map(s => (name: "Team " + str(s + 1), values: range(labels.len()).map(i => calc.rem((if calc.even(i) { 1 } else { 3 }) * s + i, 4) + 1))),
)

// The cartesian set, one chart each, same title style everywhere
#let full-set(t, labels: months) = (
  bar-chart(simple(labels, wave(labels.len())), width: W, height: H, title: "bar", x-label: "Month", y-label: "Value", theme: t),
  scatter-plot(xy(14), width: W, height: H, title: "scatter", x-label: "Reach", y-label: "Score", theme: t),
  dual-axis-chart(dual(labels), width: W, height: H, title: "dual-axis", left-label: "Revenue", right-label: "Users", x-label: "Month", theme: t),
  violin-plot(violins(4), width: W, height: H, title: "violin", x-label: "Group", y-label: "Score", theme: t),
  line-chart(simple(labels, wave(labels.len())), width: W, height: H, title: "line", x-label: "Month", y-label: "Value", theme: t),
  waterfall-chart(simple(("Start", "Sales", "Costs", "Tax", "End"), (100, 40, -30, -10, 100)), width: W, height: H, title: "waterfall", x-label: "Stage", y-label: "Gold", theme: t),
  grouped-stacked-bar-chart(grouped-stacked(("Q1", "Q2", "Q3", "Q4")), width: W, height: H, title: "grouped-stacked", x-label: "Quarter", y-label: "Revenue", theme: t),
  bump-chart(ranks(("2021", "2022", "2023", "2024")), width: W, height: H, title: "bump", theme: t),
)

// ---- page 1: themes --------------------------------------------------------
#let theme-list = (
  ("default", themes.default),
  ("dark", themes.dark),
  ("minimal", themes.minimal),
  ("presentation", themes.presentation),
  ("compact", themes.compact),
)
#for (name, t) in theme-list {
  page(fill: if name == "dark" { rgb("#111827") } else { none }, {
    text(weight: "bold", fill: if name == "dark" { white } else { black })[Theme: #name]
    v(4pt)
    rows(..full-set(t))
  })
}

// ---- page 2: label stress --------------------------------------------------
#let long-labels = ("Enterprise subscriptions", "Professional services and training", "Hardware maintenance contracts", "Self-serve", "Partner channel resale", "Other")
#let many = range(24).map(i => "Item " + str(i + 1))
#let many-long = range(22).map(i => "Department " + str(i + 1) + " (regional)")
#page({
  text(weight: "bold")[Long labels and 20+ categories]
  v(4pt)
  rows(
    bar-chart(simple(long-labels, wave(6)), width: W, height: H, title: "bar, long labels", x-label: "Segment", y-label: "Value"),
    horizontal-bar-chart(simple(long-labels, wave(6)), width: W, height: H, title: "horizontal-bar, long labels", x-label: "Value"),
    line-chart(simple(long-labels, wave(6)), width: W, height: H, title: "line, long labels", y-label: "Value"),
    lollipop-chart(simple(long-labels, wave(6)), width: W, height: H, title: "lollipop, long labels", y-label: "Value"),
    bar-chart(simple(many, wave(24)), width: W, height: H, title: "bar, 24 categories", x-label: "Item", y-label: "Value"),
    line-chart(simple(many, wave(24)), width: W, height: H, title: "line, 24 categories", x-label: "Item", y-label: "Value"),
    lollipop-chart(simple(many, wave(24)), width: W, height: H, title: "lollipop, 24 categories", show-values: true),
    horizontal-bar-chart(simple(many-long, wave(22)), width: W, height: H * 1.6, title: "horizontal-bar, 22 long rows", x-label: "Value"),
    waterfall-chart(simple(many, wave(24)), width: W, height: H, title: "waterfall, 24 steps", x-label: "Step", y-label: "Gold"),
    grouped-bar-chart(series2(many), width: W, height: H, title: "grouped-bar, 24 groups", y-label: "Value"),
    stacked-area-chart(series2(many), width: W, height: H, title: "stacked-area, 24 points", y-label: "Value"),
    bump-chart(ranks(many.slice(0, 12)), width: W, height: H, title: "bump, 12 periods"),
    box-plot(boxes(14), width: W, height: H, title: "box-plot, 14 boxes", y-label: "Value"),
    violin-plot(violins(12), width: W, height: H, title: "violin, 12 groups", y-label: "Value"),
    histogram(wave(60, base: 50, amp: 40), width: W, height: H, title: "histogram, 60 values", x-label: "Value", y-label: "Count"),
    area-chart(simple(many-long, wave(22)), width: W, height: H, title: "area, 22 long labels"),
  )
})

// ---- page 3: value stress --------------------------------------------------
#let neg = wave(8, base: 0, amp: 40)
#let one = (labels: ("Only",), values: (42,))
#let flat = simple(months.slice(0, 5), (7,) * 5)
#let big = simple(months.slice(0, 6), wave(6, base: 3000000, amp: 2000000))
#let tiny = simple(months.slice(0, 6), wave(6).map(v => v / 10000))
#page({
  text(weight: "bold")[Negatives, single point, all-equal, 1e6, 0.001]
  v(4pt)
  rows(
    bar-chart(simple(months, neg), width: W, height: H, title: "bar, negatives", y-label: "Delta"),
    stacked-bar-chart(series2(months, base: 0, amp: 30), width: W, height: H, title: "stacked-bar, negatives", y-label: "Delta"),
    lollipop-chart(simple(months, neg), width: W, height: H, title: "lollipop, negatives"),
    line-chart(simple(months, neg), width: W, height: H, title: "line, negatives", y-label: "Delta"),
    area-chart(simple(months, neg), width: W, height: H, title: "area, negatives"),
    horizontal-bar-chart(simple(months, neg), width: W, height: H, title: "horizontal-bar, negatives", x-label: "Delta"),
    horizontal-lollipop-chart(simple(months, neg), width: W, height: H, title: "horizontal-lollipop, negatives"),
    scatter-plot((x: (-30, -10, 5, 20, 40), y: (15, -25, 10, -5, 30)), width: W, height: H, title: "scatter, negatives", x-label: "x", y-label: "y"),
    bar-chart(one, width: W, height: H, title: "bar, single point", y-label: "Value"),
    line-chart(one, width: W, height: H, title: "line, single point", y-label: "Value"),
    scatter-plot((x: (5,), y: (9,)), width: W, height: H, title: "scatter, single point", x-label: "x", y-label: "y"),
    histogram((4, 4, 4, 4), width: W, height: H, title: "histogram, all equal", x-label: "Value", y-label: "Count"),
    bar-chart(flat, width: W, height: H, title: "bar, all equal", y-label: "Value"),
    line-chart(flat, width: W, height: H, title: "line, all equal", y-label: "Value"),
    scatter-plot((x: (3, 3, 3), y: (8, 8, 8)), width: W, height: H, title: "scatter, all equal", x-label: "x", y-label: "y"),
    violin-plot((labels: ("A", "B"), datasets: ((5, 5, 5, 5), (5, 5, 5))), width: W, height: H, title: "violin, all equal", y-label: "Value"),
    bar-chart(big, width: W, height: H, title: "bar, 1e6", y-label: "Users"),
    line-chart(big, width: W, height: H, title: "line, 1e6", y-label: "Users"),
    scatter-plot(xy(10, scale: 100000), width: W, height: H, title: "scatter, 1e5-1e6", x-label: "Reach", y-label: "Score"),
    dual-axis-chart(dual(months, scale: 10000), width: W, height: H, title: "dual-axis, 1e6", left-label: "Revenue", right-label: "Users"),
    bar-chart(tiny, width: W, height: H, title: "bar, 0.001", y-label: "Rate"),
    line-chart(tiny, width: W, height: H, title: "line, 0.001", y-label: "Rate"),
    scatter-plot(xy(10, scale: 0.0001), width: W, height: H, title: "scatter, 1e-3", x-label: "x", y-label: "y"),
    histogram(wave(40).map(v => v / 10000), width: W, height: H, title: "histogram, 0.001", x-label: "Rate", y-label: "Count"),
    waterfall-chart(simple(("Start", "Up", "Down", "End"), (3000000, 1200000, -800000, 3400000)), width: W, height: H, title: "waterfall, 1e6", y-label: "Gold"),
    box-plot(boxes(5, scale: 40000), width: W, height: H, title: "box-plot, 1e6", y-label: "Value"),
    violin-plot(violins(3, scale: 0.0001), width: W, height: H, title: "violin, 1e-3", y-label: "Value"),
    bump-chart(ranks(("A",)), width: W, height: H, title: "bump, single period"),
  )
})

// ---- page 4: legend positions ----------------------------------------------
#let positions = ("bottom", "right", "top", "left")
#page({
  text(weight: "bold")[Legend positions]
  v(4pt)
  rows(
    ..positions.map(p => grouped-bar-chart(series2(months.slice(0, 5)), width: W, height: H, title: "grouped-bar, " + p, y-label: "Value", theme: (legend-position: p))),
    ..positions.map(p => multi-line-chart(series2(months), width: W, height: H, title: "multi-line, " + p, y-label: "Value", theme: (legend-position: p))),
    ..positions.map(p => stacked-bar-chart(series2(months.slice(0, 5), base: 30), width: W, height: H, title: "stacked-bar, " + p, y-label: "Value", theme: (..themes.dark, legend-position: p))),
    ..positions.map(p => grouped-stacked-bar-chart(grouped-stacked(("Q1", "Q2", "Q3", "Q4")), width: W, height: H, title: "grouped-stacked, " + p, y-label: "Revenue", theme: (legend-position: p))),
    ..positions.map(p => multi-scatter-plot((series: ((name: "Home", points: ((2, 3), (4, 8), (6, 5), (8, 9))), (name: "Away", points: ((1, 6), (3, 2), (5, 7), (9, 4))))), width: W, height: H, title: "multi-scatter, " + p, x-label: "x", y-label: "y", theme: (legend-position: p))),
    ..positions.map(p => stacked-area-chart(series2(months), width: W, height: H, title: "stacked-area, " + p, y-label: "Value", theme: (legend-position: p))),
    ..positions.map(p => bubble-chart((x: (1, 3, 5, 8), y: (4, 9, 3, 7), size: (10, 40, 25, 60)), width: W, height: H, title: "bubble, " + p, x-label: "x", y-label: "y", size-label: "Size", theme: (legend-position: p))),
  )
})

// ---- page 5: surrounding text size -----------------------------------------
#page({
  set text(size: 14pt)
  text(weight: "bold")[Inside a document with #raw("#set text(size: 14pt)")]
  v(4pt)
  rows(
    bar-chart(simple(months, wave(8)), width: W, height: H, title: "bar", x-label: "Month", y-label: "Value"),
    line-chart(simple(months, wave(8)), width: W, height: H, title: "line", x-label: "Month", y-label: "Value"),
    dual-axis-chart(dual(months), width: W, height: H, title: "dual-axis", left-label: "Revenue", right-label: "Users", x-label: "Month"),
    scatter-plot(xy(14), width: W, height: H, title: "scatter", x-label: "Reach", y-label: "Score"),
    violin-plot(violins(4), width: W, height: H, title: "violin", x-label: "Group", y-label: "Score"),
    waterfall-chart(simple(("Start", "Sales", "Costs", "Tax", "End"), (100, 40, -30, -10, 100)), width: W, height: H, title: "waterfall", x-label: "Stage", y-label: "Gold"),
    grouped-bar-chart(series2(months.slice(0, 5)), width: W, height: H, title: "grouped-bar", y-label: "Value"),
    bump-chart(ranks(("2021", "2022", "2023", "2024")), width: W, height: H, title: "bump"),
    histogram(wave(60, base: 50, amp: 40), width: W, height: H, title: "histogram", x-label: "Value", y-label: "Count"),
    box-plot(boxes(5), width: W, height: H, title: "box-plot", y-label: "Value"),
    lollipop-chart(simple(months, wave(8)), width: W, height: H, title: "lollipop", y-label: "Value"),
    area-chart(simple(months, wave(8)), width: W, height: H, title: "area", y-label: "Value"),
  )
})
