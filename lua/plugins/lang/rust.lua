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
    ---@type LazyTermOpts
    local term_opts = {
      cwd = cwd,
    }
    LazyVim.terminal(cmd, term_opts)
  end,
}

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
            cargo = {
              features = "all",
            },
            -- TODO: conditionally disable for big projects
            -- use bacon or flycheck instead
            checkOnSave = true,
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
              kind.Field,
              kind.Method,
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
