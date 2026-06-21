# Neovim Semantic File Inspector — BRD + Technical Specification

## 1. Product Name

**Semantic File Inspector**

Alternative names:

- File Structure Inspector
- Semantic Outline
- Code Structure Navigator
- Buffer Intelligence Panel

---

## 2. Problem Statement

My current Neovim workflow already supports basic symbol jumping through tools like Trouble symbols, Snacks picker, or LSP document symbols.

However, those tools are too basic for large files because they mainly provide a flat or simple symbol list. They do not provide a polished, comprehensive, filterable overview of the current file.

The current pain points are:

- Too much manual scrolling in huge files.
- Too many manual Vim motions just to inspect file structure.
- Basic symbol pickers do not clearly separate variables, functions, React components, classes, methods, objects, types, interfaces, etc.
- It is hard to quickly understand what exists inside a file with thousands of lines.
- Existing tools are good for jumping, but weak for structured review and analysis.
- Refactoring from the symbol overview is not directly supported.

The goal is to build a custom Neovim feature/plugin that acts as a high-level semantic inspection layer for the current buffer.

---

## 3. Main Goal

Build an on-demand popup/window that analyzes the current file and shows a polished, filterable, navigable overview of the important symbols inside the file.

The feature should reduce:

- manual scrolling
- manual Vim navigation
- repeated search commands
- manual inspection of huge files
- cognitive load when reviewing unfamiliar files

The feature should help answer:

- What functions exist in this file?
- What React components exist in this file?
- What variables/constants exist in this file?
- What classes and methods exist in this file?
- What objects/configs exist in this file?
- What types/interfaces are declared?
- Where is the current cursor located in the file’s structure?
- Can I jump to or rename a selected symbol quickly?

---

## 4. Target Users

Primary user:

- Neovim power user
- Full-stack / frontend / backend engineer
- Works with large files
- Uses TypeScript, React, Go, Lua, JSON/YAML, and Markdown
- Wants terminal-native code inspection without switching to a heavy IDE

---

## 5. Scope

### In Scope

The plugin should support:

- Current-buffer symbol inspection
- Large-file friendly analysis
- Filter by symbol type
- Jump to symbol
- Detect symbol under current cursor
- Rename selected symbol using LSP
- Optional code actions for selected symbol
- LSP document symbols as base data source
- Treesitter AST queries for deeper/custom extraction
- React component detection
- Object/config detection
- Variables/constants detection
- Methods/classes/types/interfaces detection
- Markdown heading detection
- JSON/YAML key structure detection

### Out of Scope

Do not attempt to build:

- Full project-wide dependency graph
- Full call graph
- Full reference graph
- Full type inference engine
- Complete language parser from scratch
- AI code summarization
- Full IDE replacement
- Background indexing of the whole project
- Always-on live analysis

This feature should be **current-buffer only** and **on-demand**.

---

## 6. Existing Tools Limitation

Before implementation, inspect whether the config already includes:

- Snacks picker
- Trouble
- Telescope
- Aerial
- fzf-lua
- Treesitter
- LSP configs

These can be reused, but they are not the complete solution.

Existing tools are acceptable as UI foundations, but the desired feature requires custom extraction, filtering, categorization, and refactoring actions.

Do not simply map `Snacks.picker.lsp_symbols()` and call the task complete.

---

## 7. Functional Requirements

### 7.1 Open Semantic File Inspector

The user should be able to open the inspector with a command and keymap.

Suggested command:

```vim
:SemanticFileInspector
```

Suggested shorter command:

```vim
:FileInspector
```

Suggested keymap:

```lua
<leader>ci
```

Before assigning the keymap, inspect existing keymaps and avoid conflicts.

---

### 7.2 Display Current File Structure

The inspector should show symbols grouped by category.

Required categories:

```txt
Imports
Variables / Constants
Functions
React Components
Classes
Methods
Objects
Types / Interfaces
Enums
Structs
Markdown Headings
JSON/YAML Keys
```

