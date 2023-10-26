local leet_arg = "leetcode.nvim"

return {
  {
    "kawre/leetcode.nvim",
    lazy = leet_arg ~= vim.fn.argv()[1],
    build = ":TSUpdate html",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim", -- required by telescope
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
      "nvim-tree/nvim-web-devicons",
    },
    ---@type LeetCodeOpts
    opts = {
      arg = leet_arg,
      lang = "python3",
    },
  },
}
