vim.diagnostic.config({
  float = { border = "rounded" },
})

return {
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
      ---@type lspconfig.options
      servers = {
        lua_ls = {
          settings = {
            Lua = {
              codeLens = {
                enable = false,
              },
              diagnostics = {
                disable = { "incomplete-signature-doc", "trailing-space" },
              },
            },
          },
        },
      },
    },
  },
  {
    "williamboman/mason.nvim",
    dependencies = {
      "Zeioth/mason-extra-cmds",
      cmd = "MasonUpdateAll",
      build = ":MasonUpdateAll",
      config = true,
    },
    cmd = {
      "MasonUpdateAll", -- this cmd is provided by mason-extra-cmds
    },
    ---@type MasonSettings
    opts = {
      PATH = "append",
      max_concurrent_installers = 10,
      ui = {
        border = "rounded",
      },
    },
  },
}
