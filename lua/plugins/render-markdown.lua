-- Polished markdown rendering for LSP hover popups and Avante windows.
-- Real `.md` files in the editor are out of scope here (user doesn't edit
-- markdown in this Neovim setup); if that ever changes, add a FileType
-- autocmd calling `buf_disable()` when `buftype ~= "nofile"`.

return {
  {
    -- Ensure markdown parsers are present so render-markdown has something to walk.
    -- LazyVim merges this into the base nvim-treesitter spec.
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "markdown", "markdown_inline" } },
  },
  {
    enabled = false,
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    ft = { "markdown", "Avante" },
    opts = {
      file_types = { "markdown", "Avante" },
      -- We don't want render-markdown providing blink.cmp/cmp sources.
      completions = { lsp = { enabled = false } },
      -- Match the hover-popup behavior set in lua/config/keymaps.lua: keep
      -- markdown fences/emphasis hidden even when the cursor sits on the line.
      -- Plugin default is `concealcursor.rendered = ""` which reveals raw
      -- markdown under the cursor — the "toggle between markdown and text"
      -- you saw in Avante.
      -- Pin BOTH `default` and `rendered` to the rendered values. The plugin
      -- toggles between these two states during its render cycle (e.g. briefly
      -- before each redraw, when the buffer enters a non-`render_modes` state).
      -- If `default` is `""`, that toggle reveals raw markdown under the cursor
      -- for a frame and the conceal can stick at `""` until a full re-render.
      -- Pinning both eliminates any window where the fence becomes visible.
      -- Safe in this setup because render-markdown only attaches to hover floats
      -- and Avante — never to real markdown files where defaults matter.
      win_options = {
        conceallevel = { default = 3, rendered = 3 },
        concealcursor = { default = "n", rendered = "n" },
      },
      -- Hover popups (buftype=nofile) get a tightened style: NormalFloat padding
      -- matches the float background, sign column off (signs look broken in
      -- narrow floats). render-markdown's docs explicitly recommend this block
      -- for LSP hover docs.
      overrides = {
        buftype = {
          nofile = {
            -- Render in all modes — the plugin's default mode list can skip
            -- modes that leave fences/symbols raw. `true` = always render.
            -- This is the docs-recommended setting for LSP hover docs.
            render_modes = true,
            padding = { highlight = "NormalFloat" },
            sign = { enabled = false },
            -- Strip the code-block language header (the "lua"/"typescript" chip)
            -- in hover popups. `language = false` hides the header row while
            -- keeping delimiter concealment intact.
            code = { language = false, sign = false },
          },
        },
      },
    },
  },
}
