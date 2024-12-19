return {
  -- Reconfigure LazyVim defaults
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      servers = {
        basedpyright = {
          settings = {
            basedpyright = {
              disableLanguageServices = false,
              disableOrganizeImports = true,
              disableTaggedHints = false,
              analysis = {
                autoImportCompletions = true,
                exclude = { "cdk.out" },
                typeCheckingMode = "standard",
              },
            },
          },
        },
        pylsp = {
          settings = {
            pylsp = {
              configurationSources = { "flake8" },
              plugins = {
                autopep8 = {
                  enabled = false,
                },
                flake8 = {
                  enabled = false,
                },
                jedi_completion = {
                  enabled = false,
                },
                jedi_definition = {
                  enabled = false,
                },
                jedi_hover = {
                  enabled = false,
                },
                jedi_references = {
                  enabled = false,
                },
                jedi_signature_help = {
                  enabled = false,
                },
                jedi_symbols = {
                  enabled = false,
                },
                mccabe = {
                  enabled = false,
                },
                pycodestyle = {
                  enabled = false,
                },
                pyflakes = {
                  enabled = false,
                },
                rope_completion = {
                  enabled = false,
                },
                rope_autoimport = {
                  enabled = false,
                },
                yapf = {
                  enabled = false,
                },
              },
            },
          },
        },
      },
      setup = {
        pylsp = function()
          ---@param client vim.lsp.Client
          LazyVim.lsp.on_attach(function(client, _)
            if client.name == "pylsp" then
              -- only enable code actions
              client.server_capabilities.codeActionProvider = true
              client.server_capabilities.definitionProvider = false
              client.server_capabilities.documentFormattingProvider = false
              client.server_capabilities.documentHighlightProvider = false
              client.server_capabilities.documentRangeFormattingProvider = false
              client.server_capabilities.documentSymbolProvider = false
              client.server_capabilities.foldingRangeProvider = false
              client.server_capabilities.hoverProvider = false
              client.server_capabilities.referencesProvider = false
              client.server_capabilities.renameProvider = false
              client.server_capabilities.renameProvider = false
            end
          end)
        end,
      },
    },
  },
}
