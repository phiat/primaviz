// axes.typ - Axis specs, tick selection, label policy and scales

#import "../theme.typ": *
#import "../util.typ": format-number, nice-ticks

// ── Axis specs ──────────────────────────────────────────────────────────────
//
// An axis is described once (`value-axis`, `category-axis`), resolved against
// the room it gets (`resolve-*`), and from then on every consumer — scale, grid,
// tick marks, tick labels, annotations — reads the same resolved record. Nothing
// re-derives ticks, so grid lines, tick marks and labels cannot disagree.

/// A numeric axis over the data range `lo` to `hi`, snapped outward to a nice
/// tick list.
///
/// - lo (int, float): Lowest value to cover
/// - hi (int, float): Highest value to cover
/// - title (none, content): Axis title
/// - color (auto, color): Tick label and title color; `auto` uses the theme text color
/// - inset (length): Room kept free at both ends of the axis, so marks centred on
///   the extreme values (points, bubbles) stay inside the plot. The ticks stay at
///   their values; the axis line moves out by `inset`.
/// - ticks (auto, dictionary): A ready `nice-ticks`-style record (`min`, `max`,
///   `ticks`, `step`, `digits`, optional `labels`) to use instead of picking one
/// - labelled (bool): Draw the tick labels (the axis keeps its marks and grid)
/// - pad (dictionary): `(lo: length, hi: length)`: room the axis must keep beyond
///   the extreme values, for labels set past the end of a bar. The axis range
///   widens (to the next nice tick) until that room is there.
/// -> dictionary
#let value-axis(lo, hi, title: none, color: auto, inset: 0pt, ticks: auto, labelled: true, pad: (:)) = (
  kind: "value", lo: lo, hi: hi, title: title, color: color, inset: inset, ticks: ticks, labelled: labelled, pad: pad,
)

/// A categorical axis with one label per category.
///
/// `mode: "slots"` gives every category an equal slot and centres its mark in it
/// (bars). `mode: "points"` spreads marks evenly with just enough room at the
/// ends for the end labels (lines). When labels do not fit horizontally,
/// `overflow: "rotate"` tilts them 45 degrees (thinning only if still too dense)
/// and `overflow: "thin"` shows every k-th; `auto` picks rotate for slots, and
/// for points thin, unless thinning would leave fewer than four labels.
///
/// - labels (array): Category labels (strings, numbers or content)
/// - title (none, content): Axis title
/// - mode (str): `"slots"` or `"points"`
/// - overflow (auto, str): `"rotate"` or `"thin"`
/// - inset (length): Minimum room at the ends in `"points"` mode (marker radius)
/// - labelled (bool): Draw the tick labels (the axis keeps its marks and grid)
/// -> dictionary
#let category-axis(labels, title: none, mode: "slots", overflow: auto, inset: 0pt, labelled: true) = (
  kind: "category", labels: labels, title: title, mode: mode,
  overflow: overflow, inset: inset, color: auto, labelled: labelled,
)

// ── Text metrics ────────────────────────────────────────────────────────────

// A tick label as drawn. Metrics below measure exactly this.
#let label-text(body, t, fill: auto, size: auto) = text(
  size: if size == auto { t.axis-label-size } else { size }, fill: if fill == auto { t.text-color } else { fill },
)[#body]

// `label` cut to its longest prefix, closed with an ellipsis, for which
// `fits(candidate)` holds. A label that already fits, and any label that is not
// a string, is returned as it is.
#let _clip-label(label, fits) = {
  if type(label) != str or fits(label) { return label }
  let cs = label.clusters()
  let (lo, hi, best) = (1, cs.len() - 1, 1)
  while lo <= hi {
    let mid = calc.floor((lo + hi) / 2)
    if fits(cs.slice(0, mid).join() + "…") { best = mid; lo = mid + 1 } else { hi = mid - 1 }
  }
  cs.slice(0, best).join().trim() + "…"
}

// Full line box (ascender to descender) of a tick label.
#let label-line-height(t) = measure(text(size: t.axis-label-size, top-edge: "ascender", bottom-edge: "descender")[Ag]).height

