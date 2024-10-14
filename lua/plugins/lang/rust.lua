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
    version = "^5",
    ---@type rustaceanvim.Opts
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
        default_settings = {
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
            hover = {
              show = {
                enumVariants = 10,
                fields = 10,
              },
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
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      {
        "zjp-CN/nvim-cmp-lsp-rs",
        ---@type cmp_lsp_rs.Opts
        opts = {
          kind = function(kind)
            return {
              kind.Variable,
              kind.EnumMember,
              kind.Method,
              kind.Field,
              kind.Function,
            }
          end,
        },
        config = true,
      },
    },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local cmp_lsp_rs = require("cmp_lsp_rs")
      local rs_comparators = cmp_lsp_rs.comparators

      -- TODO: Find a way to not use a magic number
      table.insert(opts.sorting.comparators, 5, rs_comparators.inherent_import_inscope)
      table.insert(opts.sorting.comparators, 6, rs_comparators.sort_by_label_but_underscore_last)

      for _, source in ipairs(opts.sources) do
        cmp_lsp_rs.filter_out.entry_filter(source)
      end

      return opts
    end,
  },
}
