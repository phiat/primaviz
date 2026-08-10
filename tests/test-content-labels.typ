// test-content-labels.typ — Labels and series names given as content, not strings
//
// Labels accept arbitrary content (math, markup) anywhere a string works.
// Every chart here would fail to compile if a label were treated as a string.

#import "../src/lib.typ": *

#set page(margin: 0.5cm)

#let m-labels = ($alpha$, $beta$, $gamma^2$, $delta_i$)
#let m-values = (12, 26, 15, 34)
#let m-simple = (labels: m-labels, values: m-values)
#let m-multi = (
  labels: m-labels,
  series: (
    (name: $x$, values: (12, 26, 15, 34)),
    (name: $y_1$, values: (20, 14, 28, 18)),
  ),
)

= Content Labels

== Bar family

#bar-chart(m-simple, title: [Bar with math labels])

#horizontal-bar-chart(m-simple, title: [Horizontal])

#grouped-bar-chart(m-multi, title: [Grouped])

#stacked-bar-chart(m-multi, title: [Stacked])

#grouped-stacked-bar-chart(
  (
    labels: ($alpha$, $beta$),
    groups: (
      (name: $G_1$, segments: ((name: $a$, values: (10, 20)), (name: $b$, values: (5, 8)))),
      (name: $G_2$, segments: ((name: $a$, values: (12, 18)), (name: $b$, values: (6, 9)))),
    ),
  ),
  title: [Grouped stacked],
)

#pagebreak()

== Line, area, scatter

#line-chart(m-simple, title: [Line])

#multi-line-chart(m-multi, title: [Multi-line])

#area-chart(m-simple, title: [Area])

#stacked-area-chart(m-multi, title: [Stacked area])

#dual-axis-chart(
  (
    labels: m-labels,
    left: (name: $P$, values: (100, 150, 130, 180)),
    right: (name: $Delta%$, values: (10, 15, 12, 18)),
  ),
  title: [Dual axis], left-label: $P$, right-label: $Delta%$,
)

#scatter-plot((x: (1, 2, 3), y: (10, 20, 15)), title: [Scatter], x-label: $x$, y-label: $f(x)$)

#multi-scatter-plot(
  (series: ((name: $S_1$, points: ((1, 2), (3, 4))), (name: $S_2$, points: ((2, 3), (4, 5))))),
  title: [Multi scatter],
)

#bubble-chart((x: (1, 2, 3), y: (10, 20, 15), size: (5, 10, 8)), title: [Bubble])

#multi-bubble-chart(
  (series: ((name: $A$, points: ((1, 10, 5), (2, 20, 10))), (name: $B$, points: ((1.5, 12, 12), (2.5, 18, 6))))),
  title: [Multi bubble],
)

#pagebreak()

== Part-to-whole

#pie-chart(m-simple, title: [Pie])

#pie-chart(m-simple, title: [Donut], donut: true)

#waffle-chart((labels: ($alpha$, $beta$, $gamma$), values: (45, 30, 25)), title: [Waffle])

#treemap((labels: m-labels, values: m-values), title: [Treemap])

#sunburst-chart(
  (
    name: $Sigma$,
    value: 100,
    children: (
      (name: $A$, value: 60, children: ((name: $A_1$, value: 35), (name: $A_2$, value: 25))),
      (name: $B$, value: 40),
    ),
  ),
  title: [Sunburst],
)

#funnel-chart((labels: m-labels, values: (100, 70, 40, 20)), title: [Funnel])

#parliament-chart((labels: ($alpha$, $beta$, $gamma$), values: (120, 95, 70)), title: [Parliament])

#radial-bar-chart(m-simple, title: [Radial bar])

#pagebreak()

== Comparison and statistical

#lollipop-chart(m-simple, title: [Lollipop])

#horizontal-lollipop-chart(m-simple, title: [Horizontal lollipop])

#waterfall-chart((labels: m-labels, values: (100, -30, 45, -20)), title: [Waterfall])

