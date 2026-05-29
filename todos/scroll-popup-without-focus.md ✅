# ✅ Scroll Popup Without Focus (Ctrl-e / Ctrl-y)

> Implemented in `lua/config/keymaps.lua`. Bound to `<C-e>` / `<C-y>` (semantically the right fit: vim's "scroll viewport by N lines without moving cursor" keys). Tunable rate via `POPUP_SCROLL_LINES` (currently 1).

## Goal
`<C-e>` / `<C-y>` should scroll a visible info popup (hover docs, signature help, diagnostic float, any LSP info popup) without moving the cursor into it. Inside the popup the scroll is N lines (`POPUP_SCROLL_LINES`, currently 1) for smooth, fine-grained reading. When no popup is active, fall back to native `<C-e>` / `<C-y>` (no recenter — these are viewport nudges, not jumps).

## Motivation
Reading long docs (e.g. JSDoc, multi-line Python docstrings) currently requires `K` then `gk` (or `KK`) to enter the popup, scroll, `<Esc>` to exit. With this binding, you stay in the buffer and just scroll the popup in place — same UX you'd get in VS Code / IntelliJ.

## Behavior
- Popup visible → scroll the popup's window by a half-page (or N lines)
- No popup → execute native `<C-d>` / `<C-u>` (`'scroll'` option in current window)
- Multiple floats → scroll the first focusable, non-picker float (same selection rule used by `gk` in `lua/config/keymaps.lua`)

## Implementation sketch
```lua
local function scroll_popup_or(delta_keys, fallback_keys)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local cfg = vim.api.nvim_win_get_config(win)
    if cfg.relative ~= "" and cfg.focusable ~= false then
      local buf = vim.api.nvim_win_get_buf(win)
      local ft = vim.bo[buf].filetype
      if not ft:match("^snacks_picker") then
        -- Scroll the float without changing focus.
        vim.api.nvim_win_call(win, function()
          vim.cmd("normal! " .. delta_keys)
        end)
        return
      end
    end
  end
  -- "n" flag = no-remap, so we hit the built-in C-d / C-u.
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(fallback_keys, true, true, true), "n", false)
end

vim.keymap.set("n", "<C-d>", function()
  scroll_popup_or(vim.api.nvim_replace_termcodes("<C-d>", true, true, true), "<C-d>")
end, { desc = "Scroll Popup Down / Half-Page Down" })

vim.keymap.set("n", "<C-u>", function()
  scroll_popup_or(vim.api.nvim_replace_termcodes("<C-u>", true, true, true), "<C-u>")
end, { desc = "Scroll Popup Up / Half-Page Up" })
```

## Things to decide before coding
- **Scroll amount inside popup** — use the popup's own `'scroll'` (half its visible height, native vim behavior) or a fixed N? Half-height is more consistent with the fallback.
- **Insert mode** — should `<C-d>` in insert mode also scroll a visible signature popup? Native `<C-d>` in insert is "shift line left one shiftwidth" — non-trivial collision. Probably **don't bind insert mode** unless we have a concrete need; signature help is normally consulted in insert mode but with `<M-i>` to open and `<Esc>` to close, scrolling is rare.
- **Visual mode** — leave alone. Native `<C-d>` in visual still scrolls.
- **Float types to skip** — currently skipping `^snacks_picker`. Also consider skipping floats where scrolling makes no sense (notification toasts, single-line floats). Easy check: skip if buffer has fewer than the window's height lines (no scroll possible anyway, falling through to fallback would be wrong — so probably just no-op).

## Why `nvim_win_call`
`nvim_win_call(win, fn)` runs `fn` with that window temporarily current, then restores focus. It triggers `WinEnter`/`WinLeave` on the float but **does NOT trigger `BufLeave` on the original buffer** (the buffer never changes from vim's POV), so the mouse-hover BufLeave-close path (`lua/config/mouse-hover.lua:491-504`) won't fire. This is the key trick — it lets us issue `normal! <C-d>` inside the popup without the side effects that closed the popup on `gk` before that bug was fixed.

## Related
- `gk` (enter popup) — `lua/config/keymaps.lua` (search "Focus Hover/Signature Popup")
- `<Esc>` (close any float) — `lua/config/keymaps.lua:39-66`
- Mouse-hover BufLeave guard — `lua/config/mouse-hover.lua:491-509` (already fixed to not close on focus-into-float)
- Noice scroll API (`require("noice.lsp").scroll(delta)`) — not applicable here since `noice.lsp.hover/signature.enabled = false` in `lua/plugins/performance.lua:24-25`; LSP popups are native, not noice.

## Test plan
1. Open a TS/Go/Python file, `K` on a symbol with long docs → `<C-d>` scrolls popup content, cursor stays in buffer.
2. `<C-u>` scrolls back up.
3. Close popup (`<Esc>`), `<C-d>` → native half-page scroll works.
4. Open `gi` line diagnostic with long message → `<C-d>` scrolls it (or no-op gracefully if content fits).
5. With snacks picker open, `<C-d>` should NOT scroll the picker's preview — picker manages its own scroll.
