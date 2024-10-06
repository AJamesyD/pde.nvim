return {
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      ---@type lspconfig.options
      servers = {
        rust_analyzer = {
          mason = false,
        },
      },
      setup = {
        rust_analyzer = function()
          return true
        end,
      },
    },
  },
  {
    "Saecki/crates.nvim",
    opts = {
      thousands_separator = ",",
      popup = {
        border = "rounded",
        show_version_date = true,
      },
      completion = {
        cmp = { enabled = true },
        crates = { enabled = true },
      },
      lsp = {
        enabled = true,
        actions = true,
        completion = true,
        hover = true,
      },
    },
  },
  {
    "mrcjkb/rustaceanvim",
    ---@class RustaceanOpts
    opts = {
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
              features = "all",
            },
            completion = {
              fullFunctionSignatures = { enable = true },
            },
            diagnostics = {
              experimental = true,
              disabled = {
                "unresolved-proc-macro",
              },
              styleLints = { enable = true },
            },
            imports = {
              granularity = { enforce = true },
            },
            inlayHints = {
              chainingHints = { enable = true },
            },
            rustfmt = {
              extraArgs = "+nightly",
            },
          },
        },
      },
    },
  },
}
