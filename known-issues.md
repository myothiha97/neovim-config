# To Fix Config

All issues below have been resolved.

## [RESOLVED] snack smart picker not working as expected

**Fix applied:** Added explicit `smart` source configuration in `lua/plugins/snacks.lua` with:

- `frecency = true` for frequency-based sorting (most recently/frequently used files rank higher)
- `cwd_bonus = true` to prioritize files in current working directory
- `sort_empty = true` to sort even when filter is empty
- Explicit `multi = { "buffers", "recent", "files" }` ordering

## [RESOLVED] ASCII characters in pasted text

**Fix applied:** Disabled bracketed paste mode in `lua/config/options.lua`:

- Added `vim.cmd([[set t_BE=]])` to disable bracketed paste escape sequences
- This prevents terminal escape sequences like `[27;5;106~` from appearing in pasted text

**Note:** If issue persists, it may be a Ghostty terminal setting. Check Ghostty config for `clipboard-paste-bracketed-safe` option.

## [PARTIAL] Copilot single-line suggestions

**Fix applied:** Updated `lua/plugins/copilot.lua`:

- Enabled the Copilot panel (`panel.enabled = true`) for viewing multi-line suggestions
- Reduced debounce from 75ms to 50ms for faster triggering
- Added `hide_during_completion = false` to keep suggestions visible
- Added `filetypes = { ["*"] = true }` to enable for all file types

**Note:** Multi-line inline suggestions are a known limitation with copilot.lua in JS/TS files.

## [RESOLVED] Disable buffer navigation with Shift+H/L

**Fix applied:** Added to `lua/config/keymaps.lua`:

```lua
vim.keymap.del("n", "<S-h>")
vim.keymap.del("n", "<S-l>")
```

This removes the LazyVim default buffer navigation keymaps.

---

# Future TODO

## Copilot manual trigger and panel keymaps

Need to investigate and implement working keymaps for:

- `<leader>at` - Manual trigger for Copilot suggestions from normal mode
- `<M-o>` - Manual trigger for Copilot suggestions in insert mode
- `<leader>ap` - Open Copilot panel for multi-line suggestions

Current attempts using `suggestion.next()` and `require("copilot.panel").open()` did not work as expected.