Not every category needs to appear for every filetype.

Only show categories that have symbols.

---

### 7.3 Source-Order View

The default view should show symbols in source order.

Example:

```txt
File Inspector: UserProfile.tsx

[All] [Imports] [Variables] [Functions] [Components] [Objects] [Types] [Classes]

  1  import       React
  2  import       useQuery
 12  interface    UserProfileProps
 28  type         UserRole
 41  constant     DEFAULT_AVATAR_URL
 52  object       validationRules
 83  component    UserProfilePage()
149  component    UserInfoSection()
224  function     normalizeUser()
288  function     getUserDisplayName()
341  class        UserService
356    method      getUser()
389    method      updateUser()
```

---

### 7.4 Grouped View

The plugin should optionally support grouped view.

Example:

```txt
Imports
  1   React
  2   useQuery

Types / Interfaces
  12  UserProfileProps
  28  UserRole

Variables / Constants
  41  DEFAULT_AVATAR_URL
  52  validationRules

Components
  83  UserProfilePage()
 149  UserInfoSection()

Functions
 224  normalizeUser()
 288  getUserDisplayName()

Classes
 341  UserService
      356 getUser()
      389 updateUser()
```

Default mode:

```txt
source-order
```

Optional toggle:

```txt
g = toggle grouped/source-order view
```

---

### 7.5 Filter by Symbol Type

The user should be able to filter symbols by category.

Required filters:

```txt
a = all
i = imports
v = variables/constants
f = functions
c = React components/classes
m = methods
o = objects
t = types/interfaces
h = headings
```

Alternative implementation is acceptable if the chosen UI already provides better filtering.

The important requirement is that the user can quickly narrow the list.

---

### 7.6 Fuzzy Search

The inspector should support fuzzy searching where possible.

Search should match:

- symbol name
- kind
- line number
- parent symbol
- category

Example searches:

```txt
component
UserProfile
validation
method
type
```

---

### 7.7 Jump to Symbol

Pressing `Enter` on a symbol should:

1. jump to the symbol location
2. center the cursor using `zz`
3. optionally close the inspector
4. open folds if necessary

Default:

```txt
close after jump = true
```

Config option should allow keeping the inspector open after jump.

---

### 7.8 Jump to Current Cursor Symbol

The plugin should support detecting and focusing the symbol that contains the current cursor position.

Suggested key:

```txt
C = reveal current cursor symbol
```

Behavior:

- Determine nearest symbol range containing cursor.
- Focus that symbol in the inspector.
- If no exact symbol is found, focus nearest previous symbol.

This is useful when the user is inside a huge file and wants to know the current structural context.

---

### 7.9 Rename Selected Symbol

The plugin should allow renaming the selected symbol.

Suggested key:

```txt
r = rename selected symbol
```

Important rule:

Do not manually replace text.

Use LSP rename:

```lua
vim.lsp.buf.rename()
```

Behavior:

1. jump temporarily to the selected symbol location
2. trigger LSP rename
3. let the language server handle safe rename
4. refresh cached symbols after rename completes or after buffer changes

Supported rename targets:

- function names
- React component names
- class names
- method names
- type/interface names
- top-level variables/constants
- object names when LSP supports it

Limitations should be documented because not all object keys or local variables are safely renameable across all language servers.

---

### 7.10 Code Actions for Selected Symbol

Optional but useful.

Suggested key:

```txt
a = code actions
```

Behavior:

1. jump to selected symbol
2. trigger:

```lua
vim.lsp.buf.code_action()
```

Useful for:

- extracting function
- organizing imports
- fixing type errors
- converting function style
- applying quick fixes

This is optional after MVP.

---

## 8. Symbol Extraction Requirements

The plugin should use multiple data sources.

Priority:

```txt
1. LSP document symbols
2. Treesitter custom queries
3. filetype-specific fallback
```

The final symbol list should merge and deduplicate results from these sources.

---

## 9. LSP Symbol Provider

Use LSP document symbols as the base provider.

