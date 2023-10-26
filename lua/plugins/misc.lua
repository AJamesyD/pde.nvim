return {
  {
    "kawre/leetcode.nvim",
    lazy = true,
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
      lang = "python3",
    },
  },
}
