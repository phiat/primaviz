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
//   page 6  bubble charts: overlapping labelled bubbles, extremes, short and narrow, dense, themes
//   page 7  box-plot value labels on 12 and 24 boxes, markers of smooth lines with fill
//   page 8  30 cities as vertical charts: tilt, shrink, stand upright, and only then thin (all themes, floor key)
//   page 9  30 cities as horizontal charts: height auto, fixed heights, themes, negatives, annotations
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

// ---- page 6: bubble charts -------------------------------------------------
// The axis line, the ticks and the plot extent agree, no bubble clips, and no label
// lands on another label or on another bubble.
#let bubbles(n, scale: 1, shift: 0) = (
  x: range(n).map(i => calc.rem(i * 37 + 11, 97) * scale + shift),
  y: range(n).map(i => calc.rem(i * 53 + 7, 89) * scale + shift),
  size: range(n).map(i => 10 + calc.rem(i * 31, 90)),
)
#let teams = ("Arsenal", "Liverpool", "Man City", "Chelsea", "Spurs", "Everton", "Brighton")
#let close-bubbles = (
  x: (68, 72, 65, 66, 48, 69, 70),
  y: (58, 55, 62, 60, 45, 57, 56),
  size: (850, 720, 950, 900, 420, 800, 760),
  labels: teams,
)
#page({
  text(weight: "bold")[Bubble charts]
  v(4pt)
  rows(
    bubble-chart(close-bubbles, width: W, height: H, title: "7 overlapping, labelled", x-label: "Goals", y-label: "Possession %", show-labels: true, labels: teams),
    bubble-chart(close-bubbles, width: W, height: H, title: "same, dark", x-label: "Goals", y-label: "Possession %", show-labels: true, labels: teams, theme: themes.dark),
    bubble-chart(close-bubbles, width: W, height: 90pt, title: "same, 90pt tall", show-labels: true, labels: teams),
    bubble-chart(close-bubbles, width: 150pt, height: H, title: "same, 150pt wide", show-labels: true, labels: teams),
    bubble-chart((x: (0, 100, 0, 100), y: (0, 0, 100, 100), size: (90, 40, 20, 100), labels: ("SW", "SE", "NW", "NE")), width: W, height: H, title: "bubbles on the four corners", show-labels: true, labels: ("SW", "SE", "NW", "NE"), x-label: "x", y-label: "y"),
    bubble-chart((x: (-40, -10, 25, 60), y: (-5, 12, -30, 4), size: (5, 25, 60, 15)), width: W, height: H, title: "negative coordinates", x-label: "x", y-label: "y", size-label: "Size"),
    bubble-chart((x: (1, 2, 3), y: (5, 5, 5), size: (30, 30, 30), labels: ("A", "B", "C")), width: W, height: H, title: "equal sizes, one y", show-labels: true, labels: ("A", "B", "C")),
    bubble-chart((x: (4, 4, 4), y: (7, 7, 7), size: (10, 30, 50)), width: W, height: H, title: "three on one spot"),
    bubble-chart(bubbles(60), width: W, height: H, title: "60 bubbles", x-label: "x", y-label: "y", size-label: "ARR"),
    bubble-chart(bubbles(12, scale: 40000, shift: 1000000), width: W, height: H, title: "1e6 magnitude", x-label: "x", y-label: "y"),
    bubble-chart(bubbles(12, scale: 0.0004, shift: 0.001), width: W, height: H, title: "0.001 magnitude", x-label: "x", y-label: "y"),
    bubble-chart((x: (3,), y: (7,), size: (5,)), width: W, height: 100pt, title: "one bubble, short"),
    multi-bubble-chart((series: (
      (name: "A", points: range(12).map(i => (calc.rem(i * 37 + 11, 97), calc.rem(i * 53 + 7, 89), 10 + calc.rem(i * 31, 90)))),
      (name: "B", points: range(12).map(i => (calc.rem(i * 41 + 3, 97), calc.rem(i * 29 + 17, 89), 10 + calc.rem(i * 17, 90)))),
      (name: "C", points: range(12).map(i => (calc.rem(i * 23 + 5, 97), calc.rem(i * 61 + 2, 89), 10 + calc.rem(i * 43, 90)))),
    )), width: W, height: H, title: "multi-bubble, 3 x 12", x-label: "x", y-label: "y", size-label: "Size"),
    multi-bubble-chart((series: (
      (name: "A", points: ((0, 0, 50), (100, 100, 10))),
      (name: "B", points: ((100, 0, 30), (0, 100, 70))),
    )), width: W, height: H, title: "multi-bubble, corners", theme: themes.dark),
    multi-bubble-chart((series: (
      (name: "A", points: ((1, 2, 5), (2, 3, 25))),
      (name: "B", points: ((3, 1, 60), (4, 4, 15))),
    )), width: 150pt, height: 90pt, title: "multi-bubble, small"),
    multi-bubble-chart((series: (
      (name: "A", points: ((1, 2, 5), (2, 3, 25))),
      (name: "B", points: ((3, 1, 60), (4, 4, 15))),
    )), width: W, height: H, title: "multi-bubble, legend right", theme: (legend-position: "right")),
  )
})

