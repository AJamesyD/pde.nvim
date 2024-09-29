return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
    priority = 1000,
    opts = {
      highlight_overrides = {
        all = function(colors)
          return {
            CurSearch = { bg = colors.sky },
            IncSearch = { bg = colors.sky },
            CursorLineNr = { fg = colors.blue, style = { "bold" } },
            DashboardFooter = { fg = colors.overlay0 },
            TreesitterContextBottom = { style = {} },
            WinSeparator = { fg = colors.overlay1, style = { "bold" } },
            ["@markup.italic"] = { fg = colors.blue, style = { "italic" } },
            ["@markup.strong"] = { fg = colors.blue, style = { "bold" } },
            Headline = { style = { "bold" } },
            Headline1 = { fg = colors.blue, style = { "bold" } },
            Headline2 = { fg = colors.pink, style = { "bold" } },
            Headline3 = { fg = colors.lavender, style = { "bold" } },
            Headline4 = { fg = colors.green, style = { "bold" } },
            Headline5 = { fg = colors.peach, style = { "bold" } },
            Headline6 = { fg = colors.flamingo, style = { "bold" } },
            LineNr = { link = "WinSeparator" },
            rainbow1 = { fg = colors.blue, style = { "bold" } },
            rainbow2 = { fg = colors.pink, style = { "bold" } },
            rainbow3 = { fg = colors.lavender, style = { "bold" } },
            rainbow4 = { fg = colors.green, style = { "bold" } },
            rainbow5 = { fg = colors.peach, style = { "bold" } },
            rainbow6 = { fg = colors.flamingo, style = { "bold" } },
          }
        end,
      },
      color_overrides = {
        macchiato = {
          rosewater = "#F5B8AB",
          flamingo = "#F29D9D",
          pink = "#AD6FF7",
          mauve = "#FF8F40",
          red = "#E66767",
          maroon = "#EB788B",
          peach = "#FAB770",
          yellow = "#FACA64",
          green = "#70CF67",
          teal = "#4CD4BD",
          sky = "#61BDFF",
          sapphire = "#4BA8FA",
          blue = "#00BFFF",
          lavender = "#00BBCC",
          text = "#C1C9E6",
          subtext1 = "#A3AAC2",
          subtext0 = "#8E94AB",
          overlay2 = "#7D8296",
          overlay1 = "#676B80",
          overlay0 = "#464957",
          surface2 = "#3A3D4A",
          surface1 = "#2F313D",
          surface0 = "#1D1E29",
          base = "#0b0b12",
          mantle = "#11111a",
          crust = "#191926",
        },
      },
    },
  },
  {
    "folke/tokyonight.nvim",
    lazy = true,
    priority = 1000,
    opts = {
      style = "night",
      dim_inactive = true,
      ---@param c ColorScheme
      on_colors = function(c)
        local Util = require("tokyonight.util")
        c.bg = "#0d0d11"
        c.bg_dark = "#000000"
        ------
        Util.bg = c.bg

        c.diff = {
          add = Util.blend_bg(c.green2, 0.15),
          delete = Util.blend_bg(c.red1, 0.15),
          change = Util.blend_bg(c.blue7, 0.15),
        }

        c.black = Util.blend_bg(c.bg, 0.8, "#000000")
        c.border_highlight = Util.blend_bg(c.blue1, 0.8)
        c.border = c.black

        -- Popups and statusline always get a dark background
        c.bg_popup = c.bg_dark
        c.bg_statusline = c.bg_dark

        -- Sidebar and Floats are configurable
        c.bg_sidebar = c.bg_dark
        c.bg_float = c.bg_dark

        c.bg_visual = Util.blend_bg(c.blue0, 0.4)
        ------

        c.border = c.comment
      end,
      ---@param hl tokyonight.Highlights
      ---@param c ColorScheme
      on_highlights = function(hl, c)
        hl.CursorLineNr = { fg = c.orange, bold = true }
        hl.LineNr = { fg = c.orange, bold = true }
        hl.LineNrAbove = { fg = c.fg }
        hl.LineNrBelow = { fg = c.fg }
      end,
    },
    config = true,
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = true,
    priority = 1000,
  },
  {
    "Shatur/neovim-ayu",
    lazy = true,
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
    lazy = true,
    priority = 1000,
  },
  {
    "marko-cerovac/material.nvim",
    lazy = true,
    priority = 1000,
    opts = {},
  },
}
