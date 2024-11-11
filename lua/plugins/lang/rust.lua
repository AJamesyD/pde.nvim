---@type rustaceanvim.Executor
local lazyterm_executor = {
  execute_command = function(command, args, cwd, _)
    local shell = require("rustaceanvim.shell")

    local cmd = shell.make_command_from_args(command, args)
    local cmd = cmd:split(" ")
    cmd = vim.tbl_filter(function(str)
      return str ~= nil and #str > 0
    end, cmd)
    for i, str in ipairs(cmd) do
      print("cmd part " .. i .. ": " .. str)
    end
    ---@type snacks.terminal.Opts
    local term_opts = {
      cwd = cwd,
    }
    Snacks.terminal.open(cmd, term_opts)
  end,
}

return {
  {
    "stevearc/conform.nvim",
    optional = true,
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
  {
    "Saecki/crates.nvim",
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
    version = "^5",
    ---@type rustaceanvim.Opts
    opts = {
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
        executor = lazyterm_executor,
        test_executor = "background",
        crate_test_executor = "background",
      },
      server = {
        on_attach = function(_, bufnr)
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
        end,
        default_settings = {
          -- rust-analyzer language server configuration
          ["rust-analyzer"] = {
            assist = {
              emitMustUse = true,
            },
            cachePriming = {
              numThreads = "logical",
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
              limit = 100,
              postfix = { enable = false }, -- TODO: eventually try using these
              termSearch = { enable = true }, -- TODO: experiment
            },
            diagnostics = {
              experimental = true,
              disabled = {
                "unresolved-proc-macro",
              },
              styleLints = { enable = true },
            },
            hover = {
              actions = {
                references = { enable = true },
              },
              show = {
                enumVariants = 10,
                fields = 10,
              },
            },
            -- XXX: Should inherit .rustfmt config when available
            imports = {
              granularity = { enforce = true },
              preferPrelude = true,
              prefix = "self", -- This is what I've seen in CargoBrazil (I think?)
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
            interpret = {
              tests = true, -- XXX: Experimental
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
            numThreads = "logical",
            rustfmt = {
              extraArgs = "+nightly",
            },
            semanticHighlighting = {
              nonStandardTokens = false, -- TODO: find theme that supports these better
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
    },
  },
  {
    "zjp-CN/nvim-cmp-lsp-rs",
    lazy = true,
    ---@type cmp_lsp_rs.Opts
    opts = {
      kind = function(kind)
        return {
          kind.Variable,
          --
          kind.EnumMember,
          kind.Value,
          kind.Field,
          kind.Property,
          --
          kind.TypeParameter, -- ??
          kind.Method,
          --
          kind.Module,
          kind.Constructor,
          --
          kind.Function,
          --
          kind.Struct,
          kind.Enum,
          kind.Constant,
          --
          kind.Keyword,
        }
      end,
    },
  },
}
