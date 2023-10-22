return {
  {
    "stevearc/conform.nvim",
    ---@type ConformOpts
    opts = {
      formatters_by_ft = {
        python = { "black" },
      },
    },
  },
  {
    "Wansmer/treesj",
    keys = {
      { "<leader>m", "<CMD>TSJToggle<CR>", desc = "Toggle split/join" },
    },
    opts = { use_default_keymaps = false },
  },
}
