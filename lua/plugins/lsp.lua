vim.diagnostic.config({
  float = { border = "rounded" },
})

return {
  {
    "mrcjkb/rustaceanvim",
    optional = true,
    ---@class RustaceanOpts
    opts = {
      on_attach = require("lazyvim.util").lsp.on_attach(function(client, buffer) end),
      tools = {
        hover_actions = {
          replace_builtin_hover = false,
        },
        code_actions = {
          ui_select_fallback = true,
        },
      },
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
            diagnostics = {
              disabled = {
                "unresolved-proc-macro",
              },
              styleLints = {
                enable = true,
              },
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
    ---@class PluginLspOpts
    opts = {
      ---@type lspconfig.options
      servers = {
        -- Rust
        rust_analyzer = {
          mason = false,
        },
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
        rust_analyzer = function()
          return true
        end,
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
        "black",
        -- Text
        "yaml-language-server",
        "json-lsp",
        "marksman",
      },
    },
  },
}
