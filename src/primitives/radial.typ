// radial.typ - Frame helpers shared by the radial charts
//
// What every radial chart sets up around its circle: a side legend sized to
// its entries, a width budget, a title scaled to the chart.

#import "legend.typ": draw-legend-vertical
#import "container.typ": chart-container, container-inset
#import "title.typ": draw-title

/// A vertical legend sized to its entries, placed beside the chart by
/// `chart-container`. Returns `(legend, width, height, theme)`: pass
/// `theme` (with `legend-position` set to `position`) to the container, and
/// `max(0, height - chart-height)` as its `extra-height` when the legend is
/// taller than the chart.
///
/// - entries (array): Strings, or dictionaries with `name` (and `color`)
/// - theme (dictionary): Resolved theme
/// - enabled (bool): False yields no legend
/// - min-width (length): Narrowest the legend column may be
/// - max-width (length): Widest the legend column may be
/// - position (str): `"right"` or `"left"`
/// -> dictionary
#let side-legend(entries, theme, enabled: true, min-width: 60pt, max-width: 180pt, position: "right") = {
  if not enabled or entries.len() == 0 {
    (legend: none, width: 0pt, height: 0pt, theme: theme)
  } else {
    let names = entries.map(e => if type(e) == dictionary and "name" in e { e.name } else { e })
    let widest = calc.max(..names.map(n => measure(text(size: theme.legend-size)[#n]).width))
    let w = calc.max(min-width, calc.min(max-width, widest + theme.legend-swatch-size + 5pt))
    let legend = draw-legend-vertical(entries, theme, width: w)
    let themed = theme
    themed.insert("legend-position", position)
    (legend: legend, width: w, height: measure({ set text(size: 11pt); legend }).height, theme: themed)
  }
}

/// Splits the available width between a chart and what sits beside it
/// (legend column, label margins) so both stay inside the container.
/// The chart shrinks first, down to `floor`; below that the side shrinks too.
/// Returns `(chart-size, side-width)`.
///
/// - size (length): Wanted chart width
/// - side (length): Wanted width of everything beside the chart
/// - avail-w (length): Width of the containing region
/// - theme (dictionary): Resolved theme (for the container's inset)
/// - floor (length): Smallest chart worth drawing before the side gives way
/// -> array
#let split-width(size, side, avail-w, theme, floor: 80pt) = {
  if type(avail-w) != length or avail-w <= 0pt { return (size, side) }
  let budget = avail-w - 2 * theme.at("container-inset", default: container-inset)
  if size + side <= budget { (size, side) }
  else if side == 0pt { (calc.max(budget, 20pt), 0pt) }
  else if budget - side >= floor { (budget - side, side) }
  else { (budget * 0.55, budget * 0.45) }
}

/// The theme with its title scaled to a small chart: a full-size bold title
/// over an 80pt dial shouts over the heading of the group the dial sits in.
/// Charts of 130pt and more keep the theme's title size.
///
/// - theme (dictionary): Resolved theme
/// - chart-size (length): The chart's diameter or width
/// -> dictionary
#let title-for-size(theme, chart-size) = {
  let s = calc.max(theme.axis-label-size, calc.min(theme.title-size, chart-size * 0.1))
  if s >= theme.title-size { theme } else {
    let scaled = theme
    scaled.insert("title-size", s)
    scaled
  }
}

/// Height the title block needs beyond what `chart-container` reserves for
/// it, to pass as (part of) the container's `extra-height`. The container
/// budgets a title from font size and gap alone, so a chart that sizes the
/// container to its body would find the last line clipped by the border.
/// Measured against the container itself, so it stays right if the
/// container's budget changes (it is then 0).
///
/// - title (none, content): Chart title
/// - subtitle (none, content): Chart subtitle
/// - theme (dictionary): Resolved theme
/// - w (length): Width of the chart body
/// -> length
#let title-slack(title, subtitle, theme, w) = {
  if title == none and subtitle == none { 0pt } else {
    let claimed = measure(chart-container(w, 0pt, title, theme, subtitle: subtitle)[]).height
    // (an empty body box after the title: the paragraph gap between them counts)
    let need = measure(box(width: w)[#set text(size: 11pt); #draw-title(title, theme, subtitle: subtitle)#box(width: w, height: 0pt)]).height
    calc.max(0pt, need + 2 * theme.at("container-inset", default: container-inset) - claimed)
  }
}
