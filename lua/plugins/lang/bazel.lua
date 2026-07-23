vim.filetype.add({
  pattern = {
    [".*%.?bazelrc"] = "bazelrc",
  },
})

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
        bazelrc_lsp = {},
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
      ensure_installed = { "bazelrc-lsp", "buildifier", "starpls" },
    },
  },

  -- Other
  {
    "zaucy/tree-sitter-bazelrc",
    build = function(plugin)
      local parser_dir = vim.fn.stdpath("data") .. "/site/parser"
      vim.fn.mkdir(parser_dir, "p")
      local result = vim
        .system({ "tree-sitter", "build", "-o", parser_dir .. "/bazelrc.so" }, { cwd = plugin.dir })
        :wait()
      if result.code ~= 0 then
        error(result.stderr)
      end
    end,
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "bazelrc",
        callback = function(ev)
          vim.treesitter.start(ev.buf, "bazelrc")
        end,
      })
    end,
  },
}
