return {
  -- Reconfigure LazyVim defaults
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = vim.list_extend(opts.ensure_installed or {}, { "starlark" })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      servers = {
        ---@type vim.lsp.ClientConfig
        ---@diagnostic disable-next-line: missing-fields
        starpls = {
          cmd = {
            "starpls",
            "server",
            "--experimental_infer_ctx_attributes",
            "--experimental_use_code_flow_analysis",
          },
        },
      },
    },
  },
  {
    "stevearc/conform.nvim",
    ---@type conform.setupOpts
    opts = {
      formatters_by_ft = {
        bzl = { "buildifier" },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        bzl = { "buildifier" },
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = { "buildifier", "starpls" },
    },
  },
}
