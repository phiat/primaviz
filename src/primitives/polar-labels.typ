// polar-labels.typ - Label rules shared by the radial charts
//
// Every radial chart answers the same four questions about a label, and
// answers them here so a fix lands everywhere:
//
//   readable?   label-ink / legible      text colour that works on a fill / the page
//   inside?     fit-wedge-label          largest size, best spot, best orientation
//   outside?    place-outside-labels     around a circle, no collisions, leader if moved
//   room?       polar-fit-radius         biggest circle that leaves room for them
//
// A label never overlaps another label or leaves its container: it fits,
// shrinks, moves (with a leader line), or is dropped (the legend, if any,
// still carries it).
//
// All functions measure text, so call them from inside `context`.

#import "polar.typ": polar-pt

// ── Colour ──────────────────────────────────────────────────────────────

// sRGB channel (0..1) to linear light
#let _lin(c) = if c <= 0.04045 { c / 12.92 } else { calc.pow((c + 0.055) / 1.055, 2.4) }

/// WCAG relative luminance of a colour (0 = black, 1 = white).
///
/// - c (color): Colour (alpha is ignored)
/// -> float
#let luminance(c) = {
  let k = rgb(c).components()
  0.2126 * _lin(k.at(0) / 100%) + 0.7152 * _lin(k.at(1) / 100%) + 0.0722 * _lin(k.at(2) / 100%)
}

/// WCAG contrast ratio between two colours (1 = identical, 21 = black on white).
///
/// - a (color): First colour
/// - b (color): Second colour
/// -> float
#let contrast-ratio(a, b) = {
  let (la, lb) = (luminance(a), luminance(b))
  (calc.max(la, lb) + 0.05) / (calc.min(la, lb) + 0.05)
}

/// Text colour for a label drawn on a filled mark.
///
/// Takes the theme's own text colours, darker first, and uses the first with
/// at least `min-ratio` contrast against the fill; if neither reaches it,
/// black or white, whichever is stronger. (A fixed "inverse" colour is
/// unreadable on half a palette: white on yellow is 1.7:1.)
///
/// - fill (color): The mark's fill
/// - theme (dictionary): Resolved theme
/// - min-ratio (float): Contrast ratio worth keeping a theme colour for
/// -> color
#let label-ink(fill, theme, min-ratio: 4.5) = {
  let pick(cands) = cands.sorted(key: c => -contrast-ratio(c, fill)).first()
  let theirs = (theme.text-color-inverse, theme.text-color).sorted(key: c => luminance(c))
  let ok = theirs.find(c => contrast-ratio(c, fill) >= min-ratio)
  if ok != none { ok } else { pick((black, white)) }
}

/// The colour a mark is drawn in, nudged until text in it is readable on
/// the page: pale palette colours (yellow, pink) vanish as text on white.
///
/// - c (color): Wanted colour
/// - bg (color): What it is drawn on
/// - min-ratio (float): Contrast ratio to reach (3 is the large-text bar)
/// -> color
#let legible(c, bg, min-ratio: 3.0) = {
  let out = c
  let lighter-bg = luminance(bg) > 0.35
  for _ in range(10) {
    if contrast-ratio(out, bg) >= min-ratio { break }
    out = if lighter-bg { out.darken(12%) } else { out.lighten(12%) }
  }
  out
}

// ── Text fitting ────────────────────────────────────────────────────────

/// Largest font size in `size-min..size-max` at which `make(size)` is at most
/// `max-w` wide (`size-min` if none is).
///
/// - make (function): `size => content`
/// - max-w (length): Width to fit
/// - size-max (length): Preferred size
/// - size-min (length): Floor size
/// -> length
#let fit-text-size(make, max-w, size-max, size-min, step: 0.5pt) = {
  let s = size-max
  while s > size-min and measure(make(s)).width > max-w { s -= step }
  calc.max(s, size-min)
}

// ── Inside a wedge ──────────────────────────────────────────────────────

// Wrap an angle to [-180, 180)
#let _wrap(d) = calc.rem-euclid(d + 180, 360) - 180

