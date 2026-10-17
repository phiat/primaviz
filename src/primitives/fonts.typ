// fonts.typ - Font fitting, label placement, and deconfliction utilities

/// Checks whether a text label fits inside a given rectangular area.
///
/// Uses a heuristic based on character width ratio to estimate text width.
///
/// - available-width (length): Width of the container
/// - available-height (length): Height of the container
/// - text-size (length): Font size of the label
/// - text-len (int): Number of characters in the label
/// -> bool
#let label-fits-inside(available-width, available-height, text-size, text-len) = {
  let estimated-width = text-size * 0.6 * text-len
  let estimated-height = text-size * 1.2
  estimated-width <= available-width and estimated-height <= available-height
}

/// Largest font size, at or below `base-size`, whose label fits `available-width`.
///
/// Inverts the width heuristic `label-fits-inside` uses, so a label sized by
/// this function is one `label-fits-inside` accepts. Results are clamped to
/// `min-size` — a label that cannot fit stays readable rather than fitting.
///
/// - available-width (length): Width the label has to fit into
/// - base-size (length): Preferred/maximum font size
/// - text-len (int): Number of characters in the label
/// - min-size (length): Floor font size
/// -> length
#let font-to-fit-width(available-width, base-size, text-len, min-size: 4pt) = {
  if text-len <= 0 { return base-size }
  calc.max(min-size, calc.min(base-size, available-width / (0.6 * text-len)))
}

/// Returns a skip factor N so that showing every Nth label maintains min-spacing.
///
/// - count (int): Total number of labels
/// - available-length (length): Total available length for all labels
/// - min-spacing (length): Minimum spacing between label centers
/// -> int
#let density-skip(count, available-length, min-spacing: 12pt) = {
  if count <= 0 { return 1 }
  let per-label = available-length / count
  if per-label >= min-spacing { 1 } else { calc.ceil(min-spacing / per-label) }
}

/// Computes a font size that fits within the available space.
///
/// Returns `min(base-size, max(min-size, available * ratio))`.
///
/// - available (length): Available space (width or height)
/// - base-size (length): Preferred/maximum font size
/// - min-size (length): Floor font size
/// - ratio (float): Fraction of available space to use
/// -> length
#let font-for-space(available, base-size, min-size: 4pt, ratio: 0.6) = {
  calc.min(base-size, calc.max(min-size, available * ratio))
}

/// Tries shrinking a label font from `base-size` down to `shrink-min` until it fits.
///
/// Returns `(fits: bool, size: length)`.
///
/// - available-w (length): Width of the container
/// - available-h (length): Height of the container
/// - base-size (length): Starting (preferred) font size
/// - text-len (int): Number of characters in the label
/// - shrink-min (length): Minimum font size to try before giving up
/// -> dictionary
#let try-fit-label(available-w, available-h, base-size, text-len, shrink-min: 5pt) = {
  let steps = calc.max(1, int((base-size - shrink-min) / 1pt) + 1)
  let result = (fits: false, size: base-size)
  for i in range(steps) {
    let sz = base-size - i * 1pt
    if sz < shrink-min { break }
    if label-fits-inside(available-w, available-h, sz, text-len) {
      result = (fits: true, size: sz)
      break
    }
  }
  result
}

