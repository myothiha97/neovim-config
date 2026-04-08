-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--

-- Save file (Ctrl+S, works in normal and insert mode)
vim.keymap.set({ "n", "i" }, "<C-s>", "<cmd>w<cr>", { desc = "Save File" })

-- Disable buffer navigation with Shift+H/L (LazyVim defaults)
vim.keymap.del("n", "<S-h>")
vim.keymap.del("n", "<S-l>")

local comment_key = "<M-/>"

vim.keymap.set("n", "<leader>va", "ggVG", { desc = "Select all the text in the current file" })
vim.keymap.set("n", "<leader>ya", "ggyG", { desc = "Yank all text" })

-- Copy current file path (relative) to clipboard for Claude Code CLI
vim.keymap.set("n", "<leader>as", function()
  local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":.")
  vim.fn.setreg("+", path)
  vim.notify("Copied: " .. path, vim.log.levels.INFO)
end, { desc = "Copy File Path to Clipboard" })

-- Normal mode: Comment the current line
vim.keymap.set("n", comment_key, "<cmd>normal gcc<CR>", { desc = "Toggle comment line" })

-- Visual mode: Comment the highlighted selection
vim.keymap.set("v", comment_key, "<Esc>:normal gvgc<CR>", { desc = "Toggle comment block" })

-- recenter the page when hit ctrl-d/u/f/b
vim.keymap.set({ "n", "v" }, "<C-d>", "<C-d>zz", { desc = "Scroll Down and Recenter" })
vim.keymap.set({ "n", "v" }, "<C-u>", "<C-u>zz", { desc = "Scroll Up and Recenter" })
vim.keymap.set({ "n", "v" }, "<C-f>", "<C-f>zz", { desc = "Scroll Down by entire page and Recenter" })
vim.keymap.set({ "n", "v" }, "<C-b>", "<C-b>zz", { desc = "Scroll Up by entire page and Recenter" })

-- Tab in normal mode: focus any visible float, or open hover docs if none visible
-- First press opens hover docs, second press jumps into it (use q or <C-w>w to leave)
vim.keymap.set("n", "<Tab>", function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local cfg = vim.api.nvim_win_get_config(win)
    if cfg.relative ~= "" and cfg.focusable ~= false then
      vim.api.nvim_set_current_win(win)
      return
    end
  end
  vim.lsp.buf.hover()
end, { desc = "Hover / Focus Float" })

-- Signature help for insert mode and normal mode (Option+i via Ghostty)
vim.keymap.set({ "i", "n" }, "<M-i>", vim.lsp.buf.signature_help, { desc = "Signature Help" })

-- -- Enter insert mode and show completion menu (normal mode only)
-- vim.keymap.set("n", "<C-i>", function()
--   vim.cmd("startinsert")
--   vim.schedule(function()
--     require("blink.cmp").show()
--   end)
-- end, { desc = "Insert & Show Completion" })

-- terminal mode
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { noremap = true })

vim.keymap.set("i", "<Tab>", "<Tab>", { desc = "Indent" })
vim.keymap.set("i", "<S-Tab>", "<C-d>", { desc = "Outdent" })

-- map(mode, key, result, options)
vim.keymap.set("n", "gi", function()
  local _, winid = vim.diagnostic.open_float({
    focusable = true,
    border = "rounded",
    source = "always",
  })
  if winid then
    vim.api.nvim_set_current_win(winid)
  end
end, { desc = "Line Diagnostics (Focus)" })

--Configuration to only target Errors (min and max both set to ERROR for exact match)
local error_only_config = {
  severity = { min = vim.diagnostic.severity.ERROR, max = vim.diagnostic.severity.ERROR },
  float = { border = "rounded", source = "always" },
}

-- Go to next ERROR
vim.keymap.set("n", "ge", function()
  vim.diagnostic.jump({
    count = 1,
    severity = error_only_config.severity,
    float = error_only_config.float,
  })
end, { desc = "Next Error" })

-- Go to previous ERROR
vim.keymap.set("n", "gp", function()
  vim.diagnostic.jump({
    count = -1,
    severity = error_only_config.severity,
    float = error_only_config.float,
  })
end, { desc = "Prev Error" })

