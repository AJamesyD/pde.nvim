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
        nixd = {
          settings = {
            nixd = {
              opts = {
                ["flake-parts"] = {
                  expr = '(builtins.getFlake "~/.config/nix/flake.nix").debug.options',
                },
                ["flake-parts=ps"] = {
                  expr = '(builtins.getFlake "~/.config/nix/flake.nix").currentSystem.options',
                },
              },
            },
          },
        },
      },
    },
  },
}
