// lollipop.typ - Lollipop charts (vertical and horizontal)
#import "../theme.typ": _resolve-ctx, get-color
#import "../util.typ": normalize-data
#import "../validate.typ": validate-simple-data
#import "../primitives/frame.typ": cartesian-frame
#import "../primitives/axes.typ": value-axis, category-axis, fit-label-size, fit-row-size, value-text
#import "../primitives/layout.typ": resolve-size, pin

// The value axis of a lollipop chart: always includes the zero baseline.
// `pad` is the room value labels past negative dots need below the axis start.
#let _stem-axis(values, title, pad: 0pt) = {
  let (lo, hi) = (calc.min(0, ..values), calc.max(0, ..values))
  value-axis(lo, if lo == hi { 1 } else { hi }, title: title, pad: (lo: if lo < 0 { pad } else { 0pt }))
}

/// Renders a vertical lollipop chart with a thin stem and circle dot per category.
///
/// A lollipop chart is like a bar chart but uses a thin line (stem) capped by a
/// filled circle (dot) instead of a filled bar. Useful for ranked or comparison data
/// where a cleaner look is desired.
///
/// - data (dictionary, array): Label-value pairs as dict or array of tuples
/// - width (length): Chart width
/// - height (length): Chart height
/// - dot-size (length): Diameter of the dot at the end of each stem
/// - stem-width (auto, length): Thickness of the stem line; `auto` uses the theme's `stroke-thick`
/// - title (none, content): Optional chart title
/// - show-values (bool): Display value labels above dots
/// - x-label (none, content): X-axis title
/// - y-label (none, content): Y-axis title
/// - annotations (none, array): Optional annotation descriptors
/// - theme (none, dictionary): Theme overrides
/// -> content
#let lollipop-chart(
  data,
  width: auto,
  height: auto,
  dot-size: 8pt,
  stem-width: auto,
  title: none,
  show-values: true,
  x-label: none,
  y-label: none,
  annotations: none,
  theme: none,
) = context {
  layout(size => {
  validate-simple-data(data, "lollipop-chart")
  let t = _resolve-ctx(theme)
  let stem-width = if stem-width == auto { t.stroke-thick } else { stem-width }
  let norm = normalize-data(data)
  let (labels, values) = (norm.labels, norm.values)
  if values.len() == 0 { return }
  let (width, height) = resolve-size(width, height, size, n: values.len(), theme: t)
  let strs = values.map(v => value-text(v, t))

  cartesian-frame(width, height, t,
    x: category-axis(labels, title: x-label),
    y: _stem-axis(values, y-label, pad: if show-values { 1.2 * t.value-label-size + dot-size / 2 + t.label-offset } else { dot-size / 2 }),
    baseline: (y: 0), annotations: annotations, title: title,
    reserve: (top: if show-values { t.value-label-size + t.label-offset } else { 0pt }),
    p => {
      let (px, py) = (p.px, p.py)
      let vsize = fit-label-size(strs, p.X.pitch, t.value-label-size)
      for (i, val) in values.enumerate() {
        let (cx, y-end, color) = (px(i), py(val), get-color(t, i))
        place(left + top, line(start: (cx, py(0)), end: (cx, y-end), stroke: color + stem-width))
        place(left + top, dx: cx - dot-size / 2, dy: y-end - dot-size / 2,
          circle(radius: dot-size / 2, fill: color, stroke: none))
        if show-values and vsize != none {
          let above = val >= 0
          place(left + top, dx: cx - p.X.pitch / 2, dy: y-end + (if above { -1 } else { 1 }) * (dot-size / 2 + t.label-offset),
            pin(width: p.X.pitch, align: center + if above { bottom } else { top },
              text(size: vsize, fill: t.text-color)[#strs.at(i)]))
        }
      }
    },
  )
  })
}

/// Renders a horizontal lollipop chart with category labels on the y-axis.
///
/// Like a horizontal bar chart but uses a thin line (stem) from the y-axis and a
/// filled circle (dot) at the value endpoint.
///
/// - data (dictionary, array): Label-value pairs as dict or array of tuples
/// - width (length): Chart width
/// - height (length): Chart height
/// - dot-size (length): Diameter of the dot at the end of each stem
/// - stem-width (auto, length): Thickness of the stem line; `auto` uses the theme's `stroke-thick`
/// - title (none, content): Optional chart title
/// - show-values (bool): Display value labels beside dots
/// - x-label (none, content): X-axis title
/// - y-label (none, content): Y-axis title
/// - annotations (none, array): Optional annotation descriptors
/// - theme (none, dictionary): Theme overrides
/// -> content
#let horizontal-lollipop-chart(
  data,
  width: auto,
  height: auto,
  dot-size: 8pt,
  stem-width: auto,
  title: none,
  show-values: true,
  x-label: none,
  y-label: none,
  annotations: none,
  theme: none,
) = context {
  layout(size => {
  validate-simple-data(data, "horizontal-lollipop-chart")
  let t = _resolve-ctx(theme)
  let stem-width = if stem-width == auto { t.stroke-thick } else { stem-width }
  let norm = normalize-data(data)
  let (labels, values) = (norm.labels, norm.values)
  if values.len() == 0 { return }
  let (width, height) = resolve-size(width, height, size, n: values.len(), theme: t)
  let strs = values.map(v => value-text(v, t))

  cartesian-frame(width, height, t,
    x: _stem-axis(values, x-label,
      pad: dot-size / 2 + if show-values { calc.max(..strs.map(s => measure(text(size: t.value-label-size)[#s]).width)) + t.label-offset } else { 0pt }),
    y: category-axis(labels, title: y-label),
    baseline: (x: 0), annotations: annotations, title: title,
    // a value label past the longest stem must stay inside the box
    reserve: (right: if show-values { calc.max(..strs.map(s => measure(text(size: t.value-label-size)[#s]).width)) + t.label-offset + dot-size / 2 } else { dot-size / 2 }),
    p => {
      let (px, py) = (p.px, p.py)
      let vsize = fit-row-size(p.Y.pitch, t.value-label-size)
      for (i, val) in values.enumerate() {
        let (cy, x-end, color) = (py(i), px(val), get-color(t, i))
        place(left + top, line(start: (px(0), cy), end: (x-end, cy), stroke: color + stem-width))
        place(left + top, dx: x-end - dot-size / 2, dy: cy - dot-size / 2,
          circle(radius: dot-size / 2, fill: color, stroke: none))
        if show-values and vsize != none {
          let after = val >= 0
          place(left + top, dx: x-end + (if after { 1 } else { -1 }) * (dot-size / 2 + t.label-offset) - if after { 0pt } else { 200pt }, dy: cy,
            pin(width: 200pt, align: (if after { left } else { right }) + horizon,
              text(size: vsize, fill: t.text-color)[#strs.at(i)]))
        }
      }
    },
  )
  })
}