-- Resize window using Shift + arrow keys
vim.keymap.set("n", "<S-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
vim.keymap.set("n", "<S-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
vim.keymap.set("n", "<S-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
vim.keymap.set("n", "<S-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- 1. Global Indicator
local logIndicator = " -> "

-- 2. Define Templates (Grouped for flexibility)
local log_templates = {
  javascript = "console.log('%s" .. logIndicator .. "', %s);",
  typescript = "console.log('%s" .. logIndicator .. "', %s);",
  javascriptreact = "console.log('%s" .. logIndicator .. "', %s);", -- For .jsx
  typescriptreact = "console.log('%s" .. logIndicator .. "', %s);", -- For .tsx
  python = "print(f'{%s=}')",
  lua = "print('%s" .. logIndicator .. "', vim.inspect(%s))",
  rust = 'println!("{}" .. logIndicator .. "{:?}", "%s", %s);',
  go = 'fmt.Printf("%s' .. logIndicator .. '%%+v\\n", %s)',
  cpp = 'std::cout << "%s' .. logIndicator .. '" << %s << std::endl;',
}

-- 3. Dynamic logging function
local function log_visual_selection()
  -- Yank the current visual selection to register 'v'
  vim.cmd('noautocmd normal! "vy')
  local selection = vim.fn.getreg("v"):gsub("\n", "")
  -- Get current filetype
  local ft = vim.bo.filetype

  -- UNCOMMENT THE LINE BELOW TO DEBUG:
  -- print("Current Filetype detected as: " .. ft)

  -- Lookup template
  local template = log_templates[ft]

  -- If not found in our table, use a generic print fallback
  if not template then
    template = "print('%s" .. logIndicator .. "', %s)"
  end

  -- Format and insert
  local log_line = string.format(template, selection, selection)
  vim.api.nvim_put({ log_line }, "l", true, true)
end

-- 4. Mapping
vim.keymap.set("v", "<leader>l", log_visual_selection, { desc = "Dynamic Log Selection" })

-- Toggle all folds except current: zm folds all then reveals cursor, zR when already all folded
vim.keymap.set("n", "zm", function()
  if vim.o.foldlevel == 0 then
    vim.cmd("normal! zR")
  else
    vim.cmd("normal! zMzv")
  end
end, { desc = "Toggle All Folds (keep current open)" })

-- Search word under cursor and stay in place (Cmd+F via Ghostty → M-f)
vim.keymap.set("n", "<M-f>", "*N", { desc = "Highlight word under cursor" })

-- Git who: compact blame info (author, date, message) for current line
vim.keymap.set("n", "<leader>gw", function()
  local lnum = vim.fn.line(".")
  local file = vim.fn.expand("%:p")

  -- Pipe current buffer content so line numbers match even with unsaved changes
  local buf_content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
  local blame = vim.fn.system(
    { "git", "blame", "-L", lnum .. "," .. lnum, "--porcelain", "--contents", "-", "--", file },
    buf_content
  )
  if vim.v.shell_error ~= 0 then
    vim.notify("Not in a git repository", vim.log.levels.WARN)
    return
  end

  local commit = blame:match("^(%x+)")
  if not commit or commit:match("^0+$") then
    vim.notify("Line not yet committed", vim.log.levels.INFO)
    return
  end

  local author = blame:match("author ([^\n]+)") or "Unknown"
  local author_mail = blame:match("author%-mail ([^\n]+)") or ""
  local author_time = blame:match("author%-time (%d+)")
  local summary = blame:match("summary ([^\n]+)") or ""
  local date = author_time and os.date("%Y-%m-%d %H:%M", tonumber(author_time)) or "Unknown"

  local lines = {
    "Commit:  " .. commit:sub(1, 10),
    "Author:  " .. author .. " " .. author_mail,
    "Date:    " .. date,
    "",
    "  " .. summary,
  }

  local float_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(float_buf, 0, -1, false, lines)
  vim.bo[float_buf].buftype = "nofile"
  vim.bo[float_buf].modifiable = false
  vim.bo[float_buf].bufhidden = "wipe"
  vim.bo[float_buf].filetype = "git"

  local width = 0
  for _, l in ipairs(lines) do
    width = math.max(width, #l)
  end
  width = math.min(width + 4, 80)

  vim.api.nvim_open_win(float_buf, true, {
    relative = "cursor",
    width = width,
    height = #lines,
    row = 1,
    col = 0,
    style = "minimal",
    border = "rounded",
    title = " Git Who ",
    title_pos = "center",
  })

  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = float_buf, nowait = true })
  vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = float_buf, nowait = true })
end, { desc = "Git Who (blame info)" })

-- Git blame for current line (custom: shows both + and - lines in diff)
vim.keymap.set("n", "<leader>gb", function()
  local lnum = vim.fn.line(".")
  local file = vim.fn.expand("%:p")

  -- Pipe current buffer content so line numbers match even with unsaved changes
  local buf_content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
  local blame = vim.fn.system(
    { "git", "blame", "-L", lnum .. "," .. lnum, "--porcelain", "--contents", "-", "--", file },
    buf_content
  )
  if vim.v.shell_error ~= 0 then
    vim.notify("Not in a git repository", vim.log.levels.WARN)
    return
  end

  local commit = blame:match("^(%x+)")
  if not commit or commit:match("^0+$") then
    vim.notify("Line not yet committed", vim.log.levels.INFO)
    return
  end

  local output = vim.fn.system({ "git", "show", commit, "--", file })
  if vim.v.shell_error ~= 0 then
    vim.notify("Failed to get commit info", vim.log.levels.ERROR)
    return
  end

  local lines = vim.split(output, "\n")
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].filetype = "git"
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"

  local width = math.min(120, vim.o.columns - 4)
  local height = math.min(#lines, math.floor(vim.o.lines * 0.8))

  vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = "rounded",
    title = " Git Blame ",
    title_pos = "center",
  })

  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, nowait = true })
  vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = buf, nowait = true })
