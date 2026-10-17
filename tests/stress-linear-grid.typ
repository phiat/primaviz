// stress-linear-grid.typ — Robustness matrix for the row / matrix / linear charts:
// dumbbell, diverging, bullet(s), gantt, slope, funnel, timeline, sankey,
// heatmap, calendar-heatmap, correlation-matrix, treemap, waffle.
//
// Each section pushes the charts through: every theme, long labels, many rows,
// negative values, a single row, all-equal values, very large / tiny magnitudes
// and a document font size other than the default. Compile and look: no label
// should touch another label, a mark it is not about, or the container edge.
//
//   typst compile --root . tests/stress-linear-grid.typ "out-{0p}.png"

#import "../src/lib.typ": *

#set page(margin: 0.5cm, paper: "a4")
#set text(size: 8pt)

#let all-themes = (
  ("default", themes.default),
  ("dark", themes.dark),
  ("minimal", themes.minimal),
  ("presentation", themes.presentation),
  ("compact", themes.compact),
)

#let two-col(items) = grid(columns: (1fr, 1fr), column-gutter: 12pt, row-gutter: 14pt, ..items)

= Dumbbell

#two-col(all-themes.map(((name, th)) => dumbbell-chart(
  (labels: ("Revenue", "Users", "NPS", "Uptime", "Latency"), start-values: (45, 60, 68, 88, 22),
   end-values: (78, 85, 72, 95, 35), start-label: "Q1", end-label: "Q4"),
  width: 250pt, height: 190pt, title: "dumbbell " + name, show-values: true, theme: th)))

#two-col((
  dumbbell-chart(
    (labels: ("A very long category label that goes on", "Short", "Another quite long label here"),
     start-values: (10, 40, 25), end-values: (30, 20, 60)),
    width: 250pt, title: "long labels", show-values: true),
  dumbbell-chart(
    (labels: range(22).map(i => "Row " + str(i + 1)),
     start-values: range(22).map(i => calc.rem(i * 7, 23) + 5), end-values: range(22).map(i => calc.rem(i * 11, 29) + 12)),
    width: 250pt, height: 300pt, title: "22 rows", show-values: true),
  dumbbell-chart(
    (labels: ("Gain", "Loss", "Flat"), start-values: (-20, 15, -5), end-values: (30, -25, -5)),
    width: 250pt, title: "negative values", show-values: true),
  dumbbell-chart(
    (labels: ("Only",), start-values: (3,), end-values: (9,)),
    width: 250pt, title: "single row", show-values: true),
  dumbbell-chart(
    (labels: ("A", "B"), start-values: (50, 50), end-values: (50, 50)),
    width: 250pt, title: "all equal", show-values: true),
  dumbbell-chart(
    (labels: ("Big", "Bigger", "Biggest"), start-values: (1200000, 3400000, 9800000), end-values: (2500000, 8100000, 12000000)),
    width: 250pt, title: "large magnitudes", show-values: true),
  dumbbell-chart(
    (labels: ("a", "b", "c"), start-values: (0.0012, 0.0031, 0.0049), end-values: (0.0025, 0.0018, 0.0077)),
    width: 250pt, title: "tiny magnitudes", show-values: true),
  [#set text(size: 14pt)
   #dumbbell-chart(
     (labels: ("Revenue", "Users", "NPS"), start-values: (45, 60, 68), end-values: (78, 85, 72)),
     width: 250pt, title: "document text 14pt", show-values: true)],
))

#pagebreak()
= Diverging

#two-col(all-themes.map(((name, th)) => diverging-bar-chart(
  (labels: ("Enterprise", "Growth", "Starter", "Free Tier"), left-values: (15, 30, 45, 60), right-values: (85, 70, 55, 40),
   left-label: "Detractors", right-label: "Promoters"),
  width: 250pt, height: 190pt, title: "diverging " + name, x-label: "Responses", theme: th)))

