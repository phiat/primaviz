// stress-radial.typ - Robustness matrix for the radial charts
//
// Not part of test-all: a visual stress sheet. Compile it and look at the pages:
//   typst compile --root . tests/stress-radial.typ
// Every cell is a case that has gone wrong in some radial chart: long labels,
// many or tiny slices, zeros, one slice, every theme, a larger document font.

#import "../src/lib.typ": *

#set page(margin: 0.5cm, paper: "a4")
#set text(size: 8pt)

#let cases(..items) = grid(
  columns: (1fr, 1fr),
  column-gutter: 10pt,
  row-gutter: 14pt,
  ..items.pos().map(it => align(center + top, it)),
)

#let th = (
  default: themes.default,
  dark: themes.dark,
  minimal: themes.minimal,
  presentation: themes.presentation,
  compact: themes.compact,
  accessible: themes.accessible,
  print: themes.print,
)

#let langs = (("Rust", 35), ("C", 28), ("Python", 18), ("Go", 12), ("Other", 7))
#let tiny = (("Alpha", 90), ("Beta", 5), ("Gamma", 2), ("Delta", 1), ("Epsilon", 1), ("Zeta", 0.6), ("Eta", 0.4))
#let long-names = (
  ("Documentation and tutorials", 30), ("Infrastructure and operations", 25),
  ("Customer success", 20), ("Research & development of long-term bets", 15), ("Misc", 10),
)
#let many = range(26).map(i => ("Item " + str(i + 1), 4 + calc.rem(i * 7, 11)))

= Pie / donut

#cases(
  ..th.pairs().map(((name, t)) => pie-chart(langs, size: 120pt, title: "pie " + name, theme: t)),
  pie-chart(tiny, size: 140pt, title: "tiny slices (<2%)"),
  pie-chart(tiny, size: 140pt, title: "tiny slices, donut", donut: true, donut-ratio: 0.55, theme: themes.dark),
)

#pagebreak()
#cases(
  pie-chart(long-names, size: 120pt, title: "long labels"),
  pie-chart(many, size: 140pt, title: "26 slices"),
  pie-chart((("Only", 100),), size: 120pt, title: "single slice"),
  pie-chart((("Only", 100),), size: 120pt, title: "single slice, donut", donut: true),
  pie-chart((("A", 0), ("B", 50), ("C", 0), ("D", 50)), size: 120pt, title: "zero values"),
  pie-chart((("A", 0), ("B", 0)), size: 120pt, title: "all zero"),
  pie-chart((("A", 1), ("B", 1), ("C", 1), ("D", 1), ("E", 1), ("F", 1), ("G", 1)), size: 120pt, title: "all equal"),
  pie-chart(langs, size: 120pt, title: "no legend", show-legend: false),
  pie-chart(langs, size: 120pt, title: "no percentages", show-percentages: false),
  pie-chart(langs, size: 120pt, title: "legend none (theme)", theme: (legend-position: "none")),
  pie-chart(langs, size: 120pt, title: "subtitle", subtitle: "a subtitle", donut: true, donut-ratio: 0.8),
  [
    #set text(size: 14pt)
    #pie-chart(langs, size: 120pt, title: "doc text 14pt")
  ],
)

// Clusters of tiny slices at 12, 3, 6 and 9 o'clock: small labels bunch up wherever
// the cluster sits, and near the top and bottom they have little vertical room.
#let tiny5 = (("Alpha", 2), ("Beta", 1), ("Gamma", 1), ("Delta", 0.6), ("Epsilon", 0.4))
#let tiny8 = (("T1", 1.6), ("T2", 1.2), ("T3", 1), ("T4", 0.8), ("T5", 0.8), ("T6", 0.6), ("T7", 0.5), ("T8", 0.5))
#let cluster-sets = (
  ("ends at 12", (("North", 30), ("East", 25), ("South", 25), ("West", 15), ..tiny5)),
  ("straddles 12", (..tiny5.slice(0, 3), ("North", 30), ("East", 25), ("South", 25), ("West", 14), ..tiny5.slice(3))),
  ("at 3", (("North", 22.5), ..tiny5, ("East", 30), ("South", 25), ("West", 17.5))),
  ("at 6", (("North", 25), ("East", 22.5), ..tiny5, ("South", 25), ("West", 22.5))),
  ("at 9", (("North", 30), ("East", 25), ("South", 17.5), ..tiny5, ("West", 22.5))),
)

