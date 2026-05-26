return {
  "mg979/vim-visual-multi",
  branch = "master",
  event = "VeryLazy",
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

    -- VM declares <CR>/<BS> as buffer-local insert maps. On start it
    -- overwrites blink.cmp's buffer-local maps on those keys (one slot per
    -- key per mode); on exit `iunmap <buffer> <CR>` removes both. blink.cmp's
    -- installer (lazy/blink.cmp/lua/blink/cmp/keymap/apply.lua) then
    -- short-circuits on InsertEnter because it still sees other surviving
    -- `blink.cmp:`-desc'd maps, so <CR> is never reinstalled and Enter
    -- inserts a newline instead of accepting the completion.
    --
    -- Force a re-install by deleting all blink.cmp-owned insert maps; the
    -- next InsertEnter rebuilds the full keymap set from scratch.
    local refreshing = false
    local function refresh_blink_keymaps(bufnr)
      if refreshing then
        return
      end
      refreshing = true
      bufnr = bufnr or 0
      for _, m in ipairs(vim.api.nvim_buf_get_keymap(bufnr, "i")) do
        if m.desc and m.desc:find("^blink%.cmp:") then
          pcall(vim.api.nvim_buf_del_keymap, bufnr, "i", m.lhs)
        end
      end
      if vim.api.nvim_get_mode().mode == "i" then
        pcall(vim.api.nvim_exec_autocmds, "InsertEnter", { buffer = bufnr, modeline = false })
      end
      refreshing = false
    end

    vim.api.nvim_create_autocmd("User", {
      pattern = "visual_multi_exit",
      callback = function()
        if vim.b.vm_start_pos then
          vim.api.nvim_win_set_cursor(0, vim.b.vm_start_pos)
          vim.b.vm_start_pos = nil
        end
        refresh_blink_keymaps(0)
      end,
    })

    -- Defense in depth: if VM exits without firing `visual_multi_exit`
    -- (e.g. BufLeave during VM insert mode, see vm.vim:253-258), detect the
    -- broken state on the next InsertEnter — blink's <CR> missing while
    -- other blink maps survive — and recover.
    vim.api.nvim_create_autocmd("InsertEnter", {
      callback = function(args)
        local has_cr, has_other = false, false
        for _, m in ipairs(vim.api.nvim_buf_get_keymap(args.buf, "i")) do
          if m.desc and m.desc:find("^blink%.cmp:") then
            if m.lhs == "<CR>" then
              has_cr = true
            else
              has_other = true
            end
          end
        end
        if has_other and not has_cr then
          refresh_blink_keymaps(args.buf)
        end
      end,
    })
  end,
}