#two-col((
  diverging-bar-chart(
    (labels: ("A very long category label that goes on", "Short", "Another quite long label"),
     left-values: (45, 30, 60), right-values: (55, 70, 40), left-label: "Disagree with the statement", right-label: "Agree"),
    width: 250pt, title: "long labels"),
  diverging-bar-chart(
    (labels: range(20).map(i => "Row " + str(i + 1)),
     left-values: range(20).map(i => calc.rem(i * 7, 23) + 5), right-values: range(20).map(i => calc.rem(i * 11, 29) + 12)),
    width: 250pt, height: 300pt, title: "20 rows"),
  diverging-bar-chart(
    (labels: ("Only",), left-values: (30,), right-values: (70,), left-label: "No", right-label: "Yes"),
    width: 250pt, title: "single row"),
  diverging-bar-chart(
    (labels: ("A", "B", "C"), left-values: (50, 50, 50), right-values: (50, 50, 50)),
    width: 250pt, title: "all equal"),
  diverging-bar-chart(
    (labels: ("North", "South"), left-values: (1200000, 900000), right-values: (2500000, 3100000), left-label: "2020", right-label: "2025"),
    width: 250pt, title: "large magnitudes", x-label: "Population"),
  diverging-bar-chart(
    (labels: ("a", "b"), left-values: (0.002, 0.004), right-values: (0.003, 0.001), left-label: "L", right-label: "R"),
    width: 250pt, title: "tiny magnitudes"),
  [#set text(size: 14pt)
   #diverging-bar-chart(
     (labels: ("Enterprise", "Growth"), left-values: (15, 30), right-values: (85, 70), left-label: "Detractors", right-label: "Promoters"),
     width: 250pt, title: "document text 14pt", x-label: "Responses")],
  diverging-bar-chart(
    (labels: ("Alpha", "Beta"), left-values: (10, 20), right-values: (20, 10)),
    width: 250pt, title: "narrow", show-values: false),
))

#pagebreak()
= Bullet

#two-col((
  box(width: 250pt)[#bullet-charts(
    (bullets: (
      (value: 275, target: 250, ranges: (150, 225, 300), title: "Revenue ($K)"),
      (value: 82, target: 90, ranges: (60, 80, 100), title: "A rather long KPI title", label: "out of 100"),
      (value: 45, target: 50, ranges: (25, 40, 60), title: "New customers"),
      (value: 0, target: 3, ranges: (1, 2, 5), title: "Zero"),
    )), width: 250pt, title: "bullet-charts default")],
  box(fill: rgb("#1a1a2e"), inset: 8pt)[#bullet-charts(
    (bullets: (
      (value: 275, target: 250, ranges: (150, 225, 300), title: "Revenue ($K)"),
      (value: 82, target: 90, ranges: (60, 80, 100), title: "Satisfaction"),
    )), width: 230pt, title: "dark", theme: themes.dark)],
  box(width: 250pt)[#bullet-chart(1234567, 1000000, (500000, 900000, 1500000), width: 250pt, title: "Large", label: "units")],
  box(width: 250pt)[#bullet-chart(0.0042, 0.005, (0.002, 0.004, 0.006), width: 250pt, title: "Tiny")],
  [#set text(size: 14pt)
   #bullet-chart(82, 90, (60, 80, 100), width: 250pt, title: "Satisfaction", label: "doc 14pt")],
  bullet-chart(82, 90, (60, 80, 100), width: 250pt, title: "compact", theme: themes.compact),
))

#pagebreak()
= Gantt

#let tasks = (tasks: (
  (name: "Research", start: 0, end: 3, group: "Plan"),
  (name: "Design", start: 2, end: 5, group: "Plan"),
  (name: "Backend implementation", start: 4, end: 9, group: "Build"),
  (name: "Frontend", start: 5, end: 10, group: "Build"),
  (name: "Testing", start: 8, end: 11, group: "QA"),
  (name: "Launch", start: 11, end: 13, group: "QA"),
))
#two-col(all-themes.map(((name, th)) => gantt-chart(tasks,
  width: 250pt, today: 7, title: "gantt " + name, x-label: "Week", show-legend: true, theme: th,
  )))
#two-col((
  gantt-chart((tasks: range(18).map(i => (name: "Task " + str(i + 1), start: calc.rem(i * 3, 20), end: calc.rem(i * 3, 20) + 4))),
    width: 250pt, title: "18 tasks, 24 columns", x-label: "Day", bar-height: 10pt, gap: 3pt),
  gantt-chart((tasks: ((name: "A task with a really long name indeed", start: 0, end: 4), (name: "Short", start: 3, end: 8))),
    width: 250pt, title: "long names", today: 5),
  gantt-chart((tasks: ((name: "Solo", start: 0, end: 1),)), width: 250pt, title: "single task"),
  gantt-chart((tasks: range(6).map(i => (name: "T" + str(i), start: i * 20, end: i * 20 + 30))),
    width: 250pt, title: "100+ columns", x-label: "Day"),
  [#set text(size: 14pt)
   #gantt-chart(tasks, width: 250pt, title: "document text 14pt", today: 7, x-label: "Week")],
))

