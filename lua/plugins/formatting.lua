require("util").map_toggle("<leader>m", {
  name = "Split/Join",
  get = function()
    return true
  end,
  set = function(_)
    require("treesj").toggle()
  end,
}, true)

require("util").map_toggle("<leader>M", {
  name = "Split/Join (Recursive)",
  get = function()
    return true
  end,
  set = function(_)
    require("treesj").toggle({ split = { recursive = true } })
  end,
}, true)

return {
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        -- Use the "*" filetype to run formatters on all filetypes.
        -- TODO: Re-enable once I figure out how to it respect vim.g/b.autoformat
        -- ["*"] = { "trim_whitespace" },
        -- Use the "_" filetype to run formatters on filetypes that don't
        -- have other formatters configured.
        -- TODO: Re-enable once I figure out how to it respect vim.g/b.autoformat
        -- ["_"] = { "trim_newlines" },
      },
    },
  },
  {
    "Wansmer/treesj",
    event = "LazyFile",
    opts = function(_, opts)
      local overrides = {
        use_default_keymaps = false,
        max_join_length = 240,
      }

      opts = vim.tbl_deep_extend("force", overrides, opts)
      return opts
    end,
  },
}
