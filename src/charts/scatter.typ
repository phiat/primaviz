// scatter.typ - Scatter plot and bubble chart
#import "../theme.typ": _resolve-ctx, get-color
#import "../util.typ": nonzero, label-len
#import "../primitives/layout.typ": try-fit-label, greedy-deconflict, resolve-size
#import "../validate.typ": validate-scatter-data, validate-multi-scatter-data, validate-bubble-data, validate-multi-bubble-data
#import "../primitives/frame.typ": cartesian-frame
#import "../primitives/axes.typ": value-axis
#import "../primitives/legend.typ": draw-legend-auto, draw-size-legend

// Both axes of an x-y chart. `inset` keeps marks centred on the extreme values
// inside the plot instead of cutting or shifting them.
#let _xy-axes(points, inset, x-label, y-label) = {
  let xs = points.map(p => p.at(0))
  let ys = points.map(p => p.at(1))
  (
    x: value-axis(calc.min(..xs), calc.max(..xs), title: x-label, inset: inset),
    y: value-axis(calc.min(..ys), calc.max(..ys), title: y-label, inset: inset),
  )
}

// Resolves the theme with the chart's own `show-grid` override applied.
#let _scatter-theme(theme, show-grid) = _resolve-ctx(theme, overrides: if show-grid != auto { (show-grid: show-grid) } else { none })

// Radius bubbles are drawn at: the largest bubble never takes over the plot.
#let _bubble-radii(max-radius, min-radius, width, height) = {
  let hi = calc.min(max-radius, height * 0.2, width * 0.12)
  (hi: hi, lo: calc.min(min-radius, hi * 0.3))
}

// Size legend below a bubble chart: three reference circles.
#let _bubble-size-legend(size-label, size-max, max-radius, t) = if size-label != none {
  let ref-sizes = (
    (size-max, str(calc.round(size-max))),
    (calc.round(size-max * 0.5), str(calc.round(size-max * 0.5))),
    (calc.round(size-max * 0.15), str(calc.round(size-max * 0.15))),
  )
  draw-size-legend(ref-sizes, max-radius, size-max, t, title: size-label)
}

/// Renders a scatter plot of x-y data points.
///
/// - data (array, dictionary): Array of `(x, y)` tuples or dict with `x` and `y` arrays
/// - width (length): Chart width
/// - height (length): Chart height
/// - title (none, content): Optional chart title
/// - x-label (none, content): X-axis title
/// - y-label (none, content): Y-axis title
/// - point-size (length): Diameter of point markers
/// - show-grid (auto, bool): Draw background grid lines; `auto` uses theme default
/// - color (none, color): Override point color
/// - annotations (none, array): Optional annotation descriptors
/// - show-ticks (bool): Draw tick marks on the axis lines
/// - show-minor-grid (bool): Draw lighter minor grid lines between the major ones
/// - subtitle (none, content): Optional subtitle below the title
/// - radius (length): Corner radius of the chart container
/// - theme (none, dictionary): Theme overrides
/// -> content
#let scatter-plot(
  data,
  width: auto,
  height: auto,
  title: none,
  x-label: none,
  y-label: none,
  point-size: 5pt,
  show-grid: auto,
  color: none,
  annotations: none,
  show-ticks: false,
  show-minor-grid: false,
  subtitle: none,
  radius: 0pt,
  theme: none,
) = context {
  layout(size => {
  validate-scatter-data(data, "scatter-plot")
  let t = _scatter-theme(theme, show-grid)
  let (width, height) = resolve-size(width, height, size, n: 10, theme: t)
  let points = if type(data) == dictionary { data.x.zip(data.y) } else { data }
  let point-color = if color != none { color } else { get-color(t, 0) }
  let axes = _xy-axes(points, point-size / 2 + 1pt, x-label, y-label)

  cartesian-frame(width, height, t, x: axes.x, y: axes.y,
    title: title, subtitle: subtitle, radius: radius, annotations: annotations,
    show-ticks: show-ticks, show-minor-grid: show-minor-grid,
    p => {
      for pt in points {
        place(left + top, dx: (p.px)(pt.at(0)) - point-size / 2, dy: (p.py)(pt.at(1)) - point-size / 2,
          circle(radius: point-size / 2, fill: point-color, stroke: t.marker-stroke))
      }
    },
  )
  })
}