= Pie: clusters of tiny slices

#pagebreak()
#cases(
  ..cluster-sets.map(((name, d)) => pie-chart(d, size: 150pt, title: "cluster " + name)),
  ..cluster-sets.map(((name, d)) => pie-chart(d, size: 150pt, title: "donut " + name, donut: true, donut-ratio: 0.5, theme: themes.dark)),
)

#pagebreak()
#cases(
  pie-chart((("North", 30), ("East", 25), ("South", 25), ("West", 12), ..tiny8), size: 150pt, title: "8 tiny, ends at 12"),
  pie-chart((("North", 25), ("East", 22), ..tiny8, ("South", 25), ("West", 20)), size: 150pt, title: "8 tiny at 6", theme: themes.dark),
  pie-chart((("North", 21), ..tiny8, ("East", 30), ("South", 25), ("West", 14)), size: 150pt, title: "8 tiny at 3", donut: true),
  pie-chart((("North", 30), ("East", 25), ("South", 14), ..tiny8, ("West", 23)), size: 150pt, title: "8 tiny at 9", donut: true, theme: themes.dark),
  pie-chart((("Big", 80), ..tiny8.slice(0, 4).map(((n, v)) => (n, v * 2.5)), ("Rest", 5)), size: 150pt, title: "one big, four small"),
  pie-chart((("Big", 97), ("T1", 1), ("T2", 1), ("T3", 1)), size: 150pt, title: "97 + 1 + 1 + 1", theme: themes.dark),
  pie-chart((("Big", 97), ("T1", 1), ("T2", 1), ("T3", 1)), size: 150pt, title: "97 + 1 + 1 + 1, no legend", show-legend: false),
  pie-chart((("A", 1), ("B", 1), ("C", 1), ("D", 1), ("E", 1), ("F", 1), ("G", 1), ("H", 1), ("I", 1), ("J", 90)), size: 150pt, title: "nine at 1%, no legend", show-legend: false),
  pie-chart((("Big", 95.8), ..range(14).map(i => ("S" + str(i + 1), 0.3))), size: 150pt, title: "fourteen at 0.3%, no legend", show-legend: false),
  pie-chart((("North", 48), ..range(14).map(i => ("S" + str(i + 1), 0.3)), ("South", 47.8)), size: 150pt, title: "fourteen at 0.3% at 6, donut", show-legend: false, donut: true, theme: themes.dark),
)

// The same cluster at twelve places round the pie, as a pie and as a donut:
// no start angle may leave two labels touching.
#let at-place(k, tiny) = {
  let used = tiny.map(t => t.at(1)).sum()
  let before = k * (98 - used) / 11
  (..(if k == 0 { () } else { (("Before", before),) }), ..tiny, ("After", 100 - used - before))
}
#let sweep(tiny, ..args) = grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 6pt,
  row-gutter: 10pt,
  ..range(12).map(k => {
    let d = at-place(k, tiny)
    let deg = calc.round(k * (98 - tiny.map(t => t.at(1)).sum()) / 11 * 3.6)
    align(center + top, pie-chart(d, size: 90pt, show-legend: false, title: "starts " + str(deg) + "°", ..args))
  }),
)

#pagebreak()
#sweep(tiny5)
#pagebreak()
#sweep(tiny5, donut: true, theme: themes.dark)
#pagebreak()
#sweep(tiny8)
#pagebreak()
#sweep(tiny8, donut: true, donut-ratio: 0.55, theme: themes.dark)

= Radar

#let axes6 = ("Pace", "Shooting", "Passing", "Dribbling", "Defense", "Physical")
#let ser(name, vals) = (name: name, values: vals)
#let radar-data = (labels: axes6, series: (ser("Striker", (92, 88, 70, 85, 30, 80)), ser("Midfielder", (70, 62, 90, 88, 60, 74))))

#pagebreak()
#cases(
  ..th.pairs().map(((name, t)) => radar-chart(radar-data, size: 180pt, title: "radar " + name, theme: t)),
  radar-chart((labels: axes6, series: (ser("Solo", (92, 88, 70, 85, 30, 80)),)), size: 180pt, title: "single series (values on labels)"),
)

