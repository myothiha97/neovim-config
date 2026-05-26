
# Snacks Explorer: Folder-click cursor flicker

## Issue
When clicking a folder in Snacks explorer, the cursor briefly jumps to the top of the list before returning to the clicked row. This creates a small flicker during folder expand/collapse.

## Root Cause
This appears to be an upstream Snacks issue, not our config.

Folder toggle uses:

`M.actions.confirm → Tree:toggle → M.update → picker:find()`

`picker:find()` refreshes the list asynchronously. During the brief gap between clearing and re-rendering the list, the target row does not exist yet, so the cursor temporarily renders at row 1. Once Snacks restores the target row, the final cursor position is correct.

This likely also affects keyboard `<CR>`, but mouse clicks make it more visible.

## Why we are not fixing it now
- The flicker happens inside Snacks’ async render pipeline.
- `lazyredraw` did not suppress the intermediate render.
- Deeper workarounds would require touching Snacks internals and may break on future updates.
- The issue is cosmetic and only lasts a few milliseconds, so the cost/risk is not justified.

## Possible future fixes
1. Wait for an upstream Snacks fix.
2. Test direct `actions.confirm(...)` instead of `picker:action("confirm")`.
3. Try pre-setting the cursor target before running the action.
4. Last resort: rewrite the toggle/find flow synchronously, though this is brittle and high-risk.

## Related code
`lua/plugins/snacks.lua:97`

Specifically:

```lua
if item.dir or picker.input.filter.meta.searching then
  picker:action("confirm")
end