// ---- page 7: value labels and markers --------------------------------------
// Box plot value labels move aside or drop out where they would touch a neighbouring
// box, whisker, outlier or label; markers of a smooth line sit on the drawn curve.
#let boxes-out(n) = (
  labels: range(n).map(i => "G" + str(i + 1)),
  boxes: range(n).map(i => (
    min: calc.round(10 + 3 * calc.sin(i * 1.1), digits: 1), q1: calc.round(30 + 5 * calc.sin(i * 0.7), digits: 1),
    median: calc.round(45 + 6 * calc.cos(i * 0.9), digits: 1), q3: calc.round(62 + 5 * calc.sin(i * 1.3), digits: 1),
    max: calc.round(85 + 4 * calc.cos(i * 0.5), digits: 1),
    outliers: if calc.rem(i, 3) == 0 { (4, 96) } else { () },
  )),
)
#page({
  text(weight: "bold")[Value labels and markers]
  v(4pt)
  rows(
    box-plot(boxes(12), width: W, height: H, title: "12 boxes, show-values", y-label: "Value", show-values: true),
    box-plot(boxes(12), width: W, height: 220pt, title: "12 boxes, taller", y-label: "Value", show-values: true),
    box-plot(boxes-out(12), width: W, height: H, title: "12 boxes with outliers", y-label: "Value", show-values: true),
    box-plot(boxes(5), width: W, height: H, title: "5 boxes, show-values", y-label: "Value", show-values: true),
    box-plot(boxes(24), width: W, height: H, title: "24 boxes, show-values", y-label: "Value", show-values: true),
    box-plot(boxes(12, scale: 1000), width: W, height: H, title: "12 boxes, thousands", y-label: "Value", show-values: true),
    box-plot(boxes(12), width: W, height: H, title: "12 boxes, dark", y-label: "Value", show-values: true, theme: themes.dark),
    box-plot(boxes(12), width: W, height: H, title: "12 boxes, wide boxes", y-label: "Value", show-values: true, box-width: 0.8),
    line-chart(simple(months, wave(8)), width: W, height: H, title: "smooth + fill + markers", y-label: "Value", line-interpolation: "smooth", fill-area: true, show-points: true),
    line-chart(simple(months, wave(8)), width: W, height: H, title: "smooth r=3, values", y-label: "Value", line-interpolation: "smooth", smooth-radius: 3, show-points: true, show-values: true, fill-area: true),
    line-chart(simple(months, wave(8)), width: W, height: H, title: "smooth, error bars", y-label: "Value", line-interpolation: "smooth", show-points: true, errors: range(8).map(i => 4 + i)),
    line-chart(simple(months, wave(8)), width: W, height: H, title: "catmull-rom + fill + markers", y-label: "Value", line-interpolation: "catmull-rom", fill-area: true, show-points: true),
    multi-line-chart(series2(months), width: W, height: H, title: "multi-line smooth + markers", y-label: "Value", line-interpolation: "smooth", show-points: true),
    multi-line-chart(series2(months), width: W, height: H, title: "multi-line smooth r=2", y-label: "Value", line-interpolation: "smooth", smooth-radius: 2, show-points: true, theme: themes.dark),
  )
})