#pagebreak()
#cases(
  radar-chart((labels: ("Documentation quality", "Performance under load", "Ease of installation", "Community support", "Security posture", "Backwards compatibility"),
    series: (ser("A", (4, 3, 5, 2, 4, 3)),)), size: 200pt, title: "long labels"),
  radar-chart((labels: range(24).map(i => "Axis " + str(i + 1)), series: (ser("A", range(24).map(i => 3 + calc.rem(i * 5, 7))), ser("B", range(24).map(i => 2 + calc.rem(i * 3, 8))))),
    size: 220pt, title: "24 spokes"),
  radar-chart((labels: ("A", "B", "C"), series: (ser("S", (3, 5, 4)),)), size: 160pt, title: "3 spokes"),
  radar-chart((labels: ("A", "B"), series: (ser("S", (3, 5)),)), size: 160pt, title: "2 spokes"),
  radar-chart((labels: axes6, series: (ser("S", (0, 0, 0, 0, 0, 0)),)), size: 160pt, title: "all zero"),
  radar-chart((labels: axes6, series: (ser("S", (5, 5, 5, 5, 5, 5)),)), size: 160pt, title: "all equal"),
  radar-chart((labels: axes6, series: (ser("S", (0.2, 0.8, 0.5, 0.9, 0.1, 0.4)),)), size: 160pt, title: "fractions", axis-max-value: 1),
  radar-chart(radar-data, size: 160pt, title: "no legend", show-legend: false, show-value-labels: false),
  [
    #set text(size: 14pt)
    #radar-chart(radar-data, size: 180pt, title: "doc text 14pt")
  ],
)

= Rings

#let rings3 = ((name: "Move", value: 75, max: 100), (name: "Exercise", value: 22, max: 30), (name: "Stand", value: 9, max: 12))

#pagebreak()
#cases(
  ..th.pairs().slice(0, 4).map(((name, t)) => ring-progress(rings3, size: 130pt, title: "rings " + name, theme: t)),
  ring-progress(((name: "Only one", value: 50, max: 100),), size: 130pt, title: "one ring"),
  ring-progress(range(7).map(i => (name: "Goal " + str(i + 1), value: 20 + i * 12, max: 100)), size: 140pt, title: "7 rings"),
  ring-progress(((name: "Over", value: 140, max: 100), (name: "Exact", value: 100, max: 100), (name: "None", value: 0, max: 100)), size: 130pt, title: "over / full / zero"),
  ring-progress(((name: "A very long ring name indeed", value: 3, max: 8), (name: "Another extremely long entry name", value: 5, max: 8)), size: 130pt, title: "long names"),
  ring-progress(rings3, size: 130pt, title: "no labels", show-labels: false),
  ring-progress(rings3, size: 130pt, title: "no values", show-values: false),
  [
    #set text(size: 14pt)
    #ring-progress(rings3, size: 130pt, title: "doc text 14pt")
  ],
)

= Radial bar

#let health = (("net", 82), ("fs", 64), ("drivers", 91), ("mm", 47), ("arch", 70))

#pagebreak()
#cases(
  ..th.pairs().slice(0, 4).map(((name, t)) => radial-bar-chart(health, size: 130pt, title: "radial-bar " + name, theme: t)),
  radial-bar-chart(health, size: 130pt, title: "show-values", show-values: true),
  radial-bar-chart(long-names, size: 130pt, title: "long labels", show-values: true),
  radial-bar-chart(many, size: 130pt, title: "26 bars"),
  radial-bar-chart((("Only", 40),), size: 130pt, title: "single bar"),
  radial-bar-chart((("A", 0), ("B", 5), ("C", 0), ("D", 5)), size: 130pt, title: "zero values", show-values: true),
  radial-bar-chart((("A", 0), ("B", 0)), size: 130pt, title: "all zero"),
  radial-bar-chart((("A", 7), ("B", 7), ("C", 7), ("D", 7)), size: 130pt, title: "all equal"),
  radial-bar-chart(health, size: 130pt, title: "no labels", show-labels: false),
  radial-bar-chart(health, size: 130pt, title: "inner-radius 0", inner-radius: 0),
  [
    #set text(size: 14pt)
    #radial-bar-chart(health, size: 130pt, title: "doc text 14pt", show-values: true)
  ],
)

// ── Gauge / progress family ──────────────────────────────────────────────

= Gauge

