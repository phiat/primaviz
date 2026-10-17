// boxplot.typ - Box-and-whisker plot
#import "../theme.typ": _resolve-ctx, get-color
#import "../validate.typ": validate-boxplot-data
#import "../primitives/frame.typ": cartesian-frame
#import "../primitives/axes.typ": value-axis, category-axis, spread-positions, value-text
#import "../primitives/layout.typ": resolve-size

/// Renders a box-and-whisker plot for comparing distributions.
///
/// - data (dictionary): Dict with `labels` and `boxes` (each with `min`, `q1`, `median`, `q3`, `max`,
///   and optional `outliers` array of values outside the whiskers)
/// - width (length): Chart width
/// - height (length): Chart height
/// - title (none, content): Optional chart title
/// - box-width (float): Box width as fraction of slot (0 to 1)
/// - show-values (bool): Display five-number summary labels beside each box. Where boxes sit
///   too close for all five, the labels shrink (to a legible floor), then thin out to the
///   median and extremes, then to the median alone, then none: they never touch a box or each other
/// - show-grid (auto, bool): Draw background grid lines; `auto` uses theme default
/// - stroke-width (auto, length): Stroke width for box outlines and whiskers; `auto` uses the theme's `stroke-mid`
/// - outlier-radius (length): Radius of outlier marker dots
/// - include-zero (bool): Extend the value axis to include zero; off by default so the axis fits the data
/// - x-label (none, content): X-axis title
/// - y-label (none, content): Y-axis title
/// - annotations (none, array): Optional annotation descriptors (see annotations.typ)
/// - theme (none, dictionary): Theme overrides
/// -> content
#let box-plot(
  data,
  width: auto,
  height: auto,
  title: none,
  box-width: 0.5,
  show-values: false,
  show-grid: auto,
  stroke-width: auto,
  outlier-radius: 2pt,
  include-zero: false,
  x-label: none,
  y-label: none,
  annotations: none,
  theme: none,
) = context {
  layout(size => {
  validate-boxplot-data(data, "box-plot")
  let grid-overrides = if show-grid != auto { (show-grid: show-grid) } else { none }
  let t = _resolve-ctx(theme, overrides: grid-overrides)
  let stroke-width = if stroke-width == auto { t.stroke-mid } else { stroke-width }
  let (width, height) = resolve-size(width, height, size, n: data.labels.len(), theme: t)
  let (labels, boxes) = (data.labels, data.boxes)

  // The axis covers every whisker and outlier. Box plots compare spreads, so by
  // default it fits the data rather than stretching down to a zero baseline.
  let extremes = boxes.map(b => (b.min, b.max, ..b.at("outliers", default: ()))).flatten()
  let (lo, hi) = (calc.min(..extremes), calc.max(..extremes))
  let (lo, hi) = if include-zero { (calc.min(0, lo), calc.max(0, hi)) } else { (lo, hi) }

  cartesian-frame(width, height, t,
    x: category-axis(labels, title: x-label),
    y: value-axis(lo, hi, title: y-label),
    title: title, annotations: annotations,
    p => {
      let (px, py) = (p.px, p.py)
      let half-box = p.X.pitch * box-width / 2
      let half-cap = half-box / 2
      for (i, b) in boxes.enumerate() {
        let cx = px(i)
        let color = get-color(t, i)
        let whisker = stroke-width + color
        let (y-min, y-q1, y-med, y-q3, y-max) = (b.min, b.q1, b.median, b.q3, b.max).map(py)

        // Whiskers (min to q1, q3 to max) with a cap at each end
        place(left + top, line(start: (cx, y-min), end: (cx, y-q1), stroke: whisker))
        place(left + top, line(start: (cx, y-q3), end: (cx, y-max), stroke: whisker))
        for y in (y-min, y-max) {
          place(left + top, line(start: (cx - half-cap, y), end: (cx + half-cap, y), stroke: whisker))
        }

        // Box from q1 to q3, with the median across it
        place(left + top, dx: cx - half-box, dy: y-q3,
          rect(width: half-box * 2, height: y-q1 - y-q3, fill: color.transparentize(20%), stroke: whisker))
        place(left + top, line(start: (cx - half-box, y-med), end: (cx + half-box, y-med),
          stroke: stroke-width * 2 + t.text-color-inverse))

        for o in b.at("outliers", default: ()) {
          place(left + top, dx: cx - outlier-radius, dy: py(o) - outlier-radius,
            circle(radius: outlier-radius, fill: color, stroke: none))
        }
      }

      // Five-number summary beside each box, nudged apart where values are close. The
      // gap to the neighbouring box sets how much fits: all five values, else the median
      // and the extremes, else the median alone, in the text size that fits the gap
      // (down to a legible floor; nothing is drawn when even that is too wide). What
      // is drawn is also checked against every box, whisker, outlier and label, and
      // moves to the box's other side or drops out rather than touch one.
      if show-values {
        let base = t.value-label-size
        let sums = boxes.map(b => (b.max, b.q3, b.median, b.q1, b.min))
        let gap-room = p.X.pitch - half-box * 2 - 3.5pt
        let pick = none
        for kinds in ((2, 0, 4, 1, 3), (2, 0, 4), (2,)) {
          let w = kinds.map(k => sums.map(s => measure(text(size: base)[#value-text(s.at(k), t)]).width)).flatten().fold(0pt, calc.max)
          let size = if w > 0pt { calc.min(base, base * (gap-room / w)) } else { base }
          if size >= calc.min(5.5pt, base * 0.8) {
            pick = (kinds: kinds, size: size)
            break
          }
        }
        if pick != none {
          let lbl-size = pick.size
          let lbl-h = lbl-size * 1.1
          let hit(a, b) = a.x < b.x + b.w and b.x < a.x + a.w and a.y < b.y + b.h and b.y < a.y + a.h
          let sw = stroke-width
          let solids = ()  // what labels must stay clear of: boxes, whiskers with caps, outliers
          for (i, b) in boxes.enumerate() {
            let cx = px(i)
            solids.push((x: cx - half-box, y: py(b.q3), w: half-box * 2, h: py(b.q1) - py(b.q3)))
            solids.push((x: cx - sw / 2, y: py(b.max), w: sw, h: py(b.min) - py(b.max)))
            for y in (py(b.min), py(b.max)) {
              solids.push((x: cx - half-cap, y: y - sw / 2, w: half-cap * 2, h: sw))
            }
            for o in b.at("outliers", default: ()) {
              solids.push((x: cx - outlier-radius, y: py(o) - outlier-radius, w: outlier-radius * 2, h: outlier-radius * 2))
            }
          }
          let ys = sums.map(vals => spread-positions(vals.map(py), lbl-h, p.y0, p.y1))
          let placed = ()
          for k in pick.kinds {
            for (i, vals) in sums.enumerate() {
              let v = vals.at(k)
              let w = measure(text(size: lbl-size)[#value-text(v, t)]).width
              let (cx, y) = (px(i), ys.at(i).at(k))
              for x in (cx + half-box + 2.5pt, cx - half-box - 2.5pt - w) {
                let r = (x: x - 0.5pt, y: y - lbl-h / 2, w: w + 1pt, h: lbl-h)
                if r.x < p.x0 or r.x + r.w > width { continue }
                if solids.any(o => hit(o, r)) or placed.any(o => hit(o, r)) { continue }
                placed.push(r)
                place(left + top, dx: x, dy: y,
                  box(height: 0pt, align(horizon, text(size: lbl-size, fill: t.text-color)[#value-text(v, t)])))
                break
              }
            }
          }
        }
      }
    },
  )
  })
}
