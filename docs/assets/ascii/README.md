# Vendored: ascii-magic-art

Animated ASCII art for the docs home page.

- Source: https://github.com/kailashsr38/ascii-magic-art (commit `b324cb0`, 2026-10-27)
- License: MIT, see `LICENSE` in this folder. Copyright (c) 2026 ASCII Magic (ascii-magic.com).
- Piece: `pieces/reps-rept-loop.js` is ours: adapted from upstream `test-runner-dots`
  (pytest output) to show the rePS loop with Pester output from the real
  `core-fizzbuzz` exercise. The other files are copied unmodified.

Local patches to `runtime/ascii.js` (marked `rePS patch`):

1. A start token, so the element never runs two players when its upgrade calls `start()`
   from both `attributeChangedCallback` and `connectedCallback`.
2. When not animating (`still` attribute or `prefers-reduced-motion`), render the piece's
   `meta.stillAt` frame instead of `t = 0`.

`docs/javascripts/hero.js` adds the pause/play button.

Only the runtime files the piece needs are copied, keeping the upstream layout
(`runtime/`, `lib/`, `pieces/`), because `runtime/ascii.js` resolves pieces relative to
its parent folder. None of them make network requests.

To use another piece, copy `pieces/<slug>.js` from the same commit and set
`piece="<slug>"`. Check its imports first: some pieces need `lib/scene.js` or `lib/image.js`.