#pagebreak()
#cases(
  ..th.pairs().slice(0, 5).map(((name, t)) => gauge-chart(72, size: 150pt, title: "gauge " + name, label: "CPU", theme: t)),
  gauge-chart(40, size: 60pt, title: "size 60", label: "tiny"),
  gauge-chart(40, size: 220pt, title: "size 220", label: "large"),
  gauge-chart(5, min-val: 5, max-val: 5, size: 150pt, title: "min == max"),
  gauge-chart(65, size: 150pt, title: "segments", label: "load",
    segments: ((50, rgb("#59a14f")), (80, rgb("#edc948")), (100, rgb("#e15759")))),
  gauge-chart(123456, max-val: 200000, size: 150pt, title: "long value", label: "a rather long caption"),
  gauge-chart(-10, min-val: -50, max-val: 50, size: 150pt, title: "negative range"),
  gauge-chart(0, size: 150pt, title: "zero"),
  gauge-chart(100, size: 150pt, title: "full", label: "done"),
  gauge-chart(180, size: 150pt, title: "over max", label: "clamped"),
  gauge-chart(72, size: 150pt, title: "no value", show-value: false),
  gauge-chart(72, size: 150pt),
  [
    #set text(size: 14pt)
    #gauge-chart(72, size: 150pt, title: "doc text 14pt", label: "CPU")
  ],
)

= Progress

#pagebreak()
#cases(
  progress-bar(0, width: 160pt, title: "0"),
  progress-bar(100, width: 160pt, title: "100"),
  progress-bar(150, width: 160pt, title: "150 (over)"),
  progress-bar(3, width: 160pt, title: "3 (value fits nowhere)"),
  progress-bar(45, width: 80pt, title: "narrow"),
  progress-bar(45, width: 160pt, height: 8pt, title: "thin"),
  progress-bar(45, width: 160pt, height: 32pt, title: "tall"),
  progress-bar(45, width: 160pt, title: "A progress title that is far too long for its bar to hold"),
  progress-bar(70, width: 160pt, title: "dark", theme: themes.dark),
  progress-bar(70, width: 160pt, title: "presentation", theme: themes.presentation),
  progress-bar(70, width: 160pt, title: "square", rounded: false),
  progress-bar(70, width: 160pt, title: "no value", show-value: false),
  circular-progress(0, title: "0"),
  circular-progress(100, title: "100"),
  circular-progress(150, title: "150"),
  circular-progress(37, size: 40pt, title: "size 40"),
  circular-progress(37, size: 140pt, title: "size 140"),
  circular-progress(37, size: 80pt, stroke-width: 22pt, title: "thick stroke"),
  circular-progress(37, theme: themes.dark, title: "dark"),
  circular-progress(37, show-value: false, title: "no value"),
  [
    #set text(size: 14pt)
    #progress-bar(70, width: 160pt, title: "doc text 14pt")
  ],
  [
    #set text(size: 14pt)
    #circular-progress(70, title: "doc text 14pt")
  ],
)

#let targets = (("Revenue", 82), ("Retention", 64), ("NPS", 91), ("Hiring", 47))
#pagebreak()
#cases(
  progress-bars(targets, width: 250pt, title: "progress-bars"),
  progress-bars(targets, width: 250pt, title: "dark", theme: themes.dark),
  progress-bars(targets, width: 130pt, title: "narrow"),
  progress-bars(long-names, width: 250pt, title: "long labels", max-val: 100),
  progress-bars((("Zero", 0), ("Full", 100), ("Over", 150)), width: 250pt, title: "0 / 100 / 150", max-val: 100),
  progress-bars(many.slice(0, 12), width: 250pt, title: "12 bars"),
  progress-bars(targets, width: 250pt, title: "no values", show-values: false),
  progress-bars((("Only", 40),), width: 250pt, title: "single"),
  progress-bars(targets, width: 250pt, title: "compact", theme: themes.compact),
  [
    #set text(size: 14pt)
    #progress-bars(targets, width: 250pt, title: "doc text 14pt")
  ],
)

// ── Sunburst ─────────────────────────────────────────────────────────────

= Sunburst

