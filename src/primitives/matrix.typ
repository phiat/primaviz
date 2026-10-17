// matrix.typ - Layout for grids with row and column labels (heatmaps,
// correlation matrices, calendars)
//
// The grid's two label gutters are measured from the labels, not guessed from
// theme paddings: the row gutter is as wide as the widest row label, and the
// column gutter is as tall as the column labels need. Column labels stay
// horizontal whenever they fit their cells (shrinking a little first), turn 45
// degrees only when they cannot, and are thinned only when even rotated ones
// would collide. Functions measure text, so call them inside `context`.

#import "../theme.typ": *
#import "fonts.typ": text-width, text-height, max-text-width, fit-font-size, pin, place-centered

/// Lays out the label gutters around a `cell-w` × `cell-h` grid.
///
/// Returns a dictionary:
/// - `labels`: content to place at the origin of the chart box: row labels
///   right-aligned against the grid, column labels above it
/// - `gx`, `gy`: where the grid's top-left corner goes
/// - `row-w`, `header-h`: gutter sizes (the row gutter includes its gap)
/// - `overhang`: how far the last column label sticks out to the right of the grid
/// - `col-mode`: `"horizontal"` or `"rotated"`
/// - `size`: label size used
///
/// - row-labels (array): One label per row
/// - col-labels (array): One label per column
/// - cell-w (length): Cell width
/// - cell-h (length): Cell height
/// - theme (dictionary): Resolved theme
/// - max-row-w (none, length): Cap on the row gutter; wider labels shrink, then wrap
/// - label-fill (auto, color): Label colour
/// -> dictionary
#let matrix-layout(
  row-labels,
  col-labels,
  cell-w,
  cell-h,
  theme,
  max-row-w: none,
  label-fill: auto,
) = {
  let base = theme.axis-label-size
  let gap = theme.axis-label-gap
  let off = theme.label-offset + 1pt
  let fill = if label-fill == auto { theme.text-color } else { label-fill }
  let n-rows = row-labels.len()
  let n-cols = col-labels.len()

  // --- Row gutter: widest row label, measured ---
  let r-size = calc.min(base, cell-h * 0.85)
  let r-stride = 1
  if r-size < 5pt {
    r-size = 5pt
    r-stride = int(calc.ceil(r-size * 1.3 / cell-h))
  }
  let r-widest = row-labels.fold("", (a, b) => if text-width(b, r-size) > text-width(a, r-size) { b } else { a })
  if max-row-w != none and text-width(r-widest, r-size) > max-row-w - gap {
    r-size = fit-font-size(r-widest, max-row-w - gap, r-size, min: calc.max(6pt, r-size * 0.75))
  }
  let r-w = text-width(r-widest, r-size)
  let r-cap = if max-row-w != none { max-row-w - gap } else { r-w }
  let r-box = calc.min(r-w, r-cap)
  if r-w > r-cap { r-size = calc.max(5pt, calc.min(r-size, cell-h * 0.9 / 2.3)) }
  let row-w = r-box + gap

  // --- Column labels: horizontal if they fit, else rotated, else thinned ---
  let c-widest = col-labels.fold("", (a, b) => if text-width(b, base) > text-width(a, base) { b } else { a })
  let slack = 4pt
  let c-size = fit-font-size(c-widest, cell-w - slack, base, min: calc.max(6pt, base * 0.8))
  let horizontal = text-width(c-widest, c-size) <= cell-w - slack
  let c-size = if horizontal { c-size } else { base }
  let lh = text-height("Mg", c-size)
  let c-stride = 1
  let header-h = 0pt
  let overhang = 0pt
  if n-cols > 0 {
    if horizontal {
      header-h = lh + off
    } else {
      // A 45 degree label's neighbour is 0.7 cell-w away across the slant
      c-stride = int(calc.ceil(lh * 1.4 / (0.7071 * cell-w)))
      let shown = col-labels.enumerate().filter(((j, _)) => calc.rem(j, c-stride) == 0).map(((_, l)) => l)
      let wmax = max-text-width(shown, c-size)
      header-h = (wmax + lh) * 0.7071 + off
      let last = shown.last()
      overhang = calc.max(0pt, (text-width(last, c-size) + lh) * 0.7071 - cell-w / 2)
    }
  }

  let drawn = {
    for (i, l) in row-labels.enumerate() {
      if calc.rem(i, r-stride) != 0 { continue }
      place-centered(0pt, header-h + (i + 0.5) * cell-h,
        text(size: r-size, fill: fill)[#l], width: r-box, align: right)
    }
    for (j, l) in col-labels.enumerate() {
      if calc.rem(j, c-stride) != 0 { continue }
      let cx = row-w + (j + 0.5) * cell-w
      if horizontal {
        place(left + top, dx: cx - text-width(l, c-size) / 2, dy: header-h - off - lh,
          text(size: c-size, fill: fill)[#l])
      } else {
        place(left + top, dx: cx, dy: header-h - off - lh,
          rotate(-45deg, origin: bottom + left, text(size: c-size, fill: fill)[#l]))
      }
    }
  }

  (
    labels: drawn,
    gx: row-w,
    gy: header-h,
    row-w: row-w,
    header-h: header-h,
    overhang: overhang,
    col-mode: if horizontal { "horizontal" } else { "rotated" },
    size: c-size,
  )
}

/// One font size for every value written inside the cells of a grid: the
/// largest size, up to `base`, at which the widest value fits a cell.
/// `none` when even the smallest readable size does not fit (the caller then
/// omits the values rather than printing over cell edges).
///
/// - strs (array): The value strings that will be printed
/// - cell-w (length): Cell width
/// - cell-h (length): Cell height
/// - theme (dictionary): Resolved theme
/// - min (length): Smallest readable size
/// -> none, length
#let cell-label-size(strs, cell-w, cell-h, theme, min: 5pt) = {
  let base = calc.min(theme.axis-label-size, cell-h * 0.7)
  if strs.len() == 0 { return base }
  let widest = strs.fold("", (a, b) => if text-width(b, base) > text-width(a, base) { b } else { a })
  let size = fit-font-size(widest, cell-w - 4pt, base, min: min)
  if size < min or text-width(widest, size) > cell-w - 3pt { none } else { size }
}
