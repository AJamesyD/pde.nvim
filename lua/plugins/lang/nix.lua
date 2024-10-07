return {
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      ---@type lspconfig.options
      servers = {
        nil_ls = {
          settings = {
            ["nil"] = {
              nix = {
                maxMemoryMB = 3072,
                flake = {
                  autoEvalInputs = true,
                },
              },
            },
          },
        },
      },
    },
  },
}
