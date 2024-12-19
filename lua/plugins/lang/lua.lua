return {
  -- Reconfigure LazyVim defaults
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
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
}
