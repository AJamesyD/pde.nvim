vim.filetype.add({
  pattern = {
    [".*/.github/workflows/.*%.ya?ml"] = "yaml.ghaction",
    [".*/.github/actions/.*/action%.ya?ml"] = "yaml.ghaction",
  },
})

vim.api.nvim_create_autocmd("User", {
  pattern = "TSUpdate",
  once = true,
  callback = function()
    require("nvim-treesitter.parsers").ghactions = {
      install_info = {
        url = "https://github.com/rmuir/tree-sitter-ghactions",
        queries = "queries",
      },
    }
  end,
})

return {
  -- Reconfigure LazyVim defaults
  {
    "mfussenegger/nvim-lint",
    opts = { linters_by_ft = { ghaction = { "actionlint" } } },
  },
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "actionlint" } },
  },
}
