-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--

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

-- Hover docs in normal mode
vim.keymap.set("n", "<Tab>", vim.lsp.buf.hover, { desc = "Hover Documentation" })

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
  vim.diagnostic.open_float({
    focusable = true, -- Allows you to tab into the window or focus it
    border = "rounded",
    source = "always", -- Shows which LSP (e.g., jdtls) sent the error
  })
end, { desc = "Line Diagnostics (Focusable)" })

-- Configuration to only target Errors (min and max both set to ERROR for exact match)
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

-- Search word under cursor and stay in place (Cmd+F via Ghostty → M-f)
vim.keymap.set("n", "<M-f>", "*N", { desc = "Highlight word under cursor" })

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
