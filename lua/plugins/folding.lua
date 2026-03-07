return {
  {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    event = "BufReadPost",
    init = function()
      -- Disable fold highlight - run after colorscheme loads
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          vim.api.nvim_set_hl(0, "Folded", { bg = "NONE" })
          vim.api.nvim_set_hl(0, "UfoFoldedBg", { bg = "NONE" })
        end,
      })
      -- Also set immediately for current colorscheme
      vim.api.nvim_set_hl(0, "Folded", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "UfoFoldedBg", { bg = "NONE" })
    end,
    keys = {
      { "zR", function() require("ufo").openAllFolds() end, desc = "Open all folds" },
      { "zM", function() require("ufo").closeAllFolds() end, desc = "Close all folds" },
      { "zK", function() require("ufo").peekFoldedLinesUnderCursor() end, desc = "Peek fold" },
    },
    opts = {
      provider_selector = function()
        return { "treesitter", "indent" }
      end,
      fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local suffix = ("  %d lines "):format(endLnum - lnum)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0
        for _, chunk in ipairs(virtText) do
          local chunkText = chunk[1]
          local chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
          else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            break
          end
          curWidth = curWidth + chunkWidth
        end
        table.insert(newVirtText, { suffix, "Comment" })
        return newVirtText
      end,
      open_fold_hl_timeout = 0,
    },
  },

  {
    "luukvbaal/statuscol.nvim",
    event = "BufReadPost",
    init = function()
      -- Toggle fold column with <leader>uo
      vim.keymap.set("n", "<leader>uo", function()
        if vim.o.foldcolumn == "0" then
          vim.o.foldcolumn = "1"
        else
          vim.o.foldcolumn = "0"
        end
      end, { desc = "Toggle fold column" })
    end,
    opts = function()
      local builtin = require("statuscol.builtin")
      return {
        relculright = true,
        segments = {
          { text = { "%s" }, click = "v:lua.ScSa" },
          { text = { builtin.lnumfunc }, click = "v:lua.ScLa" },
          { text = { " ", builtin.foldfunc, " " }, click = "v:lua.ScFa" },
        },
      }
    end,
  },
}
