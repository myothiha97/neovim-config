# Syntax Palette: Follow-ups

## Status

**Closed 2026-07-22 as WONTFIX.** A real green/yellow collision was found,
measured, and a working fix was built and tested on real files — then reverted.
Every colour that separates cleanly looks worse than the collision does. The
palette is back to its 2026-07-21 state and that is the intended end state.

Current selections:

| role | value | L\* | chroma C\* | Lab hue |
| --- | --- | --- | --- | --- |
| yellow | `#aea10c` (`balanced`) | 65.4 | 67.4 | 97.9 |
| cyan (theme) | `#2aa298` | 60.4 | 34.6 | 186.9 |
| green | `#849900` (`solarized`) | 59.7 | 66.9 | 110.7 |
| blue | `#1d98cd` (`azure`) | 59.1 | 38.5 | 249.9 |
| red | `#b55f4a` (`terracotta`) | 50.1 | 42.9 | 40.1 |

Green and yellow measure **dE2000 9.9** apart. That is below the threshold where
small text glyphs stay distinguishable, and it is accepted knowingly. Do NOT
reopen the palette outside a scheduled config session, and do not "fix" this
without asking — it has already been fixed once and rejected.

### Benchmark against other dark themes (2026-07-22)

The palette was suspected of running bright and was measured against
`tokyonight-night` and `catppuccin-mocha`, both installed, by loading each
colorscheme and querying the same highlight groups.

| | mean accent L\* | mean perceived L\* | mean contrast | max C\* | background L\* |
| --- | --- | --- | --- | --- | --- |
| **solarized-osaka** | 59.2 | **65.6** | **6.0:1** | **67.4** | **3.9** |
| tokyonight-night | 74.3 | 78.9 | 8.5:1 | 55.0 | 10.1 |
| catppuccin-mocha | 79.0 | 83.4 | 9.5:1 | 45.7 | 12.0 |

"Perceived L\*" applies the Fairchild-Pirrotta Helmholtz-Kohlrausch correction,
which *flatters* saturated colours — and this palette still comes out the dimmest
of the three by 13-18 points.

**Conclusion: it is not too bright. If anything it runs dim.** What is unusual is
chroma — max 67.4 against 55.0 and 45.7 — on a background that is itself 6-8 L\*
points darker than theirs. High chroma against near-black is what reads as glare.

Practical consequence: when this palette feels "too bright", the fix is **chroma,
never lightness**. Lowering lightness makes an already-dim palette dimmer while
leaving the actual cause untouched.

The one genuine weak spot the benchmark surfaced is not yellow:

- `@variable.parameter` terracotta `#b55f4a` sits at **4.33:1**, just under the
  WCAG AA 4.5:1 floor for body text.
- `Comment` `#576d74` sits at 3.54:1, though dim comments are intentional.

Neither is worth acting on unless they cause real trouble — noted so the next
session does not rediscover them.

### The 2026-07-22 green/yellow fix

**Yellow is the colour that is out of position, but green is the one that moved.**
Worth understanding before touching either again.

The selected yellow sits at Lab hue 98. Solarized's own yellow is at 84. That 14
degree drift put it 12.6 degrees from the theme's olive green (110.7), at
near-identical lightness and chroma — **dE2000 8.3**, the same colour on small
glyphs.

Yellow could not be moved back, and its chroma is not a lever:

- Hue down is the theme's stock gold (hue 84-86), rejected on sight as too
  orange. Hue up is green itself.
- Dropping yellow's chroma does nothing: even at C\* 34 the olive pair only
  reaches dE2000 12.0, because 13 degrees of hue is the entire problem. Worse,
  a lower-chroma yellow *reduces* the chroma-gap term, so green then has to sit
  at hue 136 instead of 134 to clear it.
- Lightness is not a lever either, at least not usably: at hue 98 the pair does
  not clear dE2000 20 until L\* 85, a near-fluorescent lemon.

That left only green, and green could not move to anywhere acceptable either.

### Green is chosen on hue, not chroma

The opposite of the first read, and the thing that cost this session three
rounds. Verified against real files:

| candidate | hue | C\* | verdict |
| --- | --- | --- | --- |
| `solarized` `#859900` | 110.7 | 66.9 | **kept** — collides, but reads best |
| `grass` `#56a325` | 129.9 | 70.3 | too bright |
| `clover` `#599e49` | 136.0 | 53.8 | still too bright |
| `moss` `#629959` | 138.1 | 41.9 | closest call, still rejected on hue |

