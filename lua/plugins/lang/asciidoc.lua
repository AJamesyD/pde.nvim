return {
  {
    "cathaysia/tree-sitter-asciidoc",
    -- NOTE: monorepo with two grammars in subdirectories, not at repo root
    build = function(plugin)
      local parser_dir = vim.fn.stdpath("data") .. "/site/parser"
      vim.fn.mkdir(parser_dir, "p")
      local r1 = vim.system({ "tree-sitter", "build", "-o", parser_dir .. "/asciidoc.so" }, { cwd = plugin.dir .. "/tree-sitter-asciidoc" }):wait()
      if r1.code ~= 0 then error(r1.stderr) end
      local r2 = vim.system({ "tree-sitter", "build", "-o", parser_dir .. "/asciidoc_inline.so" }, { cwd = plugin.dir .. "/tree-sitter-asciidoc_inline" }):wait()
      if r2.code ~= 0 then error(r2.stderr) end
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