// Height of a row of horizontal labels: cap height plus room for descenders.
#let label-row-height(t) = measure(text(size: t.axis-label-size)[0]).height + 0.3 * t.axis-label-size

// Width of the widest of `strs` set as tick labels.
#let widest-label(strs, t) = strs.fold(0pt, (m, s) => calc.max(m, measure(label-text(s, t)).width))

// ── Value axes ──────────────────────────────────────────────────────────────

// Tick labels for a tick record, formatted once for the whole axis.
#let _tick-labels(nt, t) = {
  if "labels" in nt { return nt.labels }
  let td = t.at("tick-digits", default: auto)
  let digits = if td != auto { td } else { nt.digits }
  // One notation for the whole axis: once any tick needs SI (10k and up), all use it
  let big = nt.ticks.fold(0, (m, v) => calc.max(m, calc.abs(v))) >= 10000
  let mode = if t.number-format == "auto" and big { "si" } else { t.number-format }
  nt.ticks.map(v => format-number(v, digits: digits, mode: mode, step: nt.step))
}

// Distance needed between neighbouring tick labels so they stay clear of each other.
#let _label-need(nt, vertical, t) = if vertical {
  measure(text(size: t.axis-label-size)[0]).height * 2.6
} else {
  widest-label(_tick-labels(nt, t), t) * 1.4 + t.axis-label-size
}

// Whether the ticks of `nt` spread over `room` leave their labels clear of each other.
#let _ticks-fit(nt, room, vertical, t) = {
  let n = nt.ticks.len()
  n < 2 or room / (n - 1) >= _label-need(nt, vertical, t)
}

// Largest nice tick list (up to theme.tick-count targets) whose labels fit.
#let _pick-ticks(lo, hi, room, vertical, t) = {
  let nt = nice-ticks(lo, hi, count: 2)
  for c in range(calc.max(t.tick-count, 2), 1, step: -1) {
    nt = nice-ticks(lo, hi, count: c)
    if _ticks-fit(nt, room, vertical, t) { break }
  }
  nt
}

/// Resolves a value axis for `extent` of room: picks the tick list (once) and
/// formats its labels.
///
/// - ax (dictionary): From `value-axis`
/// - extent (length): Length of the axis
/// - vertical (bool): Whether the axis runs vertically (labels stack, not side by side)
/// - t (dictionary): Resolved theme
/// -> dictionary
#let resolve-value-axis(ax, extent, vertical, t) = {
  let room = extent - 2 * ax.inset
  let (pad-lo, pad-hi) = (ax.pad.at("lo", default: 0pt), ax.pad.at("hi", default: 0pt))
  let nt = if ax.ticks == auto {
    let nt = _pick-ticks(ax.lo, ax.hi, room, vertical, t)
    // Widen the range by what the ends are short of (a few rounds: the ticks snap outward)
    for _ in range(4) {
      let span = nt.max - nt.min
      let short-lo = calc.max(pad-lo - (ax.lo - nt.min) / span * room, 0pt)
      let short-hi = calc.max(pad-hi - (nt.max - ax.hi) / span * room, 0pt)
      if short-lo < 0.5pt and short-hi < 0.5pt { break }
      nt = _pick-ticks(nt.min - short-lo / room * span, nt.max + short-hi / room * span, room, vertical, t)
    }
    nt
  } else if ax.ticks.at("thin", default: false) {
    // A fixed tick list (histogram bin edges) shows every k-th tick: the
    // fewest that leaves the labels clear of each other
    let all = ax.ticks.ticks
    let per = room / calc.max(all.len() - 1, 1)
    let k = calc.max(1, calc.ceil(_label-need(ax.ticks, vertical, t) / per))
    (..ax.ticks, ticks: all.enumerate().filter(((i, _)) => calc.rem(i, k) == 0).map(((_, v)) => v))
  } else { ax.ticks }
  (..ax, nt: nt, labels: _tick-labels(nt, t), dlo: nt.min, dhi: nt.max, block: label-row-height(t))
}