/// Single-pass greedy label deconfliction.
///
/// Takes an array of proposal dicts, each with keys `cx`, `cy`, `lx`, `ly`, `w`, `h`
/// (plus any extra keys which are preserved). Sorts by `ly`, then nudges overlapping
/// labels, trying both upward and downward and picking the direction that keeps the
/// label closest to its original proposed position.
///
/// - proposals (array): Array of label-position dicts
/// - bounds (dictionary): Dict with `left`, `right`, `top`, `bottom` keys
/// - gap (length): Minimum vertical gap between labels
/// -> array
#let greedy-deconflict(proposals, bounds, gap: 2pt) = {
  // Sort by ly (top position)
  let sorted = proposals.sorted(key: p => p.ly)
  let placed = ()
  for p in sorted {
    let ly = p.ly
    let orig-ly = p.ly
    // Check against all already-placed labels for overlaps
    let has-overlap = true
    let iters = 0
    // Iteratively resolve overlaps (max 10 iterations to avoid infinite loops)
    while has-overlap and iters < 10 {
      has-overlap = false
      iters += 1
      for prev in placed {
        let overlap-v = prev.ly + prev.h + gap - ly
        let overlap-h = not (p.lx + p.w <= prev.lx or prev.lx + prev.w <= p.lx)
        if overlap-h and overlap-v > 0pt {
          // Try nudging down
          let ly-down = prev.ly + prev.h + gap
          // Try nudging up (above the conflicting label)
          let ly-up = prev.ly - p.h - gap
          // Pick the direction closer to the original proposed position
          let dist-down = calc.abs((ly-down - orig-ly) / 1pt)
          let dist-up = calc.abs((ly-up - orig-ly) / 1pt)
          if ly-up >= bounds.top and dist-up <= dist-down {
            ly = ly-up
          } else {
            ly = ly-down
          }
          has-overlap = true
        }
      }
    }
    // Clamp to bounds
    let ly = calc.max(bounds.top, calc.min(bounds.bottom - p.h, ly))
    let lx = calc.max(bounds.left, calc.min(bounds.right - p.w, p.lx))
    let entry = (:)
    for (k, v) in p.pairs() {
      if k == "lx" { entry.insert(k, lx) }
      else if k == "ly" { entry.insert(k, ly) }
      else { entry.insert(k, v) }
    }
    placed.push(entry)
  }
  placed
}

/// Places a label near a Cartesian point with quadrant-aware alignment.
///
/// Clamps the label position to stay within the given bounds rectangle.
/// Optionally draws a leader line from the original point to the displaced label.
///
/// - x (length): Original x position
/// - y (length): Original y position
/// - body (content): Label content to place
/// - bounds (dictionary): Dict with `left`, `right`, `top`, `bottom` keys
/// - box-width (length): Width of the label box
/// - box-height (length): Height of the label box
/// - offset-y (length): Vertical offset from the point (negative = above)
/// - leader (bool): Whether to draw a leader line
/// - leader-stroke (stroke): Stroke style for the leader line
/// -> content
#let place-cartesian-label(x, y, body, bounds, box-width: 40pt, box-height: 12pt, offset-y: -12pt, leader: false, leader-stroke: 0.5pt + gray) = {
  // Determine quadrant-aware offset: push label away from center
  let cx = (bounds.left + bounds.right) / 2
  let cy = (bounds.top + bounds.bottom) / 2

  let offset-x = if x >= cx { 8pt } else { -8pt - box-width }

  // Compute displaced position
  let lx = x + offset-x
  let ly = y + offset-y

  // Clamp to bounds
  let lx = calc.max(bounds.left, calc.min(bounds.right - box-width, lx))
  let ly = calc.max(bounds.top, calc.min(bounds.bottom - box-height, ly))

  // Leader line from original point to label anchor
  if leader {
    place(left + top,
      line(start: (x, y), end: (lx + box-width / 2, ly + box-height / 2), stroke: leader-stroke))
  }

  // Label
  place(left + top, dx: lx, dy: ly,
    box(width: box-width, align(center, body)))
}

/// Pins a label to its placement point by vertical alignment, independent of
/// the surrounding document's font size.
///
/// `place(dy: y, pin(body))` centres `body` on `y`; with `align: bottom` it
/// sits on `y`, with `align: top` it hangs from it. Prefer this over
/// `move(dy: -0.5em, ...)`: an `em` there resolves against the document's
/// text size, not the label's, so labels drift when the document font changes.
///
/// - body (content): Label content
/// - width (auto, length): Box width (for horizontal alignment)
/// - align (alignment): Alignment within the zero-height box
/// -> content
#let pin(body, width: auto, align: horizon) = box(width: width, height: 0pt, std.align(align, body))

// ---------------------------------------------------------------------------
// Measured label helpers
//
// The functions above estimate text width from a character count (0.6 em per
// character). That is fine for coarse decisions but wrong for the cases that
// matter: bold text, wide capitals, CJK, math. The helpers below measure the
// real glyph run, so a label that "fits" does fit. They call `measure`, so
// they must run inside `context` (every chart body already does).
// ---------------------------------------------------------------------------

/// Measured width of `body` set at `size`.
///
/// - body (content, str): Label
/// - size (length): Font size
/// - weight (str, int): Font weight
/// -> length
#let text-width(body, size, weight: "regular") = measure(text(size: size, weight: weight)[#body]).width