#pagebreak()
= Slope

#let slope-data = (labels: ("Enterprise", "Growth", "Starter", "Free Tier"), start-values: (85, 70, 60, 45), end-values: (65, 90, 55, 80), start-label: "H1", end-label: "H2")
#two-col(all-themes.map(((name, th)) => slope-chart(slope-data, width: 250pt, height: 230pt, title: "slope " + name, theme: th)))
#two-col((
  slope-chart((labels: ("Alpha", "Beta", "Gamma", "Delta", "Epsilon"), start-values: (50, 51, 52, 50.5, 49), end-values: (80, 30, 50, 52, 51), start-label: "Before", end-label: "After"),
    width: 250pt, height: 230pt, title: "close values"),
  slope-chart((labels: ("A rather long company name", "Another long name here", "Short"), start-values: (10, 60, 35), end-values: (40, 20, 70), start-label: "2023", end-label: "2024"),
    width: 250pt, height: 200pt, title: "long labels"),
  slope-chart((labels: range(14).map(i => "Item " + str(i + 1)), start-values: range(14).map(i => calc.rem(i * 7, 17) + 3), end-values: range(14).map(i => calc.rem(i * 5, 19) + 2), start-label: "A", end-label: "B"),
    width: 250pt, height: 330pt, title: "14 rows"),
  slope-chart((labels: ("Only",), start-values: (5,), end-values: (9,)), width: 250pt, height: 120pt, title: "single row"),
  slope-chart((labels: ("A", "B"), start-values: (7, 7), end-values: (7, 7)), width: 250pt, height: 120pt, title: "all equal"),
  slope-chart((labels: ("Up", "Down"), start-values: (-20, 15), end-values: (30, -25)), width: 250pt, height: 160pt, title: "negative values"),
  slope-chart((labels: ("Big", "Bigger"), start-values: (1200000, 9800000), end-values: (8100000, 2500000)), width: 250pt, height: 160pt, title: "large magnitudes"),
  [#set text(size: 14pt)
   #slope-chart(slope-data, width: 250pt, height: 200pt, title: "document text 14pt")],
))

#pagebreak()
= Funnel

#let funnel-data = (labels: ("Leads", "Qualified", "Demo", "Proposal", "Closed"), values: (1200, 800, 450, 280, 120))
#two-col(all-themes.map(((name, th)) => funnel-chart(funnel-data, width: 250pt, height: 230pt, title: "funnel " + name, theme: th)))
#two-col((
  funnel-chart((labels: ("Visitors with a long label", "Sign-ups from the landing page", "Activated", "Paying customers", "Retained after a year", "Advocates"), values: (50000, 12000, 6000, 2400, 1500, 300)),
    width: 250pt, height: 260pt, title: "long labels, large"),
  funnel-chart((labels: range(12).map(i => "Stage " + str(i + 1)), values: range(12).map(i => 1000 - i * 70)),
    width: 250pt, height: 320pt, title: "12 stages"),
  funnel-chart((labels: ("Only",), values: (10,)), width: 250pt, height: 100pt, title: "single stage"),
  funnel-chart((labels: ("A", "B", "C"), values: (5, 5, 5)), width: 250pt, height: 140pt, title: "all equal"),
  funnel-chart((labels: ("A", "B", "C"), values: (0.004, 0.003, 0.001)), width: 250pt, height: 140pt, title: "tiny", show-values: true),
  [#set text(size: 14pt)
   #funnel-chart(funnel-data, width: 250pt, height: 200pt, title: "document text 14pt")],
))

#pagebreak()
= Timeline, sankey

