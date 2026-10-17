// reserve.typ - Exact height reservation for chart-container
//
// chart-container sizes its box from a formula (`title-size + title-gap + 4pt`
// for the title) and a caller-supplied `extra-height` for everything else. The
// real title block is taller than the formula and a legend has a height of its
// own, so charts that guess `extra-height` (30pt, 50pt...) clip a bottom legend
// or leave dead bands. `container-extra` measures what the container will
// actually flow and returns the shortfall, so a chart passes
// `extra-height: container-extra(...)` and the box fits its content exactly.
//
// This is a workaround that lives next to chart-container, not in it: once the
// container measures its own title and legend, this file can go.

#import "../theme.typ": *
#import "./title.typ": draw-title
#import "./container.typ": container-inset

/// Extra height a chart-container needs so that its title, body and legend fit.
///
/// Mirrors chart-container's own flow (title, optional top legend, body,
/// optional bottom legend) inside `measure`, then subtracts what the container
/// already reserves from its formula. Call inside `context`, with the same
/// arguments you give the container.
///
/// - width (length): Body width given to chart-container
/// - height (length): Body height given to chart-container
/// - title (none, content): Title
/// - theme (dictionary): Resolved theme
/// - subtitle (none, content): Subtitle
/// - legend (none, content): Legend content given to chart-container
/// - extra-legend-separation (length): Separation given to chart-container
/// - legend-width (length): Side legend width given to chart-container
/// - floor (length): Reserve at least this much (a chart's own axis padding)
/// -> length
#let container-extra(
  width,
  height,
  title,
  theme,
  subtitle: none,
  legend: none,
  extra-legend-separation: 0pt,
  legend-width: 120pt,
  floor: 0pt,
) = {
  let lp = theme.legend-position
  let has-subtitle = subtitle != none
  let subtitle-overhead = if has-subtitle { theme.at("subtitle-size", default: theme.axis-title-size) + 3pt } else { 0pt }
  let title-overhead = if title != none {
    theme.title-size + theme.title-gap + 4pt + subtitle-overhead
  } else if has-subtitle { subtitle-overhead + theme.title-gap + 4pt } else { 0pt }

  let side = (lp == "right" or lp == "left") and legend != none
  let flow = measure(width: width, {
    set text(size: 11pt)
    draw-title(title, theme, subtitle: subtitle)
    if lp == "top" and legend != none { legend; v(extra-legend-separation) }
    box(width: width, height: height)
    if lp == "bottom" and legend != none { v(extra-legend-separation); legend }
  }).height
  // A side legend sits beside the body; it only adds height when it is taller
  let side-extra = if side {
    calc.max(0pt, measure(width: legend-width, legend).height - height)
  } else { 0pt }
  calc.max(floor, flow - height - title-overhead + 1pt) + side-extra
}