Request:

```lua
textDocument/documentSymbol
```

Support both response types:

```txt
DocumentSymbol[]
SymbolInformation[]
```

The provider should extract:

- name
- kind
- detail
- line
- column
- range
- selection range
- children
- parent/container name

LSP is good for:

- functions
- classes
- methods
- interfaces
- types
- enums
- structs
- some variables/constants

LSP may be weak for:

- React component classification
- object literal names
- local variables
- framework-specific patterns

Therefore, Treesitter is needed.

---

## 10. Treesitter Provider

Treesitter should supplement LSP by detecting patterns LSP does not classify well.

### 10.1 TypeScript / JavaScript / TSX / JSX

Detect:

```txt
imports
exported constants
top-level variables
function declarations
arrow functions assigned to constants
React components
classes
methods
interfaces
type aliases
enums
object literals assigned to constants
```

React component detection patterns:

```tsx
function UserCard() {}
export function UserCard() {}
const UserCard = () => {}
export const UserCard = () => {}
const UserCard = memo(() => {})
const UserCard = forwardRef(() => {})
```

Component heuristic:

- PascalCase name
- function/arrow function/class
- returns JSX, or located in `.tsx/.jsx`
- optionally uses React hooks

Do not classify every function as component.

---

### 10.2 Go

Detect:

```txt
package name
imports
const declarations
var declarations
type declarations
structs
interfaces
functions
methods
```

Go method example:

```go
func (s *UserService) GetUser() {}
```

Should display as:

```txt
method UserService.GetUser()
```

---

### 10.3 Lua

Detect:

```txt
local functions
module/table functions
top-level local variables
returned table fields
plugin spec objects
config sections
```

Useful for Neovim config files.

Examples:

```lua
local function setup_keymaps() end
M.setup = function() end
return {
  "folke/snacks.nvim",
  opts = {},
}
```

---

### 10.4 Markdown

Detect headings:

```md
# Title

## Section

### Subsection
```

Display hierarchy based on heading level.

---

### 10.5 JSON / YAML

Detect key structure.

Default behavior:

```txt
show top-level keys
show second-level keys
limit deep nesting
```

Config:

```lua
json_yaml_max_depth = 2
```

Do not display every scalar value in huge JSON/YAML files.

---

## 11. Symbol Data Model

All providers must normalize into this structure:

```lua
---@class SemanticSymbol
---@field id string
---@field name string
---@field kind string
---@field category string
---@field line integer
---@field col integer
---@field end_line integer|nil
---@field end_col integer|nil
---@field level integer
---@field parent string|nil
---@field detail string|nil
---@field source "lsp"|"treesitter"|"fallback"
---@field filetype string
---@field range table|nil
---@field selection_range table|nil
---@field children SemanticSymbol[]|nil
---@field renameable boolean
```

Recommended `kind` values:

```txt
import
variable
constant
function
component
class
method
object
type
interface
enum
struct
heading
key
package
module
```

Recommended `category` values:

```txt
imports
variables
functions
components
classes
methods
objects
types
headings
keys
```

---

## 12. Deduplication Rules

Because LSP and Treesitter may return the same symbols, deduplicate by:

```txt
name + line + kind
```

or

```txt
line + col + normalized name
```

Preferred behavior:

- Keep LSP symbol when LSP has better range/detail.
- Keep Treesitter symbol when it has better category classification, especially React components and objects.
- Merge metadata when possible.

Example:

If LSP returns:

```txt
function UserCard
```

and Treesitter detects:

```txt
component UserCard
```

Final symbol should be:

```txt
component UserCard
```

with LSP range preserved if useful.

---

## 13. UI Design

### Preferred UI Implementation

First inspect existing UI tools.

Preferred order:

```txt
1. Snacks picker custom source
2. Telescope custom picker
3. native floating window
4. Trouble-style list
```

Since my config likely uses LazyVim/Snacks, prefer building a custom Snacks picker source if possible.

The UI should look polished and consistent with my existing Neovim style.