#two-col((
  timeline-chart((events: (
    (date: "Jan 2024", title: "Kickoff of the whole project", description: "Project started with a very long description that has to wrap onto several lines"),
    (date: "Mar 2024", title: "Alpha", description: "Internal release"),
    (date: "Jun 2024", title: "Beta", description: "Public beta"),
    (date: "Sep 2024", title: "v1.0 and an unusually long title for a milestone", description: "Stable"),
  )), width: 250pt, event-gap: 40pt, title: "timeline long text"),
  timeline-chart((events: ((date: "2024", title: "Solo"),)), width: 250pt, title: "single event"),
  sankey-chart((nodes: ("Revenue", "Salaries and benefits", "R&D", "Marketing", "Infrastructure", "Savings", "Growth fund"),
    flows: ((from: 0, to: 1, value: 40), (from: 0, to: 2, value: 25), (from: 0, to: 3, value: 15), (from: 0, to: 4, value: 20),
            (from: 2, to: 5, value: 10), (from: 2, to: 6, value: 15))),
    width: 250pt, height: 220pt, title: "sankey long labels", show-values: true),
  sankey-chart((nodes: ("Revenue", "Salaries", "R&D", "Savings", "Growth"),
    flows: ((from: 0, to: 1, value: 40), (from: 0, to: 2, value: 25), (from: 2, to: 3, value: 10), (from: 2, to: 4, value: 15))),
    width: 250pt, height: 200pt, title: "sankey dark", theme: themes.dark),
  [#set text(size: 14pt)
   #sankey-chart((nodes: ("A", "B", "C"), flows: ((from: 0, to: 1, value: 3), (from: 1, to: 2, value: 3))), width: 250pt, height: 120pt, title: "document text 14pt")],
))

#pagebreak()
= Heatmap, correlation, calendar

#let hm = (rows: ("Sales", "Eng", "Marketing", "Support"), cols: ("Mon", "Tue", "Wed", "Thu", "Fri"), values: ((82, 95, 78, 88, 65), (45, 52, 68, 71, 38), (33, 41, 55, 48, 29), (91, 87, 93, 85, 72)))
#two-col(all-themes.map(((name, th)) => heatmap(hm, cell-size: 34pt, title: "heatmap " + name, theme: th)))
#two-col((
  heatmap((rows: ("A row with a long name", "Short"), cols: ("A column with a long name", "Other long column", "X"), values: ((1, 2, 3), (4, 5, 6))), title: "long labels", cell-size: 30pt),
  heatmap((rows: range(18).map(i => "R" + str(i)), cols: range(18).map(i => "Column " + str(i)), values: range(18).map(i => range(18).map(j => calc.rem(i * j, 11)))), title: "18 x 18", cell-size: 18pt),
  heatmap((rows: ("Only",), cols: ("One",), values: ((5,),)), title: "single cell"),
  heatmap((rows: ("A", "B"), cols: ("X", "Y"), values: ((3, 3), (3, 3))), title: "all equal"),
  heatmap((rows: ("A", "B"), cols: ("X", "Y"), values: ((-5, 3), (12, -1))), title: "negative", palette: "coolwarm"),
  heatmap((rows: ("A", "B"), cols: ("X", "Y"), values: ((1200000, 3400000), (900000, 12000000))), title: "large", cell-size: 50pt),
  heatmap((rows: ("A", "B"), cols: ("X", "Y"), values: ((0.0012, 0.0034), (0.0009, 0.012))), title: "tiny", cell-size: 50pt),
  [#set text(size: 14pt)
   #heatmap(hm, cell-size: 34pt, title: "document text 14pt")],
  correlation-matrix((labels: ("net", "fs", "mm", "drv", "arch"), values: ((1, 0.7, 0.3, 0.5, 0.2), (0.7, 1, 0.4, 0.6, 0.3), (0.3, 0.4, 1, 0.2, 0.8), (0.5, 0.6, 0.2, 1, 0.4), (0.2, 0.3, 0.8, 0.4, 1))), title: "correlation", theme: themes.dark),
  correlation-matrix((labels: ("Operating margin", "Revenue growth", "Churn rate"), values: ((1, -0.4, -0.7), (-0.4, 1, 0.1), (-0.7, 0.1, 1))), title: "correlation long labels"),
  correlation-matrix((labels: ("a", "b"), values: ((1, -1), (-1, 1))), title: "extremes", show-legend: false),
  calendar-heatmap((dates: range(56).map(i => "2024-0" + str(1 + calc.div-euclid(i, 28)) + "-" + (if calc.rem(i, 28) + 1 < 10 { "0" } else { "" }) + str(calc.rem(i, 28) + 1)), values: range(56).map(i => calc.rem(i * 7, 11))),
    title: "calendar two months", cell-size: 12pt),
  calendar-heatmap((dates: ("2024-03-04", "2024-03-05", "2024-03-12"), values: (3, 1, 9)), title: "calendar sparse", cell-size: 16pt, theme: themes.dark),
))

#pagebreak()
= Treemap, waffle

