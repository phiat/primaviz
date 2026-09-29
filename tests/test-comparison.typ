// test-comparison.typ — Bump, slope, dumbbell, diverging, lollipop tests

#import "../src/lib.typ": *
#import "data.typ": simple-data

#set page(margin: 0.5cm)

= Lollipop Charts

#lollipop-chart(simple-data, title: "lollipop-chart")

#lollipop-chart(
  (labels: ("Mon", "Tue", "Wed", "Thu", "Fri"), values: (12, 28, 19, 35, 22)),
  width: 350pt,
  height: 200pt,
  title: "Weekly Activity",
  dot-size: 5pt,
  stem-width: 2pt,
  x-label: "Day",
  y-label: "Count",
)

#horizontal-lollipop-chart(simple-data, title: "horizontal-lollipop-chart")

#horizontal-lollipop-chart(
  (labels: ("Alpha", "Beta", "Gamma", "Delta"), values: (40, 25, 60, 35)),
  width: 400pt,
  height: 200pt,
  title: "Horizontal Lollipop (custom)",
  dot-size: 6pt,
  stem-width: 2pt,
  x-label: "Score",
  y-label: "Group",
)

#pagebreak()

= Bullet Charts

#bullet-chart(275, 250, (150, 225, 300), title: "Revenue ($K)")

#v(12pt)

#bullet-chart(82, 90, (60, 80, 100), title: "Satisfaction", label: "out of 100")

#v(12pt)

#bullet-charts(
  (bullets: (
    (value: 275, target: 250, ranges: (150, 225, 300), title: "Revenue ($K)"),
    (value: 82, target: 90, ranges: (60, 80, 100), title: "Satisfaction (%)"),
    (value: 45, target: 50, ranges: (25, 40, 60), title: "New Customers"),
  )),
  width: 350pt,
  bar-height: 25pt,
  gap: 15pt,
  title: "KPI Dashboard",
)

#v(12pt)

#bullet-chart(0, 50, (30, 60, 100), title: "Zero value")

#v(12pt)

#bullet-chart(120, 80, (30, 60, 100), title: "Over max")

#pagebreak()

= Slope Chart

#slope-chart(
  (
    labels: ("Company A", "Company B", "Company C", "Company D"),
    start-values: (85, 70, 60, 45),
    end-values: (65, 90, 55, 80),
    start-label: "2023",
    end-label: "2024",
  ),
  width: 300pt,
  height: 250pt,
  title: "Market Position Change",
)

#slope-chart(
  (
    labels: ("Alpha", "Beta", "Gamma"),
    start-values: (50, 50, 50),
    end-values: (80, 30, 50),
    start-label: "Before",
    end-label: "After",
  ),
  width: 280pt,
  height: 200pt,
  title: "Slope (equal start)",
  show-values: false,
)

#pagebreak()

= Diverging Bar Chart

#let diverging-data = (
  labels: ("Product A", "Product B", "Product C", "Product D"),
  left-values: (45, 30, 60, 25),
  right-values: (55, 70, 40, 75),
  left-label: "Disagree",
  right-label: "Agree",
)

#diverging-bar-chart(
  diverging-data,
  width: 400pt,
  height: 200pt,
  title: "Survey Results",
)

#v(12pt)

#diverging-bar-chart(
  (
    labels: ("Male", "Female"),
    left-values: (100, 90),
    right-values: (95, 105),
    left-label: "2020",
    right-label: "2025",
  ),
  width: 350pt,
  height: 150pt,
  title: "Population Pyramid",
  bar-height: 0.8,
)

#v(12pt)

// Without legend (no left-label/right-label)
#diverging-bar-chart(
  (
    labels: ("A", "B", "C"),
    left-values: (10, 20, 30),
    right-values: (30, 20, 10),
  ),
  title: "No Legend Variant",
  show-values: false,
)

#pagebreak()

= Bump Chart

#bump-chart(
  (
    labels: ("2020", "2021", "2022", "2023", "2024"),
    series: (
      (name: "Team A", values: (1, 2, 1, 3, 2)),
      (name: "Team B", values: (3, 1, 2, 1, 1)),
      (name: "Team C", values: (2, 3, 3, 2, 3)),
    ),
  ),
  width: 400pt,
  height: 250pt,
  title: "F1 Championship Positions",
)

#v(12pt)

#bump-chart(
  (
    labels: ("Q1", "Q2", "Q3", "Q4"),
    series: (
      (name: "Alpha", values: (1, 1, 2, 1)),
      (name: "Beta", values: (2, 3, 1, 2)),
      (name: "Gamma", values: (3, 2, 3, 3)),
    ),
  ),
  width: 350pt,
  height: 200pt,
  title: "Bump Chart (no labels)",
  show-labels: false,
  dot-size: 6pt,
  line-width: 3pt,
)

#pagebreak()

= Dumbbell Chart

#dumbbell-chart(
  (
    labels: ("Revenue", "Costs", "Profit", "Headcount"),
    start-values: (100, 80, 20, 50),
    end-values: (150, 70, 80, 65),
    start-label: "2023",
    end-label: "2024",
  ),
  width: 400pt,
  height: 200pt,
  title: "Year-over-Year Comparison",
  show-values: true,
)

#v(12pt)

#dumbbell-chart(
  (
    labels: ("Math", "Science", "English"),
    start-values: (70, 70, 70),
    end-values: (85, 60, 90),
    start-label: "Pre-test",
    end-label: "Post-test",
  ),
  width: 350pt,
  height: 180pt,
  title: "Dumbbell (no values)",
  dot-size: 12pt,
)

#v(12pt)

// Equal values edge case
#dumbbell-chart(
  (
    labels: ("A", "B"),
    start-values: (50, 50),
    end-values: (50, 50),
  ),
  width: 300pt,
  height: 120pt,
  title: "Dumbbell (equal values)",
)
