// test-line.typ — Line chart tests

#import "../src/lib.typ": *
#import "data.typ": simple-data, multi-data

#set page(margin: 0.5cm)

= Line Charts

#line-chart(simple-data, title: "line-chart")

#line-chart(simple-data, title: "line-chart smooth", line-interpolation: "smooth")

#line-chart(simple-data, title: "line-chart catmull-rom", line-interpolation: "catmull-rom")

// Thick linear stroke without markers — segments must join, not show notches
#line-chart(simple-data, title: "line-chart thick linear, no points", show-points: false, line-width: 6pt)

#multi-line-chart(multi-data, title: "multi-line-chart")

#multi-line-chart(multi-data, title: "multi-line-chart smooth", line-interpolation: "smooth")

#multi-line-chart(multi-data, title: "multi-line-chart catmull-rom", line-interpolation: "catmull-rom")

#let dual-data = (
  labels: ("Q1", "Q2", "Q3", "Q4"),
  left: (name: "Revenue", values: (100, 150, 130, 180)),
  right: (name: "Growth %", values: (10, 15, 12, 18)),
)

#dual-axis-chart(
  dual-data,
  width: 400pt,
  height: 250pt,
  title: "dual-axis-chart",
  left-label: "Revenue ($)",
  right-label: "Growth (%)",
  x-label: "Quarter",
  show-grid: true,
)