/// Resolves two vertical value axes that share one set of grid lines: finds a
/// tick count for which both land on the same number of ticks, so every tick of
/// one axis lines up with a tick of the other. Falls back to independent ticks
/// when no common count exists (`aligned: false`).
///
/// -> array (left axis, right axis)
#let resolve-value-pair(a, b, extent, t) = {
  let tc = calc.max(t.tick-count, 2)
  for c in (..range(tc, 1, step: -1), ..range(tc + 1, tc + 4)) {
    let na = nice-ticks(a.lo, a.hi, count: c)
    let nb = nice-ticks(b.lo, b.hi, count: c)
    if na.ticks.len() == nb.ticks.len() and _ticks-fit(na, extent - 2 * a.inset, true, t) {
      return (
        resolve-value-axis((..a, ticks: na), extent, true, t),
        resolve-value-axis((..b, ticks: nb), extent, true, t),
      )
    }
  }
  (resolve-value-axis(a, extent, true, t), resolve-value-axis(b, extent, true, t))
}

// ── Category axes ───────────────────────────────────────────────────────────

/// Resolves a horizontal category axis over `len`: slot geometry and the label
/// policy. Labels that fit are shown flat; otherwise they are thinned or rotated
/// as the axis asks, so no two labels ever overlap. Thinning keeps the fewest
/// labels that stay clear of each other, measured pair by pair (one long label
/// does not thin the short ones). Rotated labels never take more than
/// `max-block` of height: longer text is cut with an ellipsis.
///
/// Adds `n`, `pitch` (distance between marks), `inset`, `dlo`/`dhi` (index
/// domain), `rotate`, `skip`, `shown` (indices of the labels drawn), `texts`
/// (the labels as drawn, clipped where needed), `block` (height the label row
/// needs) and `over-left` (how far a rotated first label reaches left of the plot).
#let resolve-category-axis(ax, len, t, max-block: none) = {
  let n = ax.labels.len()
  let width-of(l) = measure(label-text(l, t)).width
  let natural = ax.labels.map(width-of)
  let lh = label-line-height(t)
  // A single point has nothing to spread: it takes the middle, like a lone slot
  let slots = ax.mode == "slots" or n == 1
  let pitch-for(inset) = if slots { len / n } else if n > 1 { (len - 2 * inset) / (n - 1) } else { len }
  // Flat end labels are centred on the end marks, so the marks move in by half their width
  let flat-inset = if slots { 0pt } else {
    calc.min(calc.max(ax.inset, calc.max(natural.first(), natural.last()) / 2 + 1pt), len * 0.3)
  }
  let gap = 0.6 * t.axis-label-size
  // Whether every s-th label, set flat, stays clear of its neighbour
  let clear(s) = range(0, n, step: s).windows(2).all(ij => {
    let (a, b) = ij
    (natural.at(a) + natural.at(b)) / 2 + gap <= (b - a) * pitch-for(flat-inset)
  })
  let flat = clear(1)
  let thin-skip = if flat { 1 } else { range(2, n + 1).find(clear) }
  // `auto`: slots rotate; points thin, unless thinning would leave under four labels
  let rotate = not flat and (ax.overflow == "rotate" or (ax.overflow == auto and (slots or (n >= 4 and calc.ceil(n / thin-skip) < 4))))
  // Tilted labels end at their mark and reach left, not right: only the marker needs room
  let inset = if rotate and not slots { calc.min(ax.inset, len * 0.3) } else { flat-inset }
  let pitch = pitch-for(inset)
  let skip = if rotate { calc.max(1, calc.ceil(1.8 * lh / pitch)) } else { thin-skip }
  let wcap = if rotate and max-block != none { calc.max(max-block / 0.7071 - lh, 3 * lh) }
  let texts = if wcap == none { ax.labels } else {
    ax.labels.map(l => _clip-label(l, c => width-of(c) <= wcap))
  }
  let ws = if wcap == none { natural } else { texts.map(width-of) }
  let shown = range(0, n, step: skip)
  let wshown = shown.map(i => ws.at(i)).fold(0pt, calc.max)
  let first-x = if slots { pitch / 2 } else { inset }
  (
    ..ax, n: n, ws: ws, texts: texts, pitch: pitch, inset: inset, rotate: rotate, skip: skip, shown: shown,
    dlo: if slots { -0.5 } else { 0 }, dhi: if slots { n - 0.5 } else { calc.max(n - 1, 1) },
    block: if rotate { 0.7071 * (wshown + lh) } else { label-row-height(t) },
    over-left: if rotate { calc.max(0pt, 0.7071 * ws.first() + 0.354 * lh - first-x) } else { 0pt },
  )
}