#let tm = (labels: ("Salaries", "Infra", "R&D", "Marketing", "Office", "Legal"), values: (1200, 800, 500, 400, 300, 250))
#two-col(all-themes.map(((name, th)) => treemap(tm, width: 250pt, height: 190pt, title: "treemap " + name, theme: th)))
#two-col((
  treemap((labels: ("A category with a long name", "Another long category name", "Tiny", "T2", "Mid size label"), values: (1000, 600, 4, 2, 200)), width: 250pt, height: 190pt, title: "long and tiny"),
  treemap((labels: range(30).map(i => "Item " + str(i + 1)), values: range(30).map(i => 100 - i * 3)), width: 250pt, height: 220pt, title: "30 cells"),
  treemap((labels: ("Only",), values: (10,)), width: 250pt, height: 100pt, title: "single"),
  treemap((labels: ("A", "B", "C"), values: (5, 5, 5)), width: 250pt, height: 120pt, title: "all equal"),
  treemap((labels: ("Big", "Bigger", "Biggest"), values: (1200000, 3400000, 9800000)), width: 250pt, height: 140pt, title: "large magnitudes"),
  [#set text(size: 14pt)
   #treemap(tm, width: 250pt, height: 160pt, title: "document text 14pt")],
  waffle-chart((labels: ("Rust", "C", "Python", "Go", "Other"), values: (35, 28, 18, 12, 7)), size: 150pt, title: "waffle"),
  waffle-chart((labels: ("A long category name here", "Another quite long category name", "Short"), values: (50, 30, 20)), size: 150pt, title: "waffle long labels"),
  waffle-chart((labels: ("Rust", "C", "Python"), values: (50, 30, 20)), size: 150pt, title: "waffle dark", theme: themes.dark),
  [#set text(size: 14pt)
   #waffle-chart((labels: ("Yes", "No"), values: (72, 28)), size: 130pt, title: "waffle 14pt")],
))

#pagebreak()
= Dense rows, funnel sweep

// Funnel: every stage count from 2 to 20 in the harness size (a 354pt by 150pt
// body). Outside labels get their measured column; none wraps into a sliver,
// none overlaps, a stage is left unlabelled only when no label could fit.
#let fn-stages(n) = (labels: range(n).map(i => "Stage " + str(i + 1)), values: range(n).map(i => calc.round(10000 * calc.pow(0.8, i))))
#two-col((2, 3, 5, 8, 12, 16, 20).map(n => funnel-chart(fn-stages(n), width: 354pt, height: 150pt, title: str(n) + " stages, 150pt high")))
#two-col((
  funnel-chart(fn-stages(12), width: 354pt, height: 150pt, title: "12 stages, compact", theme: themes.compact),
  funnel-chart(fn-stages(12), width: 354pt, height: 150pt, title: "12 stages, dark", theme: themes.dark),
  funnel-chart(fn-stages(12), width: 354pt, title: "12 stages, auto height"),
  funnel-chart((labels: ("Visited the marketing website", "Started a free trial of the product", "Invited at least one teammate", "Entered payment details", "Converted to a paid plan"), values: (9000, 3400, 1800, 760, 410)),
    width: 354pt, height: 150pt, title: "long labels"),
  funnel-chart((labels: ("Visited the marketing website", "Started a free trial of the product", "Invited at least one teammate", "Entered payment details", "Converted to a paid plan"), values: (9000, 3400, 1800, 760, 410)),
    width: 170pt, height: 190pt, title: "long labels, narrow"),
  funnel-chart(fn-stages(8), width: 354pt, height: 150pt, title: "no values", show-values: false, show-percentages: false),
))

// Dense row charts in a short body: labels shrink with the pitch before any is
// dropped, then thin evenly (first and last always shown).
#let cities-d = ("Austin", "Boston", "Chicago", "Denver", "El Paso", "Fresno", "Galway", "Houston", "Irvine", "Juneau",
  "Kansas", "Lisbon", "Madrid", "Nashville", "Oslo", "Paris", "Quito", "Rome", "Seoul", "Tokyo", "Utrecht", "Vienna",
  "Warsaw", "Xian", "York", "Zurich", "Accra", "Berlin", "Cairo", "Dakar", "Essen", "Faro", "Graz", "Hanoi", "Izmir",
  "Jaipur", "Kyoto", "Lagos", "Milan", "Nice")
#let dense-rows(n) = (labels: cities-d.slice(0, n), start-values: range(n).map(i => calc.rem(i * 7, 41) + 10),
  end-values: range(n).map(i => calc.rem(i * 11, 47) + 30), start-label: "2023", end-label: "2024")
