-- NOTE: queries are owned locally (queries/kanata/) due to upstream regex bug
--   (postsolar/tree-sitter-kanata#1). Don't add a query copy step to build.
return {
  {
    "postsolar/tree-sitter-kanata",
    build = function(plugin)
      local parser_dir = vim.fn.stdpath("data") .. "/site/parser"
      vim.fn.mkdir(parser_dir, "p")
      vim.system({ "tree-sitter", "build", "-o", parser_dir .. "/kanata.so" }, { cwd = plugin.dir }):wait()
    end,
    init = function()
      vim.filetype.add({ extension = { kbd = "kanata" } })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "kanata",
        callback = function(ev)
          vim.treesitter.start(ev.buf, "kanata")
        end,
      })
    end,
  },
}
