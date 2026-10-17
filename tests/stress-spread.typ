// stress-spread.typ - The one label spreader, drawn
//
// Not part of test-all: a visual stress sheet (test-spread.typ asserts the same
// contracts). Compile it and look at the pages:
//   typst compile --root . tests/stress-spread.typ
// Every cell is a crowd of labels that all want (nearly) the same place. Nothing
// may overlap; a label that finds no room is left out, never drawn on another.

#import "../src/primitives/fonts.typ": spread-labels
#import "../src/primitives/polar-labels.typ": place-outside-labels

#set page(margin: 0.6cm, paper: "a4")
#set text(size: 7pt)

#let cells(cols, ..items) = grid(
  columns: (1fr,) * cols,
  column-gutter: 8pt,
  row-gutter: 12pt,
  ..items.pos().map(it => align(center + top, it)),
)

#let ink = rgb("#2a4d7a")
#let faint = luma(150)

// ── A column of labels beside a line of dots ────────────────────────────────
//
// `wants` are the dots; each label is a box of its own height, drawn at the place the
// spreader gives it, with a leader to its dot. `lo`..`hi` is the room (shown as ticks).
#let column(wants, sizes: 9pt, gap: 1pt, lo: 0pt, hi: 120pt, priority: none, caption: none, min-gap: 0pt) = {
  let pos = spread-labels(wants, sizes: sizes, gap: gap, min-gap: min-gap, lo: lo, hi: hi, priority: priority)
  let size-of(i) = if type(sizes) == array { sizes.at(i) } else { sizes }
  let left-out = pos.filter(p => p == none).len()
  stack(spacing: 3pt,
    box(width: 92pt, height: hi + 4pt, {
      place(left + top, dx: 6pt, dy: lo, line(start: (0pt, 0pt), end: (0pt, hi - lo), stroke: 0.5pt + faint))
      for y in (lo, hi) { place(left + top, dx: 3pt, dy: y, line(length: 6pt, stroke: 0.5pt + faint)) }
      for (i, y) in wants.enumerate() {
        place(left + top, dx: 6pt - 1.5pt, dy: y - 1.5pt, circle(radius: 1.5pt, fill: ink, stroke: none))
        if pos.at(i) != none {
          let h = size-of(i)
          place(left + top, line(start: (7.5pt, y), end: (22pt, pos.at(i)), stroke: 0.4pt + faint))
          place(left + top, dx: 22pt, dy: pos.at(i) - h / 2,
            box(width: 52pt, height: h, stroke: 0.4pt + ink, fill: ink.lighten(88%), inset: (x: 2pt),
              align(horizon + left, text(size: 5.5pt)[Label #(i + 1)])))
        }
      }
    }),
    text(size: 6pt, fill: faint)[#if caption != none [#caption] else [#wants.len() labels]#if left-out > 0 [, #left-out left out]],
  )
}

// n labels wanting the same place, 0.5pt apart (a worst case), in the middle of the room
#let crowd(n, ..args) = column(range(n).map(i => 60pt + i * 0.5pt), caption: [#n at one place], ..args)

= The spreader: crowds in a column

Two to thirteen labels, all wanting the same place (the dots), in a room of 120pt. Up to
12 keep their 1pt gap; 13 x 9pt leaves 3pt for twelve gaps, so the gap is squeezed. No
overlaps, evenly spaced, centred on the dots.

#cells(6, ..range(2, 14).map(n => crowd(n, sizes: 9pt, gap: 1pt)))

== Away from the middle: pressed against an end of the room

#cells(6,
  ..range(2, 8).map(n => column(range(n).map(i => 4pt + i * 0.5pt), caption: [#n at the top], sizes: 9pt)),
  ..range(2, 8).map(n => column(range(n).map(i => 116pt - i * 0.5pt), caption: [#n at the bottom], sizes: 9pt)),
)

== Labels of different heights, shuffled input order

#cells(4,
  column((70pt, 20pt, 72pt, 21pt, 50pt, 69pt, 95pt), sizes: (12pt, 8pt, 16pt, 8pt, 10pt, 8pt, 12pt), caption: [mixed heights, any order]),
  column((30pt, 31pt, 32pt, 33pt, 34pt, 80pt, 81pt, 82pt), sizes: (8pt, 14pt, 8pt, 14pt, 8pt, 8pt, 14pt, 8pt), caption: [two clusters]),
  column((10pt, 40pt, 25pt, 70pt, 55pt), sizes: 8pt, caption: [already clear: nothing moves]),
  column((60pt,), sizes: 8pt, caption: [one label]),
)

#pagebreak()

== When the room is short

The gap (3pt) is squeezed first; then labels are left out, the lowest priority first,
then the most crowded one (the first and the last go last), so what is left is thinned
evenly.

#cells(6,
  column(range(8).map(i => 40pt + i * 1pt), sizes: 9pt, gap: 3pt, hi: 80pt, caption: [8 in 80pt: gap squeezed]),
  column(range(8).map(i => 40pt + i * 1pt), sizes: 9pt, gap: 3pt, min-gap: 3pt, hi: 80pt, caption: [same, gap kept: thinned]),
  column(range(12).map(i => 8pt + i * 5pt), sizes: 9pt, hi: 80pt, caption: [12 spread out, room for 8]),
  column(range(12).map(i => 8pt + i * 5pt), sizes: 9pt, hi: 80pt, priority: range(12).map(i => if i >= 4 and i <= 8 { 9 } else { 1 }), caption: [labels 5 to 9 win]),
  column(range(20).map(i => 60pt + i * 0.5pt), sizes: 9pt, hi: 60pt, caption: [20 in room for 6]),
  column(range(5).map(i => 60pt + i * 1pt), sizes: 30pt, hi: 70pt, caption: [tall labels: 2 fit]),
)

= The same spreader along a circle

Outside labels of a pie: a crowd of 3, 6, 9 and 12 marks at 12, 3, 6 and 9 o'clock
(a degree apart). The labels fan out sideways at the top and bottom and up and down at
the sides; none touches another.

#let ring(n, at) = {
  let w = 150pt
  let h = 110pt
  box(width: w, height: h, context {
    let items = range(n).map(i => (angle: at + (i - (n - 1) / 2) * 1.0, body: text(size: 6.5pt)[Segment #(i + 1)]))
    place(left + top, dx: w / 2 - 26pt, dy: h / 2 - 26pt, circle(radius: 26pt, fill: ink.lighten(70%), stroke: none))
    place-outside-labels(items, w / 2, h / 2, 26pt, (left: 0pt, right: w, top: 0pt, bottom: h), gap: 4pt, leader-stroke: 0.4pt + faint)
  })
}

#cells(4,
  ..(270, 0, 90, 180).map(at => ring(3, at)),
  ..(270, 0, 90, 180).map(at => ring(6, at)),
  ..(270, 0, 90, 180).map(at => ring(9, at)),
  ..(270, 0, 90, 180).map(at => ring(12, at)),
)
