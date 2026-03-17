return {
  -- Reconfigure LazyVim defaults
  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        rustfmt = {
          options = { nightly = true },
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
        crates = {
          enabled = true,
          min_chars = 2,
        },
      },
      popup = {
        show_version_date = true,
      },
    },
  },
  {
    "mrcjkb/rustaceanvim",
    optional = true,
    version = "^8",
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
            -- NOTE: Redundant with ufo's servers["*"] foldingRange capability (ui.lua).
            -- Kept so rust-analyzer retains folding if ufo is ever removed.
            local capability_overrides = {
              textDocument = {
                foldingRange = {
                  dynamicRegistration = false,
                  lineFoldingOnly = true,
                },
              },
            }
            client.capabilities = vim.tbl_deep_extend("force", client.capabilities or {}, capability_overrides)
            local map = require("util").map

            if LazyVim.has("nvim-dap") then
              map("n", "<leader>dr", function()
                vim.cmd.RustLsp("debuggables")
              end, { desc = "Rust Debuggables", buffer = bufnr })
            end

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
              check = {
                command = "clippy",
                extraArgs = {
                  "--no-deps",
                },
              },
              completion = {
                fullFunctionSignatures = { enable = true },
              },
              diagnostics = {
                experimental = {
                  enable = true,
                },
                styleLints = { enable = true },
              },
              files = {
                exclude = {
                  ".cargo",
                  ".config",
                  ".direnv",
                  ".github",
                  ".gitlab",
                  ".jj",
                  ".venv",
                  "bin",
                  "build",
                  "node_modules",
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
                  minLines = 35,
                },
                -- closureCaptureHints = { enable = true }, -- TODO: make toggle-able
                expressionAdjustmentHints = {
                  enable = "always",
                  hideOutsideUnsafe = true,
                },
                genericParameterHints = {
                  lifetime = { enable = true },
                  type = { enable = true },
                },
              },
              lens = {
                run = { enable = false },
                debug = { enable = false },
                -- All references default to false.
                -- TODO: make toggle-able
                references = {
                  -- adt = { enable = true },
                  -- enumVariant = { enable = true },
                  -- method = { enable = true },
                  -- trait = { enable = true },
                },
              },
              lru = {
                capacity = 512,
              },
              references = {
                excludeImports = true,
              },
              rustfmt = {
                extraArgs = { "+nightly" },
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

      local toolbox_ra_path = vim.fn.expand("~") .. "/.toolbox/bin/rust-analyzer"
      if vim.fn.executable(toolbox_ra_path) ~= 0 then
        vim.notify("Using toolbox-vended rust-analyzer")
        overrides.server.cmd = { toolbox_ra_path }
      end

      opts = vim.tbl_deep_extend("force", opts, overrides)
      return opts
    end,
  },

  -- Other
  {
    "jmbuhr/otter.nvim",
    optional = true,
    opts = {
      buffers = {
        preambles = {
          rust = {
            "#![allow(unused, dead_code)]",
            "use std::collections::*;",
            "use std::io::{self, Read, Write, BufRead};",
            "use std::path::{Path, PathBuf};",
            "use std::fmt;",
            "use std::fs;",
          },
        },
      },
    },
  },
}
