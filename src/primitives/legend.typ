// legend.typ - Legend rendering primitives

#import "../theme.typ": *
#import "../util.typ": heat-color
#import "fonts.typ": pin

/// Side of a legend swatch. The theme's `legend-swatch-size` is an upper bound:
/// a swatch is a key to the label beside it, so it stays smaller than the label's
/// text and never dominates it.
///
/// - theme (dictionary): Resolved theme
/// -> length
#let legend-swatch-size(theme) = calc.min(theme.legend-swatch-size, theme.legend-size * 0.75)

// Optional legend title rendered above entries.
#let _legend-title(title, theme) = {
  if title != none {
    text(size: theme.legend-size, weight: "bold", fill: theme.text-color)[#title]
    v(3pt)
  }
}

// One legend entry: a swatch centred on the label's cap height, then the label.
// Swatch and label are one box so an entry never breaks across lines. It is
// built in code mode, with no markup spaces, so its width does not depend on the
// ambient text size (the legend is measured where it is made and drawn elsewhere).
#let _legend-entry(name, color, theme, swatch-type) = {
  let sz = legend-swatch-size(theme)
  // Shift that centres a swatch of height `h` on the label's cap-height band
  let centred(h) = (h - 0.66 * theme.legend-size) / 2
  box({
    if swatch-type == "line" {
      box(width: 1.6 * sz, height: theme.stroke-thick, fill: color, baseline: centred(theme.stroke-thick))
    } else if swatch-type == "circle" {
      box(width: sz, height: sz, baseline: centred(sz),
        circle(radius: sz / 2, fill: color, stroke: theme.marker-stroke))
    } else {
      box(width: sz, height: sz, fill: color, baseline: centred(sz), radius: sz * 0.2)
    }
    h(0.4 * sz)
    text(size: theme.legend-size, fill: theme.text-color)[#name]
  })
}

// Name and color of the i-th legend entry (a string or a dict with name/color).
#let _entry-parts(entry, i, theme) = (
  if type(entry) == dictionary and "name" in entry { entry.name } else { entry },
  if type(entry) == dictionary and "color" in entry { entry.color } else { get-color(theme, i) },
)

// Horizontal legend (for bar, line, area charts).
#let draw-legend(entries, theme, swatch-type: "box", title: none) = {
  v(5pt)
  align(center, {
    _legend-title(title, theme)
    for (i, entry) in entries.enumerate() {
      // Gaps go between entries, so the row stays centred
      if i > 0 { h(theme.legend-gap) }
      let (name, color) = _entry-parts(entry, i, theme)
      _legend-entry(name, color, theme, swatch-type)
    }
  })
}

// Vertical legend (for pie, radar, side panels). `width: auto` fits the widest entry.
#let draw-legend-vertical(entries, theme, width: 130pt, title: none, swatch-type: "box") = {
  box(width: width, {
    _legend-title(title, theme)
    for (i, entry) in entries.enumerate() {
      let (name, color) = _entry-parts(entry, i, theme)
      _legend-entry(name, color, theme, swatch-type)
      if i < entries.len() - 1 {
        linebreak()
        v(2pt)
      }
    }
  })
}

/// Automatically picks horizontal or vertical legend based on
/// `theme.legend-position`.  Returns `none` when the legend is
/// suppressed (`show-legend` is false or position is `"none"`).
///
/// - entries (array): Legend entries — strings or dicts with `name` (and optional `color`)
/// - theme (dictionary): Resolved theme
/// - show-legend (bool): Master toggle; when false nothing is rendered
/// - swatch-type (str): `"box"`, `"line"`, or `"circle"`
/// - title (none, str): Optional legend title displayed above entries
/// - fit-width (bool): Size a side legend to its widest entry instead of the default column
/// -> content, none
#let draw-legend-auto(entries, theme, show-legend: true, swatch-type: "box", title: none, fit-width: false) = {
  if not show-legend { return }
  if theme.legend-position == "none" { return }
  if entries.len() == 0 { return }

  if theme.legend-position == "right" or theme.legend-position == "left" {
    draw-legend-vertical(entries, theme, title: title, swatch-type: swatch-type, ..if fit-width { (width: auto) })
  } else {
    draw-legend(entries, theme, swatch-type: swatch-type, title: title)
  }
}

