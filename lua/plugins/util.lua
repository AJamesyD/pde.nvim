return {
  -- Reconfigure LazyVim extras
  {
    "ahmedkhalf/project.nvim",
    optional = true,
    opts = function(_, opts)
      opts.exclude_dirs = vim.list_extend(opts.exclude_dirs or {}, { "build/*", ".cargo/*" })
      opts.scope_chdir = "tab"
    end,
  },
}
