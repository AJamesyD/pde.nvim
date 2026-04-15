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
      -- TODO: re-enable with lensline.nvim for proper indentation.
      -- Native codelens renders at column 0, ignoring code indentation.
      ---@type lsp.CodeLensOptions
      codelens = {
        enabled = false,
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
