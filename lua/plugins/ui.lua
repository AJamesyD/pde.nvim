return {
  -- {
  --   "nvimdev/dashboard-nvim",
  --   enabled = false,
  -- },
  {
    "rcarriga/nvim-notify",
    opts = {
      timeout = 2000,
      stages = "fade_in_slide_out",
    },
  },
  {
    "akinsho/bufferline.nvim",
    dependencies = { "tiagovla/scope.nvim" }, -- TODO: configure scope w/ resession.
    keys = {
      { "<leader>br", false },
      { "<leader>bl", false },
      { "<leader>bb", "<CMD>BufferLinePick<CR>",      desc = "Pick buffer open" },
      { "<leader>bc", "<CMD>BufferLinePickClose<CR>", desc = "Pick buffer close" },
    },
    opts = {
      options = {
        style_preset = require("bufferline").style_preset.no_italic,
        themable = true,
        separator_style = "slant",
        show_buffer_close_icons = false,
        custom_filter = function(buf_number)
          local buf_in_cwd = vim.api.nvim_buf_get_name(buf_number):find(vim.fn.getcwd(), 0, true)
          return buf_in_cwd
        end,
        groups = {
          options = {
            toggle_hidden_on_enter = true,
          },
          items = {
            require("bufferline.groups").builtin.pinned:with({
              name = "Pinned",
              icon = " ",
              separator = {
                style = require("bufferline.groups").separator.pill,
              },
            }),
            {
              name = "Docs",
              auto_close = false, -- whether or not close this group if it doesn't contain the current buffer
              ---@param buf bufferline.Buffer
              matcher = function(buf)
                local filename = vim.api.nvim_buf_get_name(buf.id)
                return filename:lower():match("%.md") or filename:lower():match("%.txt")
              end,
            },
            require("bufferline.groups").builtin.ungrouped:with({
              name = " ",
              separator = {
                style = require("bufferline.groups").separator.pill,
              },
            }),
          },
        },
      },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
      },
    },
  },
  {
    "folke/noice.nvim",
    keys = {
      { "<leader>snl", false },
      { "<leader>snh", "<CMD>Telescope noice<CR>", desc = "Noice History" },
      { "<leader>sna", false },
    },
    opts = {
      presets = {
        bottom_search = false,
        lsp_doc_border = true,
      },
    },
  },
  {
    "iamcco/markdown-preview.nvim", -- TODO: Does this belong in ui?
    build = "cd app && npm install",
    ft = "markdown",
  },
  {
    "m4xshen/smartcolumn.nvim",
    event = "LazyFile",
    opts = {
      colorcolumn = "100",
      disabled_filetypes = {
        "help",
        "text",
        "markdown",
        "TelescopePrompt",
        "TelescopeResults",
        "alpha",
        "dashboard",
        "neo-tree",
        "Trouble",
        "lazy",
        "mason",
        "notify",
        "toggleterm",
        "lazyterm",
      },
      custom_colorcolumn = {
        lua = "120",
        python = "120",
      },
    },
  },
  {
    "mrjones2014/smart-splits.nvim",
    lazy = false,
    keys = {
      -- resizing splits
      {
        "<A-h>",
        function()
          require("smart-splits").resize_left()
        end,
        desc = "Resize left",
      },
      {
        "<A-j>",
        function()
          require("smart-splits").resize_down()
        end,
        desc = "Resize down",
      },
      {
        "<A-k>",
        function()
          require("smart-splits").resize_up()
        end,
        desc = "Resize up",
      },
      {
        "<A-l>",
        function()
          require("smart-splits").resize_right()
        end,
        desc = "Resize right",
      },
      -- moving between splits
      {
        "<C-h>",
        function()
          require("smart-splits").move_cursor_left()
        end,
        desc = "Move cursor left",
      },
      {
        "<C-j>",
        function()
          require("smart-splits").move_cursor_down()
        end,
        desc = "Move cursor down",
      },
      {
        "<C-k>",
        function()
          require("smart-splits").move_cursor_up()
        end,
        desc = "Move cursor up",
      },
      {
        "<C-l>",
        function()
          require("smart-splits").move_cursor_right()
        end,
        desc = "Move cursor right",
      },
      -- Swapping buffers between windows
      {
        "<leader>wh",
        function()
          require("smart-splits").swap_buf_left()
        end,
        desc = "Swap left",
      },
      {
        "<leader>wj",
        function()
          require("smart-splits").swap_buf_down()
        end,
        desc = "Swap down",
      },
      {
        "<leader>wk",
        function()
          require("smart-splits").swap_buf_up()
        end,
        desc = "Swap up",
      },
      {
        "<leader>wl",
        function()
          require("smart-splits").swap_buf_right()
        end,
        desc = "Swap right",
      },
    },
    opts = {
      default_amount = 5,
    },
  },
  {
    "folke/edgy.nvim",
    optional = true,
    opts = {
      animate = {
        enabled = false,
      },
      exit_when_last = true,
      close_when_all_hidden = true,
    },
  },
  {
    "stevearc/stickybuf.nvim",
    event = "LazyFile",
    cmd = { "PinBuffer", "PinBuftype", "PinFiletype" },
    opts = {},
  },
  {
    "eandrju/cellular-automaton.nvim",
    keys = {
      { "<leader>fml", "<CMD>CellularAutomaton make_it_rain<CR>", desc = "FML" },
    },
  },
}
