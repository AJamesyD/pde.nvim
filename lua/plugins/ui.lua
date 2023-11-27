local function is_dependency_file(buf_number)
  local file_name = vim.api.nvim_buf_get_name(buf_number)
  local dependency_locations = {
    "site-packages", -- python
    "node_modules",  -- JS/TS
  }
  for location in pairs(dependency_locations) do
    if file_name:match(location) then
      return true
    end
  end
  return false
end

return {
  {
    "rcarriga/nvim-notify",
    opts = {
      stages = "static",
    },
  },
  {
    "echasnovski/mini.indentscope",
    opts = {
      draw = {
        animation = require("mini.indentscope").gen_animation.none(),
      },
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
          local is_dependency_file = is_dependency_file(buf_number)
          local buf_in_cwd = vim.api.nvim_buf_get_name(buf_number):find(vim.fn.getcwd(), 0, true)
          return buf_in_cwd and not is_dependency_file
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
              name = " ",
              separator = {
                style = require("bufferline.groups").separator.pill,
              },
            }),
            {
              name = "Deps",
              auto_close = true, -- whether or not close this group if it doesn't contain the current buffer
              ---@param buf bufferline.Buffer
              matcher = function(buf)
                return is_dependency_file(buf.id)
              end,
            },
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
      { "<leader>snh", "<CMD>Telescope noice<CR>", desc = "Noice History" },
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
  {
    "folke/twilight.nvim",
    cmd = {
      "Twilight",
      "TwilightEnable",
      "TwilightDisable",
    },
    keys = {
      {
        "<leader>uT",
        "<cmd>Twilight<cr>",
        desc = "Toggle Twilight",
      },
    },
    opts = {
      dimming = {
        alpha = 0.5,
      },
      expand = {
        -- Python
        "function_definition",
        "class_definition",
        "while_statement",
        "for_statement",
        "if_statement",
        "with_statement",
        "try_statement",
        "match_statement",

        -- Lua
        "do_statement",
        "while_statement",
        "repeat_statement",
        "if_statement",
        "for_statement",
        "function_declaration",
        "function_definition",
        "table_constructor",

        -- Common
        "function",
        "method",
        "table",
      },
    },
  },
  {
    "carbon-steel/detour.nvim",
    event = "VeryLazy",
    cmd = "Detour",
    keys = {
      {
        "<C-w><CR>",
        "<CMD>Detour<CR>",
        desc = "Detour popup",
      },
    },
  },
}
