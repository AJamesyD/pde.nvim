return {
  { "nvim-treesitter/nvim-treesitter", opts = { ensure_installed = { "swift" } } },
  { "neovim/nvim-lspconfig", opts = { servers = { sourcekit = { mason = false } } } },
  { "stevearc/conform.nvim", opts = { formatters_by_ft = { swift = { "swift" } } } },
  { "mfussenegger/nvim-lint", opts = { linters_by_ft = { swift = { "swiftlint" } } } },
}
