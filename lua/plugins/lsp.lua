vim.diagnostic.config({
  float = { border = "rounded" },
})

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
    ---@type MasonSettings
    opts = {
      PATH = "append",
      max_concurrent_installers = 10,
      ui = {
        border = "rounded",
      },
    },
  },

  -- Other
  {
    "oribarilan/lensline.nvim",
    branch = "release/1.x",
    event = "LspAttach",
    opts = {},
    config = true,
  },
}