---

### Required UI Features

The UI must support:

- symbol list
- line number
- symbol kind/category
- indentation for nested symbols
- filtering
- search
- jump
- rename
- current cursor reveal
- close with `q` / `Esc`

---

### Suggested Keymaps Inside Inspector

```txt
Enter       jump to selected symbol
r           rename selected symbol
a           code action at selected symbol
g           toggle grouped/source-order view
f           filter symbol type
C           reveal current cursor symbol
R           refresh symbols
q           close
Esc         close
```

Avoid overriding default picker behavior unless necessary.

---

## 14. Commands

Create commands:

```vim
:FileInspector
:FileInspectorRefresh
:FileInspectorLspOnly
:FileInspectorTreesitterOnly
```

Minimum required:

```vim
:FileInspector
:FileInspectorRefresh
```

---

## 15. Public Lua API

Expose:

```lua
require("semantic_file_inspector").setup(opts)
require("semantic_file_inspector").open()
require("semantic_file_inspector").refresh()
require("semantic_file_inspector").current_symbol()
require("semantic_file_inspector").rename_selected()
```

---

## 16. Suggested File Structure

```txt
lua/
  semantic_file_inspector/
    init.lua
    config.lua
    cache.lua
    collector.lua
    normalize.lua
    dedupe.lua
    actions.lua
    ui/
      init.lua
      snacks.lua
      float.lua
    providers/
      lsp.lua
      treesitter.lua
      markdown.lua
      json_yaml.lua
    queries/
      typescript.lua
      javascript.lua
      tsx.lua
      go.lua
      lua.lua
    utils.lua
```

---

## 17. Configuration

Example setup:

```lua
require("semantic_file_inspector").setup({
  keymap = "<leader>ci",

  providers = {
    priority = { "lsp", "treesitter", "fallback" },
    merge_results = true,
  },

  ui = {
    backend = "snacks", -- "snacks" | "telescope" | "float"
    width = 0.65,
    height = 0.75,
    border = "rounded",
    default_view = "source_order",
    show_icons = true,
    show_line_numbers = true,
    show_source = false,
    close_on_jump = true,
  },

  symbols = {
    show_imports = true,
    show_variables = true,
    show_top_level_variables = true,
    show_local_variables = false,
    show_functions = true,
    show_components = true,
    show_classes = true,
    show_methods = true,
    show_objects = true,
    show_types = true,
    show_interfaces = true,
    show_markdown_headings = true,
    json_yaml_max_depth = 2,
  },

  performance = {
    enable_cache = true,
    lsp_timeout_ms = 1200,
    treesitter_timeout_ms = 800,
    max_symbols = 800,
    max_file_size_kb = 1500,
    large_file_mode = true,
  },

  refactor = {
    enable_rename = true,
    enable_code_actions = true,
  },
})
```

---

## 18. Performance Requirements

This feature must be optimized for huge files.

### Core Rule

Do not run continuously in the background.

Only collect symbols when:

- user opens the inspector
- user manually refreshes
- buffer changed and cache is stale

### Cache Key

Cache symbols by:

```txt
bufnr
changedtick
filetype
provider
```

Use:

```lua
vim.api.nvim_buf_get_changedtick(bufnr)
```

### Large File Protection

For large files:

- avoid deep AST traversal
- do not collect every local variable
- limit JSON/YAML depth
- cap max symbols
- timeout slow providers
- show partial results if needed

Example warning:

```txt
FileInspector: large file detected. Showing structural symbols only.
```

---

## 19. MVP Definition

### MVP Must Include

- `:FileInspector`
- keymap to open inspector
- LSP document symbols provider
- Treesitter supplement for TypeScript/TSX
- React component detection
- variable/function/class/method/type/object categories
- filter by symbol type
- jump to selected symbol
- rename selected symbol through LSP
- cache by `changedtick`
- graceful fallback when no symbols exist

### MVP Can Exclude

