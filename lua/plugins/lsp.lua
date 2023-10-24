return {
  { import = "lazyvim.plugins.extras.lang.json" },
  { import = "lazyvim.plugins.extras.lang.yaml" },
  { import = "lazyvim.plugins.extras.lang.python" },
  { import = "lazyvim.plugins.extras.lang.typescript" },
  -- add pyright to lspconfig
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "smjonas/inc-rename.nvim",
        init = function()
          require("lazyvim.util").lsp.on_attach(function(_, buffer)
            -- stylua: ignore
            vim.keymap.set("n", "<leader>cr", "<CMD>IncRename ", { desc = "Rename", buffer = buffer })
          end)
        end,
        config = true,
      },
    },
    ---@class PluginLspOpts
    opts = {
      inlay_hints = {
        enabled = true,
      },
      ---@type lspconfig.options
      servers = {
        -- Lua
        lua_ls = {
          settings = {
            Lua = {
              hint = {
                enable = true,
                arrayIndex = "Disable",
              },
            },
          },
        },
        -- Python
        pyright = {
          settings = {
            pyright = {
              disableLanguageServices = false,
              disableOrganizeImports = true,
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
                  enabled = true,
                },
                rope_autoimport = {
                  enabled = true,
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
          ---@param client lsp.Client
          require("lazyvim.util").lsp.on_attach(function(client, _)
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

  -- add any tools you want to have installed below
  {
    "williamboman/mason.nvim",
    keys = {
      { "<leader>cm", false },
    },
    opts = {
      ensure_installed = {
        -- Lua
        "lua-language-server",
        "stylua",
        -- Shell
        "shellcheck",
        "shfmt",
        -- Python
        "ruff-lsp",
        "python-lsp-server",
        "pyright",
        "black",
        -- Text
        "yaml-language-server",
        "json-lsp",
        "marksman",
      },
    },
  },
}