// Keep text upright: an angle in [-90, 90] (so a vertical label on the left
// of a circle reads upward, on the right downward: tops face outward)
#let _upright(d) = {
  let a = _wrap(d)
  if a > 90 { a - 180 } else if a < -90 { a + 180 } else { a }
}

/// Whether a `w`×`h` label, centred at distance `r` along `mid`, lies inside
/// the wedge (`r-in..r-out`, `mid ± half-span`) with `pad` to spare.
///
/// `rot` turns the label (degrees clockwise, as on screen). Exact for
/// convex wedges (half-span < 90deg, which is any label worth fitting).
///
/// - r (length): Distance of the label centre from the chart centre
/// - mid (float): Direction of the label centre, degrees
/// - w (length): Label width
/// - h (length): Label height
/// - r-in (length): Inner radius of the wedge (0 for a pie slice)
/// - r-out (length): Outer radius of the wedge
/// - half-span (float): Half the wedge's sweep, degrees
/// - rot (float): Label rotation in degrees
/// - pad (length): Clearance to keep from every edge
/// -> bool
#let rect-in-wedge(r, mid, w, h, r-in, r-out, half-span, rot: 0, pad: 1pt) = {
  let (r, w, h, r-in, r-out, pad) = (r, w, h, r-in, r-out, pad).map(x => x / 1pt)
  let (px, py) = (r * calc.cos(mid * 1deg), r * calc.sin(mid * 1deg))
  let (cr, sr) = (calc.cos(rot * 1deg), calc.sin(rot * 1deg))
  let ok = true
  for (sx, sy) in ((-1, -1), (1, -1), (1, 1), (-1, 1)) {
    let (u, v) = (sx * w / 2, sy * h / 2)
    let (x, y) = (px + u * cr - v * sr, py + u * sr + v * cr)
    let rho = calc.sqrt(x * x + y * y)
    if rho > r-out - pad { ok = false }
    if half-span < 90 and rho > 0.001 {
      let off = calc.abs(_wrap(calc.atan2(x, y).deg() - mid))
      if off > half-span - pad / rho * 57.2958 { ok = false }
    }
  }
  if ok and r-in > 0 {
    // the rectangle's nearest point to the centre must clear the hole
    let (lu, lv) = (-px * cr - py * sr, px * sr - py * cr)
    let (du, dv) = (lu - calc.max(-w / 2, calc.min(w / 2, lu)), lv - calc.max(-h / 2, calc.min(h / 2, lv)))
    if calc.sqrt(du * du + dv * dv) < r-in + pad { ok = false }
  }
  ok
}

/// Finds the biggest label that fits inside a wedge and where it sits.
///
/// Tries `make(size)` from `size-max` down to `size-min`, horizontal first;
/// with `rotate`, a label that fits no size horizontally is tried along the
/// radius and then along the arc (turned to stay upright). At each size the
/// spot nearest `r-pref` that fits wins. Returns `none` when nothing fits:
/// the caller moves the label outside, or drops it.
///
/// - make (function): `size => content`
/// - mid (float): Direction of the wedge's middle, degrees
/// - half-span (float): Half the wedge's sweep, degrees
/// - r-in (length): Inner radius of the wedge (0 for a pie slice)
/// - r-out (length): Outer radius of the wedge
/// - size-max (length): Preferred label size
/// - size-min (length): Smallest size worth printing
/// - r-pref (auto, length): Preferred distance of the label from the centre
/// - rotate (bool): Allow turning the label
/// - pad (length): Clearance from the wedge's edges
/// -> none, dictionary with `size`, `r`, `rot`, `w`, `h`
#let fit-wedge-label(make, mid, half-span, r-in, r-out, size-max, size-min, r-pref: auto, rotate: false, pad: 1.2pt) = {
  let pref = if r-pref == auto { (r-in + r-out) / 2 } else { r-pref }
  let step = (r-out - r-in) / 10
  let radii = ()
  for k in range(0, 11) {
    for sign in (1, -1) {
      let r = pref + sign * k * step
      if r >= r-in and r <= r-out and r not in radii { radii.push(r) }
    }
  }
  let sizes = ()
  let s = size-max
  while s >= size-min { sizes.push(s); s -= 0.5pt }
  if sizes.len() == 0 { sizes.push(size-min) }
  let dims = sizes.map(s => measure(make(s)))

  let rots = ((0,),)
  if rotate { rots.push((_upright(mid), _upright(mid + 90))) }
  let found = none
  for rs in rots {
    for (i, size) in sizes.enumerate() {
      for rot in rs {
        for r in radii {
          if found == none and rect-in-wedge(r, mid, dims.at(i).width, dims.at(i).height, r-in, r-out, half-span, rot: rot, pad: pad) {
            found = (size: size, r: r, rot: rot, w: dims.at(i).width, h: dims.at(i).height)
          }
        }
      }
    }
  }
  found
}

