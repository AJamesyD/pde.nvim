return {
  -- Reconfigure LazyVim defaults
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.highlight = opts.highlight or {}
      local vim_regex_highlighting = opts.highlight.additional_vim_regex_highlighting
      if type(vim_regex_highlighting) == "table" then
        vim_regex_highlighting = vim.list_extend(vim_regex_highlighting, { "ion" })
      else
        vim_regex_highlighting = { "ion" }
      end

      opts.highlight.additional_vim_regex_highlighting = vim_regex_highlighting
      return opts
    end,
  },
}
