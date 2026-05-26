# Reading, Exploring, and Analyzing Large Codebases with Neovim

A practical guide for using Neovim/Vim like a senior engineer — focused on
*reading and understanding* code, not just writing it.

> Senior engineers spend roughly 80% of their coding time **reading**, not
> typing. Optimizing reading speed is the highest-leverage Neovim skill.

---

## Table of Contents

1. [Mental Model](#1-mental-model)
2. [The Core Reading Toolkit](#2-the-core-reading-toolkit)
3. [Navigating Unfamiliar Codebases](#3-navigating-unfamiliar-codebases)
4. [LSP-Powered Code Exploration](#4-lsp-powered-code-exploration)
5. [Searching Across Large Codebases](#5-searching-across-large-codebases)
6. [Folds: Reading by Structure](#6-folds-reading-by-structure)
7. [Marks, Jumplist, and Changelist](#7-marks-jumplist-and-changelist)
8. [Text Objects for Reading](#8-text-objects-for-reading)
9. [Git Archaeology Inside Neovim](#9-git-archaeology-inside-neovim)
10. [AI-Assisted Reading](#10-ai-assisted-reading)
11. [Workflows for Specific Tasks](#11-workflows-for-specific-tasks)
12. [Plugins in This Config](#12-plugins-in-this-config)
13. [Practice Exercises](#13-practice-exercises)
14. [Further Reading](#14-further-reading)

---

## 1. Mental Model

### Reading > Writing

A senior engineer joining a new project does not start by writing code. They
spend days or weeks reading. The faster they can read, jump, and trace, the
faster they ramp up.

### Navigate by meaning, not by lines

Beginners scroll. Intermediates search with `/`. Seniors **jump by symbol** —
they ask "where is this function defined?" and `gd` takes them there. They
ask "who calls this?" and `gr` lists callers.

### Build a breadcrumb trail

Every jump (`gd`, `*`, `/`, search) pushes onto the **jumplist**. `Ctrl-o`
walks backward through it. This means you can dive arbitrarily deep into a
codebase and always unwind your path. This is the single most underused
Vim feature.

### One Neovim instance, all day

Senior users open Neovim in the morning and close it at night. Buffers
accumulate, marks get set, jumplist grows. Quitting and reopening throws
away context.

---

## 2. The Core Reading Toolkit

Master these first. Everything else is decoration.

| Keys | Action | When to use |
|------|--------|-------------|
| `gd` | Go to definition | "What is this function?" |
| `gr` | Find references | "Who calls this?" |
| `gi` | Go to implementation | Interface → implementer |
| `K` | Hover docs | "What does this symbol mean?" |
| `<C-o>` | Jump back | Unwind one step |
| `<C-i>` | Jump forward | Redo a backward jump |
| `*` | Search word under cursor | Find all usages in file |
| `#` | Search word backward | Same, going up |
| `%` | Jump to matching bracket | Read block structure |
| `gg` / `G` | Top / bottom of file | Get oriented |
| `<C-]>` | Tag jump (classic) | LSP-free fallback |
| `:b <name>` | Switch buffer by name | Avoid re-opening files |

If you only learn one habit from this document, make it:

> **See a symbol you don't understand → `gd` → read it → `<C-o>` to return.**

This loop alone replaces 80% of mouse usage in an IDE.

---

## 3. Navigating Unfamiliar Codebases

### The first-pass strategy

When opening a new repo:

1. **Read the entry point.** `main.go`, `index.ts`, `cmd/server/main.go`,
   `init.lua`. Wherever execution starts.
2. **Fold everything.** Press `zM` to collapse all functions — you see the
   shape of the file at a glance.
3. **Outline the file.** Open document symbols with your picker
   (`<leader>ss` in this config). Read function names like a table of
   contents.
4. **Follow `gd` into 2-3 key functions.** Don't read everything. Pick the
   most important-looking entry point and trace it.
5. **Use `gr` on a critical function.** This reveals the data flow — who
   calls it, where it sits in the system.
6. **Mark interesting spots.** `mA`, `mB`, `mC` for global marks. Return
   with `'A`, `'B`, `'C` from anywhere.

### The "feature trace" workflow

When asked to understand how feature X works:

1. Grep for a string the user would see — error message, button label,
   route name.
2. `gd` from there into the function that produces it.
3. Walk backward through the call chain with `gr` on each function.
4. Build a mental map: HTTP route → handler → service → DB.

### When the file is too large

- `zM` then `zo` only what matters.
- Use the outline picker (`<leader>ss`) instead of scrolling.
- Split the screen (`:split` / `<C-w>s`) so you can see two parts at once.
- Use marks (`ma`, `mb`) to ping-pong between two locations.

---

## 4. LSP-Powered Code Exploration

The LSP is your IDE. Once it's running, Neovim has feature parity with
VS Code for navigation.

### Essential LSP commands

```
gd                        Go to definition
gD                        Go to declaration (often same as gd)
gr                        Find references
gi                        Go to implementation
gy                        Go to type definition
K                         Hover documentation
<leader>ca                Code actions
<leader>rn                Rename symbol
[d  /  ]d                 Prev / next diagnostic
<leader>ss                Document symbols (this file)
<leader>sS                Workspace symbols (whole project)
```

> The exact keymaps in this config live in `lua/plugins/lsp.lua` and
> `lua/config/keymaps.lua`. Check there for your actual bindings.

### Reading patterns with LSP

- **Trace a call chain:** `gd` into a function, `gd` into the next call,
  `<C-o> <C-o>` to walk back out.
- **Survey an interface:** `gi` on an interface method shows every
  implementation. Useful in Go, Java, TypeScript codebases.
- **Find shared state:** `gr` on a global variable or module export reveals
  every reader/writer.
- **Hover everything you don't recognize.** `K` is cheap. Use it
  aggressively. It teaches you the codebase.

### Workspace symbols are underrated

`<leader>sS` (or `:Telescope lsp_workspace_symbols` / Snacks equivalent)
lets you fuzzy-find any symbol in the whole project. It's like `gd` but
when you don't know which file the symbol lives in.

Example: "I know there's a `validateOrder` function somewhere…"
→ `<leader>sS` → type `validateOrder` → Enter. Done.

---

## 5. Searching Across Large Codebases

### Live grep is your first weapon

Use Snacks picker grep (`<leader>sg` or your binding). It runs ripgrep
under the hood and is fast on million-line codebases.

Patterns that pay off:

- **Find an error message:** grep the literal string a user reported.
- **Find a route:** grep `POST /api/users` or whatever the URL pattern is.
- **Find a config key:** grep `"maxRetries"` to see where it's read.
- **Find usages across the whole repo:** grep the function name (broader
  than LSP `gr` in dynamically-typed languages).

### Searching by file type

Most pickers let you filter by extension. To search only Go files:
`pattern -t go` in ripgrep, or use the picker's filter UI.

### When grep fails: use the LSP

If you grep for a method name and get 200 hits, switch to LSP `gr` — it
filters by *actual symbol references*, not text matches. Huge time saver
in big codebases.


### Search history

`/` then `<C-p>` walks backward through your search history. Reuse
expensive regexes without retyping.

---

## 6. Folds: Reading by Structure

Folds let you collapse functions, classes, and blocks. They turn a
2000-line file into a 30-line outline.

### Fold commands

| Keys | Action |
|------|--------|
| `zM` | Close all folds |
| `zR` | Open all folds |
| `za` | Toggle fold under cursor |
| `zo` | Open fold |
| `zc` | Close fold |
| `zj` / `zk` | Move to next / previous fold |
| `zA` | Toggle fold recursively |

### Treesitter folding

Modern Neovim uses Treesitter for fold detection. If your config has
Treesitter installed, folds align with syntactic structure (functions,
blocks, classes) rather than indentation.

### The "outline read" pattern

1. Open an unfamiliar file.
2. `zM` to close everything.
3. Scroll through — read function signatures like a table of contents.
4. `zo` only the function you want to dive into.
5. `zc` when done. Move on.

This is faster than scrolling and forces you to think about structure.

---

## 7. Marks, Jumplist, and Changelist

These three lists are the senior user's memory.

### Marks

- `ma` sets local mark `a` (current file only).
- `mA` sets **global** mark `A` (jumps to that file from anywhere).
- `'a` jumps to the line of mark `a`.
- `` `a `` jumps to the exact column.
- `:marks` lists all marks.

**Use global marks as bookmarks.** Set `mA` on the API handler you're
investigating, `mB` on the database layer, `mC` on the test. Now `'A`,
`'B`, `'C` jump between them from anywhere.

### Jumplist

Every "big" motion (search, `gd`, `G`, `*`, line number jump) pushes onto
the jumplist.

- `<C-o>` walks backward.
- `<C-i>` walks forward.
- `:jumps` shows the list.

This is automatic. You don't manage it. Just remember: **`<C-o>` is "back"**.

### Changelist

`g;` jumps to the previous edit location. `g,` jumps forward. Useful when
you've been reading and want to return to where you last edited.

---

## 8. Text Objects for Reading

Text objects let you operate on semantic chunks. They're usually taught
for editing, but they're equally useful for reading.

### Useful for reading

| Keys | Selects |
|------|---------|
| `vif` | Inside function (with treesitter-textobjects) |
| `vaf` | Around function (includes signature) |
| `vi{` | Inside braces |
| `va{` | Around braces |
| `vi"` | Inside quotes |
| `vip` | Inside paragraph |
| `vii` | Inside indentation level (with `vim-indent-object`) |

### Why this matters for reading

- `vaf` selects an entire function — yank with `y`, paste into a scratch
  buffer to compare with another function.
- `vi{` selects the body of a block — copy it elsewhere to read in
  isolation.
- `vip` selects a paragraph — useful for SQL queries, log blocks, comment
  sections.

### `:help text-objects`

The most underread help page in Vim. Worth 20 minutes of your time.

---

## 9. Git Archaeology Inside Neovim

Reading code often means asking: *why* is this here? Git answers that.

### `:Gitsigns blame_line`

Shows who last changed the current line, when, and the commit message.
This is the fastest "why does this exist?" tool.

### `:Git log` (fugitive) or equivalent

See recent commits to the current file. Reveals churn, recent
refactorings, and the rough age of code.

### `:Gitsigns diffthis`

See how the current file differs from HEAD. Useful when reading code in
a PR branch.

### Time-travel reading

`:Git log -- path/to/file` shows the history of a single file. You can
check out an old version into a buffer and read it side-by-side with
`:vert diffsplit`. Great for understanding why a function evolved the
way it did.

---

## 10. AI-Assisted Reading

This config includes Avante and Sidekick. Use them as a *reading aid*,
not just a writing tool.

### Patterns

- **"Explain this function":** highlight a function, ask the AI to walk
  you through it line-by-line. Especially useful for regex, complex
  reduce/fold logic, or unfamiliar language features.
- **"What does this codebase do?":** point the AI at the README and a few
  key files, ask for an architectural overview before diving in.
- **"Trace this call chain for me":** give the AI a function name and
  ask where it gets called from. Use this as a fast outline, then verify
  with `gr` yourself.
- **"What's the convention here?":** ask the AI to look at 3-4 similar
  files and describe the pattern. Saves you reading them all.

### When *not* to use AI

- When the LSP would be faster (`gd`, `gr`). The LSP is exact; AI is
  approximate.
- When verifying behavior — read the actual code, not a summary.
- For anything safety-critical (auth, billing, migrations). Read it
  yourself.

---

## 11. Workflows for Specific Tasks

### Task: "Understand a new repo in 30 minutes"

1. `cat README.md` (or open it in Neovim).
2. Open the entry point file. `zM` to collapse.
3. `<leader>ss` for the outline. Read the function names.
4. Pick the 3 most interesting functions. `gd` into each.
5. `<leader>sg` for "main", "init", "start" — find the bootstrapping path.
6. Set global marks (`mA`, `mB`) on the two most important files.
7. Ask Avante for a high-level summary of the architecture.

### Task: "Trace a bug from the user-visible error"

1. `<leader>sg` for the error message string (or part of it).
2. `gd` from the string into the function that throws/logs it.
3. `gr` on that function — who calls it?
4. Walk backward through the call chain with `<C-o>`.
5. Mark suspicious lines with `ma`, `mb` as you go.
6. Once you find the root cause, `'a`, `'b` to revisit your candidates.

### Task: "Review a PR locally"

1. Check out the branch.
2. `:Gitsigns diffthis` on each changed file, or `:Git diff main...HEAD`.
3. For each changed function: `gd` into its dependencies, `gr` on the
   function itself — what's the blast radius?
4. Run the tests inside Neovim (`:terminal` or test plugin).

### Task: "Find every place a config flag is read"

1. `<leader>sg` for the flag name as a string.
2. If it's accessed via a getter: LSP `gr` on the getter.
3. Cross-reference both lists.

### Task: "Refactor across many files"

1. `:cdo` or `:cfdo` after populating the quickfix list with `gr`.
2. Or: LSP rename (`<leader>rn`) for type-safe rename.
3. Verify with `<leader>sg` for stray text references the LSP missed.

---

## 12. Plugins in This Config

The following plugins in this config support reading workflows. Bindings
are approximate — check `lua/config/keymaps.lua` for the actual values.

### Snacks (picker, explorer)

- **Picker** — fuzzy find files, buffers, symbols, grep results.
  The single most-used reading tool. Bindings under `<leader>s`.
- **Explorer** — file tree. Open briefly, find file, close.
  Avoid keeping it open as a permanent sidebar.

### LSP (`lua/plugins/lsp.lua`)

- Provides `gd`, `gr`, `gi`, `K`, code actions, rename.
- Diagnostics with `[d` and `]d`.

### Oil.nvim

- Edit directories like buffers. Great for browsing structure and bulk
  file operations.

### Mouse-hover (`lua/config/mouse-hover.lua`)

- LSP hover triggered by mouse hover. Use casually while reading.

### Avante / Sidekick

- AI-assisted reading and Q&A. See [Section 10](#10-ai-assisted-reading).

### Gitsigns / Git plugins

- Inline blame, diff, hunks. The fastest "why?" answer for any line.

---

## 13. Practice Exercises

To build muscle memory, drill these on your own config (this repo) for
one week:

### Week 1: `gd` + `<C-o>` loop

- Open `init.lua`.
- Use `gd` to jump into every `require()` call.
- Use `<C-o>` to return.
- Goal: never touch the arrow keys or mouse to navigate.

### Week 2: Pickers

- Use the document symbols picker (`<leader>ss`) instead of scrolling.
- Use live grep (`<leader>sg`) instead of `:vimgrep` or `find`.
- Goal: open any file in your config in under 3 seconds.

### Week 3: Folds and outlines

- Open `lua/plugins/lsp.lua` (likely your longest plugin file).
- `zM` and read only function signatures.
- `zo` one function at a time.
- Goal: build a habit of folding before reading.

### Week 4: Marks and jumplist

- Set global marks on 3 key files: `mC` on config, `mP` on plugins,
  `mK` on keymaps.
- Practice `'C`, `'P`, `'K` until reflexive.
- After every reading session, run `:jumps` to see your trail.

### Ongoing: One new motion per week

- Pick one from `:help motion.txt`.
- Use it deliberately for a week.
- Examples: `f<char>`, `t<char>`, `}` (next paragraph), `[m` / `]m`
  (next method), `[[` / `]]` (next section).

---

## 14. Further Reading

### Built-in help (start here)

- `:Tutor` — built-in tutorial. Re-do it once a year.
- `:help motion.txt` — every motion explained.
- `:help text-objects` — text objects reference.
- `:help jump-motions` — jumplist details.
- `:help lsp` — built-in LSP API.

### External

- **ThePrimeagen** (YouTube) — watch a fluent user navigate in real time.
- **TJ DeVries** (YouTube) — Neovim core maintainer, deep config content.
- **`learn-vim`** (book by Igor Irianto) — most thorough free Vim book.
- **`vim-be-good`** (plugin) — gamified motion practice.
- **`hardtime.nvim`** (plugin) — punishes bad habits like spamming `hjkl`.

### Codebase-specific learning

- Read the Neovim source itself if curious — `runtime/lua/vim/lsp.lua`
  is a great example of well-organized Lua.
- Read your favorite plugins' source. You learn idioms and patterns.

---

## Closing Thought

Becoming fast in Neovim is not about memorizing 200 commands. It's about
using **the same 20 commands so often they become invisible** — your
hands move before you consciously decide to move them.

The keystrokes drop away. What's left is just *reading the code*.
