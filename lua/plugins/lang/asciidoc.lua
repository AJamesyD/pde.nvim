return {
  {
    "cathaysia/tree-sitter-asciidoc",
    -- NOTE: monorepo with two grammars in subdirectories, not at repo root
    build = function(plugin)
      local parser_dir = vim.fn.stdpath("data") .. "/site/parser"
      vim.fn.mkdir(parser_dir, "p")
      vim.system({ "tree-sitter", "build", "-o", parser_dir .. "/asciidoc.so" }, { cwd = plugin.dir .. "/tree-sitter-asciidoc" }):wait()
      vim.system({ "tree-sitter", "build", "-o", parser_dir .. "/asciidoc_inline.so" }, { cwd = plugin.dir .. "/tree-sitter-asciidoc_inline" }):wait()
    end,
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "asciidoc",
        callback = function(ev)
          vim.treesitter.start(ev.buf, "asciidoc")
        end,
      })
    end,
  },
}
