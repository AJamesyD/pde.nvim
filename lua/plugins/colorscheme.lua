return {
  {
    "catppuccin/nvim",
    main = "catppuccin",
    lazy = false,
    priority = 1000,
    enabled = false,
  },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "night",
    },
  },
  {
    "maxmx03/fluoromachine.nvim",
    lazy = false,
    priority = 1000,
  },
  {
    "Shatur/neovim-ayu",
    lazy = false,
    priority = 1000,
  },
  {
    "EdenEast/nightfox.nvim",
    lazy = false,
    priority = 1000,
  },
  {
    "justinsgithub/oh-my-monokai.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent_background = true,
      ---@param c Colorscheme
      override = function(c)
        return {
          LspInlayHint = { fg = c.specialcomment },
        }
      end,
    },
  },
}