end, { desc = "Git Blame Line" })


-- Snacks picker: grep within current file
vim.keymap.set("n", "<leader>sl", function()
  Snacks.picker.grep({
    dirs = { vim.api.nvim_buf_get_name(0) },
  })
end, { desc = "Grep in Current File" })

-- =============================================
-- TREESITTER FUNCTION NAVIGATION
-- =============================================

-- Helper: Get treesitter node at cursor and find parent function
local function get_function_node()
  -- Use built-in vim.treesitter API (modern approach)
  local node = vim.treesitter.get_node()
  if not node then
    return nil
  end

  -- Function node types for different languages
  local function_types = {
    "function_declaration", -- JS/TS/Go/Lua
    "function_definition", -- Python/C/C++
    "arrow_function", -- JS/TS
    "method_definition", -- JS/TS class methods
    "function_expression", -- JS/TS
    "function_item", -- Rust
    "func_literal", -- Go
    "lambda_expression", -- Python
    "lexical_declaration", -- const fn = () => {} wrapper
  }

  -- Walk up the tree to find function node
  while node do
    local node_type = node:type()
    for _, fn_type in ipairs(function_types) do
      if node_type == fn_type then
        return node
      end
    end
    -- Special case: variable declaration containing arrow function
    if node_type == "lexical_declaration" or node_type == "variable_declaration" then
      for child in node:iter_children() do
        if child:type() == "variable_declarator" then
          for subchild in child:iter_children() do
            local subtype = subchild:type()
            if subtype == "arrow_function" or subtype == "function_expression" then
              return node
            end
          end
        end
      end
    end
    node = node:parent()
  end
  return nil
end

-- [f / ]f navigation handled by nvim-treesitter-textobjects (see treesitter.lua)

-- Jump to function name/signature
vim.keymap.set("n", "gf", function()
  local node = get_function_node()
  if node then
    local start_row, start_col = node:start()
    vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })
    -- Move to first non-whitespace character
    vim.cmd("normal! ^")
    vim.cmd("normal! zz")
  else
    vim.notify("No function found at cursor", vim.log.levels.WARN)
  end
end, { desc = "Go to Function Start (Treesitter)" })

-- Jump to end of current function (opposite of gf)
vim.keymap.set("n", "gh", function()
  local node = get_function_node()
  if node then
    local end_row, _ = node:end_()
    vim.api.nvim_win_set_cursor(0, { end_row + 1, 0 })
    -- Move to first non-whitespace character (the closing brace)
    vim.cmd("normal! ^")
    vim.cmd("normal! zz")
  else
    vim.notify("No function found at cursor", vim.log.levels.WARN)
  end
end, { desc = "Go to Function End (Treesitter)" })
