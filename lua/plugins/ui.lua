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
      { "<leader>bb", "<CMD>BufferLinePick<CR>", desc = "Pick buffer" },
      { "<leader>be", "<CMD>Telescope buffer<CR>", desc = "Buffers (Telescope)" },
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
              name = "Ungrouped",
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
    "folke/noice.nvim",
    opts = {
      presets = {
        bottom_search = false,
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
}
