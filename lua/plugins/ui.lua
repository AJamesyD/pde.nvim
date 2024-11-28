require("snacks")
  .toggle({
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
  :map("<leader>uz")

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
    "akinsho/bufferline.nvim",
    enabled = vim.g.neovide or false,
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
    opts = function(_, opts)
      local bufferline_groups = require("bufferline.groups")
      local overrides = {
        options = {
          style_preset = require("bufferline").style_preset.no_italic,
          separator_style = "slant",
          show_buffer_close_icons = false,
          show_close_icon = false,
          move_wraps_at_ends = true,
          tab_size = 12,
          groups = {
            options = {
              toggle_hidden_on_enter = true,
            },
            items = {
              bufferline_groups.builtin.pinned:with({
                icon = " ",
                separator = {
                  style = bufferline_groups.separator.pill,
                },
              }),
              bufferline_groups.builtin.ungrouped:with({
                name = " ",
                separator = {
                  style = bufferline_groups.separator.pill,
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
      }

      opts = vim.tbl_deep_extend("force", opts, overrides)
      return opts
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      local overrides = {
        options = {
          globalstatus = true,
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
        },
      }

      opts.sections.lualine_a = {
        {
          "mode",
          ---@param str string
          fmt = function(str)
            if vim.tbl_contains({ "VISUAL", "INSERT", "COMMAND" }, str) then
              return str:sub(1, 3)
            elseif vim.tbl_contains({ "NORMAL", "REPLACE", "CONFIRM", "TERMINAL" }, str) then
              return str:sub(1, 4)
            elseif vim.tbl_contains({ "O-PENDING", "V-REPLACE" }, str) then
              return str:sub(1, 6)
            end

            return str
          end,
        },
      }

      if not vim.g.neovide then
        -- WARN: Scary magic number usage
        local pretty_path_element = table.remove(opts.sections.lualine_c, 4)
        local filetype_icon_element = table.remove(opts.sections.lualine_c, 3)
        local lualine_c_overrides = {
          -- {
          --   -- Insert mid section
          --   function()
          --     return "%="
          --   end,
          -- },
          {
            "buffers",

            max_length = function()
              return vim.o.columns * 1 / 2
            end,

            buffers_color = {
              -- Same values as the general color option can be used here.
              active = "lualine_c_normal", -- Color for active buffer.
              inactive = "lualine_c_inactive", -- Color for inactive buffer.
            },

            symbols = {
              modified = " ●", -- Text to show when the buffer is modified
              alternate_file = " ", -- Text to show to identify the alternate file
              directory = "", -- Text to show when the buffer is a directory
            },
            separator = { right = "" },
          },
        }
        opts.sections.lualine_c = vim.list_extend(opts.sections.lualine_c or {}, lualine_c_overrides)
      end
      local diagnostics_element = table.remove(opts.sections.lualine_c, 2)

      table.remove(opts.sections.lualine_x, 5) -- Remove diff
      table.insert(opts.sections.lualine_x, diagnostics_element)

      opts.sections.lualine_y = {
        {
          "progress",
          cond = function()
            local num_lines = vim.fn.line("$")
            if vim.b[0].is_text_file then
              return num_lines > 100
            else
              return num_lines > 500
            end
          end,
          draw_empty = true,
          padding = { left = 1, right = 1 },
        },
        {
          "location",
          cond = function()
            return vim.o.colorcolumn ~= ""
          end,
          draw_empty = true,
          padding = { left = 1, right = 1 },
        },
      }

      opts.sections.lualine_z = {
        { "grapple" },
      }

      local extensions_overrides = {
        "mason",
        "quickfix",
        "trouble",
      }
      opts.extensions = vim.list_extend(opts.extensions or {}, extensions_overrides)

      opts = vim.tbl_deep_extend("force", opts, overrides)
      return opts
    end,
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
    "echasnovski/mini.indentscope",
    optional = true,
    opts = function(_, opts)
      local indentscope = require("mini.indentscope")
      local overrides = {
        draw = {
          animation = (vim.g.neovide and indentscope.gen_animation.quadratic()) or indentscope.gen_animation.none(),
        },
        options = {
          -- Whether to use cursor column when computing reference indent.
          -- Useful to see incremental scopes with horizontal cursor movements.
          indent_at_cursor = false,
        },
      }

      opts = vim.tbl_deep_extend("force", opts, overrides)
      return opts
    end,
  },
  {
    "tiagovla/scope.nvim",
    config = true,
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
      scope = "window",
      custom_colorcolumn = {
        rust = "100",
        lua = "120",
      },
    },
  },
  {
    "mrjones2014/smart-splits.nvim",
    -- Cannot be loaded just by <C-h/j/k/l> keys
    -- or else tmux will capture first
    event = "VeryLazy",
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
              return MyUtils.min_sidebar_size(30, vim.o.columns, 0.1)
            end,
          },
          right = {
            size = function()
              return MyUtils.min_sidebar_size(30, vim.o.columns, 0.1)
            end,
          },
        },
        animate = {
          enabled = vim.g.neovide or false,
        },
        exit_when_last = true,
        close_when_all_hidden = true,
      }
      opts = vim.tbl_deep_extend("force", opts, overrides)

      for _, config in ipairs(opts.left) do
        -- Reconfigure neo-tree defaults
        if type(config) == "table" and config.ft == "neo-tree" then
          config.pinned = false
        end
      end

      local temp_right = opts.right
      for _, config in ipairs(temp_right) do
        -- Reconfigure grug-far defaults
        if type(config) == "table" and config.ft == "grug-far" then
          config.size.width = function()
            return MyUtils.min_sidebar_size(10, vim.o.columns, 0.25)
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

      opts = vim.tbl_deep_extend("force", opts, overrides)
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
          cursorcolumn = false,
          laststatus = 0,
          number = false,
          relativenumber = false,
          signcolumn = "no",
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
      on_open = function(_)
        vim.b.miniindentscope_disable = true
        require("ibl").setup_buffer(0, { enabled = false })
      end,
      on_close = function()
        vim.b.miniindentscope_disable = false
        require("ibl").setup_buffer(0, { enabled = true })
      end,
    },
  },
  {
    "tzachar/highlight-undo.nvim",
    -- TODO: Remove either when I move to nvim 0.11 or when plugin fixes this
    commit = "c87a6ec1ded241ef223269077cbd5f97a6f0d5bf",
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
    event = "LazyFile",
    dependencies = {
      "kevinhwang91/promise-async",
      {
        "neovim/nvim-lspconfig",
        opts = function(_, opts)
          local keys = require("lazyvim.plugins.lsp.keymaps").get()
          keys[#keys + 1] = {
            "K",
            function()
              local winid = require("ufo").peekFoldedLinesUnderCursor()
              if not winid then
                require("noice.lsp").hover()
              end
            end,
            desc = "Hover",
          }

          local overrides = {
            capabilities = {
              textDocument = {
                foldingRange = {
                  dynamicRegistration = false,
                  lineFoldingOnly = true,
                },
              },
            },
          }

          opts = vim.tbl_deep_extend("force", opts, overrides)
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
        local suffix = (" 󰁂 %d "):format(endLnum - lnum)
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
        table.insert(newVirtText, { suffix, "MoreMsg" })
        return newVirtText
      end

      local overrides = {
        provider_selector = function(_, filetype, buftype)
          local function handleFallbackException(bufnr, err, providerName)
            if type(err) == "string" and err:match("UfoFallbackException") then
              return require("ufo").getFolds(bufnr, providerName)
            else
              return require("promise").reject(err)
            end
          end

          return (filetype == "" or buftype == "nofile") and "indent" -- only use indent until a file is opened
            or function(bufnr)
              return require("ufo")
                .getFolds(bufnr, "lsp")
                :catch(function(err)
                  return handleFallbackException(bufnr, err, "treesitter")
                end)
                :catch(function(err)
                  return handleFallbackException(bufnr, err, "indent")
                end)
            end
        end,
        close_fold_kinds_for_ft = {
          default = { "imports" },
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

      opts = vim.tbl_deep_extend("force", opts, overrides)
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