/// Resolves a vertical category axis over `len` (horizontal bars): the label
/// column is as wide as the widest label up to `max-col`; wider labels wrap, and
/// a label taller than its row is cut with an ellipsis. When the rows are too
/// short for the type size it shrinks (to 75%), and only then are labels thinned.
///
/// Adds `n`, `pitch`, `dlo`/`dhi`, `col` (label column width), `size` (type
/// size of the labels), `skip`, `texts`.
#let resolve-category-axis-v(ax, len, max-col, t) = {
  let n = ax.labels.len()
  let pitch = len / n
  let lh = label-line-height(t)
  let fit = calc.min(1, pitch / (1.15 * lh))
  let size = t.axis-label-size * calc.max(fit, 0.75)
  let skip = if fit >= 0.75 { 1 } else { calc.ceil(1.15 * lh * 0.75 / pitch) }
  let col = calc.min(ax.labels.map(l => measure(label-text(l, t, size: size)).width).fold(0pt, calc.max), max-col)
  // A label may wrap onto as many lines as its row holds with air to spare
  // (one line's height plus the descender room), and is cut with an ellipsis past that
  let one = measure(label-text("A", t, size: size)).height
  let step = measure(box(width: col, label-text([A \ A], t, size: size))).height - one
  let lines = calc.max(1, calc.floor((pitch * skip * 0.95 - one - 0.3 * size) / step) + 1)
  let room = one + (lines - 1) * step + 0.5pt
  let texts = ax.labels.map(l => _clip-label(l, c => measure(box(width: col, label-text(c, t, size: size))).height <= room))
  (
    ..ax, n: n, pitch: pitch, inset: 0pt, dlo: -0.5, dhi: n - 0.5,
    col: col, size: size, skip: skip, texts: texts,
  )
}

// ── Scales ──────────────────────────────────────────────────────────────────

/// Linear scale of a resolved axis laid over `len` starting at `start`.
/// Returns `(pos, dom)`: `pos(v)` maps a value (or category index) to a length
/// along the axis; `dom` is the `(lo, hi)` the full length spans, for overlays
/// that work in data coordinates. With `flip`, larger values sit nearer `start`'s
/// far end (vertical value axes, where values grow upward).
#let axis-scale(ax, start, len, flip: false) = {
  let inner = len - 2 * ax.inset
  let span = if ax.dhi == ax.dlo { 1 } else { ax.dhi - ax.dlo }
  let pos = v => if flip {
    start + len - ax.inset - (v - ax.dlo) / span * inner
  } else {
    start + ax.inset + (v - ax.dlo) / span * inner
  }
  let e = ax.inset / inner * span
  (pos: pos, dom: (lo: ax.dlo - e, hi: ax.dhi + e))
}