#two-col((
  dumbbell-chart(dense-rows(24), width: 354pt, height: 150pt, title: "dumbbell, 24 rows"),
  dumbbell-chart(dense-rows(40), width: 354pt, height: 150pt, title: "dumbbell, 40 rows (thinned)"),
  diverging-bar-chart((labels: cities-d.slice(0, 25), left-values: range(25).map(i => calc.rem(i * 7, 23) + 5), right-values: range(25).map(i => calc.rem(i * 11, 29) + 12), left-label: "Disagree", right-label: "Agree"),
    width: 354pt, height: 150pt, title: "diverging, 25 rows"),
  diverging-bar-chart((labels: cities-d.slice(0, 40), left-values: range(40).map(i => calc.rem(i * 7, 23) + 5), right-values: range(40).map(i => calc.rem(i * 11, 29) + 12)),
    width: 354pt, height: 150pt, title: "diverging, 40 rows (thinned)"),
  gantt-chart((tasks: range(24).map(i => (name: "Task " + str(i + 1) + " " + cities-d.at(i), start: calc.rem(i * 3, 22), end: calc.rem(i * 3, 22) + 2 + calc.rem(i * 5, 6), group: ("Plan", "Build", "QA", "Ship").at(calc.rem(i, 4))))),
    width: 354pt, height: 150pt, bar-height: 6pt, gap: 2pt, title: "gantt, 24 tasks", show-legend: true),
  gantt-chart((tasks: range(40).map(i => (name: "Task " + str(i + 1), start: calc.rem(i * 3, 22), end: calc.rem(i * 3, 22) + 3))),
    width: 354pt, height: 150pt, bar-height: 4pt, gap: 1pt, title: "gantt, 40 tasks (thinned)"),
  heatmap((rows: range(20).map(i => "R" + str(i + 1)), cols: range(20).map(i => "C" + str(i + 1)), values: range(20).map(i => range(20).map(j => calc.rem(i * 7 + j * 13, 100)))),
    cell-size: 9pt, title: "heatmap 20 x 20"),
  heatmap((rows: range(30).map(i => "R" + str(i + 1)), cols: range(30).map(i => "C" + str(i + 1)), values: range(30).map(i => range(30).map(j => calc.rem(i * 7 + j * 13, 100)))),
    cell-size: 7pt, title: "heatmap 30 x 30 (vertical columns)"),
  heatmap((rows: range(60).map(i => "R" + str(i + 1)), cols: range(60).map(i => "C" + str(i + 1)), values: range(60).map(i => range(60).map(j => calc.rem(i * 7 + j * 13, 100)))),
    cell-size: 4pt, title: "heatmap 60 x 60 (thinned)"),
  correlation-matrix((labels: range(20).map(i => "V" + str(i + 1)), values: range(20).map(i => range(20).map(j => if i == j { 1.0 } else { calc.round(calc.pow(0.85, calc.abs(i - j)), digits: 2) }))),
    cell-size: 9pt, title: "correlation 20 x 20"),
))

#pagebreak()
= Ink on fills (WCAG), colour defaults, direct labels

// Labels on filled marks pick the text colour by WCAG contrast: light, dark,
// accessible (pale yellow and orange fills) and print (greys).
#let ink-themes = (("default", themes.default), ("dark", themes.dark), ("accessible", themes.accessible), ("print", themes.print))
#two-col(ink-themes.map(((name, th)) => treemap(tm, width: 250pt, height: 170pt, title: "treemap " + name, theme: th)))
#two-col(ink-themes.map(((name, th)) => funnel-chart(funnel-data, width: 250pt, height: 200pt, title: "funnel " + name + ", colour per stage", color-by-stage: true, theme: th)))
#two-col(ink-themes.map(((name, th)) => heatmap(hm, cell-size: 34pt, title: "heatmap " + name, theme: th)))
#two-col(ink-themes.map(((name, th)) => diverging-bar-chart(
  (labels: ("Enterprise", "Growth", "Starter"), left-values: (60, 30, 45), right-values: (40, 70, 55), left-label: "No", right-label: "Yes"),
  width: 250pt, height: 120pt, title: "diverging " + name, theme: th)))