/// Measured height of `body` set at `size` (one line, cap-height to baseline
/// plus any descender the content carries).
///
/// - body (content, str): Label
/// - size (length): Font size
/// - weight (str, int): Font weight
/// -> length
#let text-height(body, size, weight: "regular") = measure(text(size: size, weight: weight)[#body]).height

/// Widest of several labels, measured.
///
/// - labels (array): Labels
/// - size (length): Font size
/// - weight (str, int): Font weight
/// -> length
#let max-text-width(labels, size, weight: "regular") = {
  labels.fold(0pt, (acc, l) => calc.max(acc, text-width(l, size, weight: weight)))
}

/// Largest font size, between `min` and `base`, at which `body` fits in
/// `avail` (measured, not estimated). Glyph advances scale with the size, so
/// one measurement at `base` is enough. When even `min` is too big the result
/// is `min`: the caller decides whether to wrap, thin out or drop the label.
///
/// - body (content, str): Label
/// - avail (length): Width the label has to fit into
/// - base (length): Preferred size
/// - min (length): Floor size
/// - weight (str, int): Font weight
/// -> length
#let fit-font-size(body, avail, base, min: 5pt, weight: "regular") = {
  let w = text-width(body, base, weight: weight)
  if w <= avail or w <= 0pt { base } else { calc.max(min, base * (avail / w)) }
}

/// Every Nth label is enough when labels of width `label-w` are spaced
/// `pitch` apart: returns that N (at least 1). This is the first resort when
/// labels collide: thin them out, do not rotate them.
///
/// - label-w (length): Widest label
/// - pitch (length): Distance between neighbouring label centres
/// - gap (length): Clear space wanted between neighbouring labels
/// -> int
#let label-stride(label-w, pitch, gap: 4pt) = {
  if pitch <= 0pt { return 1 }
  calc.max(1, int(calc.ceil((label-w + gap) / pitch - 1e-9)))
}

/// `c` of `n` positions, spread evenly over the whole run, always including
/// the first and the last (when `c` is 1, only the first). Neighbours are at
/// least `floor((n - 1) / (c - 1))` positions apart.
///
/// - n (int): Number of positions
/// - c (int): How many to keep
/// -> array of ints, ascending
#let spread-indices(n, c) = {
  if n <= 0 or c <= 0 { return () }
  if c >= n { return array.range(n) }
  if c == 1 { return (0,) }
  array.range(c).map(j => int(calc.round(j * (n - 1) / (c - 1))))
}

/// Which of `n` evenly spaced positions to label when labels have to be
/// at least `k` positions apart. Unlike "every k-th from the first", the
/// labelled positions are spread evenly over the whole run and always include
/// the first and the last (never closer than `k` to each other); when not even
/// two fit, only the first is kept.
///
/// - n (int): Number of positions
/// - k (int): Minimum distance, in positions, between labelled ones
/// -> array of ints, ascending
#let thin-indices(n, k) = {
  if n <= 0 { return () }
  if k <= 1 or n == 1 { return array.range(n) }
  spread-indices(n, calc.quo(n - 1, k) + 1)
}

/// Label size for positions `pitch` apart (rows, columns): the largest size
/// up to `base` at which neighbouring labels do not touch (`line-k` is the
/// line height the label needs, in em; 1.0 leaves room for descenders). The
/// size shrinks to `floor` before anything is dropped; only if even `floor`
/// does not fit does `stride` rise above 1, to the number of positions
/// between labels (feed it to `thin-indices`).
///
/// - pitch (length): Distance between neighbouring label centres
/// - base (length): Preferred size
/// - floor (length): Smallest size worth printing
/// - line-k (float): Line height needed, in em
/// -> dictionary with `size` and `stride`
#let fit-pitch(pitch, base, floor: 5pt, line-k: 1.0) = {
  let s = calc.min(base, pitch / line-k)
  if s >= floor { (size: s, stride: 1) } else {
    (size: floor, stride: calc.max(2, int(calc.ceil(floor * line-k / pitch - 1e-9))))
  }
}