- JSON/YAML deep support
- grouped view
- code actions
- Markdown support
- Telescope backend
- native floating backend
- workspace-wide symbols

---

## 20. Implementation Plan

### Phase 0 — Discovery

Before writing implementation, inspect my current Neovim config.

Answer:

- Is Snacks picker installed?
- Is Telescope installed?
- Is Trouble installed?
- Is Treesitter installed and configured?
- What LSP clients are configured?
- What keymaps already exist under `<leader>c`?
- Where should this module live in my config?
- Is this better implemented as a local config module or standalone plugin-style module?

Do not implement before this discovery step.

---

### Phase 1 — Basic LSP Inspector

Implement:

- command: `:FileInspector`
- keymap
- LSP document symbols request
- normalized symbol model
- simple picker UI
- jump to symbol

This proves the core workflow.

---

### Phase 2 — Treesitter Enrichment

Add Treesitter extraction for:

- TypeScript
- TSX
- JavaScript
- JSX

Detect:

- functions
- React components
- top-level variables/constants
- object literals
- classes
- methods
- types/interfaces

---

### Phase 3 — Filtering and Categories

Add:

- category filters
- source-order view
- grouped view if simple
- icons/kind labels
- fuzzy search support

---

### Phase 4 — Current Cursor Awareness

Add:

- current symbol detection
- reveal current cursor symbol in inspector
- optional statusline integration later

---

### Phase 5 — Refactor Actions

Add:

- rename selected symbol using LSP
- optional code actions
- refresh cache after rename

Do not implement manual text replacement.

---

### Phase 6 — More Filetypes

Add support for:

- Go
- Lua
- Markdown
- JSON
- YAML

---

### Phase 7 — Hardening

Add:

- cache
- timeout handling
- large file mode
- deduplication
- error handling
- documentation

---

## 21. Acceptance Criteria

The feature is complete when:

- I can open the inspector from any supported buffer.
- It shows a polished overview of the current file.
- It separates symbols by type/category.
- It detects React components as components, not just generic functions.
- It shows important variables/constants, not every noisy local variable by default.
- It shows objects/configs when useful.
- It supports filtering by symbol type.
- I can jump to a selected symbol.
- I can reveal the symbol around my current cursor.
- I can rename selected symbols using LSP.
- It works well with large files.
- It does not freeze Neovim.
- It degrades gracefully when LSP or Treesitter is unavailable.
- It does not add unnecessary plugins.
- It fits the existing Neovim UI style.

---

## 22. Important Implementation Rules

- Do not build a full parser manually.
- Do not use regex-only parsing for complex languages.
- Do not show every local variable by default.
- Do not show every variable usage/reference by default.
- Do not manually rename symbols with string replacement.
- Do not run expensive analysis on every cursor move.
- Do not add a new plugin unless existing UI tools are insufficient.
- Prefer LSP for semantic operations.
- Prefer Treesitter for structural extraction and framework-specific patterns.
- Keep the feature modular and easy to disable.

---

## 23. Final Desired Workflow

When I open a huge file, I should be able to press one key and immediately see a structured overview like this:

```txt
File Inspector: BookingForm.tsx

[All] [Imports] [Vars] [Fns] [Components] [Objects] [Types] [Classes]

Imports
  1   React
  2   useForm
  3   zodResolver

Types
  18  BookingFormProps
  29  BookingPayload

Variables / Constants
  44  DEFAULT_FORM_VALUES
  58  bookingValidationSchema

Objects
  72  fieldConfig
  96  errorMessages

Components
  121 BookingForm()
  244 BookingSummary()
  318 PaymentSection()

Functions
  401 normalizeBookingPayload()
  449 validateBookingDate()
  501 calculateTotalPrice()
```

From this panel, I should be able to:

- inspect the whole file quickly
- filter to only components/functions/objects/etc.
- jump directly to a symbol
- reveal where my current cursor is located structurally
- rename selected functions/classes/components/objects through LSP

This should become a serious code-reading and file-navigation tool, not just a basic symbol picker.
