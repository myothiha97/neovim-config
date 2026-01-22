-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--

local comment_key = "<M-/>"

vim.keymap.set("n", "<leader>va", "ggVG", { desc = "Select all the text in the current file" })
vim.keymap.set("n", "<leader>ya", "ggyG", { desc = "Yank all text" })

-- Normal mode: Comment the current line
vim.keymap.set("n", comment_key, "<cmd>normal gcc<CR>", { desc = "Toggle comment line" })

-- Visual mode: Comment the highlighted selection
vim.keymap.set("v", comment_key, "<Esc>:normal gvgc<CR>", { desc = "Toggle comment block" })

-- recenter the page when hit ctrl-d/u/f/b
vim.keymap.set({ "n", "v" }, "<C-d>", "<C-d>zz", { desc = "Scroll Down and Recenter" })
vim.keymap.set({ "n", "v" }, "<C-u>", "<C-u>zz", { desc = "Scroll Up and Recenter" })
vim.keymap.set({ "n", "v" }, "<C-f>", "<C-f>zz", { desc = "Scroll Down by entire page and Recenter" })
vim.keymap.set({ "n", "v" }, "<C-b>", "<C-b>zz", { desc = "Scroll Up by entire page and Recenter" })

-- Hover docs in normal mode (Cmd+i via Alacritty)
vim.keymap.set("n", "<C-k>", vim.lsp.buf.hover, { desc = "Hover Documentation" })

-- Signature help for insert mode and normal mode  (Cmd+i via Alacritty)
vim.keymap.set({ "i", "n" }, "<C-i>", vim.lsp.buf.signature_help, { desc = "Signature Help" })

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

-- Resize window using <Alt> arrow keys
-- vim.keymap.set("n", "<A-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
-- vim.keymap.set("n", "<A-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
-- vim.keymap.set("n", "<A-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
-- vim.keymap.set("n", "<A-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- Resize window using <Shift> + arrow keys
-- vim.keymap.set("n", "<S-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
-- vim.keymap.set("n", "<S-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
-- vim.keymap.set("n", "<S-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
-- vim.keymap.set("n", "<S-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- Resize window using Command + arrow keys (via the Alacritty tunnel)
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
