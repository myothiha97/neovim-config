
# Config Refactoring

## Goal
Refactor and simplify configuration files to make them more consistent, maintainable, and easier to extend for additional languages.

## Unified Config Areas
- LSP
- Folding
- Search and replace
- Diagnostics
- Debugging
- Code analysis

## Language Priorities and Current State

| Language | Status |
|----------|--------|
| TS/JS    | Fully configured |
| Go       | Not configured yet |
| Python   | ~30% configured; some LSP features may already work |
| Rust     | Not configured yet |
| C        | Not configured yet |

## Planned Additions

### AI Action Keymaps / Commands
- Generate commit messages
- Analyze the codebase
- Review new changes

### Code Analysis Keymaps / Commands
- Check code coverage or code quality → display results in a popup or dedicated pane
- Analyze all variables, functions, classes, objects, and symbols used in a file (with usage counts) → display in a popup or dedicated pane
