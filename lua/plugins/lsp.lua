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
        "pyright",
        "black",
        -- Text
        "yaml-language-server",
        "json-lsp",
        "marksman",
      },
    },
  },
  { import = "lazyvim.plugins.extras.lsp.none-ls" },
  {
    "nvimtools/none-ls.nvim",
    dependencies = {
      "ThePrimeagen/refactoring.nvim",
    },
    opts = function(_, opts)
      local nls = require("null-ls")
      opts.sources = {
        nls.builtins.code_actions.refactoring,
      }
    end,
  },
}
