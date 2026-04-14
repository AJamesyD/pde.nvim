return {
  -- Reconfigure LazyVim defaults
  {
    "neovim/nvim-lspconfig",
    ---@type PluginLspOpts
    opts = {
      ---@type vim.diagnostic.Opts
      diagnostics = {
        virtual_text = { prefix = "icons" },
      },
      ---@type lsp.CodeLensOptions
      codelens = {
        enabled = true,
      },
    },
  },
  {
    "mason-org/mason.nvim",
    dependencies = {
      {
        "folke/lazydev.nvim",
        optional = true,
        opts = function(_, opts)
          opts.library = opts.library or {}
          table.insert(opts.library, { path = "mason.nvim", words = { "mason" } })
        end,
      },
    },
    ---@type MasonSettings
    opts = {
      PATH = "append",
      max_concurrent_installers = 10,
    },
  },

}