#diverging-bar-chart(
  (labels: m-labels, left-values: (45, 30, 60, 25), right-values: (55, 70, 40, 75),
   left-label: $-$, right-label: $+$),
  title: [Diverging],
)

#slope-chart(
  (labels: m-labels, start-values: (85, 70, 60, 45), end-values: (65, 90, 55, 80),
   start-label: $t_0$, end-label: $t_1$),
  title: [Slope],
)

#dumbbell-chart(
  (labels: m-labels, start-values: (85, 70, 60, 45), end-values: (65, 90, 55, 80),
   start-label: $t_0$, end-label: $t_1$),
  title: [Dumbbell],
)

#bump-chart(
  (labels: m-labels, series: ((name: $T_1$, values: (1, 2, 1, 3)), (name: $T_2$, values: (3, 1, 2, 1)))),
  title: [Bump],
)

#box-plot(
  (labels: m-labels, boxes: (
    (min: 1, q1: 3, median: 5, q3: 7, max: 9),
    (min: 2, q1: 4, median: 6, q3: 8, max: 10),
    (min: 0, q1: 2, median: 4, q3: 6, max: 8),
    (min: 3, q1: 5, median: 7, q3: 9, max: 11),
  )),
  title: [Box plot],
)

#violin-plot(
  (labels: ($alpha$, $beta$), datasets: ((1, 2, 3, 4, 5, 4, 3), (2, 3, 4, 5, 6, 5, 4))),
  title: [Violin],
)

#radar-chart((labels: m-labels, series: ((name: $S$, values: (5, 8, 6, 7)),)), title: [Radar])

#pagebreak()

== Matrix, flow, time

#heatmap(
  (rows: ($r_1$, $r_2$), cols: ($c_1$, $c_2$), values: ((1, 2), (3, 4))),
  title: [Heatmap],
)

#correlation-matrix((labels: ($x$, $y$), values: ((1.0, 0.5), (0.5, 1.0))), title: [Correlation])

#sankey-chart(
  (nodes: ($S$, $A$, $B$), flows: ((from: 0, to: 1, value: 30), (from: 0, to: 2, value: 20))),
  title: [Sankey],
)

#chord-diagram((labels: ($A$, $B$, $C$), matrix: ((0, 10, 5), (8, 0, 7), (4, 6, 0))), title: [Chord])

#gantt-chart(
  (tasks: ((name: $tau_1$, start: 0, end: 3, group: $P$), (name: $tau_2$, start: 2, end: 6, group: $P$)),
   time-labels: ($w_1$, $w_2$, $w_3$, $w_4$, $w_5$, $w_6$)),
  title: [Gantt],
)

#timeline-chart(
  (events: (
    (date: $t_0$, title: [Start], description: [Phase $0$], category: $P$),
    (date: $t_1$, title: [End], category: $Q$),
  )),
  title: [Timeline],
)

#word-cloud((words: ((text: $alpha$, weight: 10), (text: $beta$, weight: 6), (text: $gamma$, weight: 3))), title: [Word cloud])

#pagebreak()

== Progress and single-value

#gauge-chart(72, title: [Gauge], label: $%$)

#progress-bar(60, title: [Progress $eta$])

#progress-bars((labels: ($alpha$, $beta$), values: (0.6, 0.3)), title: [Progress bars])

#circular-progress(75, title: [Circular $rho$])

#ring-progress(((name: $A$, value: 8, max: 10), (name: $B$, value: 5, max: 10)), title: [Rings])

#bullet-chart(275, 250, (150, 225, 300), title: [Bullet $R$], label: $K$)

#metric-card(value: 1234, label: $R$, delta: 12.5)

#metric-row(((value: 1234, label: $R$, delta: 12.5), (value: 42, label: $N$)))

#histogram((2.1, 3.5, 4.2, 5.1, 5.7, 6.2, 6.8, 7.3, 7.8, 8.2), title: [Histogram], x-label: $x$, y-label: $n$)

#sparkline((4, 7, 2, 9, 5))
