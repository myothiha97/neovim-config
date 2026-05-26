
# Nvim: Smooth Scrolling Improvement

## Goal
Improve scrolling smoothness to be closer to GUI editors like WebStorm, Zed, or VS Code — for mouse, trackpad, and keyboard navigation.

## Current State
Significant effort has already been made to smooth scrolling, but it still falls short of GUI editors.

## Requirements
- Must not cause performance regressions on large files or large projects.
- Must cover all three input methods: mouse wheel, trackpad gestures, keyboard (`<C-d>`, `<C-u>`, `j/k`, etc.).

## Research Directions
- Evaluate `neoscroll.nvim` configuration options more deeply.
- Check if `mousescroll` option tuning can help with trackpad inertia.
- Investigate terminal-level scroll frame rate as a limiting factor (e.g. `scrollback`, `smoothscroll` in Kitty/WezTerm).
- Profile whether any autocmd or plugin is triggering redraws during scroll.
