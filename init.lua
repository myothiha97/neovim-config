-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- 1. Define your language templates and global indicator
local logIndicator = " -> " -- Change this once to update all logs

local log_templates = {
  javascript = "console.log('%s" .. logIndicator .. "', %s);",
  typescript = "console.log('%s" .. logIndicator .. "', %s);",
  python = "print(f'{%s=}')", -- Python f-strings handle their own formatting
  lua = "print('%s" .. logIndicator .. "', vim.inspect(%s))",
  rust = 'println!("{}" .. logIndicator .. "{:?}", "%s", %s);',
  go = 'fmt.Printf("%s' .. logIndicator .. '%%+v\\n", %s)',
  cpp = 'std::cout << "%s' .. logIndicator .. '" << %s << std::endl;',
}

-- 2. Create the dynamic logging function
local function log_visual_selection()
  -- Yank the current visual selection to register 'v'
  vim.cmd('noautocmd normal! "vy')
  local selection = vim.fn.getreg("v"):gsub("\n", "") -- remove newlines

  -- Detect filetype and select template (fallback to print)
  local ft = vim.bo.filetype
  local template = log_templates[ft] or "print('%s" .. logIndicator .. "', %s)"

  -- Format the log statement
  -- We pass 'selection' twice: once for the label and once for the value
  local log_line = string.format(template, selection, selection)

  -- Insert the log line on a new line below the current cursor
  vim.api.nvim_put({ log_line }, "l", true, true)
end

-- 3. Map it to a key (e.g., <leader>l) in Visual mode
vim.keymap.set("v", "<leader>l", log_visual_selection, { desc = "Dynamic Log Selection" })
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
