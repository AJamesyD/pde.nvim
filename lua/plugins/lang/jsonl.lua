return {
  -- Reconfigure LazyVim defaults
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      { "AJamesyD/tree-sitter-jsonl" },
    },
    opts = function(_, opts)
      local ts_parser_configs = require("nvim-treesitter.parsers").get_parser_configs()

      ---@diagnostic disable-next-line: inject-field
      ts_parser_configs.jsonl = {
        install_info = {
          url = "https://github.com/AJamesyD/tree-sitter-jsonl",
          files = { "src/parser.c" },
          branch = "mainline",
        },
      }

      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "jsonl" })
      end
    end,
  },
}
