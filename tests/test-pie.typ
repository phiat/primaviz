// test-pie.typ — Pie chart tests

#import "../src/lib.typ": *
#import "data.typ": simple-data

#set page(margin: 0.5cm)

= Pie Chart

#pie-chart(simple-data, title: "pie-chart")

#pie-chart(simple-data, title: "pie-chart (donut)", donut: true)

// `radius` is the container corner radius, not the pie geometry
#pie-chart(simple-data, title: "pie-chart (container radius)", radius: 8pt, theme: themes.dark)
