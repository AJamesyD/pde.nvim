-- Ignore builtin colorschemes
vim.opt.wildignore:append(vim.env.VIMRUNTIME .. "/colors/*")

return {
  -- Reconfigure LazyVim defaults
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,

    ---@param opts tokyonight.Config
    opts = function(_, opts)
      ---@type tokyonight.Config
      local overrides = {
        style = "night",
        dim_inactive = true,
        ---@param colors ColorScheme
        on_colors = function(colors)
          local Util = require("tokyonight.util")
          colors.bg = colors.bg_dark
          colors.bg_dark = Util.blend(colors.bg, 0.8, "#000000")
          colors.fg = "#FFFFFF"
          colors.fg_dark = Util.blend(colors.fg, 0.5, "#000000")
          colors.fg_gutter = Util.blend(colors.fg_dark, 0.5, "#000000")

          -----------
          -- Rerun parts of default setup that rely on changed colors
          -- https://github.com/folke/tokyonight.nvim/blob/b262293ef481b0d1f7a14c708ea7ca649672e200/lua/tokyonight/colors/init.lua
          Util.bg = colors.bg
          Util.fg = colors.fg

          colors.none = "NONE"

          colors.diff = {
            add = Util.blend_bg(colors.green2, 0.15),
            delete = Util.blend_bg(colors.red1, 0.15),
            change = Util.blend_bg(colors.blue7, 0.15),
            text = colors.blue7,
          }

          colors.git.ignore = colors.dark3
          colors.black = Util.blend_bg(colors.bg, 0.8, "#000000")
          colors.border_highlight = Util.blend_bg(colors.blue1, 0.8)
          colors.border = colors.black

          -- Popups and statusline always get a dark background
          colors.bg_popup = colors.bg_dark
          colors.bg_statusline = colors.bg_dark

          -- Sidebar and Floats are configurable
          colors.bg_sidebar = colors.bg_dark
          colors.bg_float = colors.bg_dark

          colors.bg_visual = Util.blend_bg(colors.blue0, 0.4)
          colors.bg_search = colors.blue0
          colors.fg_sidebar = colors.fg_dark
          colors.fg_float = colors.fg

          colors.error = colors.red1
          colors.todo = colors.blue
          colors.warning = colors.yellow
          colors.info = colors.blue2
          colors.hint = colors.teal

          colors.rainbow = {
            colors.blue,
            colors.yellow,
            colors.green,
            colors.teal,
            colors.magenta,
            colors.purple,
            colors.orange,
            colors.red,
          }

          -- stylua: ignore
          --- @class TerminalColors
          colors.terminal = {
            black          = colors.black,
            black_bright   = colors.terminal_black,
            red            = colors.red,
            red_bright     = Util.brighten(colors.red),
            green          = colors.green,
            green_bright   = Util.brighten(colors.green),
            yellow         = colors.yellow,
            yellow_bright  = Util.brighten(colors.yellow),
            blue           = colors.blue,
            blue_bright    = Util.brighten(colors.blue),
            magenta        = colors.magenta,
            magenta_bright = Util.brighten(colors.magenta),
            cyan           = colors.cyan,
            cyan_bright    = Util.brighten(colors.cyan),
            white          = colors.fg_dark,
            white_bright   = colors.fg,
          }
          -----------

          colors.border = Util.blend_fg(colors.border, 0.5)
        end,
        ---@param hl tokyonight.Highlights
        ---@param c ColorScheme
        on_highlights = function(hl, c)
          hl.CursorLineNr = { fg = c.orange, bold = true }
          hl.LineNr = { fg = c.orange, bold = true }
          hl.LineNrAbove = { fg = c.fg }
          hl.LineNrBelow = { fg = c.fg }
        end,
      }

      opts = vim.tbl_deep_extend("force", opts, overrides)
      return opts
    end,
  },
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
      integrations = {
        ufo = true,
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

  -- Other
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
    opts = {
      contrast = {
        terminal = true, -- Enable contrast for the built-in terminal
        sidebars = true, -- Enable contrast for sidebar-like windows ( for example Nvim-Tree )
        floating_windows = true, -- Enable contrast for floating windows
        cursor_line = true, -- Enable darker background for the cursor line
        non_current_windows = true, -- Enable contrasted background for non-current windows
      },

      disable = {
        colored_cursor = true, -- Disable the colored cursor
      },

      high_visibility = {
        lighter = false, -- Enable higher contrast text for lighter style
        darker = true, -- Enable higher contrast text for darker style
      },

      async_loading = true, -- Load parts of the theme asynchronously for faster startup (turned on by default)

      custom_colors = nil, -- If you want to override the default colors, set this to a function

      custom_highlights = {}, -- Overwrite highlights with your own
    },
  },
  {
    "eldritch-theme/eldritch.nvim",
    lazy = true,
    priority = 1000,
    opts = {
      dim_inactive = true,
    },
  },
  {
    "olivercederborg/poimandres.nvim",
    lazy = true,
    priority = 1000,
    opts = {
      bold_vert_split = true,
    },
  },
}
