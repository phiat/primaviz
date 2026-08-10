// test-options.typ — Option combos: show-values, density, etc.

#import "../src/lib.typ": *
#import "data.typ": simple-data, multi-data

#set page(margin: 0.5cm)

= Option Combinations

== Bar chart options
#bar-chart(simple-data, width: 250pt, height: 150pt, show-values: true, title: "values", theme: (show-grid: true))
#bar-chart(simple-data, width: 250pt, height: 150pt, show-values: false, title: "no values, no grid")

== Line chart options
#line-chart(simple-data, width: 250pt, height: 150pt, show-points: false, fill-area: true, title: "fill, no points")
#line-chart(simple-data, width: 250pt, height: 150pt, show-points: true, show-values: true, title: "points + values")
#line-chart(simple-data, width: 250pt, height: 150pt, fill-area: true, fill-opacity: 80%, title: "fill, custom opacity")
#line-chart(simple-data, width: 250pt, height: 150pt, fill-area: true, line-interpolation: "catmull-rom", title: "fill follows the curve")
#line-chart(
  (labels: ("A", "B", "C", "D"), values: (20, -15, 30, -5)),
  width: 250pt, height: 150pt, fill-area: true, title: "fill across zero",
)

== Histogram options
#histogram(
  (2.1, 3.5, 5.1, 5.7, 6.2, 7.1, 8.0, 9.0),
  width: 250pt, height: 150pt, density: true, show-values: true, title: "density + values",
)

== Box plot options
#box-plot(
  (labels: ("A", "B"), boxes: (
    (min: 10, q1: 25, median: 35, q3: 50, max: 70),
    (min: 15, q1: 30, median: 42, q3: 55, max: 65),
  )),
  width: 250pt, height: 150pt, show-values: true, show-grid: true, title: "values + grid",
)

== Violin plot options
#violin-plot(
  (labels: ("A",), datasets: ((2, 3, 4, 5, 6, 7, 8),)),
  width: 200pt, height: 150pt, show-box: false, show-grid: false, title: "no box, no grid",
)

== Legend position: none
#multi-line-chart(multi-data, width: 250pt, height: 150pt, title: "legend-position: none", theme: (legend-position: "none"))

== Waterfall with types
#waterfall-chart(
  (labels: ("Start", "+A", "-B", "Sub", "+C", "Total"),
   values: (100, 50, -30, 120, 40, 160),
   types: ("total", "pos", "neg", "subtotal", "pos", "total")),
  width: 300pt, height: 150pt, title: "explicit types",
)
