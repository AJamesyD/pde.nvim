return {
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
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
          setup = {
            ["nil"] = function()
              LazyVim.lsp.on_attach(function(client, _)
                -- TODO: Re-enable when semantic highlighting is better
                client.server_capabilities.semanticTokensProvider = nil
              end, "nil")
            end,
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
          setup = {
            ["nixd"] = function()
              LazyVim.lsp.on_attach(function(client, _)
                -- TODO: Re-enable when semantic highlighting is better
                client.server_capabilities.semanticTokensProvider = nil
              end, "nixd")
            end,
          },
        },
      },
    },
  },
}