/// Renders a multi-series scatter plot with color-coded point groups.
///
/// - data (dictionary): Dict with `series` array, each containing `name` and `points` (array of `(x, y)`)
/// - width (length): Chart width
/// - height (length): Chart height
/// - title (none, content): Optional chart title
/// - x-label (none, content): X-axis title
/// - y-label (none, content): Y-axis title
/// - point-size (length): Diameter of point markers
/// - show-grid (auto, bool): Draw background grid lines; `auto` uses theme default
/// - show-legend (bool): Show series legend
/// - annotations (none, array): Optional annotation descriptors
/// - theme (none, dictionary): Theme overrides
/// - extra-legend-separation (length): Extra space between legend and chart
/// -> content
#let multi-scatter-plot(
  data,
  width: auto,
  height: auto,
  title: none,
  x-label: none,
  y-label: none,
  point-size: 5pt,
  show-grid: auto,
  show-legend: true,
  annotations: none,
  extra-legend-separation: 0pt,
  theme: none,
) = context {
  layout(size => {
  validate-multi-scatter-data(data, "multi-scatter-plot")
  let t = _scatter-theme(theme, show-grid)
  let (width, height) = resolve-size(width, height, size, n: 10, theme: t)
  let series = data.series
  let axes = _xy-axes(series.map(s => s.points).join(), point-size / 2 + 1pt, x-label, y-label)

  cartesian-frame(width, height, t, x: axes.x, y: axes.y,
    title: title, annotations: annotations, extra-legend-separation: extra-legend-separation,
    legend: draw-legend-auto(series.map(s => s.name), t, show-legend: show-legend, swatch-type: "circle", fit-width: true),
    p => {
      for (si, s) in series.enumerate() {
        for pt in s.points {
          place(left + top, dx: (p.px)(pt.at(0)) - point-size / 2, dy: (p.py)(pt.at(1)) - point-size / 2,
            circle(radius: point-size / 2, fill: get-color(t, si), stroke: t.marker-stroke))
        }
      }
    },
  )
  })
}

