return {
  -- Reconfigure LazyVim extras
  {
    "ahmedkhalf/project.nvim",
    optional = true,
    opts = function(_, opts)
      local overrides = {
        scope_chdir = "tab",
      }

      local exclude_dirs_overrides = { "build/*", ".cargo/*" }
      opts.exclude_dirs = vim.list_extend(opts.exclude_dirs or {}, exclude_dirs_overrides)

      opts = vim.tbl_deep_extend("force", opts, overrides)
    end,
  },
}
