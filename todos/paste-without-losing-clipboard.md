
# Paste Without Losing Clipboard Content

## Goal
Override the default `p` behavior so that pasting over a selection does not replace the clipboard with the deleted text.

## Proposed Keymap
```lua
vim.keymap.set("n", "<leader>p", ':let @/=@"<CR>"_dP', { silent = true })
```

## Notes
- The default `p` in visual mode sends the replaced text into the unnamed register, overwriting the original clipboard content.
- `"_dP` deletes into the black-hole register and then pastes, preserving the original yank.
- Decide whether to bind this to `<leader>p` or override `p` directly in visual mode.
