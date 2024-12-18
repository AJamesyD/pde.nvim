require("snacks")
  .toggle({
    name = "Split/Join",
    get = function()
      return true
    end,
    set = function(_)
      require("treesj").toggle()
    end,
    notify = false,
  })
  :map("<leader>m")

require("snacks")
  .toggle({
    name = "Split/Join (Recursive)",
    get = function()
      return true
    end,
    set = function(_)
      require("treesj").toggle({ split = { recursive = true } })
    end,
    notify = false,
  })
  :map("<leader>M")

return {
  -- Reconfigure LazyVim defaults
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        -- TODO: Figure out how to make * and _ respect vim.b/g.autoformat
        -- Use the "*" filetype to run formatters on all filetypes.
        ["*"] = { "trim_whitespace", "injected" },
        -- Use the "_" filetype to run formatters on filetypes that don't
        -- have other formatters configured.
        -- ["_"] = { "trim_newlines" },
      },
    },
  },

  -- Other
  {
    "Wansmer/treesj",
    event = "LazyFile",
    opts = function(_, opts)
      local overrides = {
        use_default_keymaps = false,
        max_join_length = 240,
      }

      opts = vim.tbl_deep_extend("force", opts, overrides)
      return opts
    end,
  },
  {
    "NMAC427/guess-indent.nvim",
    config = true,
  },
}
