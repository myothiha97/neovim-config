# Syntax Palette: Follow-ups

## Status

Done and committed on 2026-07-21. Blue and red were retuned in
`lua/colorschemes/solarized-osaka-palette.lua`; yellow was left alone.

Final selections:

| role | value | L\* | chroma C\* |
| --- | --- | --- | --- |
| yellow | `#a3970b` (`darker`) | 61.6 | 64.2 |
| cyan (theme) | `#2aa298` | 60.5 | 34.7 |
| green (theme) | `#859900` | 59.7 | 67.0 |
| blue | `#1d98cd` (`azure`) | 59.1 | 38.5 |
| red | `#b55f4a` (`terracotta`) | 50.1 | 42.9 |

The four accents now sit inside 2.5 L\* points, with `base0` variables above them
at 69.2 and punctuation below at 50.1. Nothing below is required. Do NOT reopen
the palette outside a scheduled config session.

## Remaining Work

All three are "slightly better" changes, which rule 1 says is never a reason on
its own. Review at the 2026-09-20 checkpoint and most likely drop them.

### 1. Neutral brackets in dense JSX

`@punctuation.bracket` currently shares terracotta with `@variable.parameter`.
JSX carries roughly 3x the punctuation density of Go, so TSX shows far more of it
than any other filetype. Pointing brackets at a neutral `c.base01` (L\* 44.8, no
hue) would calm TSX without touching Go or Python.

Only do this if dense JSX actually reads busy in daily work.

### 2. TS/JS variables are an accent, other languages are not

`@variable.typescript` and `@variable.javascript` are painted yellow by the theme
(`groups/treesitter.lua`), while Go and Python variables use `base0`. TypeScript
therefore reads ~7.6 L\* softer than Go. Overriding both to `c.base0` in
`on_highlights` would make all three languages consistent.

Verified this is not overridden by LSP: `groups/semantic_tokens.lua` sets
`["@lsp.type.variable"] = {}` so treesitter wins.

### 3. Brighter yellow variant

`variants.yellow.brighter` (`#baac0d`, L\* 69.5) matches `base0` almost exactly.
An alternative to item 2 that keeps yellow variables but lifts them to body-text
weight. Mutually exclusive with item 2, not both.

## Notes

- Tune on **hue and chroma, never lightness**. Lightness-only changes on text
  glyphs land below the perceptual threshold and return no signal. The 2026-07-21
  session lost most of its time to this: 8 of 11 saved red variants sat within
  2.4 degrees of the same hue and all felt identical.
- Background is `hsl(192, 100%, 5%)`. Keep accent hues clear of it, and if one
  must sit close, keep chroma above ~35 or it reads muddy. This is why `balanced`
  (`#4488ab`, C\* 27.2) failed.
- Error red is `#ff3b30` (Lab hue 3 degrees). Keep the punctuation red clear of it
  so brackets never read as diagnostics.
- Every tested colour is kept as a named variant in the palette file, so any swap
  is a one-word edit to the `return` block at the bottom.
