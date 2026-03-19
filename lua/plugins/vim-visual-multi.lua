return {
  "mg979/vim-visual-multi",
  branch = "master",
  event = "BufReadPost",
  init = function()
    vim.g.VM_maps = {
      -- Cmd+D: add next occurrence (VSCode/Zed Cmd+D)
      ["Find Under"] = "<M-d>",
      ["Find Subword Under"] = "<M-d>",
      -- Cmd+Shift+L: select all occurrences (VSCode/Zed Cmd+Shift+L)
      ["Select All"] = "<M-L>",
      -- skip current match (like VSCode's "Skip" with Cmd+K Cmd+D)
      ["Skip Region"] = "<M-]>",
    }
    -- exit at first cursor position (like VSCode - stay where you started)
    vim.g.VM_reselect_first = 1
    -- show match count in statusline
    vim.g.VM_set_statusline = 3
  end,
}