#pagebreak()
// One colour unless colour says something: funnel stages and ungrouped tasks
// share the first palette colour; groups keep one colour each. `color-by-stage`
// and `color-by-task` opt back in.
#two-col((
  funnel-chart(funnel-data, width: 250pt, height: 200pt, title: "funnel, one colour"),
  funnel-chart(funnel-data, width: 250pt, height: 200pt, title: "funnel, colour per stage", color-by-stage: true),
  gantt-chart((tasks: tasks.tasks.map(tk => (name: tk.name, start: tk.start, end: tk.end))), width: 250pt, title: "gantt, ungrouped: one colour", today: 7),
  gantt-chart((tasks: tasks.tasks.map(tk => (name: tk.name, start: tk.start, end: tk.end))), width: 250pt, title: "gantt, colour per task", color-by-task: true),
  // Group names beside the first bar of each group; a legend where they do not fit
  gantt-chart(tasks, width: 250pt, title: "gantt, group names beside bars", show-legend: true, today: 7, x-label: "Week"),
  gantt-chart(tasks, width: 250pt, title: "gantt, dark", show-legend: true, theme: themes.dark),
  gantt-chart((tasks: range(12).map(i => (name: "Task " + str(i + 1), start: calc.rem(i * 5, 10), end: calc.rem(i * 5, 10) + 14 - calc.rem(i * 5, 10), group: "A rather long group name " + str(calc.rem(i, 3) + 1)))),
    width: 250pt, title: "gantt, bars span the plot: legend", show-legend: true),
  gantt-chart((tasks: range(24).map(i => (name: "Task " + str(i + 1), start: calc.rem(i * 3, 20), end: calc.rem(i * 3, 20) + 4, group: ("Plan", "Build", "QA").at(calc.rem(i, 3))))),
    width: 250pt, height: 150pt, title: "gantt, rows too tight for names: legend", show-legend: true),
  // Names level with their bands
  waffle-chart((labels: ("Rust", "C", "Python", "Go", "Other"), values: (35, 28, 18, 12, 7)), size: 150pt, title: "waffle, names beside bands"),
  waffle-chart((labels: ("A", "B", "C", "D", "E", "F"), values: (30, 25, 20, 12, 8, 5)), size: 150pt, title: "waffle, thin bands spread", theme: themes.dark),
  waffle-chart((labels: ("A long category name here", "Another quite long category name", "Short"), values: (50, 30, 20)), size: 150pt, title: "waffle, long names: legend"),
  waffle-chart((labels: ("Yes", "No"), values: (72, 28)), size: 130pt, title: "waffle, two", show-values: false),
))

#pagebreak()
// Sankey: labels of middle columns sit on flows, set on a halo
#two-col((
  sankey-chart((nodes: ("Organic", "Paid", "Referral", "Landing", "Pricing", "Docs", "Blog", "Signup", "Trial", "Churned", "Paid plan", "Free plan"),
    flows: ((from: 0, to: 3, value: 80), (from: 0, to: 4, value: 40), (from: 1, to: 3, value: 60), (from: 1, to: 5, value: 30), (from: 2, to: 4, value: 25), (from: 2, to: 6, value: 35),
            (from: 3, to: 7, value: 90), (from: 3, to: 8, value: 50), (from: 4, to: 7, value: 40), (from: 4, to: 8, value: 25), (from: 5, to: 8, value: 30), (from: 6, to: 7, value: 35),
            (from: 7, to: 10, value: 70), (from: 7, to: 11, value: 95), (from: 8, to: 9, value: 40), (from: 8, to: 10, value: 65))),
    width: 250pt, height: 260pt, title: "sankey, busy middle columns", show-values: true),
  sankey-chart((nodes: ("Organic", "Paid", "Referral", "Landing", "Pricing", "Docs", "Blog", "Signup", "Trial", "Churned", "Paid plan", "Free plan"),
    flows: ((from: 0, to: 3, value: 80), (from: 0, to: 4, value: 40), (from: 1, to: 3, value: 60), (from: 1, to: 5, value: 30), (from: 2, to: 4, value: 25), (from: 2, to: 6, value: 35),
            (from: 3, to: 7, value: 90), (from: 3, to: 8, value: 50), (from: 4, to: 7, value: 40), (from: 4, to: 8, value: 25), (from: 5, to: 8, value: 30), (from: 6, to: 7, value: 35),
            (from: 7, to: 10, value: 70), (from: 7, to: 11, value: 95), (from: 8, to: 9, value: 40), (from: 8, to: 10, value: 65))),
    width: 250pt, height: 260pt, title: "sankey, dark", show-values: true, theme: themes.dark),
))

#pagebreak()
= Compact theme: sizes follow the theme's base size

