// container.typ - Chart container wrapper

#import "../theme.typ": *
#import "./title.typ": draw-title

/// Fallback inset for non-theme contexts (e.g. heatmap overhead calc).
/// Charts should use theme.container-inset instead.
#let container-inset = 8pt

/// Space between a chart and a legend beside it.
#let legend-gap = 10pt

// Wraps chart body in a box with optional background/border and title.
// Adds inset padding so light and dark themes render at the same outer size.
//
// By default the outer height is `height + extra-height + title-overhead`, an
// estimate the caller has to get right. With `fit: true` the container instead
// takes the height of what it holds (title, legend and a `height`-tall body), so
// nothing has to be guessed and nothing can overflow. In fit mode
// `legend-width: auto` sizes a side legend to its content.
#let chart-container(width, height, title, theme, extra-height: 0pt, legend: none, legend-width: 120pt, extra-legend-separation: 0pt, subtitle: none, radius: 0pt, fit: false, body) = {
  let has-bg = theme.background != none
  let pad = theme.at("container-inset", default: container-inset)
  let has-subtitle = subtitle != none
  let subtitle-overhead = if has-subtitle { theme.at("subtitle-size", default: theme.axis-title-size) + 3pt } else { 0pt }
  let title-overhead = if title != none { theme.title-size + theme.title-gap + 4pt + subtitle-overhead } else { if has-subtitle { subtitle-overhead + theme.title-gap + 4pt } else { 0pt } }
  let lp = theme.legend-position
  let side-legend = (lp == "right" or lp == "left") and legend != none
  let gap = if side-legend { legend-gap } else { 0pt }
  let build(legend-width) = box(
    width: if side-legend { width + gap + legend-width + 2 * pad } else { width + 2 * pad },
    height: if fit { auto } else { height + extra-height + title-overhead + 2 * pad },
    fill: theme.background,
    stroke: theme.border,
    inset: pad,
    radius: radius,
  )[
    // Charts are sized by the theme, not the document: pin the ambient text
    // size (Typst's default) so flow spacing, leading and the spaces between
    // legend entries don't shift with the document's `set text(size: ..)`.
    #set text(size: 11pt)
    #draw-title(title, theme, subtitle: subtitle)
    #if lp == "top" and legend != none {
      legend
      v(extra-legend-separation)
    }
    #if lp == "right" and legend != none {
      context {
        let legend-h = measure(legend).height
        // Center legend relative to chart; allow negative dy when legend is taller
        let legend-dy = (height - legend-h) / 2
        let content-h = calc.max(height, legend-h)
        // Shift both chart and legend down if legend extends above chart
        let base-dy = if legend-dy < 0pt { -legend-dy } else { 0pt }
        box(width: width + legend-gap + legend-width, height: content-h)[
          #place(left + top, dy: base-dy, box(width: width, height: height, body))
          #place(left + top, dx: width + legend-gap + extra-legend-separation, dy: base-dy + legend-dy,
            box(width: legend-width, legend))
        ]
      }
    } else if lp == "left" and legend != none {
      context {
        let legend-h = measure(legend).height
        let legend-dy = (height - legend-h) / 2
        let content-h = calc.max(height, legend-h)
        let base-dy = if legend-dy < 0pt { -legend-dy } else { 0pt }
        box(width: width + legend-gap + legend-width, height: content-h,)[
          #place(left + top, dy: base-dy + legend-dy, dx: -extra-legend-separation,
            box(width: legend-width, legend))
          #place(left + top, dx: legend-width + legend-gap, dy: base-dy,
            box(width: width, height: height, body))
        ]
      }
    } else {
      body
      if legend != none and lp == "bottom" {
        v(extra-legend-separation)
        legend
      }
    }
  ]
  if fit and side-legend and legend-width == auto {
    context build(measure(legend).width)
  } else {
    build(legend-width)
  }
}
