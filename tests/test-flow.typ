// test-flow.typ — Sankey, chord, gantt, timeline tests

#import "../src/lib.typ": *

#set page(margin: 0.5cm)

= Sankey Chart

#sankey-chart(
  (
    nodes: ("Budget", "Salary", "Invest", "Rent", "Food", "Savings", "Stocks", "Bonds"),
    flows: (
      (from: 0, to: 1, value: 5000),
      (from: 0, to: 2, value: 2000),
      (from: 1, to: 3, value: 2000),
      (from: 1, to: 4, value: 1500),
      (from: 1, to: 5, value: 1500),
      (from: 2, to: 6, value: 1200),
      (from: 2, to: 7, value: 800),
    ),
  ),
  width: 400pt,
  height: 250pt,
  title: "Budget Allocation",
)

#sankey-chart(
  (
    nodes: ("Source A", "Source B", "Process", "Output X", "Output Y"),
    flows: (
      (from: 0, to: 2, value: 30),
      (from: 1, to: 2, value: 20),
      (from: 2, to: 3, value: 35),
      (from: 2, to: 4, value: 15),
    ),
  ),
  width: 350pt,
  height: 200pt,
  title: "Sankey (with values)",
  show-values: true,
)

#pagebreak()

= Chord Diagram

#chord-diagram(
  (
    labels: ("A", "B", "C", "D"),
    matrix: (
      (0, 10, 5, 3),
      (8, 0, 7, 2),
      (4, 6, 0, 9),
      (2, 3, 8, 0),
    ),
  ),
  size: 300pt,
  title: "Basic Chord Diagram",
)

#v(12pt)

#chord-diagram(
  (
    labels: ("Sales", "Marketing", "Engineering"),
    matrix: (
      (0, 20, 10),
      (15, 0, 25),
      (5, 12, 0),
    ),
  ),
  size: 250pt,
  arc-width: 20pt,
  gap: 4,
  title: "Department Collaboration",
)

#v(12pt)

// Minimal: two entities
#chord-diagram(
  (
    labels: ("X", "Y"),
    matrix: (
      (0, 50),
      (30, 0),
    ),
  ),
  size: 200pt,
  title: "Two-Entity Chord",
  show-labels: false,
)

#pagebreak()

= Gantt Chart

#gantt-chart(
  (
    tasks: (
      (name: "Research", start: 0, end: 3, group: "Planning"),
      (name: "Design", start: 2, end: 5, group: "Planning"),
      (name: "Backend", start: 4, end: 9, group: "Development"),
      (name: "Frontend", start: 5, end: 10, group: "Development"),
      (name: "Testing", start: 8, end: 12, group: "QA"),
      (name: "Launch", start: 12, end: 13, group: "Release"),
    ),
    time-labels: ("W1", "W2", "W3", "W4", "W5", "W6", "W7", "W8", "W9", "W10", "W11", "W12", "W13"),
  ),
  width: 420pt,
  title: "Project Schedule",
  today: 7,
)

#v(12pt)

#gantt-chart(
  (
    tasks: (
      (name: "Task A", start: 0, end: 3),
      (name: "Task B", start: 2, end: 6),
      (name: "Task C", start: 5, end: 8),
    ),
  ),
  width: 350pt,
  title: "Gantt (no groups, auto labels)",
)

#pagebreak()

= Timeline Chart

#timeline-chart(
  (
    events: (
      (date: "Jan 2024", title: "Project Start", description: "Initial planning phase"),
      (date: "Mar 2024", title: "v0.1 Release", description: "First public beta"),
      (date: "Jun 2024", title: "v0.5 Release", description: "Added 20 chart types"),
      (date: "Sep 2024", title: "v1.0 Launch", description: "Production ready"),
    ),
  ),
  title: "Project Milestones",
)

#v(12pt)

// With categories for color coding
#timeline-chart(
  (
    events: (
      (date: "Week 1", title: "Research", description: "Market analysis", category: "Planning"),
      (date: "Week 3", title: "Design", description: "UI/UX mockups", category: "Planning"),
      (date: "Week 5", title: "Backend", description: "API development", category: "Dev"),
      (date: "Week 8", title: "Frontend", description: "React components", category: "Dev"),
      (date: "Week 10", title: "Testing", description: "QA and bug fixes", category: "QA"),
      (date: "Week 12", title: "Launch", category: "Release"),
    ),
  ),
  width: 400pt,
  event-gap: 55pt,
  marker-size: 14pt,
  title: "Timeline with Categories",
)

#v(12pt)

// Minimal: no descriptions
#timeline-chart(
  (
    events: (
      (date: "2023", title: "Founded"),
      (date: "2024", title: "Series A"),
      (date: "2025", title: "IPO"),
    ),
  ),
  width: 300pt,
  event-gap: 50pt,
  title: "Company History (minimal)",
)