/// Breaks a label wider than `max-w` onto several lines, the lines leaning
/// toward the mark it names (right-aligned on the left of a circle, left-aligned
/// on the right). Without this one long name pushes a whole chart small.
///
/// - body (content): Label
/// - max-w (length): Widest the label may be
/// - angle (float): Degrees clockwise from 3 o'clock of the mark it names
/// -> content
#let wrap-label(body, max-w, angle) = {
  if measure(body).width <= max-w { body } else {
    let c = calc.cos(angle * 1deg)
    let al = if c < -0.3 { right } else if c > 0.3 { left } else { center }
    box(width: max-w, align(al, par(justify: false, leading: 0.4em, body)))
  }
}

/// Places `body` centred on (`x`, `y`), optionally turned by `rot` degrees
/// clockwise (see `fit-wedge-label`).
///
/// - x (length): Centre x
/// - y (length): Centre y
/// - w (length): Label width
/// - h (length): Label height
/// - body (content): Label
/// - rot (float): Rotation, degrees clockwise
/// -> content
#let place-centred(x, y, w, h, body, rot: 0) = {
  let b = box(width: w + 1pt, height: h, align(center + horizon, body))
  place(left + top, dx: x - w / 2 - 0.5pt, dy: y - h / 2,
    if rot == 0 { b } else { rotate(rot * 1deg, b) })  // Typst turns positive angles clockwise, like screen angles
}

// ── Outside a circle ────────────────────────────────────────────────────

// Top-left of a w×h label for a mark at (mx, my): a continuous slide from
// left of the point (angle 0) to centred above/below it (angle ±90°) to
// right of it (angle 180°), then nudged outward until no part of the label
// is nearer the mark than `gap` (a big label at a diagonal would otherwise
// graze the mark it names).
#let _slot(angle, w, h, mx, my, gap) = {
  let (c, s) = (calc.cos(angle * 1deg), calc.sin(angle * 1deg))
  let (x, y) = (mx + gap * c - w * (1 - c) / 2, my + gap * s - h * (1 - s) / 2)
  for _ in range(6) {
    let (ex, ey) = (calc.max(x - mx, 0pt, mx - x - w), calc.max(y - my, 0pt, my - y - h))
    let d = calc.sqrt((ex / 1pt) * (ex / 1pt) + (ey / 1pt) * (ey / 1pt)) * 1pt
    if d >= gap - 0.05pt { break }
    // How fast moving along (c, s) opens the gap, given where the nearest point is
    let (ux, uy) = (if x > mx { 1 } else { -1 }, if y > my { 1 } else { -1 })
    let rate = if d == 0pt { 1.0 } else { calc.max(0.25, (ux * ex / 1pt * c + uy * ey / 1pt * s) / (d / 1pt)) }
    x += (gap - d) / rate * c
    y += (gap - d) / rate * s
  }
  (x, y)
}

