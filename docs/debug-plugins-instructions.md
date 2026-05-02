# Debug Plugin Instructions

## Copilot Suggestions Not Appearing

### Check state from normal mode

```vim
" Check if toggle was accidentally turned off
:lua =vim.g.copilot_enabled

" Check if copilot client is attached to current buffer
:lua =require("copilot.client").buf_is_attached(0)

" Check auto_trigger internal state (source of truth)
:lua =require("copilot.suggestion").auto_trigger

" General health check
:checkhealth copilot

" View copilot logs for errors
:Copilot log
```

### Check / force from inside insert mode

```vim
" Temporarily map a key to manually fetch next suggestion
:lua vim.keymap.set("i", "<C-x><C-c>", require("copilot.suggestion").next)
```

### Fix desynced auto_trigger

`vim.g.copilot_enabled` is only a display tracker — the real state lives in
`require("copilot.suggestion").auto_trigger`. They can desync if `<leader>ad`
was hit accidentally.

If `auto_trigger` returns `false`, re-enable it:

```vim
:lua require("copilot.suggestion").toggle_auto_trigger()
```

### Common causes

- `<leader>ad` accidentally pressed → `auto_trigger` flipped to `false`
- `buf_is_attached(0)` returns `false` → copilot never initialized for the buffer (loaded before buffer existed, or filetype excluded)
