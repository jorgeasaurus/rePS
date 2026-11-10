# Vendored: ascii-magic-art

Animated ASCII art for the docs home page.

- Source: https://github.com/kailashsr38/ascii-magic-art (commit `b324cb0`, 2026-10-27)
- License: MIT, see `LICENSE` in this folder. Copyright (c) 2026 ASCII Magic (ascii-magic.com).
- Piece: `pieces/reps-rept-loop.js` is ours: adapted from upstream `test-runner-dots`
  (pytest output) to show the rePS loop with Pester output from the real
  `core-fizzbuzz` exercise. The other files are copied unmodified.

Only the runtime files the piece needs are copied, keeping the upstream layout
(`runtime/`, `lib/`, `pieces/`), because `runtime/ascii.js` resolves pieces relative to
its parent folder. None of them make network requests.

To use another piece, copy `pieces/<slug>.js` from the same commit and set
`piece="<slug>"`. Check its imports first: some pieces need `lib/scene.js` or `lib/image.js`.
