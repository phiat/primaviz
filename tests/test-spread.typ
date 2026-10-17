// test-spread.typ - spread-labels, the one 1-D label spreader (fonts.typ)
//
// Assertions only: the compile fails if a contract breaks. For a look at the
// same cases drawn, see stress-spread.typ.

#import "../src/primitives/fonts.typ": spread-labels

#set page(margin: 0.5cm)

= spread-labels

#let near(a, b) = calc.abs(a - b) < 0.02pt
#let size-of(sizes, i) = if type(sizes) == array { sizes.at(i) } else { sizes }

// Pseudo-random numbers in [0, 1), always the same
#let lcg(seed, count) = {
  let out = ()
  let x = seed
  for _ in range(count) {
    x = calc.rem(x * 1103515245 + 12345, 2147483648)
    out.push(x / 2147483648)
  }
  out
}

// What every layout promises: labels that were given a place keep their order, do not
// overlap and stay inside lo..hi. Returns the places.
#let check(wants, sizes, gap, lo, hi, tag) = {
  let pos = spread-labels(wants, sizes: sizes, gap: gap, lo: lo, hi: hi)
  assert(pos.len() == wants.len(), message: tag + ": one place per label")
  let kept = range(wants.len()).filter(i => pos.at(i) != none)
  let order = kept.sorted(key: i => (wants.at(i), i))
  for k in range(1, order.len()) {
    let (a, b) = (order.at(k - 1), order.at(k))
    let least = (size-of(sizes, a) + size-of(sizes, b)) / 2
    assert(pos.at(b) - pos.at(a) >= least - 0.02pt,
      message: tag + ": labels " + str(a) + " and " + str(b) + " overlap: " + repr(pos))
  }
  for i in kept {
    if lo != none { assert(pos.at(i) - size-of(sizes, i) / 2 >= lo - 0.02pt, message: tag + ": label " + str(i) + " above lo") }
    if hi != none { assert(pos.at(i) + size-of(sizes, i) / 2 <= hi + 0.02pt, message: tag + ": label " + str(i) + " below hi") }
  }
  pos
}

== Labels that already clear each other stay put

#{
  let wants = (10pt, 40pt, 25pt, 70pt)
  let pos = check(wants, 8pt, 2pt, 0pt, 100pt, "clear")
  for k in range(4) { assert(near(pos.at(k), wants.at(k)), message: "clear labels must not move: " + repr(pos)) }
  [clear labels: unchanged]
}

== A cluster is centred on where its members wanted to be

#{
  let pos = check((50pt, 50pt), 10pt, 0pt, 0pt, 100pt, "pair")
  assert(near(pos.at(0), 45pt) and near(pos.at(1), 55pt), message: "a tied pair parts evenly: " + repr(pos))
  // three, one of them off to the side: the least total movement
  let pos3 = check((50pt, 50pt, 50pt), 10pt, 0pt, 0pt, 100pt, "triple")
  assert(near(pos3.at(0), 40pt) and near(pos3.at(1), 50pt) and near(pos3.at(2), 60pt), message: "triple: " + repr(pos3))
  [cluster: centred]
}

== Seven labels that all want the same place (the case greedy deconfliction got wrong)

#{
  let wants = range(7).map(i => 104pt + i * 2pt)
  let pos = check(wants, 8pt, 2pt, none, none, "seven")
  for k in range(1, 7) { assert(near(pos.at(k) - pos.at(k - 1), 10pt), message: "seven: pitch 10pt " + repr(pos)) }
  // centred on the mean wish
  assert(near((pos.first() + pos.last()) / 2, (wants.first() + wants.last()) / 2), message: "seven: centred")
  [seven: even pitch, centred]
}

== Input order does not matter; results come back in input order

#{
  let wants = (80pt, 20pt, 82pt, 21pt, 50pt, 79pt)
  let sizes = (8pt, 6pt, 10pt, 6pt, 8pt, 8pt)
  let pos = check(wants, sizes, 1pt, 0pt, 120pt, "shuffled")
  let order = range(6).sorted(key: i => wants.at(i))
  let sorted-wants = order.map(i => wants.at(i))
  let sorted-sizes = order.map(i => sizes.at(i))
  let sorted-pos = check(sorted-wants, sorted-sizes, 1pt, 0pt, 120pt, "sorted")
  for (k, i) in order.enumerate() { assert(near(pos.at(i), sorted-pos.at(k)), message: "same layout in any order") }
  [order: ok]
}

== Equal wishes keep their input order

#{
  let pos = check((30pt, 30pt, 30pt, 30pt), 6pt, 0pt, 0pt, 100pt, "ties")
  for k in range(1, 4) { assert(pos.at(k) > pos.at(k - 1), message: "ties keep input order: " + repr(pos)) }
  [ties: ok]
}

== Bounds clamp, whatever the label wants

#{
  let up = check((-50pt,), 12pt, 0pt, 0pt, 100pt, "clamp-lo")
  assert(near(up.first(), 6pt), message: "clamped to lo + half: " + repr(up))
  let down = check((500pt,), 12pt, 0pt, 0pt, 100pt, "clamp-hi")
  assert(near(down.first(), 94pt), message: "clamped to hi - half: " + repr(down))
  // a cluster pressed against the end keeps its spacing
  let against = check((98pt, 99pt, 100pt), 10pt, 0pt, 0pt, 100pt, "against-hi")
  assert(near(against.last(), 95pt) and near(against.at(0), 75pt), message: "pushed back from hi: " + repr(against))
  // only one end bounded
  let lo-only = spread-labels((-5pt, -4pt), sizes: 10pt, lo: 0pt)
  assert(near(lo-only.at(0), 5pt) and near(lo-only.at(1), 15pt), message: "lo only: " + repr(lo-only))
  let hi-only = spread-labels((105pt, 104pt), sizes: 10pt, hi: 100pt)
  assert(near(hi-only.at(0), 95pt) and near(hi-only.at(1), 85pt), message: "hi only: " + repr(hi-only))
  [bounds: ok]
}

