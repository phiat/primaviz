// line.typ - Line charts (single and multi-series)
#import "../theme.typ": resolve-theme, get-color
#import "../util.typ": normalize-data
#import "../validate.typ": validate-simple-data, validate-series-data
#import "../primitives/container.typ": chart-container
#import "../primitives/axes.typ": draw-grid, draw-axis-titles
#import "../primitives/legend.typ": draw-legend

// Single line chart
#let line-chart(
  data,
  width: 300pt,
  height: 200pt,
  title: none,
  show-points: true,
  show-values: false,
  line-width: 1.5pt,
  point-size: 4pt,
  fill-area: false,
  x-label: none,
  y-label: none,
  theme: none,
) = {
  validate-simple-data(data, "line-chart")
  let t = resolve-theme(theme)
  let norm = normalize-data(data)
  let labels = norm.labels
  let values = norm.values

  let max-val = calc.max(..values)
  let min-val = calc.min(..values)
  let val-range = max-val - min-val
  if val-range == 0 { val-range = 1 }

  let n = values.len()

  chart-container(width, height, title, t, extra-height: 30pt)[
    #let chart-height = height - 20pt
    #let chart-width = width - 50pt

    #box(width: width, height: chart-height)[
      // Grid (no-op by default)
      #draw-grid(40pt, 0pt, chart-width, chart-height, t)

      #place(left + top, line(start: (40pt, 0pt), end: (40pt, chart-height), stroke: t.axis-stroke))
      #place(left + bottom, line(start: (40pt, 0pt), end: (width, 0pt), stroke: t.axis-stroke))

      #let points = ()
      #for (i, val) in values.enumerate() {
        let x = 45pt + (i / (n - 1)) * (chart-width - 10pt)
        let y = chart-height - ((val - min-val) / val-range) * (chart-height - 20pt) - 10pt
        points.push((x, y))
      }

      #for i in array.range(n - 1) {
        let p1 = points.at(i)
        let p2 = points.at(i + 1)
        place(
          left + top,
          line(
            start: (p1.at(0), p1.at(1)),
            end: (p2.at(0), p2.at(1)),
            stroke: line-width + get-color(t, 0),
          )
        )
      }

      #if show-points {
        for (i, pt) in points.enumerate() {
          place(
            left + top,
            dx: pt.at(0) - point-size / 2,
            dy: pt.at(1) - point-size / 2,
            circle(radius: point-size / 2, fill: get-color(t, 0), stroke: white + 1pt)
          )

          if show-values {
            place(
              left + top,
              dx: pt.at(0) - 10pt,
              dy: pt.at(1) - 15pt,
              text(size: t.axis-label-size, fill: t.text-color)[#values.at(i)]
            )
          }
        }
      }

      #for (i, lbl) in labels.enumerate() {
        let x = 45pt + (i / (n - 1)) * (chart-width - 10pt)
        place(
          left + bottom,
          dx: x - 15pt,
          dy: 10pt,
          text(size: t.axis-label-size, fill: t.text-color)[#lbl]
        )
      }

      #for i in array.range(t.tick-count) {
        let fraction = if t.tick-count > 1 { i / (t.tick-count - 1) } else { 0 }
        let y-val = calc.round(min-val + val-range * fraction, digits: 1)
        let y-pos = chart-height - fraction * (chart-height - 20pt) - 10pt
        place(
          left + top,
          dx: 5pt,
          dy: y-pos - 5pt,
          text(size: t.axis-label-size, fill: t.text-color)[#y-val]
        )
      }

      // Axis titles
      #draw-axis-titles(x-label, y-label, 40pt + chart-width / 2, chart-height / 2, t)
    ]
  ]
}

// Multi-series line chart
#let multi-line-chart(
  data,
  width: 300pt,
  height: 200pt,
  title: none,
  show-points: true,
  show-legend: true,
  x-label: none,
  y-label: none,
  theme: none,
) = {
  validate-series-data(data, "multi-line-chart")
  let t = resolve-theme(theme)
  let labels = data.labels
  let series = data.series

  let all-values = series.map(s => s.values).flatten()
  let max-val = calc.max(..all-values)
  let min-val = calc.min(..all-values)
  let val-range = max-val - min-val
  if val-range == 0 { val-range = 1 }

  let n = labels.len()

  chart-container(width, height, title, t, extra-height: 50pt)[
    #let chart-height = height - 20pt
    #let chart-width = width - 50pt

    #box(width: width, height: chart-height)[
      // Grid (no-op by default)
      #draw-grid(40pt, 0pt, chart-width, chart-height, t)

      #place(left + top, line(start: (40pt, 0pt), end: (40pt, chart-height), stroke: t.axis-stroke))
      #place(left + bottom, line(start: (40pt, 0pt), end: (width, 0pt), stroke: t.axis-stroke))

      #for (si, s) in series.enumerate() {
        let values = s.values
        let color = get-color(t, si)

        let points = ()
        for (i, val) in values.enumerate() {
          let x = 45pt + (i / (n - 1)) * (chart-width - 10pt)
          let y = chart-height - ((val - min-val) / val-range) * (chart-height - 20pt) - 10pt
          points.push((x, y))
        }

        for i in array.range(n - 1) {
          let p1 = points.at(i)
          let p2 = points.at(i + 1)
          place(
            left + top,
            line(
              start: (p1.at(0), p1.at(1)),
              end: (p2.at(0), p2.at(1)),
              stroke: 1.5pt + color,
            )
          )
        }

        if show-points {
          for pt in points {
            place(
              left + top,
              dx: pt.at(0) - 3pt,
              dy: pt.at(1) - 3pt,
              circle(radius: 3pt, fill: color, stroke: white + 0.5pt)
            )
          }
        }
      }

      #for (i, lbl) in labels.enumerate() {
        let x = 45pt + (i / (n - 1)) * (chart-width - 10pt)
        place(
          left + bottom,
          dx: x - 15pt,
          dy: 10pt,
          text(size: t.axis-label-size, fill: t.text-color)[#lbl]
        )
      }

      #for i in array.range(t.tick-count) {
        let fraction = if t.tick-count > 1 { i / (t.tick-count - 1) } else { 0 }
        let y-val = calc.round(min-val + val-range * fraction, digits: 1)
        let y-pos = chart-height - fraction * (chart-height - 20pt) - 10pt
        place(
          left + top,
          dx: 5pt,
          dy: y-pos - 5pt,
          text(size: t.axis-label-size, fill: t.text-color)[#y-val]
        )
      }

      // Axis titles
      #draw-axis-titles(x-label, y-label, 40pt + chart-width / 2, chart-height / 2, t)
    ]

    #if show-legend {
      draw-legend(series.map(s => s.name), t, swatch-type: "line")
    }
  ]
}