// Slides labels apart vertically until none overlaps another it shares
// horizontal space with, each staying as near as it can to where it wanted
// to be: pairwise relaxation (overlapping pair moves half each way), then an
// exact sweep down and back up so nothing is left touching. Returns the new
// `ly` of every label; what still cannot fit inside `bounds` stays
// overlapping, for the caller to drop.
// (fonts.typ's greedy-deconflict leaves clusters of three or more stacked on
// the same row, so it is not used here.)
#let _spread(props, bounds, gap) = {
  let n = props.len()
  let order = array.range(n).sorted(key: i => (props.at(i).ly, i))
  let ys = props.map(p => p.ly)
  let hit(a, b) = props.at(a).lx < props.at(b).lx + props.at(b).w and props.at(b).lx < props.at(a).lx + props.at(a).w
  let clamp(i) = calc.max(bounds.top, calc.min(bounds.bottom - props.at(i).h, ys.at(i)))

  for _ in range(40) {
    let moved = false
    for ai in range(n) {
      for bi in range(ai + 1, n) {
        let (a, b) = (order.at(ai), order.at(bi))
        let d = props.at(a).h + gap - (ys.at(b) - ys.at(a))
        if d > 0pt and hit(a, b) {
          ys.at(a) -= d / 2
          ys.at(b) += d / 2
          moved = true
        }
      }
    }
    for i in range(n) { ys.at(i) = clamp(i) }
    if not moved { break }
  }
  for bi in range(n) {
    for ai in range(bi) {
      let (a, b) = (order.at(ai), order.at(bi))
      if hit(a, b) { ys.at(b) = calc.max(ys.at(b), ys.at(a) + props.at(a).h + gap) }
    }
  }
  for bi in range(n - 1, -1, step: -1) {
    let b = order.at(bi)
    ys.at(b) = calc.min(ys.at(b), bounds.bottom - props.at(b).h)
    for ai in range(bi) {
      let a = order.at(ai)
      if hit(a, b) { ys.at(a) = calc.min(ys.at(a), ys.at(b) - props.at(a).h - gap) }
    }
  }
  ys.map(y => calc.max(y, bounds.top))
}

/// Half-width and half-height of the box, centred on the chart, that holds a
/// circle of radius `r` and every outside label around it (see
/// `place-outside-labels`).
///
/// - items (array): Dictionaries with `angle` (degrees) and `body`
/// - r (length): Circle radius
/// - gap (length): Distance between circle and label
/// - pad (length): Clearance beyond the labels
/// -> dictionary with `x` and `y`
#let polar-label-extent(items, r, gap: 4pt, pad: 1pt) = {
  let (xs, ys) = ((r,), (r,))
  for it in items {
    let m = measure(it.body)
    let (c, s) = (calc.cos(it.angle * 1deg), calc.sin(it.angle * 1deg))
    let (lx, ly) = _slot(it.angle, m.width + 1pt, m.height, r * c, r * s, gap)
    xs += (calc.abs(lx), calc.abs(lx + m.width + 1pt))
    ys += (calc.abs(ly), calc.abs(ly + m.height))
  }
  (x: calc.max(..xs) + pad, y: calc.max(..ys) + pad)
}

/// Biggest circle radius at which every outside label (see
/// `place-outside-labels`) still fits inside a `box-w`×`box-h` box centred
/// on (`cx`, `cy`).
///
/// - items (array): Dictionaries with `angle` (degrees) and `body`
/// - cx (length): Centre x
/// - cy (length): Centre y
/// - box-w (length): Box width
/// - box-h (length): Box height
/// - gap (length): Distance between circle and label
/// - pad (length): Clearance from the box's edges
/// -> length
#let polar-fit-radius(items, cx, cy, box-w, box-h, gap: 4pt, pad: 1pt) = {
  let sizes = items.map(it => { let m = measure(it.body); (m.width + 1pt, m.height) })
  // How far the labels poke out of the box when the circle has radius r
  let over(r) = {
    let worst = r - (calc.min(cx, cy, box-w - cx, box-h - cy) - pad)
    for (it, (w, h)) in items.zip(sizes) {
      let (x, y) = _slot(it.angle, w, h, r * calc.cos(it.angle * 1deg), r * calc.sin(it.angle * 1deg), gap)
      worst = calc.max(worst, cx + x + w - (box-w - pad), pad - (cx + x), cy + y + h - (box-h - pad), pad - (cy + y))
    }
    worst
  }
  // Bisection: `over` only grows with r
  let (lo, hi) = (calc.min(cx, cy) * 0.25, calc.min(cx, cy, box-w - cx, box-h - cy) - pad)
  if over(hi) <= 0pt { hi } else {
    for _ in range(12) {
      let mid = (lo + hi) / 2
      if over(mid) <= 0pt { lo = mid } else { hi = mid }
    }
    lo
  }
}