The highest-chroma option reads calmest, and dropping chroma 25 points did not
stop hue 136 reading as vivid. Below hue ~122 green reads warm and olive; above
~130 it reads kelly green. **The entire warm band is inside collision range**, so
no green is both warm and clear of yellow.

That is why this closed as WONTFIX: the fix works, it just costs the warm olive,
and the warmth is worth more in daily use than the separation is.

### A per-language split was tried and removed

Yellow density does differ sharply by language:

| language | what is yellow |
| --- | --- |
| TSX / JSX | `@tag.tsx` — every `<div>`, `<p>`, `<span>` — plus `Type` |
| Go | `Type` (`int`, `string`, `float64`) |
| Python | `Type` (`str` annotations) |
| Lua | nothing |

That suggested scoping a separate green to `tsx` / `typescript` / `javascript`
and keeping the olive elsewhere. It was implemented and then reverted: Go is not
sparse enough. Every function signature (`func sum(nums ...int) int`) puts an
olive keyword directly beside a yellow type, so the collision showed up there
too. **Do not retry the split** — the premise that only JSX is yellow-dense is
wrong.

### If this ever gets reopened

Everything tried is saved by name in the palette file, so re-testing is a
one-word edit to the `return` block. The full fix that was built and reverted:

| pair | as shipped (now) | with `moss` + `balanced` |
| --- | --- | --- |
| green / yellow | **8.3** | 21.9 |
| green / cyan | 30.6 | 18.7 |
| cyan / blue | 21.8 | 21.8 |

Note that green/cyan gets *worse* under the fix. It stays usable — the two are
49 degrees apart in hue and dE2000 understates hue separation at low chroma —
but it is a second reason the trade was not clearly worth taking.

The only untried direction, if the collision ever becomes genuinely painful in
daily work: move `Type` off yellow instead of moving green. That kills the
collision at its source (a keyword only ever touches yellow via a type
annotation or a JSX tag) while leaving both green and yellow alone. Measured
worst-case separation against every Go neighbour: magenta `#cc3399` scores 24.5,
violet `#a3a9e8` scores 19.2. Cyan and blue both fail — they collide with
strings and function names respectively.

## Remaining Work

All three are "slightly better" changes, which rule 1 says is never a reason on
its own. Review at the 2026-09-20 checkpoint and most likely drop them.

### 1. Neutral brackets in dense JSX

`@punctuation.bracket` currently shares terracotta with `@variable.parameter`.
JSX carries roughly 3x the punctuation density of Go, so TSX shows far more of it
than any other filetype. Pointing brackets at a neutral `c.base01` (L\* 44.8, no
hue) would calm TSX without touching Go or Python.

Only do this if dense JSX actually reads busy in daily work.

### 2. TS/JS variables are an accent, other languages are not — DONE

Closed. `solarized-osaka.lua` links `@variable.typescript` and
`@variable.javascript` back to `@variable`, so plain variables use `base0` in
every JS/TS file and match Go and Python.

Verified this is not overridden by LSP: `groups/semantic_tokens.lua` sets
`["@lsp.type.variable"] = {}` so treesitter wins.

### 3. Brighter yellow variant — DROPPED

`variants.yellow.brighter` (`#baac0d`) is still saved. It sits at hue 98 like
`darker`, so it now works fine against the retuned green. Superseded by item 2
regardless.

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
- **Check every new accent against the whole palette with dE2000, not by eye.**
  Rough reading for small text glyphs: under 10 is confusable, 10-20 is
  distinguishable but tiring, over 20 is unambiguous. Judging one colour in
  isolation is what let yellow drift into green on 2026-07-21 — it looked fine
  alone and only failed next to keywords in real TSX.
- **Judge green on hue, not chroma.** The 2026-07-22 session wasted three rounds
  assuming "too bright" meant chroma. It did not: `solarized` at C\* 66.9 reads
  calm and `clover` at C\* 53.8 reads bright, because the difference is hue 111
  vs 136. Chroma only decides flat vs alive *within* a hue.
- **Check a candidate in every language before shipping it.** The binding
  neighbour changes: TSX is yellow-dense (`@tag.tsx`), Go and Python are
  cyan-dense (strings) with almost no yellow, Lua has neither. A green that
  passes in one can fail in another, and testing only TSX is what produced two
  rejected greens in a row.
- **Scoping to a language family is legitimate here.** The theme already defines
  `@keyword.tsx` / `@keyword.javascript` separately, so a per-family override
  follows its grain rather than fighting it. Prefer it over degrading a colour
  in four languages to fix one.
