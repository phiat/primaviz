// sparkline.typ - Tiny inline charts for tables and running text
#import "../theme.typ": resolve-theme, get-color

// Sparkline: tiny line chart, no axes, no labels
#let sparkline(
  values,
  width: 60pt,
  height: 15pt,
  color: none,
  show-endpoint: true,
  fill-area: false,
  stroke-width: 1pt,
  theme: none,
) = {
  let t = resolve-theme(theme)
  let c = if color != none { color } else { get-color(t, 0) }
  let n = values.len()

  if n == 0 {
    box(width: width, height: height, baseline: -3pt)
  } else if n == 1 {
    // Single value: just a dot in the center
    box(width: width, height: height, baseline: -3pt)[
      #place(left + top, dx: width / 2 - 2pt, dy: height / 2 - 2pt,
        circle(radius: 2pt, fill: c, stroke: none))
    ]
  } else {
    let min-val = calc.min(..values)
    let max-val = calc.max(..values)
    let val-range = max-val - min-val
    // Avoid division by zero when all values are the same
    let val-range = if val-range == 0 { 1 } else { val-range }

    // Compute points: x evenly spaced, y scaled
    let points = ()
    for i in array.range(n) {
      let x = if n == 1 { width / 2 } else { (i / (n - 1)) * width }
      let y = height - ((values.at(i) - min-val) / val-range) * height
      points.push((x, y))
    }

    box(width: width, height: height, baseline: -3pt)[
      // Fill area beneath the line
      #if fill-area {
        let fill-points = ()
        // Start at bottom-left
        fill-points.push((0pt, height))
        for pt in points {
          fill-points.push((pt.at(0), pt.at(1)))
        }
        // End at bottom-right
        fill-points.push((width, height))
        place(left + top,
          polygon(fill: c.transparentize(70%), stroke: none, ..fill-points))
      }
      // Draw line segments
      #for i in array.range(n - 1) {
        let p1 = points.at(i)
        let p2 = points.at(i + 1)
        place(left + top,
          line(
            start: (p1.at(0), p1.at(1)),
            end: (p2.at(0), p2.at(1)),
            stroke: stroke-width + c,
          ))
      }
      // Endpoint dot
      #if show-endpoint {
        let last = points.at(n - 1)
        place(left + top, dx: last.at(0) - 2pt, dy: last.at(1) - 2pt,
          circle(radius: 2pt, fill: c, stroke: none))
      }
    ]
  }
}

// Sparkbar: tiny bar chart
#let sparkbar(
  values,
  width: 60pt,
  height: 15pt,
  color: none,
  gap: 1pt,
  theme: none,
) = {
  let t = resolve-theme(theme)
  let c = if color != none { color } else { get-color(t, 0) }
  let n = values.len()

  if n == 0 {
    box(width: width, height: height, baseline: -3pt)
  } else {
    let max-val = calc.max(..values)
    let max-val = if max-val == 0 { 1 } else { max-val }
    let bar-width = (width - gap * (n - 1)) / n

    box(width: width, height: height, baseline: -3pt)[
      #for i in array.range(n) {
        let bar-height = (values.at(i) / max-val) * height
        let x = i * (bar-width + gap)
        let y = height - bar-height
        place(left + top, dx: x, dy: y,
          rect(width: bar-width, height: bar-height, fill: c, stroke: none))
      }
    ]
  }
}

// Sparkdot: tiny dot/scatter chart
#let sparkdot(
  values,
  width: 60pt,
  height: 15pt,
  color: none,
  dot-size: 2.5pt,
  theme: none,
) = {
  let t = resolve-theme(theme)
  let c = if color != none { color } else { get-color(t, 0) }
  let n = values.len()

  if n == 0 {
    box(width: width, height: height, baseline: -3pt)
  } else {
    let min-val = calc.min(..values)
    let max-val = calc.max(..values)
    let val-range = max-val - min-val
    let val-range = if val-range == 0 { 1 } else { val-range }

    box(width: width, height: height, baseline: -3pt)[
      #for i in array.range(n) {
        let x = if n == 1 { width / 2 } else { (i / (n - 1)) * width }
        let y = height - ((values.at(i) - min-val) / val-range) * height
        let is-last = i == n - 1
        let r = if is-last { dot-size * 1.3 } else { dot-size }
        let dot-color = if is-last { c.darken(20%) } else { c }
        place(left + top, dx: x - r, dy: y - r,
          circle(radius: r, fill: dot-color, stroke: none))
      }
    ]
  }
}