#let org = json("../data/sales.json").org
#let deep = (name: "root", children: (
  (name: "Alpha", value: 50, children: (
    (name: "A1", value: 30, children: ((name: "A1a", value: 20, children: ((name: "A1a-i", value: 12), (name: "A1a-ii", value: 8))), (name: "A1b", value: 10))),
    (name: "A2", value: 20))),
  (name: "Beta", value: 30, children: ((name: "B1", value: 18), (name: "B2", value: 12))),
  (name: "Gamma", value: 20),
))
#let slivers = (name: "root", children: (
  (name: "Big", value: 70, children: ((name: "Big one", value: 60), (name: "Big two", value: 10))),
  (name: "Small", value: 5), (name: "Smaller", value: 3), (name: "Tiny", value: 1.5), (name: "Tinier", value: 0.5),
  (name: "Medium", value: 20, children: ((name: "M1", value: 12), (name: "M2", value: 6), (name: "M3", value: 2))),
))
#let wordy = (name: "root", children: (
  (name: "Documentation and tutorials", value: 40, children: ((name: "Getting started guide", value: 25), (name: "Reference manual", value: 15))),
  (name: "Infrastructure and operations", value: 35, children: ((name: "Continuous integration", value: 20), (name: "Deployment tooling", value: 15))),
  (name: "Research & development of long-term bets", value: 25),
))

#pagebreak()
#cases(
  sunburst-chart(org, size: 220pt, title: "sunburst default"),
  sunburst-chart(org, size: 220pt, title: "dark", theme: themes.dark),
  sunburst-chart(org, size: 220pt, title: "minimal", theme: themes.minimal),
  sunburst-chart(org, size: 220pt, title: "presentation", theme: themes.presentation),
  sunburst-chart(org, size: 220pt, title: "compact", theme: themes.compact),
  sunburst-chart(org, size: 220pt, title: "no labels", show-labels: false),
  sunburst-chart(deep, size: 260pt, title: "4 levels", ring-width: 28pt),
  sunburst-chart(deep, size: 260pt, title: "max-depth 2", max-depth: 2),
  sunburst-chart(slivers, size: 260pt, title: "narrow slices"),
  sunburst-chart(wordy, size: 260pt, title: "long labels"),
  sunburst-chart(org, size: 260pt, title: "half circle", total-angle: 180deg, start-angle: 180deg),
  [
    #set text(size: 14pt)
    #sunburst-chart(org, size: 220pt, title: "doc text 14pt")
  ],
)

// ── Parliament ───────────────────────────────────────────────────────────

= Parliament

#let parties = (("Greens", 38), ("Labour", 120), ("Liberal", 64), ("Conservative", 130), ("Nationalist", 25), ("Independent", 7))
#pagebreak()
#cases(
  parliament-chart(parties, size: 230pt, title: "parliament default"),
  parliament-chart(parties, size: 230pt, title: "dark", theme: themes.dark),
  parliament-chart(parties, size: 230pt, title: "legend bottom", theme: (legend-position: "bottom")),
  parliament-chart(parties, size: 230pt, title: "legend top", theme: (legend-position: "top")),
  parliament-chart(parties, size: 230pt, title: "legend left", theme: (legend-position: "left")),
  parliament-chart(parties, size: 230pt, title: "legend none", theme: (legend-position: "none")),
  parliament-chart(parties, size: 230pt, title: "no legend", show-legend: false),
  parliament-chart((("Only", 40),), size: 230pt, title: "one party"),
  parliament-chart(range(20).map(i => ("Party " + str(i + 1), 3 + calc.rem(i * 5, 9))), size: 230pt, title: "20 parties"),
  parliament-chart((("A", 3), ("B", 2)), size: 230pt, title: "5 seats", dot-size: 12pt),
  parliament-chart(parties, size: 230pt, title: "minimal", theme: themes.minimal),
  [
    #set text(size: 14pt)
    #parliament-chart(parties, size: 230pt, title: "doc text 14pt")
  ],
)

