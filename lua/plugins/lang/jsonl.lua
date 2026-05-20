return {
  {
    "AJamesyD/tree-sitter-jsonl",
    build = function(plugin)
      local parser_dir = vim.fn.stdpath("data") .. "/site/parser"
      vim.fn.mkdir(parser_dir, "p")
      vim.system({ "tree-sitter", "build", "-o", parser_dir .. "/jsonl.so" }, { cwd = plugin.dir }):wait()
    end,
    init = function()
      vim.filetype.add({ extension = { jsonl = "jsonl" } })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "jsonl",
        callback = function(ev)
          vim.treesitter.start(ev.buf, "jsonl")
        end,
      })
    end,
  },
  {
    "Wansmer/treesj",
    opts = function(_, opts)
      local tsj_utils = require("treesj.langs.utils")
      local json = require("treesj.langs.json")

      local overrides = {
        langs = {
          jsonl = tsj_utils.merge_preset(json, {}),
        },
      }

      opts = vim.tbl_deep_extend("force", opts, overrides)
      return opts
    end,
  },
}
