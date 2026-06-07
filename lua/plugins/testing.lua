-- Test runner + coverage — the WebStorm "test tool window + gutter coverage" equivalent.
--
-- Two independent pieces, both 100% on-demand: nothing loads at startup, nothing runs on
-- the typing/scroll hot path. The only CPU work is the external test process, run async
-- via nvim-nio — same cost as a terminal, so the UI stays responsive.
--
--   1. neotest — runs tests, inline ✓/✗ virtual text, results summary, output float.
--      Enabled via LazyVim's `test.core` extra (see lazyvim.json), which also AUTO-wires
--      adapters from your already-enabled lang extras — you get these for free:
--          • Go     → neotest-golang   (+ DAP debug on <leader>td)
--          • Python → neotest-python
--          • Rust   → rustaceanvim
--      This file only adds the TS/JS adapter (the typescript extra ships none) and tightens
--      two defaults below. Core keymaps come from test.core, all under <leader>t:
--          tr run nearest · tt run file · tT run all · ts summary · to output · tw watch · td debug
--
--   2. nvim-coverage — paints covered/uncovered lines in the sign column from a REPORT your
--      test runner produced. It does NOT run anything itself — generate the report first:
--          • TS/JS (Vitest): npx vitest run --coverage    → coverage/lcov.info
--          • Go:             go test -coverprofile=cover.out ./...
--      then <leader>tcc (or :Coverage) to load + show. lcov/coverprofile parse natively;
--      no luarocks needed.

return {
  -- TS/JS adapter + two safety/perf overrides on the neotest provided by test.core.
  {
    "nvim-neotest/neotest",
    optional = true, -- only applies if test.core is enabled (it is)
    dependencies = {
      "marilari88/neotest-vitest", -- Vitest. For Jest: swap to "nvim-neotest/neotest-jest".
    },
    opts = {
      adapters = {
        ["neotest-vitest"] = {}, -- Jest: replace this key with ["neotest-jest"] = {}
      },
      -- PROTECT your curated/persisted quickfix pins. neotest defaults quickfix.enabled=true,
      -- which repopulates the live list on every run — and the VimLeavePre persistence
      -- (config/quickfix-persistence.lua, via autocmds.lua) would then bake test failures
      -- into the saved pins. Results still arrive via virtual text, the output panel, and the
      -- summary, so nothing is lost by turning this off.
      quickfix = { enabled = false },
      -- PERFORMANCE: skip project-wide discovery / file-watching. Running nearest/file/cwd
      -- still works; the summary just lists tests from files you've opened or run, not the
      -- whole tree. Flip to { enabled = true } if you want auto-populated project discovery.
      discovery = { enabled = false },
    },
  },

  -- Gutter coverage. Lazy: loads only when a Coverage command/keymap is invoked.
  {
    "andythigpen/nvim-coverage",
    main = "coverage",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = {
      "Coverage",
      "CoverageLoad",
      "CoverageShow",
      "CoverageHide",
      "CoverageToggle",
      "CoverageClear",
      "CoverageSummary",
    },
    -- stylua: ignore
    keys = {
      { "<leader>tc",  "",                          desc = "+coverage" },
      { "<leader>tcc", "<cmd>Coverage<cr>",         desc = "Coverage: load & show" },
      { "<leader>tct", "<cmd>CoverageToggle<cr>",   desc = "Coverage: toggle signs" },
      { "<leader>tcs", "<cmd>CoverageSummary<cr>",  desc = "Coverage: summary" },
      { "<leader>tcx", "<cmd>CoverageClear<cr>",    desc = "Coverage: clear" },
    },
    -- Minimal setup: signs + summary only, no background watcher. Set `auto_reload = true`
    -- if you want loaded signs to refresh when the report file changes on the next run.
    opts = {},
  },
}