/// Labels around a circle: each label sits just beyond its own mark, labels
/// that would collide are slid apart vertically, and a displaced label gets a
/// leader line back to its mark. A label that still cannot be placed without
/// touching another is dropped (lowest `priority` first).
///
/// - items (array): Dictionaries with `angle` (degrees), `body` (content),
///   and optionally `r` (where the mark ends, default `r`) and `priority`
///   (default 0; higher survives)
/// - cx (length): Centre x
/// - cy (length): Centre y
/// - r (length): Default radius of the marks
/// - bounds (dictionary): `left`, `right`, `top`, `bottom` the labels must stay inside
/// - gap (length): Distance between mark and label
/// - leader-stroke (stroke): Style of the leader lines
/// - tol (length): How far a label may slide before it earns a leader
/// -> content
#let place-outside-labels(items, cx, cy, r, bounds, gap: 4pt, leader-stroke: 0.5pt + gray, tol: 1.5pt) = {
  let props = ()
  for (i, it) in items.enumerate() {
    let m = measure(it.body)
    let (w, h) = (m.width + 1pt, m.height)
    let ar = it.at("r", default: r)
    let (ax, ay) = polar-pt(cx, cy, ar, it.angle)
    let (lx, ly) = _slot(it.angle, w, h, ax, ay, gap)
    props.push((cx: ax, cy: ay, lx: lx, ly: ly, lx0: lx, ly0: ly, w: w, h: h, idx: i, angle: it.angle,
      priority: it.at("priority", default: 0), body: it.body))
  }

  // More labels on a side than it has room for: keep the highest priority
  let room = calc.max(1, calc.floor((bounds.bottom - bounds.top) / (calc.max(..props.map(p => p.h), 1pt) + 2pt)))
  let kept = ()
  for left-side in (true, false) {
    let side = props.filter(p => (calc.cos(p.angle * 1deg) < 0) == left-side)
    kept += side.sorted(key: p => (-p.priority, p.idx)).slice(0, calc.min(side.len(), room + 2))
  }

  let ys = _spread(kept, bounds, 2pt)
  let placed = kept.enumerate().map(((i, p)) => (..p, ly: ys.at(i),
    lx: calc.max(bounds.left, calc.min(bounds.right - p.w, p.lx))))

  // Greedy deconfliction can leave a crowded cluster overlapping: drop those
  let shown = ()
  for p in placed.sorted(key: p => (-p.priority, p.idx)) {
    let clash = shown.any(q => p.lx < q.lx + q.w and q.lx < p.lx + p.w and p.ly < q.ly + q.h and q.ly < p.ly + p.h)
    if not clash { shown.push(p) }
  }

  for p in shown {
    let c = calc.cos(p.angle * 1deg)
    let moved = calc.abs(p.ly - p.ly0) > tol or calc.abs(p.lx - p.lx0) > tol
    let (ax, ay) = (p.cx, p.cy)
    let h-align = if c < -0.3 { right } else if c > 0.3 { left } else { center }
    place(left + top, dx: p.lx, dy: p.ly,
      box(width: p.w, height: p.h, align(h-align + horizon, p.body)))
    // Leader from the mark to the nearest point of the label
    let (tx, ty) = (calc.max(p.lx, calc.min(p.lx + p.w, ax)), calc.max(p.ly, calc.min(p.ly + p.h, ay)))
    let (dx, dy) = ((tx - ax) / 1pt, (ty - ay) / 1pt)
    let len = calc.sqrt(dx * dx + dy * dy)
    if moved and len > 3 {
      place(left + top, line(start: (ax, ay), end: (tx - dx / len * 1.5pt, ty - dy / len * 1.5pt), stroke: leader-stroke))
    }
  }
}
