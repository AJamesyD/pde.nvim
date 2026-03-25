return {
  -- Reconfigure LazyVim defaults
  {
    "stevearc/conform.nvim",
    dependencies = {
      {
        "folke/lazydev.nvim",
        optional = true,
        opts = function(_, opts)
          opts.library = opts.library or {}
          table.insert(opts.library, { path = "conform.nvim", words = { "conform" } })
        end,
      },
    },
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
}
