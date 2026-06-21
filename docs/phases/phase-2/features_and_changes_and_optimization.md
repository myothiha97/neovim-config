# Neovim UI Optimization Roadmap

I want to improve my Neovim UI/UX in a controlled way. Please inspect my current Neovim configuration first, then propose and implement only the changes that are technically clean, maintainable, and compatible with the existing setup.

Reference images:

- `nvim/assets/neovim-ui-optimization.png`
- `nvim/assets/scroll-info-location.png`

## General Requirements

- Preserve my current UI style, color scheme, statusline design, and existing keymaps unless a change is required.
- Prefer using existing configured plugins, LSP, Treesitter, or built-in Neovim APIs before adding new plugins.
- Do not add new plugins unless the feature cannot be implemented cleanly with the current setup.
- Keep the implementation modular and easy to disable.
- Add clear comments only where the logic is non-obvious.
- After implementation, explain:
  - what files were changed,
  - what behavior was added,
  - what keymaps or commands were introduced,
  - any limitations or trade-offs.

---

# 1. Current Symbol Indicator in Lua Statusline

**Priority:** Medium

## Goal

Add or fix a statusline indicator that shows the current code symbol/scope where the cursor is located.

The expected behavior is similar to the reference image, where the statusline shows the current symbol/context, for example:

- current function name
- current method name
- current class name
- current object/key path
- current JSON/YAML/TOML key path when possible
- current Lua/TypeScript/Go symbol when supported

## Expected Behavior

- When the cursor is inside a function, method, class, object, or structured block, the statusline should show the nearest meaningful symbol.
- For nested structures, show the most useful current context, not a long noisy path.
- If no symbol is available, hide the component or show a minimal fallback.
- It should work with LSP document symbols when available.
- If LSP is unavailable, use Treesitter or another safe fallback if already available in the config.
- Avoid expensive recalculation on every cursor movement if it affects performance.

## Acceptance Criteria

- The statusline displays the current symbol/context for common filetypes:
  - Lua
  - TypeScript/JavaScript
  - Go
  - JSON
  - YAML
  - Markdown, if reasonably supported

- The component does not break when LSP is not attached.
- The component does not create noticeable latency while editing.

---

# 2. Semantic File Inspector / File Structure Review Popup

**Priority:** High

## Goal

Build a dedicated popup/window for inspecting the structure of the current file without relying on manual scrolling, repeated Vim motions, or basic symbol jumping.

This should be more polished and comprehensive than a basic Trouble/Snacks/LSP symbol list. The goal is to create a current-buffer file inspection tool that helps me quickly understand what exists inside large files with hundreds or thousands of lines.

For full BRD and implementation details, refer to:

`docs/phases/phase-2/neovim-file-inspector-BRD_+_Technical_Specification.md`

## Expected Content

The inspector should show important structural symbols from the current file, including:

- imports
- variables/constants
- functions
- React components
- classes
- methods
- objects/config objects
- types/interfaces
- enums/structs when applicable
- Markdown headings when applicable
- JSON/YAML key sections when applicable

The popup should not show full implementation bodies.

## Expected Behavior

- Show a clean, readable overview of the current file.
- Support filtering by symbol type, for example:
  - variables
  - functions
  - React components
  - classes
  - methods
  - objects
  - types/interfaces

- Allow quick jumping to the selected symbol.
- Allow revealing or focusing the symbol around the current cursor position.
- Support keyboard navigation.
- Close easily with `q`, `Esc`, or the existing picker/window convention in my config.
- Prefer LSP for semantic operations and Treesitter for deeper structural detection.
- Use existing UI tools such as Snacks picker, Trouble, Telescope, or native floating windows if they fit the requirement.
- Do not treat basic `lsp_symbols` output as complete unless it satisfies the full inspection workflow.
- Support safe rename/refactor actions where possible by using LSP rename/code actions, not manual text replacement.

## Suggested UX

Possible command:

```vim
:FileInspector
```

Possible keymap:

```lua
<leader>ci
```

Before choosing the final keymap, inspect my existing keymaps and avoid conflicts.

Suggested actions inside the inspector:

```txt
Enter   jump to selected symbol
r       rename selected symbol using LSP
a       show code actions if supported
f       filter by symbol type
C       reveal current cursor symbol
R       refresh symbols
q/Esc   close
```

## Acceptance Criteria

- I can open a popup/window showing a structured review of the current file.
- The inspector is useful for large files with hundreds or thousands of lines.
- Symbols are categorized clearly, not shown as one basic flat list only.
- React components are recognized as components where possible.
- Variables/constants, functions, classes, methods, objects, and types/interfaces can be reviewed separately.
- I can filter by symbol type.
- I can jump to the selected symbol.
- I can reveal the symbol around my current cursor.
- I can rename supported symbols through LSP.
- The feature degrades gracefully when LSP or Treesitter data is unavailable.
- It does not create noticeable latency while editing.
- Detailed behavior and implementation should follow:

`docs/phases/phase-2/neovim-file-inspector-BRD_+_Technical_Specification.md`

---

# 3. Move Scroll Information to Top-Right Floating Overlay

**Priority:** Low

## Current Problem

The scroll information is currently displayed on the right side of the Lua statusline. This makes the statusline visually crowded.

## Goal

Move the scroll information out of the statusline and display it as a small top-right floating overlay, similar to the reference image.

Reference behavior:

- display scroll percentage
- display current line / total lines if possible
- position it at the top-right corner of the active window
- keep it visually minimal and aligned with my existing UI style

## Desired Behavior

The scroll overlay should not be permanently visible.

It should appear only while scrolling or navigating through the file, then automatically disappear shortly after movement stops.

It should handle common navigation methods, including:

- mouse scroll
- `j` / `k`
- `Ctrl-d`
- `Ctrl-u`
- `Ctrl-f`
- `Ctrl-b`
- `gg`
- `G`
- search jumps
- LSP jumps
- any movement that changes the visible viewport

## Implementation Notes

Please research the best Neovim-native way to detect scrolling or viewport changes. Possible events/APIs to consider:

- `WinScrolled`
- `CursorMoved`
- `CursorMovedI`
- `winsaveview()`
- floating windows
- timers/debounce logic

The overlay should automatically close after a short delay, for example 800–1200ms after the last scroll/movement event.

## Acceptance Criteria

- Scroll info is removed from the statusline.
- Scroll info appears at the top-right of the active window during scrolling/navigation.
- Scroll info hides automatically after scrolling stops.
- The overlay follows the active window correctly.
- It does not interfere with editing, completion menus, diagnostics, or other floating windows.
- It does not noticeably affect performance.

---

# Priority Order

Implement in this order:

1. File Structure / Symbol Overview Popup — High priority
2. Current Symbol Indicator in Statusline — Medium priority
3. Scroll Info Floating Overlay — Low priority

If the low-priority scroll overlay requires too much complexity, do not implement it immediately. Instead, document the recommended approach and leave it as a future task.
