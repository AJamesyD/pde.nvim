return {
  {
    "catppuccin/nvim",
    main = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = {
      integrations = {
        aerial = true,
        bufferline = true,
        dashboard = true,
        fidget = true,
        flash = true,
        gitsigns = true,
        harpoon = true,
        headlines = true,
        indent_blankline = { enabled = true },
        mason = true,
        mini = { enabled = true },
        neotree = true,
        neogit = true,
        noice = true,
        cmp = true,
        native_lsp = {
          enabled = true,
          inlay_hints = { background = "true" },
        },
        notify = true,
        semantic_tokens = true,
        treesitter_context = true,
        treesitter = true,
        telescope = { enabled = true },
        lsp_trouble = true,
        illuminate = {
          enabled = true,
          lsp = true,
        },
        which_key = true,
      },
    },
  },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "night",
      on_highlights = function(hl, c)
        hl.CursorLineNr = { fg = c.orange, bold = true }
        hl.LineNr = { fg = c.orange, bold = true }
        hl.LineNrAbove = { fg = c.fg_gutter }
        hl.LineNrBelow = { fg = c.fg_gutter }
      end,
    },
  },
  {
    "nyoom-engineering/oxocarbon.nvim",
    lazy = false,
    priority = 1000,
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    priority = 1000,
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
    opts = {
      overrides = {
        WinSeparator = { fg = "#808080" },
        LineNr = { fg = "#808080" },
      },
    },
    config = function(_, opts)
      require("ayu").setup(opts)
    end,
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