== Never overlapping when a solution exists (random clusters, 2 to 12 labels)

#{
  let trials = 0
  for seed in range(1, 121) {
    let n = 2 + calc.rem(seed, 11)
    let r = lcg(seed * 7919, 3 * n)
    let wants = range(n).map(i => r.at(i) * 100pt)
    let sizes = range(n).map(i => 4pt + r.at(n + i) * 8pt)
    let gap = r.at(2 * n) * 3pt
    let need = sizes.sum() + (n - 1) * gap
    // room for all, with a little to spare
    let pos = check(wants, sizes, gap, 0pt, need * 1.1 + 5pt, "random " + str(seed))
    assert(not pos.contains(none), message: "random " + str(seed) + ": all fit, none may be left out")
    // and the clear space asked for is kept when the room has it
    let order = range(n).sorted(key: i => (wants.at(i), i))
    for k in range(1, n) {
      let (a, b) = (order.at(k - 1), order.at(k))
      assert(pos.at(b) - pos.at(a) >= (sizes.at(a) + sizes.at(b)) / 2 + gap - 0.02pt, message: "random " + str(seed) + ": gap kept")
    }
    trials += 1
  }
  [#trials random clusters: no overlaps, none left out]
}

== When the room is short: the gap is squeezed first

#{
  // 5 labels of 10pt with 4pt gaps need 66pt; 54pt holds them touching-ish (gap 1pt)
  let pos = check((10pt, 11pt, 12pt, 13pt, 14pt), 10pt, 4pt, 0pt, 54pt, "squeeze")
  assert(not pos.contains(none), message: "squeeze: everything still shown")
  assert(near(pos.at(1) - pos.at(0), 11pt), message: "squeeze: gap shrinks evenly to 1pt: " + repr(pos))
  // no squeezing allowed: labels are left out instead
  let strict = spread-labels((10pt, 11pt, 12pt, 13pt, 14pt), sizes: 10pt, gap: 4pt, min-gap: 4pt, lo: 0pt, hi: 54pt)
  assert(strict.filter(p => p == none).len() == 1, message: "strict: one label is left out: " + repr(strict))
  [squeeze: ok]
}

== When the room cannot hold them: the lowest priority goes first, the rest never overlap

#{
  let wants = (50pt, 51pt, 52pt, 53pt, 54pt)
  let pos = check(wants, 10pt, 0pt, 0pt, 30pt, "priority")
  assert(pos.filter(p => p != none).len() == 3, message: "room for three: " + repr(pos))
  let pri = spread-labels(wants, sizes: 10pt, lo: 0pt, hi: 30pt, priority: (1, 1, 9, 1, 9))
  assert(pri.at(2) != none and pri.at(4) != none, message: "the priorities survive: " + repr(pri))
  assert(pri.filter(p => p != none).len() == 3, message: "three kept: " + repr(pri))
  [priority: ok]
}

== Without priorities the survivors are thinned evenly, the ends kept

#{
  let wants = range(9).map(i => i * 10pt)
  let pos = check(wants, 6pt, 0pt, 0pt, 5 * 6pt, "thin")
  let kept = range(9).filter(i => pos.at(i) != none)
  assert(kept == (0, 2, 4, 6, 8), message: "even thinning: " + repr(kept))
  // a crowd that cannot fit anywhere: first and last survive longest
  let crowd = range(20).map(i => i * 1pt)
  let c = check(crowd, 6pt, 0pt, 0pt, 3 * 6pt, "crowd")
  assert(c.first() != none and c.last() != none, message: "ends kept: " + repr(c))
  assert(c.filter(p => p != none).len() == 3, message: "room for three: " + repr(c))
  [thinning: ok]
}

== A label bigger than the room is centred, not lost

#{
  let pos = spread-labels((10pt,), sizes: 40pt, lo: 0pt, hi: 30pt)
  assert(near(pos.first(), 15pt), message: "oversize label centred: " + repr(pos))
  [oversize: ok]
}

== Empty and single

#{
  assert(spread-labels(()) == (), message: "empty")
  assert(near(spread-labels((7pt,)).first(), 7pt), message: "single, unbounded: unchanged")
  [edge cases: ok]
}

== `need`: spacing that depends on the pair (here, along a circle: degrees as points)

#{
  // neighbour a then b need 10 "degrees" plus 5 per index step: 0, 10, 25 ... apart
  let pos = spread-labels((30pt, 30pt, 30pt), need: (a, b) => 10pt + 5pt * b)
  assert(near(pos.at(1) - pos.at(0), 15pt) and near(pos.at(2) - pos.at(1), 20pt), message: "need: " + repr(pos))
  assert(near((pos.at(0) + pos.at(1) + pos.at(2)) / 3, 30pt), message: "need: centred on the wish: " + repr(pos))
  // same wishes, same layout through sizes and through need
  let a = spread-labels((20pt, 22pt, 60pt), sizes: 8pt, gap: 2pt)
  let b = spread-labels((20pt, 22pt, 60pt), need: (x, y) => 10pt)
  for k in range(3) { assert(near(a.at(k), b.at(k)), message: "need == sizes + gap") }
  [need: ok]
}