/// Gradient color bar legend for heatmaps and color-mapped charts.
///
/// Renders a vertical gradient bar with min/max labels. Can be placed
/// inline or absolutely positioned by the caller.
///
/// - min-val (number): Minimum data value (label at bottom)
/// - max-val (number): Maximum data value (label at top)
/// - palette (str, array): Palette name or color stop array
/// - theme (dictionary): Resolved theme
/// - bar-width (length): Width of the gradient bar
/// - bar-height (length): Height of the gradient bar
/// - steps (int): Number of discrete color segments
/// - reverse (bool): Reverse palette direction
/// -> content
#let draw-gradient-legend(min-val, max-val, palette, theme, bar-width: 15pt, bar-height: auto, steps: 30, reverse: false) = {
  let h = if bar-height == auto { 80pt } else { bar-height }
  let step-h = h / steps
  box(width: bar-width + 8pt, height: h + 4pt)[
    // Gradient bar
    #for i in array.range(steps) {
      let normalized = 1 - i / steps
      let cell-color = heat-color(normalized, palette: palette, reverse: reverse)
      place(left + top,
        dx: 0pt,
        dy: (i / steps) * h,
        rect(width: bar-width, height: step-h + 0.5pt, fill: cell-color, stroke: none))
    }
    // Max label (above bar)
    #place(left + top, dx: 0pt, dy: -2pt,
      pin(width: bar-width, align: center + bottom, text(size: theme.axis-label-size, fill: theme.text-color)[#calc.round(max-val, digits: 1)]))
    // Min label (below bar)
    #place(left + top, dx: 0pt, dy: h + 2pt,
      box(width: bar-width, align(center, text(size: theme.axis-label-size, fill: theme.text-color)[#calc.round(min-val, digits: 1)])))
  ]
}

/// Size legend for bubble charts — shows 2-3 reference circles with labels.
///
/// - sizes (array): Array of (value, label) pairs for reference bubbles
/// - max-radius (length): Maximum bubble radius (for scaling)
/// - max-value (number): Maximum data value (for scaling)
/// - theme (dictionary): Resolved theme
/// - title (none, str): Optional title (e.g., "Market Value (£M)")
/// -> content
#let draw-size-legend(sizes, max-radius, max-value, theme, title: none, max-legend-radius: 12pt) = {
  let cap = calc.min(max-radius, max-legend-radius)
  // One reference circle and its label, a single box (code mode: its width does
  // not depend on the ambient text size)
  let entry(val, lbl) = box({
    let r = calc.max(2pt, cap * calc.sqrt(val / calc.max(1, max-value)))
    box(baseline: r - 1pt, box(width: 2 * r, height: 2 * r,
      circle(radius: r, fill: none, stroke: theme.text-color-light + 0.75pt)))
    h(2pt)
    text(size: theme.legend-size, fill: theme.text-color)[#lbl]
  })
  if theme.legend-position == "right" or theme.legend-position == "left" {
    // Beside the chart: a column, like the series legend
    box({
      _legend-title(title, theme)
      for (i, (val, lbl)) in sizes.enumerate() {
        entry(val, lbl)
        if i < sizes.len() - 1 { linebreak(); v(2pt) }
      }
    })
  } else {
    v(3pt)
    align(center, {
      if title != none {
        text(size: theme.legend-size, fill: theme.text-color)[#title]
        h(6pt)
      }
      for (i, (val, lbl)) in sizes.enumerate() {
        if i > 0 { h(8pt) }
        entry(val, lbl)
      }
    })
  }
}
