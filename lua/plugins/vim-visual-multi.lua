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
    -- show match count in statusline
    vim.g.VM_set_statusline = 3

    -- Restore cursor to original position on exit (like VSCode/Zed)
    vim.api.nvim_create_autocmd("User", {
      pattern = "visual_multi_start",
      callback = function()
        vim.b.vm_start_pos = vim.api.nvim_win_get_cursor(0)
      end,
    })
    vim.api.nvim_create_autocmd("User", {
      pattern = "visual_multi_exit",
      callback = function()
        if vim.b.vm_start_pos then
          vim.api.nvim_win_set_cursor(0, vim.b.vm_start_pos)
          vim.b.vm_start_pos = nil
        end
        -- VM sometimes leaves a buffer-local <CR> insert-mode keymap behind,
        -- which breaks blink.cmp's Enter acceptance. Force-clean it on exit.
        pcall(vim.api.nvim_buf_del_keymap, 0, "i", "<CR>")
      end,
    })
  end,
}