/// Spreads labels along one axis so none overlaps another, moving each as
/// little as possible and never reordering them.
///
/// Labels that collide are grouped and the group is centred on where its
/// members wanted to be (pool-adjacent-violators); the result is clamped into
/// `[lo, hi]`. If the labels cannot all fit, the spacing shrinks evenly.
///
/// - ys (array): Wanted centre of each label (lengths), in any order
/// - sep (length): Minimum distance between neighbouring centres (label height + gap)
/// - lo (none, length): Lowest allowed centre
/// - hi (none, length): Highest allowed centre
/// -> array of lengths, same order as `ys`
#let spread-1d(ys, sep, lo: none, hi: none) = {
  let n = ys.len()
  if n == 0 { return () }
  let sep = if lo != none and hi != none and n > 1 and (n - 1) * sep > hi - lo {
    (hi - lo) / (n - 1)
  } else { sep }
  let order = array.range(n).sorted(key: i => ys.at(i))
  let clamp-pos(pos, count) = {
    let p = pos
    if hi != none { p = calc.min(p, hi - (count - 1) * sep) }
    if lo != none { p = calc.max(p, lo) }
    p
  }
  // A block is a run of labels stacked `sep` apart; `sum` is the sum of its
  // members' wanted positions less their offset inside the block, so the
  // block's best position is sum / count.
  let blocks = ()
  for (k, i) in order.enumerate() {
    let blk = (count: 1, sum: ys.at(i), pos: clamp-pos(ys.at(i), 1))
    while blocks.len() > 0 {
      let prev = blocks.last()
      if prev.pos + prev.count * sep > blk.pos + 0.001pt {
        let _ = blocks.pop()
        let count = prev.count + blk.count
        let sum = prev.sum + blk.sum - blk.count * prev.count * sep
        blk = (count: count, sum: sum, pos: clamp-pos(sum / count, count))
      } else { break }
    }
    blocks.push(blk)
  }
  let sorted-pos = ()
  for blk in blocks {
    for j in array.range(blk.count) { sorted-pos.push(blk.pos + j * sep) }
  }
  let out = array.range(n).map(_ => 0pt)
  for (k, i) in order.enumerate() { out.at(i) = sorted-pos.at(k) }
  out
}

/// Places `body` with its vertical centre on `y` and its left edge on `x`,
/// whatever its height: the body is measured, so a wrapped or stacked
/// multi-line label is centred as a block. (A zero-height `box` aligned to
/// the horizon only works for one line; a stack inside one collapses.)
///
/// - x (length): Left edge of the label box
/// - y (length): Vertical centre
/// - body (content): Label
/// - width (auto, length): Box width; text wraps inside it
/// - align (alignment): Horizontal alignment inside the box
/// -> content
#let place-centered(x, y, body, width: auto, align: left) = {
  let b = box(width: width, std.align(align, body))
  let h = measure(b).height
  place(left + top, dx: x, dy: y - h / 2, b)
}

/// Decides how to set a label, with an optional second (detail) line, inside
/// a `w` × `h` cell: the largest size, from `base` down to `min`, at which the
/// label fits *measured*: on one line, or wrapped at spaces when no word is
/// wider than the cell. The detail line is added when it fits under the label.
///
/// Returns `none` when not even `min` fits: the caller then leaves the cell
/// unlabelled (or labels it elsewhere) instead of printing past its edges.
///
/// - label (content, str): Main label
/// - detail (none, content, str): Secondary line (a value, a share)
/// - w (length): Cell width available to text
/// - h (length): Cell height available to text
/// - base (length): Preferred size
/// - min (length): Smallest readable size
/// - weight (str, int): Weight of the main label
/// - detail-k (float): Detail size relative to the label
/// - lead-k (float): Space between the lines, in em of the label
/// -> none, dictionary with `size`, `wrapped` and `detail`
#let fit-cell-label(label, detail, w, h, base, min: 6pt, weight: "bold", detail-k: 0.85, lead-k: 0.25) = {
  if w <= 0pt or h <= 0pt { return none }
  let words = if type(label) == str { label.split(" ") } else { (label,) }
  let steps = int((base - min) / 0.5pt)
  for k in range(calc.max(steps, 0) + 1) {
    let s = base - k * 0.5pt
    if s * 1.2 > h { continue }
    let lw = text-width(label, s, weight: weight)
    let main-h = if lw <= w { s * 1.2 } else if max-text-width(words, s, weight: weight) <= w {
      measure(box(width: w, text(size: s, weight: weight)[#label])).height
    } else { none }
    if main-h == none or main-h > h { continue }
    let det-h = s * (detail-k * 1.2 + lead-k)
    let has-detail = detail != none and detail != "" and main-h + det-h <= h and text-width(detail, s * detail-k) <= w
    return (size: s, wrapped: lw > w, detail: has-detail)
  }
  none
}