// Dots, markers, bars and gaps default to multiples of `base-size`; the compact
// theme (5pt) draws them smaller than the default (8pt), and an explicit size
// still wins.
#let cmp(f) = ((themes.default, "default"), (themes.compact, "compact")).map(((th, name)) => f(th, name))
#two-col(cmp((th, name) => dumbbell-chart(
  (labels: ("Revenue", "Users", "NPS", "Uptime"), start-values: (45, 60, 68, 88), end-values: (78, 85, 72, 95), start-label: "Q1", end-label: "Q4"),
  width: 250pt, title: "dumbbell " + name, show-values: true, theme: th)))
#two-col(cmp((th, name) => slope-chart(slope-data, width: 250pt, title: "slope " + name, theme: th)))
#two-col(cmp((th, name) => timeline-chart((events: (
    (date: "Jan 2024", title: "Kickoff", description: "Project started"),
    (date: "Mar 2024", title: "Alpha", description: "Internal release"),
    (date: "Jun 2024", title: "Beta", description: "Public beta"))), width: 250pt, title: "timeline " + name, theme: th)))
#two-col(cmp((th, name) => gantt-chart(tasks, width: 250pt, title: "gantt " + name, theme: th)))
#two-col(cmp((th, name) => bullet-charts(
  (bullets: ((value: 275, target: 250, ranges: (150, 225, 300), title: "Revenue ($K)"), (value: 82, target: 90, ranges: (60, 80, 100), title: "Satisfaction"))),
  width: 250pt, title: "bullet-charts " + name, theme: th)))
#two-col((
  dumbbell-chart((labels: ("A", "B"), start-values: (10, 40), end-values: (30, 20)), width: 250pt, title: "explicit dot-size: 14pt", dot-size: 14pt, theme: themes.compact),
  slope-chart(slope-data, width: 250pt, title: "explicit dot-size: 10pt", dot-size: 10pt, theme: themes.compact),
))

#pagebreak()
= Dense rows: value labels keep the label floor

#let dense-d(n) = (labels: range(n).map(i => "Row " + str(i + 1)), left-values: range(n).map(i => calc.rem(i * 7, 23) + 5),
  right-values: range(n).map(i => calc.rem(i * 11, 29) + 12), left-label: "Disagree", right-label: "Agree")
#two-col((
  diverging-bar-chart(dense-d(25), width: 354pt, height: 150pt, title: "diverging, 25 rows in 150pt"),
  diverging-bar-chart(dense-d(30), width: 354pt, height: 150pt, title: "diverging, 30 rows in 150pt"),
  diverging-bar-chart(dense-d(40), width: 354pt, height: 150pt, title: "diverging, 40 rows: values left out"),
  dumbbell-chart((labels: range(30).map(i => "Row " + str(i + 1)), start-values: range(30).map(i => calc.rem(i * 7, 41) + 10), end-values: range(30).map(i => calc.rem(i * 11, 47) + 30)),
    width: 354pt, height: 150pt, title: "dumbbell, 30 rows", show-values: true),
))

#pagebreak()
= Direct labels that find no room: smaller, then thinned, never overlapping

#let slope-n(n) = (labels: range(n).map(i => "Item " + str(i + 1)), start-values: range(n).map(i => calc.rem(i * 37, 61) + 10),
  end-values: range(n).map(i => calc.rem(i * 53, 67) + 25), start-label: "2023", end-label: "2024")
#let fan(n) = (
  nodes: ("Total",) + range(n).map(i => "Destination " + str(i + 1)),
  flows: range(n).map(i => (from: 0, to: i + 1, value: n - i + 2)),
)
#two-col((
  slope-chart(slope-n(20), width: 354pt, height: 150pt, title: "slope, 20 rows: smaller type, every label"),
  slope-chart(slope-n(45), width: 354pt, height: 150pt, title: "slope, 45 rows: labels thinned"),
  waffle-chart((labels: range(12).map(i => "Category " + str(i + 1)), values: range(12).map(i => 12 - i)), size: 120pt, title: "waffle, 12 names: legend"),
  waffle-chart((labels: range(5).map(i => "Cat " + str(i + 1)), values: (40, 30, 15, 10, 5)), size: 90pt, title: "waffle, 5 names in 90pt"),
  sankey-chart(fan(18), width: 354pt, height: 150pt, title: "sankey, 18 outputs in 150pt: smallest left out"),
  sankey-chart(fan(8), width: 354pt, height: 150pt, title: "sankey, 8 outputs"),
))