// ---- pages 8 and 9: every category named ------------------------------------
// 30 cities: all the labels stay (flat, tilted, upright, and only at the very end thinned).
// Vertical charts go through the ladder of the category axis; horizontal ones grow with
// `height: auto`, and with a fixed height shrink their labels to the floor before thinning.
#let cities30 = (
  "Austin", "Boston", "Chicago", "Denver", "El Paso", "Fresno", "Galway", "Houston", "Irvine", "Juneau",
  "Kansas", "Lisbon", "Madrid", "Nashville", "Oslo", "Paris", "Quito", "Rome", "Seoul", "Tokyo",
  "Utrecht", "Vienna", "Warsaw", "Xian", "York", "Zurich", "Accra", "Berlin", "Cairo", "Dakar",
)
#let city-data(n) = simple(cities30.slice(0, n), range(n).map(i => 20 + calc.rem(i * 37, 71)))
#let city-themes = (("default", themes.default), ("dark", themes.dark), ("compact", themes.compact), ("presentation", themes.presentation))
#page({
  text(weight: "bold")[30 cities, vertical: the labels tilt, shrink and stand up before any is dropped]
  v(4pt)
  rows(cols: 3,
    bar-chart(city-data(30), width: 354pt, height: 150pt, title: "bar, 354 x 150", y-label: "Score"),
    bar-chart(city-data(30), width: 354pt, height: 150pt, title: "bar, no axis title"),
    bar-chart(city-data(30), width: 354pt, height: auto, title: "bar, height auto"),
    bar-chart(city-data(30), width: 370pt, height: 150pt, title: "bar, 370 wide"),
    lollipop-chart(city-data(30), width: 354pt, height: 150pt, title: "lollipop, 354 x 150"),
    lollipop-chart(city-data(30), width: 354pt, height: 150pt, title: "lollipop, with axis title", y-label: "Score"),
    grouped-bar-chart(series2(cities30.slice(0, 24), base: 50, amp: 30), width: 354pt, height: 150pt, title: "grouped-bar, 24 categories"),
    stacked-bar-chart(series2(cities30.slice(0, 24), base: 30, amp: 10), width: 354pt, height: 150pt, title: "stacked-bar, 24 categories"),
    line-chart(city-data(30), width: 354pt, height: 150pt, title: "line, 30 points"),
    area-chart(city-data(30), width: 354pt, height: 150pt, title: "area, 30 points"),
    line-chart(simple(range(100).map(i => str(i + 1)), wave(100)), width: 354pt, height: 150pt, title: "line, 100 points (thinned at the floor)"),
    box-plot(boxes(24), width: 354pt, height: 150pt, title: "box-plot, 24 boxes"),
    ..city-themes.map(((name, th)) => bar-chart(city-data(30), width: 354pt, height: 150pt, title: "bar, " + name, y-label: "Score", theme: th)),
    ..city-themes.slice(1).map(((name, th)) => lollipop-chart(city-data(30), width: 354pt, height: 150pt, title: "lollipop, " + name, theme: th)),
    bar-chart(city-data(30), width: 354pt, height: 150pt, title: "floor raised to 8pt", y-label: "Score", theme: (category-label-min-size: 8pt)),
  )
})

#page(width: 1190pt, height: auto, flipped: false, {
  text(weight: "bold")[30 cities, horizontal: height auto grows the rows, a fixed height shrinks the labels, then thins]
  v(4pt)
  rows(cols: 6,
    horizontal-bar-chart(city-data(30), width: 250pt, height: auto, title: "bar, auto", x-label: "Score", y-label: "City"),
    horizontal-bar-chart(city-data(30), width: 250pt, height: 330pt, title: "bar, 330pt"),
    horizontal-bar-chart(city-data(30), width: 250pt, height: 150pt, title: "bar, 150pt (labels thinned)"),
    horizontal-lollipop-chart(city-data(30), width: 250pt, height: auto, title: "lollipop, auto", x-label: "Score", y-label: "City"),
    horizontal-lollipop-chart(city-data(30), width: 250pt, height: 330pt, title: "lollipop, 330pt"),
    horizontal-lollipop-chart(city-data(30), width: 250pt, height: 150pt, title: "lollipop, 150pt (labels thinned)"),
    ..city-themes.slice(1).map(((name, th)) => horizontal-bar-chart(city-data(30), width: 250pt, height: 330pt, title: "bar, 330pt, " + name, theme: th)),
    ..city-themes.slice(1).map(((name, th)) => horizontal-lollipop-chart(city-data(30), width: 250pt, height: 330pt, title: "lollipop, 330pt, " + name, theme: th)),
    horizontal-bar-chart((labels: ("A", "B", "C", "D"), values: (12, -5, 30, 18)), width: 250pt, title: "negatives", y-label: "Group", x-label: "Delta"),
    horizontal-bar-chart((labels: ("Alpha", "Beta", "Gamma"), values: (12000, 54000, 31000)), width: 250pt, title: "10k+, v-line", annotations: ((type: "v-line", value: 30000, label: "target"),)),
    horizontal-lollipop-chart((labels: ("A", "B", "C", "D"), values: (12, -5, 30, 18)), width: 250pt, title: "negatives", y-label: "Group", x-label: "Delta"),
    horizontal-bar-chart((labels: ("Only",), values: (7,)), width: 250pt, title: "one row"),
    horizontal-bar-chart((labels: ("Enterprise subscriptions", "Professional services and training", "Hardware maintenance contracts", "Self-serve"), values: (84, 61, 120, 47)), width: 250pt, title: "long labels"),
  )
})
