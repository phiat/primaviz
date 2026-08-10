// test-scatter.typ — Scatter, multi-scatter, bubble, multi-bubble tests

#import "../src/lib.typ": *
#import "data.typ": scatter-data, multi-scatter-data, bubble-data, multi-bubble-data

#set page(margin: 0.5cm)

= Scatter & Bubble Charts

#scatter-plot(scatter-data, title: "scatter-plot")

#multi-scatter-plot(multi-scatter-data, title: "multi-scatter-plot")

#bubble-chart(bubble-data, title: "bubble-chart")

#multi-bubble-chart(multi-bubble-data, title: "multi-bubble-chart")

#multi-bubble-chart(
  multi-bubble-data,
  width: 350pt, height: 220pt,
  title: "multi-bubble-chart with axis titles",
  x-label: "Quarter", y-label: "Revenue", size-label: "Headcount",
)
