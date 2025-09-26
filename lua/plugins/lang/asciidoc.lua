return {
  -- Reconfigure LazyVim defaults
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      { "cathaysia/tree-sitter-asciidoc" },
    },
    opts = function(_, opts)
      local ts_parser_configs = require("nvim-treesitter.parsers")

      ---@diagnostic disable-next-line: inject-field
      ts_parser_configs.asciidoc = {
        install_info = {
          url = "https://github.com/cathaysia/tree-sitter-asciidoc",
          location = "tree-sitter-asciidoc",
          files = { "src/parser.c", "src/scanner.c" },
        },
      }

      ---@diagnostic disable-next-line: inject-field
      ts_parser_configs.asciidoc_inline = {
        install_info = {
          url = "https://github.com/cathaysia/tree-sitter-asciidoc",
          location = "tree-sitter-asciidoc_inline",
          files = { "src/parser.c", "src/scanner.c" },
        },
      }

      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "asciidoc", "asciidoc_inline" })
      end
    end,
  },

  -- Other
  {
    "tigion/nvim-asciidoc-preview",
    ft = { "asciidoc" },
    build = "cd server && npm install",
  },
}
