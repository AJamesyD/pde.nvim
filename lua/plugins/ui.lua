require("util").map_toggle("<leader>uz", {
  name = "ZenMode",
  get = function()
    return require("zen-mode.view").is_open()
  end,
  set = function(state)
    if state then
      require("zen-mode").open()
    else
      require("zen-mode").close()
    end
  end,
})

require("util").map_toggle("<leader>uT", {
  name = "Twilight",
  get = function()
    return require("twilight.view").enabled
  end,
  set = function(state)
    if state then
      require("twilight").enable()
    else
      require("twilight").disable()
    end
  end,
})

return {
  {
    "rcarriga/nvim-notify",
    opts = function(_, opts)
      if not vim.g.neovide then
        opts.stages = "static"
      end
      return opts
    end,
  },
  {
    "echasnovski/mini.indentscope",
    optional = true,
    opts = function(_, opts)
      local indentscope = require("mini.indentscope")
      local overrides = {
        draw = {
          animation = indentscope.gen_animation.none(),
        },
        options = {
          -- Whether to use cursor column when computing reference indent.
          -- Useful to see incremental scopes with horizontal cursor movements.
          indent_at_cursor = false,
        },
      }

      if vim.g.neovide then
        overrides.draw.animation = indentscope.gen_animation.exponential()
      end

      opts = vim.tbl_deep_extend("force", overrides, opts)
      return opts
    end,
  },
  {
    "akinsho/bufferline.nvim",
    dependencies = {
      "tiagovla/scope.nvim",
      config = true,
    },
    keys = {
      { "<leader>bP", false },
      { "<leader>br", false },
      { "<leader>bl", false },
      { "[B", false },
      { "]B", false },
      { "<B", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer prev" },
      { ">B", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer next" },
      { "<leader>bl", false },
      { "<leader>bb", "<CMD>BufferLinePick<CR>", desc = "Pick buffer open" },
      { "<leader>bc", "<CMD>BufferLinePickClose<CR>", desc = "Pick buffer close" },
    },
    opts = {
      options = {
        style_preset = require("bufferline").style_preset.no_italic,
        separator_style = "slant",
        show_buffer_close_icons = false,
        show_close_icon = false,
        move_wraps_at_ends = true,
        always_show_bufferline = false,
        auto_toggle_bufferline = false,
        tab_size = 12,
        groups = {
          options = {
            toggle_hidden_on_enter = true,
          },
          items = {
            require("bufferline.groups").builtin.pinned:with({
              icon = " ",
              separator = {
                style = require("bufferline.groups").separator.pill,
              },
            }),
            require("bufferline.groups").builtin.ungrouped:with({
              name = " ",
              separator = {
                style = require("bufferline.groups").separator.pill,
              },
            }),
            {
              name = " test",
              ---@param buf bufferline.Buffer
              matcher = function(buf)
                local is_test_file = vim.b[buf.id].is_test_file
                return type(is_test_file) ~= "nil" and is_test_file
              end,
            },
            {
              name = " docs",
              ---@param buf bufferline.Buffer
              matcher = function(buf)
                local is_text_file = vim.b[buf.id].is_text_file
                return type(is_text_file) ~= "nil" and is_text_file
              end,
            },
            {
              name = " misc",
              ---@type vim.api.keyset.highlight
              highlight = { underline = true },
              ---@param buf bufferline.Buffer
              matcher = function(buf)
                local is_relevant_file = vim.b[buf.id].is_relevant_file
                return type(is_relevant_file) ~= "nil" and not is_relevant_file
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
        globalstatus = true,
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
    },
    opts = {
      presets = {
        bottom_search = false,
        lsp_doc_border = true,
      },
    },
  },
  {
    "m4xshen/smartcolumn.nvim",
    event = "LazyFile",
    opts = {
      colorcolumn = "120",
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
        -- lua = "120",
      },
    },
  },
  {
    "mrjones2014/smart-splits.nvim",
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
    opts = function(_, opts)
      ---@param min_size integer
      ---@param max_size integer
      ---@param fraction_of_max number
      local function min_sidebar_size(min_size, max_size, fraction_of_max)
        return math.max(math.floor(max_size * fraction_of_max), min_size)
      end
      ---@type Edgy.Config
      local overrides = {
        keys = {
          ["<c-Right>"] = false,
          ["<c-Left>"] = false,
          ["<c-Up>"] = false,
          ["<c-Down>"] = false,
          -- increase width
          ["<A-l>"] = function(win)
            win:resize("width", 2)
          end,
          -- decrease width
          ["<A-h>"] = function(win)
            win:resize("width", -2)
          end,
          -- increase height
          ["<A-k>"] = function(win)
            win:resize("height", 2)
          end,
          -- decrease height
          ["<A-j>"] = function(win)
            win:resize("height", -2)
          end,
        },
        options = {
          left = {
            size = function()
              return min_sidebar_size(30, vim.o.columns, 0.1)
            end,
          },
          right = {
            size = function()
              return min_sidebar_size(30, vim.o.columns, 0.1)
            end,
          },
        },
        animate = {
          enabled = vim.g.neovide or false,
        },
        exit_when_last = true,
        close_when_all_hidden = true,
      }
      opts = vim.tbl_deep_extend("force", overrides, opts)

      local temp_right = opts.right
      for _, config in ipairs(temp_right) do
        if type(config) == "table" and config.ft == "grug-far" then
          config.size.width = function()
            return min_sidebar_size(10, vim.o.columns, 0.25)
          end
        end
      end

      opts.right = opts.left
      opts.left = temp_right
      return opts
    end,
  },
  {
    "stevearc/stickybuf.nvim",
    event = "LazyFile",
    cmd = { "PinBuffer", "PinBuftype", "PinFiletype" },
    opts = {},
  },
  {
    "eandrju/cellular-automaton.nvim",
    cmd = "CellularAutomaton",
    keys = {
      { "<leader>FML", "<CMD>CellularAutomaton make_it_rain<CR>", desc = "FML" },
    },
  },
  {
    "folke/twilight.nvim",
    cmd = {
      "Twilight",
      "TwilightEnable",
      "TwilightDisable",
    },
    opts = function(_, opts)
      local overrides = {
        dimming = {
          alpha = 0.5,
          inactive = true,
        },
        context = 15,
        exclude = {
          "markdown",
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
          "import_from_statement",
          "parenthesized_expression",
          "generator_expression",
          "list_comprehension",
          "set_comprehension",
          "dictionary_comprehension",
          "tuple",
          "list",
          "set",
          "dictionary",
          "string",

          -- Lua
          "do_statement",
          "while_statement",
          "repeat_statement",
          "if_statement",
          "for_statement",
          "function_declaration",
          "function_definition",
          "table_constructor",

          -- Rust
          "mod_item",
          "foreign_mod_item",
          "function_item",
          "struct_item",
          "trait_item",
          "enum_item",
          "impl_item",
          "type_item",
          "union_item",
          "const_item",
          "use_declaration",
          "let_declaration",
          "loop_expression",
          "for_expression",
          "while_expression",
          "if_expression",
          "match_expression",
          "call_expression",
          "array_expression",
          "macro_definition",
          "macro_invocation",
          "attribute_item",

          -- Common
          "function",
          "method",
          "table",
          "if_statement",
        },
      }

      opts = vim.tbl_deep_extend("force", overrides, opts)
      return opts
    end,
  },
  {
    "folke/zen-mode.nvim",
    cmd = { "ZenMode" },
    opts = {
      window = {
        width = 0.85,
        options = {
          signcolumn = "no",
          number = false,
          relativenumber = false,
          cursorcolumn = false,
        },
      },
      plugins = {
        -- disables git signs
        gitsigns = { enabled = true },
        -- disables the tmux statusline
        tmux = { enabled = true },
        -- this will change the font size on kitty when in zen mode
        -- to make this work, you need to set the following kitty options:
        -- - allow_remote_control socket-only
        -- - listen_on unix:/tmp/kitty
        kitty = {
          enabled = true,
          font = "+4", -- font size increment
        },
        -- this will change the font size on alacritty when in zen mode
        -- requires  Alacritty Version 0.10.0 or higher
        -- uses `alacritty msg` subcommand to change font size
        alacritty = {
          enabled = true,
          font = "18", -- font size
        },
        -- this will change the scale factor in Neovide when in zen mode
        -- See alse also the Plugins/Wezterm section in this projects README
        neovide = {
          enabled = true,
          -- Will multiply the current scale factor by this number
          scale = 1.2,
          -- disable the Neovide animations while in Zen mode
          disable_animations = {
            neovide_animation_length = 0,
            neovide_cursor_animate_command_line = false,
            neovide_scroll_animation_length = 0,
            neovide_position_animation_length = 0,
            neovide_cursor_animation_length = 0,
            neovide_cursor_vfx_mode = "",
          },
        },
      },
    },
  },
  {
    "tzachar/highlight-undo.nvim",
    keys = {
      {
        "u",
        desc = "which_key_ignore",
      },
      {
        "<C-r>",
        desc = "which_key_ignore",
      },
    },
    opts = {},
  },
  {
    "kevinhwang91/nvim-ufo",
    dependencies = {
      "kevinhwang91/promise-async",
      {
        "luukvbaal/statuscol.nvim",
        -- TODO: experiment with this
        enabled = false,
        opts = function(_, opts)
          local builtin = require("statuscol.builtin")
          local overrides = {
            relculright = true,
            segments = {
              { text = { "%s" }, click = "v:lua.ScSa" },
              { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
              { text = { builtin.foldfunc }, click = "v:lua.ScFa" },
            },
          }

          opts = vim.tbl_deep_extend("force", overrides, opts)
          return opts
        end,
        config = true,
      },
      {
        "neovim/nvim-lspconfig",
        opts = function(_, opts)
          local keys = require("lazyvim.plugins.lsp.keymaps").get()
          keys[#keys + 1] = {
            "K",
            function()
              local ok, ufo = pcall(require, "ufo")
              local winid = ok and ufo.peekFoldedLinesUnderCursor()
              if not winid then
                require("noice.lsp").hover()
              end
            end,
            desc = "Hover",
          }
          return opts
        end,
      },
    },
    keys = {
      {
        "zR",
        function()
          require("ufo").openAllFolds()
        end,
      },
      {
        "zM",
        function()
          require("ufo").closeAllFolds()
        end,
      },
      {
        "zr",
        function()
          require("ufo").openFoldsExceptKinds()
        end,
      },
    },
    opts = function(_, opts)
      local handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local foldedLines = endLnum - lnum
        local suffix = ("  %d"):format(foldedLines)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0
        for _, chunk in ipairs(virtText) do
          local chunkText = chunk[1]
          local chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
          else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            -- str width returned from truncate() may less than 2nd argument, need padding
            if curWidth + chunkWidth < targetWidth then
              suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
            end
            break
          end
          curWidth = curWidth + chunkWidth
        end
        local rAlignAppndx = math.max(math.min(vim.opt.textwidth["_value"], width - 1) - curWidth - sufWidth, 0)
        suffix = (" "):rep(rAlignAppndx) .. suffix
        table.insert(newVirtText, { suffix, "MoreMsg" })
        return newVirtText
      end
      local overrides = {
        -- INFO: Uncomment to use treeitter as fold provider, otherwise nvim lsp is used
        -- provider_selector = function(bufnr, filetype, buftype)
        --   return { "treesitter", "indent" }
        -- end,
        close_fold_kinds_for_ft = {
          default = {},
        },
        fold_virt_text_handler = handler,
        preview = {
          mappings = {
            scrollU = "<C-u>",
            scrollD = "<C-d>",
            jumpTop = "[",
            jumpBot = "]",
          },
        },
      }

      opts = vim.tbl_deep_extend("force", overrides, opts)
      return opts
    end,
    init = function()
      -- Required
      vim.opt.foldenable = true
      vim.opt.foldcolumn = "auto:1" -- '0' is not bad
      vim.opt.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
      vim.opt.foldlevelstart = 99

      -- Optional
      vim.opt.foldminlines = 20
    end,
    config = function(_, opts)
      require("ufo").setup(opts)
    end,
  },
}
