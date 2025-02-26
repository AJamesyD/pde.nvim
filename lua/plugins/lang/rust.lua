return {
  -- Reconfigure LazyVim defaults
  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        rust = {
          args = function(self, ctx)
            local util = require("conform.util")

            local args = { "+nightly", "--emit=stdout" }
            local edition = util.parse_rust_edition(ctx.dirname) or self.options.default_edition
            table.insert(args, "--edition=" .. edition)

            return args
          end,
        },
      },
      formatters_by_ft = {
        rust = { "rustfmt" },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      servers = {
        rust_analyzer = {
          enabled = false,
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

  -- Reconfigure LazyVim extras
  {
    "Saecki/crates.nvim",
    optional = true,
    opts = {
      thousands_separator = ",",
      completion = {
        cmp = { enabled = true },
        crates = { enabled = true },
      },
      popup = {
        border = "rounded",
        show_version_date = true,
      },
    },
  },
  {
    "mrcjkb/rustaceanvim",
    optional = true,
    version = "^5",
    ---@param opts rustaceanvim.Opts
    opts = function(_, opts)
      ---@type rustaceanvim.Opts
      local overrides = {
        tools = {
          hover_actions = {
            replace_builtin_hover = false,
          },
          ---@type rustaceanvim.FloatWinConfig|vim.api.keyset.win_config
          float_win_config = {
            auto_focus = true,
            open_split = "vertical",
            width = 0.8,
          },
          test_executor = "background",
          crate_test_executor = "background",
        },
        ---@type rustaceanvim.lsp.ClientConfig
        ---@diagnostic disable-next-line: missing-fields
        server = {
          standalone = false,
          on_attach = function(client, bufnr)
            local capability_overrides = {
              textDocument = {
                foldingRange = {
                  dynamicRegistration = false,
                  lineFoldingOnly = true,
                },
              },
            }
            client.capabilities = vim.tbl_deep_extend("force", client.capabilities or {}, capability_overrides)
            local map = MyUtils.map

            map("n", "<leader>dr", function()
              vim.cmd.RustLsp("debuggables")
            end, { desc = "Rust Debuggables", buffer = bufnr })

            -- Move lines
            map("i", "<A-j>", function()
              vim.cmd.RustLsp({ "moveItem", "down" })
            end, { desc = "Move Down", buffer = bufnr })
            map("i", "<A-k>", function()
              vim.cmd.RustLsp({ "moveItem", "up" })
            end, { desc = "Move Up", buffer = bufnr })
            map("v", "<A-j>", function()
              vim.cmd.RustLsp({ "moveItem", "down" })
            end, { desc = "Move Down", buffer = bufnr })
            map("v", "<A-k>", function()
              vim.cmd.RustLsp({ "moveItem", "up" })
            end, { desc = "Move Up", buffer = bufnr })

            -- Join lines
            map("n", "J", function()
              vim.cmd.RustLsp("joinLines")
            end, { desc = "Join Lines", buffer = bufnr })

            -- HACK: Workaround to ignore ServerCancelled error
            -- https://github.com/neovim/neovim/issues/30985#issuecomment-2447329525
            for _, method in ipairs({ "textDocument/diagnostic", "workspace/diagnostic" }) do
              local default_diagnostic_handler = vim.lsp.handlers[method]
              vim.lsp.handlers[method] = function(err, result, context, config)
                if err ~= nil and err.code == -32802 then
                  return
                end
                return default_diagnostic_handler(err, result, context, config)
              end
            end
          end,

          default_settings = {
            -- rust-analyzer language server configuration
            ["rust-analyzer"] = {
              assist = {
                emitMustUse = true,
              },
              cargo = {
                features = "all",
              },
              -- TODO: conditionally disable for big projects
              -- use bacon or flycheck instead
              checkOnSave = true,
              check = {
                command = "clippy",
                extraArgs = {
                  "--no-deps",
                },
                features = "all",
              },
              completion = {
                fullFunctionSignatures = { enable = true },
                postfix = { enable = false }, -- TODO: eventually try using these
              },
              diagnostics = {
                enable = true,
                experimental = {
                  enable = true,
                },
                disabled = {
                  "unresolved-proc-macro",
                },
                styleLints = { enable = true },
              },
              files = {
                exclude = {
                  ".cargo",
                  ".config",
                  ".direnv",
                  ".git",
                  ".github",
                  ".gitlab",
                  ".venv",
                  "bin",
                  "build",
                  "node_modules",
                  "target",
                  "venv",
                },
              },
              hover = {
                show = {
                  enumVariants = 10,
                  fields = 10,
                },
              },
              -- XXX: Should inherit .rustfmt config when available
              imports = {
                granularity = { enforce = true },
                preferPrelude = true,
              },
              inlayHints = {
                closingBraceHints = {
                  enable = true,
                  minLines = 35,
                },
                -- closureCaptureHints = { enable = true }, -- TODO: make toggle-able
                closureReturnTypeHints = { enable = "block" },
                expressionAdjustmentHints = {
                  enable = true,
                  hideOutsideUnsafe = true,
                },
                genericParameterHints = {
                  lifetime = { enable = true },
                  type = { enable = true },
                },
              },
              lens = {
                enable = true,
                debug = { enable = false }, -- TODO: find better way to integrate with nvim-dap
                implementations = { enable = true },
                -- All references default to false.
                -- TODO: make toggle-able
                references = {
                  -- adt = { enable = true },
                  -- enumVariant = { enable = true },
                  -- method = { enable = true },
                  -- trait = { enable = true },
                },
                run = { enable = false }, -- TODO: find better way to integrate with neotest
              },
              lru = {
                capacity = 512,
              },
              references = {
                excludeImports = true,
              },
              rustfmt = {
                extraArgs = "+nightly",
              },
              workspace = {
                symbol = {
                  search = {
                    limit = 512,
                  },
                },
              },
            },
          },
        },
      }

      opts = vim.tbl_deep_extend("force", opts, overrides)
      return opts
    end,
  },
}