/// Renders a bubble chart where each point has an x, y, and size dimension.
///
/// - data (array, dictionary): Array of `(x, y, size)` tuples or dict with `x`, `y`, `size` arrays
/// - width (length): Chart width
/// - height (length): Chart height
/// - title (none, content): Optional chart title
/// - x-label (none, content): X-axis title
/// - y-label (none, content): Y-axis title
/// - min-radius (length): Minimum bubble radius
/// - max-radius (length): Maximum bubble radius
/// - show-grid (auto, bool): Draw background grid lines; `auto` uses theme default
/// - color (none, color): Override bubble color
/// - show-labels (bool): Display text labels on bubbles
/// - labels (none, array): Array of label strings for each bubble
/// - size-label (none, content): Title for the bubble size legend; `none` hides the legend
/// - annotations (none, array): Optional annotation descriptors
/// - theme (none, dictionary): Theme overrides
/// -> content
#let bubble-chart(
  data,
  width: auto,
  height: auto,
  title: none,
  x-label: none,
  y-label: none,
  size-label: none,
  min-radius: 5pt,
  max-radius: 30pt,
  show-grid: auto,
  color: none,
  show-labels: false,
  labels: none,
  annotations: none,
  theme: none,
) = context {
  layout(size => {
  validate-bubble-data(data, "bubble-chart")
  let t = _scatter-theme(theme, show-grid)
  let (width, height) = resolve-size(width, height, size, n: 10, theme: t)
  let points = if type(data) == dictionary {
    data.x.zip(data.y).zip(data.size).map(p => (p.at(0).at(0), p.at(0).at(1), p.at(1)))
  } else { data }
  let sizes = points.map(p => p.at(2))
  let (size-min, size-max) = (calc.min(..sizes), calc.max(..sizes))
  let size-range = nonzero(size-max - size-min)
  let bubble-color = if color != none { color } else { get-color(t, 0) }
  let r = _bubble-radii(max-radius, min-radius, width, height)
  let axes = _xy-axes(points, r.hi + 1pt, x-label, y-label)

  cartesian-frame(width, height, t, x: axes.x, y: axes.y,
    title: title, annotations: annotations,
    legend: _bubble-size-legend(size-label, size-max, max-radius, t),
    p => {
      let (px, py) = (p.px, p.py)
      let bounds = (left: p.x0, right: p.x1, top: p.y0, bottom: p.y1)
      let computed = points.enumerate().map(((i, pt)) => (
        i: i, px: px(pt.at(0)), py: py(pt.at(1)),
        radius: r.lo + ((pt.at(2) - size-min) / size-range) * (r.hi - r.lo),
      ))

      for b in computed {
        place(left + top, dx: b.px - b.radius, dy: b.py - b.radius,
          circle(radius: b.radius, fill: bubble-color.transparentize(40%), stroke: bubble-color + 1.5pt))
      }

      // Labels: inside the bubble when they fit, otherwise beside it with a leader
      if show-labels and labels != none {
        let lbl-size = t.axis-label-size
        let lbl-h = lbl-size * 1.4
        let (inside, outside) = ((), ())
        for b in computed {
          if b.i >= labels.len() { continue }
          let lbl = labels.at(b.i)
          let lbl-len = label-len(lbl)
          let fit = try-fit-label(b.radius * 2, b.radius * 2, lbl-size, lbl-len)
          if fit.fits {
            inside.push((px: b.px, py: b.py, radius: b.radius, lbl: lbl, size: fit.size))
          } else {
            let lbl-w = calc.max(40pt, lbl-size * 0.6 * lbl-len + 4pt)
            // Beside the bubble, away from the plot centre; above or below by half
            let lx = if b.px >= (p.x0 + p.x1) / 2 { b.px + 4pt } else { b.px - lbl-w - 4pt }
            let ly = if b.py <= (p.y0 + p.y1) / 2 { b.py + b.radius + 4pt } else { b.py - b.radius - lbl-h - 4pt }
            outside.push((cx: b.px, cy: b.py, radius: b.radius, lx: lx, ly: ly, w: lbl-w, h: lbl-h, lbl: lbl))
          }
        }

        for il in inside {
          let lbl-w = calc.max(il.radius * 2, il.size * 0.6 * label-len(il.lbl) + 4pt)
          place(left + top, dx: il.px - lbl-w / 2, dy: il.py - il.size * 0.7,
            box(width: lbl-w, height: il.size * 1.4,
              align(center + horizon, text(size: il.size, fill: t.text-color, weight: "bold")[#il.lbl])))
        }
        for ol in greedy-deconflict(outside, bounds) {
          // Leader from the bubble edge toward the label centre
          let (ax, ay) = (ol.lx + ol.w / 2, ol.ly + ol.h / 2)
          let (dx, dy) = ((ax - ol.cx) / 1pt, (ay - ol.cy) / 1pt)
          let dist = calc.max(1.0, calc.sqrt(dx * dx + dy * dy))
          place(left + top, line(
            start: (ol.cx + dx / dist * ol.radius, ol.cy + dy / dist * ol.radius), end: (ax, ay),
            stroke: 0.5pt + t.text-color-light))
          place(left + top, dx: ol.lx, dy: ol.ly,
            box(width: ol.w, align(center, text(size: lbl-size, fill: t.text-color, weight: "bold")[#ol.lbl])))
        }
      }
    },
  )
  })
}

/// Renders a multi-series bubble chart with color-coded point groups and
/// per-point size dimension.
///
/// - data (dictionary): Dict with `series` array, each containing `name` and
///   `points` (array of `(x, y, size)` tuples)
/// - width (length): Chart width
/// - height (length): Chart height
/// - title (none, content): Optional chart title
/// - x-label (none, content): X-axis title
/// - y-label (none, content): Y-axis title
/// - min-radius (length): Minimum bubble radius
/// - max-radius (length): Maximum bubble radius
/// - show-grid (auto, bool): Draw background grid lines; `auto` uses theme default
/// - show-legend (bool): Show series legend
/// - size-label (none, content): Title for the bubble size legend; `none` hides the legend
/// - annotations (none, array): Optional annotation descriptors
/// - theme (none, dictionary): Theme overrides
/// -> content
#let multi-bubble-chart(
  data,
  width: auto,
  height: auto,
  title: none,
  x-label: none,
  y-label: none,
  size-label: none,
  min-radius: 4pt,
  max-radius: 25pt,
  show-grid: auto,
  show-legend: true,
  annotations: none,
  theme: none,
) = context {
  layout(size => {
  validate-multi-bubble-data(data, "multi-bubble-chart")
  let t = _scatter-theme(theme, show-grid)
  let (width, height) = resolve-size(width, height, size, n: 10, theme: t)
  let series = data.series
  let points = series.map(s => s.points).join()
  let sizes = points.map(p => p.at(2))
  let (size-min, size-max) = (calc.min(..sizes), calc.max(..sizes))
  let size-range = nonzero(size-max - size-min)
  let r = _bubble-radii(max-radius, min-radius, width, height)
  let axes = _xy-axes(points, r.hi + 1pt, x-label, y-label)
  let series-legend = draw-legend-auto(series.map(s => s.name), t, show-legend: show-legend, swatch-type: "circle", fit-width: true)

  cartesian-frame(width, height, t, x: axes.x, y: axes.y,
    title: title, annotations: annotations,
    legend: { series-legend; _bubble-size-legend(size-label, size-max, max-radius, t) },
    p => {
      for (si, s) in series.enumerate() {
        let color = get-color(t, si)
        for pt in s.points {
          let rad = r.lo + ((pt.at(2) - size-min) / size-range) * (r.hi - r.lo)
          place(left + top, dx: (p.px)(pt.at(0)) - rad, dy: (p.py)(pt.at(1)) - rad,
            circle(radius: rad, fill: color.transparentize(40%), stroke: color + 1.5pt))
        }
      }
    },
  )
  })
}