// Angular (party wedges, the default) and rows fill: few and many parties, a
// 5-seat party, 600+ seats, a light and a dark theme.
#let chamber(a, b, c, d, e) = (("A", a), ("B", b), ("C", c), ("D", d), ("E", e))
#pagebreak()
#cases(
  parliament-chart(parties, size: 230pt, title: "fill-order: rows", fill-order: "rows"),
  parliament-chart(parties, size: 230pt, title: "fill-order: rows, dark", fill-order: "rows", theme: themes.dark),
  parliament-chart((("A", 60), ("B", 40)), size: 230pt, title: "2 parties"),
  parliament-chart((("A", 60), ("B", 40)), size: 230pt, title: "2 parties, rows", fill-order: "rows"),
  parliament-chart((chamber(30, 25, 20, 15, 10)), size: 230pt, title: "5 parties"),
  parliament-chart((chamber(5, 5, 5, 5, 5)), size: 230pt, title: "5 parties of 5 seats", dot-size: 8pt, gap: 2pt),
  parliament-chart((("A", 300), ("Tiny", 5), ("B", 200), ("C", 90), ("D", 12)), size: 250pt, dot-size: 3pt, title: "600+ seats, a 5-seat party mid-chamber"),
  parliament-chart((("A", 300), ("B", 200), ("C", 90), ("D", 12), ("Tiny", 5)), size: 250pt, dot-size: 3pt, title: "600+ seats, dark", theme: themes.dark),
)

// ── Chord ────────────────────────────────────────────────────────────────

= Chord

#let deps = json("../data/codebase.json").dependencies
#let chord-n(n, f) = (labels: range(n).map(i => "Entity " + str(i + 1)), matrix: range(n).map(i => range(n).map(j => if i == j { 0 } else { f(i, j) })))
#pagebreak()
#cases(
  chord-diagram(deps, size: 200pt, title: "chord default"),
  chord-diagram(deps, size: 200pt, title: "dark", theme: themes.dark),
  chord-diagram(deps, size: 200pt, title: "minimal", theme: themes.minimal),
  chord-diagram(deps, size: 200pt, title: "presentation", theme: themes.presentation),
  chord-diagram(deps, size: 200pt, title: "compact", theme: themes.compact),
  chord-diagram(deps, size: 200pt, title: "no labels", show-labels: false),
  chord-diagram(chord-n(3, (i, j) => 5 + i + j), size: 200pt, title: "3 entities"),
  chord-diagram(chord-n(20, (i, j) => calc.rem(i * 3 + j * 7, 5)), size: 240pt, title: "20 entities"),
  chord-diagram((labels: ("A", "B", "C", "D"), matrix: ((0, 5, 0, 2), (3, 0, 0, 1), (0, 0, 0, 0), (4, 6, 0, 0))), size: 200pt, title: "zero row"),
  chord-diagram((labels: ("Documentation and tutorials", "Infrastructure and operations", "Research & development of bets", "Customer success"),
    matrix: ((0, 5, 3, 2), (3, 0, 4, 1), (2, 6, 0, 3), (4, 1, 5, 0))), size: 200pt, title: "long names"),
  chord-diagram((labels: ("A", "B", "C"), matrix: ((9, 2, 1), (1, 7, 2), (2, 1, 8))), size: 200pt, title: "self flows"),
  chord-diagram((labels: ("A", "B", "C"), matrix: ((0, 0, 0), (0, 0, 0), (0, 0, 0))), size: 200pt, title: "no flow"),
  [
    #set text(size: 14pt)
    #chord-diagram(deps, size: 200pt, title: "doc text 14pt")
  ],
)

// ── Word cloud ───────────────────────────────────────────────────────────

= Word cloud

#let wc = json("../data/words.json")
#pagebreak()
#cases(
  word-cloud(wc, width: 270pt, height: 200pt, title: "word-cloud default"),
  word-cloud(wc, width: 270pt, height: 200pt, title: "dark", theme: themes.dark),
  word-cloud(wc, width: 270pt, height: 200pt, title: "minimal", theme: themes.minimal),
  word-cloud(wc, width: 270pt, height: 200pt, title: "presentation", theme: themes.presentation),
  word-cloud(wc, width: 270pt, height: 200pt, title: "circle", shape: "circle"),
  word-cloud(wc, width: 270pt, height: 200pt, title: "diamond", shape: "diamond"),
  word-cloud(wc, width: 270pt, height: 200pt, title: "triangle", shape: "triangle"),
  word-cloud((words: ((text: "Solo", weight: 5),)), width: 270pt, height: 120pt, title: "one word"),
  word-cloud((words: ("Alpha", "Beta", "Gamma", "Delta", "Epsilon", "Zeta").map(x => (text: x, weight: 9))), width: 270pt, height: 120pt, title: "all equal"),
  word-cloud(wc, width: 130pt, height: 100pt, title: "small canvas"),
  word-cloud(wc, width: 270pt, height: 200pt, title: "compact", theme: themes.compact),
  [
    #set text(size: 14pt)
    #word-cloud(wc, width: 270pt, height: 200pt, title: "doc text 14pt")
  ],
)

