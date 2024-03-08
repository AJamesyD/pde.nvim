vim.diagnostic.config({
  float = { border = "rounded" },
})

return {
  {
    "linux-cultist/venv-selector.nvim",
    optional = true,
    dependencies = { "neovim/nvim-lspconfig", "nvim-telescope/telescope.nvim" },
    cmd = { "VenvSelect", "VenvSelectCached", "VenvSelectCurrent" },
  },
  {
    "mrcjkb/rustaceanvim",
    optional = true,
    opts = {
      on_attach = require("lazyvim.util").lsp.on_attach(function(client, buffer) end),
      server = {
        settings = {
          -- rust-analyzer language server configuration
          ["rust-analyzer"] = {
            cargo = {
              features = "all",
            },
            check = {
              command = "clippy",
              extraArgs = {
                "--no-deps",
              },
              features = "all",
            },
            inlayHints = {
              chainingHints = { enable = true },
            },
          },
        },
      },
    },
  },
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
        opts = {
          preview_empty_name = true,
        },
      },
    },
    ---@class PluginLspOpts
    opts = {
      ---@type lspconfig.options
      servers = {
        -- Lua
        lua_ls = {
          settings = {
            Lua = {
              doc = {
                privateName = { "^_" },
              },
              hint = {
                enable = true,
                arrayIndex = "Disable",
                semicolon = "Disable",
              },
              workspace = {
                checkThirdParty = false,
              },
              diagnostics = {
                disable = { "incomplete-signature-doc", "trailing-space" },
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
            python = {
              analysis = {
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
    opts = {
      ensure_installed = {
        -- Lua
        "lua-language-server",
        "stylua",
        "selene",
        "luacheck",
        -- Shell
        "bash-language-server",
        "shfmt",
        "shellcheck",
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
