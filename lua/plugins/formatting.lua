return {
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        -- Use the "*" filetype to run formatters on all filetypes.
        ["*"] = { "trim_whitespace" },
        -- Use the "_" filetype to run formatters on filetypes that don't
        -- have other formatters configured.
        ["_"] = { "trim_whitespace", "trim_newlines" },
      },
    },
  },
  {
    "Wansmer/treesj",
    keys = {
      { "<leader>m", "<CMD>TSJToggle<CR>", desc = "Toggle split/join" },
    },
    opts = {
      use_default_keymaps = false,
      max_join_length = 240,
    },
  },
}
