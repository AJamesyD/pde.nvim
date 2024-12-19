return {
  -- Reconfigure LazyVim defaults
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      servers = {
        ---@type vim.lsp.ClientConfig
        ---@diagnostic disable-next-line: missing-fields
        nil_ls = {
          settings = {
            ["nil"] = {
              nix = {
                maxMemoryMB = nil,
                flake = {
                  autoArchive = true,
                  autoEvalInputs = true,
                },
              },
            },
          },
          on_attach = function(client, bufnr)
            -- TODO: Re-enable when semantic highlighting is better
            client.server_capabilities.semanticTokensProvider = nil
          end,
        },
        ---@type vim.lsp.ClientConfig
        ---@diagnostic disable-next-line: missing-fields
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
          on_attach = function(client, bufnr)
            -- TODO: Re-enable when semantic highlighting is better
            client.server_capabilities.semanticTokensProvider = nil
          end,
        },
      },
    },
  },
}