// ── Metrics, sparklines, dashboard pieces ────────────────────────────────

= Metrics

#let kpis = json("../data/sales.json").kpis
#pagebreak()
#cases(
  metric-row(kpis, width: 270pt),
  metric-row(kpis, width: 270pt, theme: themes.dark),
  metric-row((..kpis.slice(0, 2), (value: 7, label: "No trend", delta: 2.5)), width: 270pt),
  metric-row((kpis.at(0), (value: 7, label: "No trend, no delta"), (value: "n/a", label: "Text value")), width: 270pt),
  metric-row((kpis.at(0), (value: 1250000, label: "A rather long metric label here", delta: -33.3, format: "si")), width: 270pt),
  metric-row(kpis, width: 270pt, theme: themes.presentation),
  metric-row(kpis, width: 270pt, theme: themes.compact),
  metric-card(value: 0, label: "Zero", delta: 0, width: 130pt),
  metric-card(value: 12.5, label: "Suffix", suffix: "ms", delta: -1.2, trend: (3, 3, 3, 3), width: 130pt),
  metric-card(value: 99, label: "Narrow", delta: 5, trend: (1, 5, 2), width: 80pt),
  [
    #set text(size: 14pt)
    #metric-row(kpis, width: 270pt)
  ],
)

= Sparklines

#let flat = (4, 4, 4, 4, 4)
#let neg = (-3, -1, -4, 2, 5, -2)
#let spark-table = table(
  columns: (auto, auto, auto, auto),
  align: (left, center, center, center),
  inset: 4pt,
  [*case*], [*sparkline*], [*sparkbar*], [*sparkdot*],
  ..(
    ("normal", (3, 5, 4, 7, 6, 9, 8)), ("flat", flat), ("single", (5,)), ("two points", (2, 8)),
    ("negative", neg), ("all zero", (0, 0, 0)), ("all negative", (-5, -3, -4)), ("long", range(60).map(i => calc.sin(i / 4) * 10)),
  ).map(((name, v)) => (
    name,
    sparkline(v, width: 60pt, height: 16pt, fill-area: true),
    sparkbar(v, width: 60pt, height: 16pt),
    sparkdot(v, width: 60pt, height: 16pt),
  )).flatten(),
)
#pagebreak()
#cases(
  spark-table,
  [
    #set text(size: 14pt)
    #spark-table
  ],
  box(fill: themes.dark.background, inset: 6pt, spark-table),
)

= Dashboard pieces

#pagebreak()
#cases(
  compact-table(
    ("Plan", "Q1", "Q2", "Notes"),
    (("Enterprise", "120", "150", "A long note that has to wrap inside its column"), ("Growth", "80", "95", "ok"), ("Starter", "40", "45", "")),
    highlight-col: 2),
  compact-table(("Plan", "Q1", "Q2"), (("Enterprise", "120", "150"), ("Growth", "80", "95")), highlight-col: 1, theme: themes.dark),
  [
    #alert([Deployment pipeline running.], variant: "info", title: "Info")
    #alert([CPU usage above 85%.], variant: "warning", title: "Warning")
    #alert([Build failed on staging; see the log for the long and detailed reason it failed.], variant: "error", title: "Error")
    #alert([All tests passing.], variant: "success", title: "Success")
    #alert([No title, default variant.])
  ],
  [
    #alert([Deployment pipeline running.], variant: "info", title: "Info", theme: themes.dark)
    #alert([CPU usage above 85%.], variant: "warning", title: "Warning", theme: themes.dark)
    #alert([Build failed on staging.], variant: "error", title: "Error", theme: themes.dark)
    #alert([All tests passing.], variant: "success", title: "Success", theme: themes.dark)
  ],
  box(fill: themes.dark.background, inset: 6pt, [
    #for v in ("default", "secondary", "destructive", "outline", "success") { badge(v, variant: v, theme: themes.dark); h(4pt) }
  ]),
  [
    #for v in ("default", "secondary", "destructive", "outline", "success") { badge(v, variant: v); h(4pt) }
  ],
  [
    #set text(size: 14pt)
    #alert([Doc text 14pt], variant: "warning", title: "Warning")
    #badge("14pt", variant: "success")
  ],
)
