return {
  -- Reconfigure LazyVim defaults
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      { "cathaysia/tree-sitter-asciidoc" },
    },
    opts = function(_, opts)
      vim.api.nvim_create_autocmd("User", {
        pattern = "TSUpdate",
        callback = function()
          local ts_parser_configs = require("nvim-treesitter.parsers")

          ---@diagnostic disable-next-line: inject-field
          ts_parser_configs.asciidoc = {
            tier = 1, -- "stable"
            install_info = {
              url = "https://github.com/cathaysia/tree-sitter-asciidoc",
              revision = "276ae6b766830e9d9de9106713d94a6913279bc2",
              location = "tree-sitter-asciidoc",
              files = { "src/parser.c", "src/scanner.c" },
            },
          }

          ---@diagnostic disable-next-line: inject-field
          ts_parser_configs.asciidoc_inline = {
            tier = 1, -- "stable"
            install_info = {
              url = "https://github.com/cathaysia/tree-sitter-asciidoc",
              revision = "276ae6b766830e9d9de9106713d94a6913279bc2",
              location = "tree-sitter-asciidoc_inline",
              files = { "src/parser.c", "src/scanner.c" },
            },
          }
        end,
      })

      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "asciidoc", "asciidoc_inline" })
      end
    end,
  },
}
