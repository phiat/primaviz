// funnel.typ - Funnel chart for process/conversion stages
#import "../theme.typ": _resolve-ctx, get-color
#import "../util.typ": normalize-data, nonzero, contrast-text
#import "../validate.typ": validate-simple-data
#import "../primitives/container.typ": chart-container
#import "../primitives/layout.typ": resolve-size, text-width, fit-font-size, spread-1d, place-centered
#import "../primitives/rows.typ": value-str
#import "../primitives/reserve.typ": container-extra

/// Renders a funnel chart for visualizing process or conversion stages.
///
/// Each stage's name (and, optionally, its value and share of the first
/// stage) is written inside its segment when it fits, in the segment's
/// contrast colour. Segments too narrow for their label are labelled in a
/// shared column to the right, in the same two-line style, joined by a thin
/// horizontal leader.
///
/// - data (dictionary, array): Label-value pairs as dict or array of tuples
/// - width (length): Chart width
/// - height (length): Chart height
/// - title (none, content): Optional chart title
/// - show-values (bool): Display numeric values on segments
/// - show-percentages (bool): Display conversion percentages relative to the first stage
/// - gap (length): Vertical gap between segments
/// - theme (none, dictionary): Theme overrides
/// -> content
#let funnel-chart(
  data,
  width: auto,
  height: auto,
  title: none,
  show-values: true,
  show-percentages: true,
  gap: 3pt,
  theme: none,
) = context {
  layout(size => {
  validate-simple-data(data, "funnel-chart")
  let t = _resolve-ctx(theme)
  let norm = normalize-data(data)
  let labels = norm.labels
  let values = norm.values
  let n = values.len()
  let (width, height) = resolve-size(width, height, size, n: n, theme: t, rows: true, row-pitch: t.cell-size * 1.5)

  let max-val = nonzero(calc.max(..values))
  let first-val = nonzero(values.at(0))
  let seg-h = (height - gap * (n - 1)) / n
  let cx = width / 2
  let half-of(v) = calc.max(0pt, v / max-val * width / 2)

  // "value · share" under each name
  let details = values.map(v => {
    let parts = ()
    if show-values { parts.push(value-str(v, t)) }
    if show-percentages { parts.push(str(calc.round(v / first-val * 100, digits: 1)) + "%") }
    if parts.len() > 0 { parts.join(" · ") } else { "" }
  })

  let s0 = t.value-label-size
  let detail-k = 0.85   // detail line size relative to the name
  let lead-k = 0.3      // leading between the two lines, in em of the name
  let pad = 4pt         // clear space between text and the segment edge
  let s-min = calc.min(s0, 8pt)  // smallest size for a label set inside a segment

  // Segment geometry: half widths at the top and bottom edge
  let tops = values.map(half-of)
  let bots = values.enumerate().map(((i, v)) => if i < n - 1 { half-of(values.at(i + 1)) } else { half-of(v) })
  // Usable width at height `y` below the segment's top
  let width-at(i, y) = 2 * (tops.at(i) + (bots.at(i) - tops.at(i)) * (y / seg-h))

  // Decide how each label is set: the largest size (down to `s-min`) at which the
  // richest variant fits inside the trapezoid, measured at the text's lowest
  // edge; otherwise outside
  let plan = values.enumerate().map(((i, v)) => {
    let name = labels.at(i)
    let det = details.at(i)
    let found = none
    for k in range(int(calc.max(0pt, s0 - s-min) / 1pt) + 1) {
      if found != none { continue }
      let s = s0 - k * 1pt
      let w-name = text-width(name, s, weight: "bold")
      let w-det = if det != "" { text-width(det, s * detail-k) } else { 0pt }
      let stack-h = s * (1.2 + detail-k * 1.2 + lead-k)
      let line-h = s * 1.2
      if det != "" and stack-h <= seg-h - 2pt and calc.max(w-name, w-det) <= width-at(i, seg-h / 2 + stack-h / 2) - 2 * pad {
        found = (mode: "stack", size: s)
      } else if det != "" and line-h <= seg-h - 2pt and w-name + 0.4 * s + w-det <= width-at(i, seg-h / 2 + line-h / 2) - 2 * pad {
        found = (mode: "inline", size: s)
      } else if line-h <= seg-h - 2pt and w-name <= width-at(i, seg-h / 2 + line-h / 2) - 2 * pad {
        found = (mode: "name", size: s)
      }
    }
    if found == none { (mode: "out", size: s0 * 0.9) } else { found }
  })

  // Outside labels share one column, just clear of the widest outside segment.
  // Each wraps at the room it has (a single word wider than that shrinks); the
  // column is then spread vertically by the tallest label so none overlaps
  let outs = array.range(n).filter(i => plan.at(i).mode == "out")
  let s-out = s0 * 0.9
  let out-x = if outs.len() > 0 { cx + calc.max(..outs.map(i => (tops.at(i) + bots.at(i)) / 2)) + 14pt } else { 0pt }
  let out-w = calc.max(20pt, width - out-x)
  let out-bodies = outs.map(i => {
    let name = labels.at(i)
    let det = details.at(i)
    let words = if type(name) == str { name.split(" ") } else { (name,) }
    let sz = calc.min(s-out, ..words.map(w => fit-font-size(w, out-w, s-out, min: 6pt, weight: "bold")))
    let name-t = text(size: sz, weight: "bold", fill: t.text-color)[#name]
    let body = if det != "" {
      stack(dir: ttb, spacing: sz * lead-k, name-t, text(size: sz * detail-k, fill: t.text-color-light)[#det])
    } else { name-t }
    (body: body, h: measure(box(width: out-w, body)).height)
  })
  let out-sep = out-bodies.fold(0pt, (acc, b) => calc.max(acc, b.h)) + 2pt
  let out-ys = spread-1d(
    outs.map(i => i * (seg-h + gap) + seg-h / 2), out-sep,
    lo: out-sep / 2, hi: height - out-sep / 2)

  let extra = container-extra(width, height, title, t)
  chart-container(width, height, title, t, extra-height: extra)[
    #box(width: width, height: height)[
      #for (i, val) in values.enumerate() {
        let y-top = i * (seg-h + gap)
        let color = get-color(t, i)
        place(left + top, dy: y-top, polygon(
          fill: color,
          stroke: t.marker-stroke,
          (cx - tops.at(i), 0pt), (cx + tops.at(i), 0pt),
          (cx + bots.at(i), seg-h), (cx - bots.at(i), seg-h),
        ))

        let p = plan.at(i)
        let name = labels.at(i)
        let det = details.at(i)
        if p.mode != "out" {
          let fg = contrast-text(color)
          let name-t = text(size: p.size, weight: "bold", fill: fg)[#name]
          let det-t = text(size: p.size * detail-k, fill: fg)[#det]
          let body = if p.mode == "stack" {
            stack(dir: ttb, spacing: p.size * lead-k, name-t, det-t)
          } else if p.mode == "inline" {
            [#name-t#h(0.4 * p.size)#det-t]
          } else { name-t }
          place-centered(cx - tops.at(i), y-top + seg-h / 2, body, width: 2 * tops.at(i), align: center)
        }
      }

      // Outside labels: same two-line style, in the text colour, one column
      #for (k, i) in outs.enumerate() {
        let mid = i * (seg-h + gap) + seg-h / 2
        let edge = cx + (tops.at(i) + bots.at(i)) / 2 + 3pt
        let ly = out-ys.at(k)
        place(left + top, line(start: (edge, mid), end: (out-x - 3pt, ly), stroke: t.stroke-thin + t.text-color-light))
        place-centered(out-x, ly, out-bodies.at(k).body, width: out-w, align: left)
      }
    ]
  ]
  })
}