/// Largest font size, at most `size`, at which every label in `strs` fits a slot
/// `slot` wide with a little air between neighbours; `none` when they would need
/// to go below `min-size`. Direct labels (value labels above bars) use this to
/// shrink, then drop, instead of overlapping.
#let fit-label-size(strs, slot, size, min-size: 5.5pt) = {
  let w = strs.fold(0pt, (m, s) => calc.max(m, measure(text(size: size)[#s]).width))
  if w <= 0pt { return size }
  let fitted = calc.min(size, size * ((slot * 0.94) / w))
  // A theme whose labels are small already keeps them down to 80% of that size
  if fitted >= calc.min(min-size, size * 0.8) { fitted } else { none }
}

/// Moves label positions `ys` (any order) apart so neighbouring labels keep at
/// least `gap` between centres, within `lo` to `hi` where room allows. Labels
/// keep their order and stay as near their own position as the others permit.
/// Direct labels (end-of-line names, box plot values) use this to avoid collisions.
#let spread-positions(ys, gap, lo, hi) = {
  let order = range(ys.len()).sorted(key: i => ys.at(i))
  let out = ys
  let floor = lo
  for i in order {
    out.at(i) = calc.max(ys.at(i), floor)
    floor = out.at(i) + gap
  }
  let ceil = hi
  for i in order.rev() {
    out.at(i) = calc.min(out.at(i), ceil)
    ceil = out.at(i) - gap
  }
  out
}

/// Font size, at most `size`, for labels in rows `pitch` apart so neighbouring
/// rows never touch; `none` when that would go below `min-size`.
#let fit-row-size(pitch, size, min-size: 5.5pt) = {
  let fitted = calc.min(size, pitch * 0.9)
  if fitted >= calc.min(min-size, size * 0.8) { fitted } else { none }
}

/// Compact text for a data value shown beside a mark: values from 10 000 up
/// are abbreviated the way the axis ticks are (`15k`, `1.5M`); smaller values
/// are shown as given.
#let value-text(v, t) = {
  if (type(v) == int or type(v) == float) and calc.abs(v) >= 10000 and t.number-format == "auto" {
    format-number(v, digits: 1, mode: "auto")
  } else { v }
}
// ── For charts that lay out their own rows ──────────────────────────────────
//
// The row-oriented charts (dumbbell, diverging, gantt, bullet, ...) draw their
// own axes. These three helpers keep their signatures; cartesian charts use
// `cartesian-frame` instead.

// Draw a single right-aligned y-axis category label in the left margin.
#let draw-y-label(label, y, margin-width, theme) = {
  place(left + top, dx: 0pt, dy: y, box(width: margin-width - theme.axis-label-gap, height: 0pt, align(right + horizon,
    text(size: theme.axis-label-size, fill: theme.text-color)[#label],
  )))
}

// Height of a row of x tick labels; rotated (45 degrees) labels take their
// widest label's diagonal.
#let measure-x-tick-height(values, theme, rotated: false) = {
  if not rotated { return measure(text(size: theme.axis-label-size)[0]).height }
  values.fold(0pt, (m, v) => calc.max(m, measure(text(size: theme.axis-label-size)[#v]).width * calc.sqrt(2) / 2))
}

// Axis titles: the x title below the tick labels (centred on `x-center`), the y
// title rotated left of the tick labels (centred on `y-center`). `origin-x` and
// `origin-y` are the axis corner; `y-tick-width` and `x-tick-height` the measured
// tick label extents.
#let draw-axis-titles(
  x-label, y-label, x-center, y-center, theme,
  origin-x: none, origin-y: none, y-tick-width: 0pt, x-tick-height: 0pt,
) = {
  let gap = theme.axis-label-gap
  let title-gap = theme.at("axis-title-gap", default: gap)
  let title(body) = text(size: theme.axis-title-size, fill: theme.text-color)[#body]
  if x-label != none {
    let lbl = title(x-label)
    let tick-h = if x-tick-height != 0pt { x-tick-height } else { measure(text(size: theme.axis-label-size)[0]).height }
    let ox-y = if origin-y != none { origin-y } else { y-center * 2 }
    place(left + top, dx: x-center - measure(lbl).width / 2, dy: ox-y + gap + tick-h + title-gap, lbl)
  }
  if y-label != none {
    // The rotated box is placed by its centre: measure() of a rotated box is the unrotated size
    let lbl = title(y-label)
    let (tw, th) = (measure(lbl).width, measure(lbl).height)
    let ox-x = if origin-x != none { origin-x } else { theme.axis-padding-left }
    let strip-x = ox-x - gap / 2 - y-tick-width - title-gap - th
    place(left + top, dx: strip-x + th / 2 - tw / 2, dy: y-center - th / 2, rotate(-90deg, lbl))
  }
}
