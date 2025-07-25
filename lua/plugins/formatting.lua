return {
  -- Reconfigure LazyVim defaults
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        -- TODO: Figure out how to make * and _ respect vim.b/g.autoformat
        -- Use the "*" filetype to run formatters on all filetypes.
        ["*"] = { "trim_whitespace", "injected" },
        -- Use the "_" filetype to run formatters on filetypes that don't
        -- have other formatters configured.
        -- ["_"] = { "trim_newlines" },
      },
    },
  },

  -- Other
  {
    "NMAC427/guess-indent.nvim",
    config = true,
  },
}
