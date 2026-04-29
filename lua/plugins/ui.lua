local util = require("util")

return {
  -- Reconfigure LazyVim defaults
  {
    "akinsho/bufferline.nvim",
    enabled = false,
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

      opts.sections.lualine_b = {
        {
          "branch",
          fmt = function(name)
            return require("util").format_branch(name)
          end,
          cond = function()
            return vim.o.columns >= require("util").WIDTH_BRANCH
          end,
        },
      }

      -- Drop path, filetype icon, root_dir from lualine_c: dropbar handles file identity.
      for i = #opts.sections.lualine_c, 1, -1 do
        local c = opts.sections.lualine_c[i]
        if not (type(c) == "table" and c[1] == "diagnostics") then
          table.remove(opts.sections.lualine_c, i)
        end
      end

      for i = #opts.sections.lualine_x, 1, -1 do
        local c = opts.sections.lualine_x[i]
        if type(c) == "table" and c[1] == "diff" then
          table.remove(opts.sections.lualine_x, i)
        end
      end

      opts.sections.lualine_y = {
        {
          "progress",
          cond = function()
            return vim.o.columns >= require("util").WIDTH_PROGRESS and vim.fn.line("$") > 500
          end,
          draw_empty = true,
          padding = { left = 1, right = 1 },
        },
        {
          "location",
          cond = function()
            return vim.o.columns >= require("util").WIDTH_PROGRESS and vim.o.colorcolumn ~= ""
          end,
          draw_empty = true,
          padding = { left = 1, right = 1 },
        },
      }

      opts.sections.lualine_z = {
        {
          function()
            local grapple = require("grapple")
            local current = grapple.find({ buffer = 0 })
            if not current then
              return ""
            end
            local tags = grapple.tags()
            if not tags then
              return ""
            end
            for i, tag in ipairs(tags) do
              if tag.path == current.path then
                return "󰛢 [" .. (tag.name or i) .. "]"
              end
            end
            return ""
          end,
          cond = function()
            return package.loaded["grapple"] ~= nil
          end,
        },
      }

      local extensions_overrides = {
        "mason",
        "nvim-dap-ui",
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
    },
    opts = {
      lsp = {
        hover = {
          silent = true,
        },
      },
      presets = {
        bottom_search = false,
        lsp_doc_border = true,
      },
    },
  },
  {
    "folke/snacks.nvim",
    ---@type snacks.Config
    opts = {
      dim = {
        ---@type snacks.scope.Config
        ---@diagnostic disable-next-line: missing-fields
        scope = {
          min_size = 5,
          max_size = 30,
          siblings = true,
          treesitter = {
            blocks = {
              enabled = true,
              -- Default
              "function_declaration",
              "function_definition",
              "method_declaration",
              "method_definition",
              "class_declaration",
              "class_definition",
              "do_statement",
              "while_statement",
              "repeat_statement",
              "if_statement",
              "for_statement",

              -- Rust (tree-sitter-rust grammar, circa 2025-01)
              "array_expression",
              "attribute_item",
              "call_expression",
              "const_item",
              "enum_item",
              "for_expression",
              "foreign_mod_item",
              "function_item",
              "if_expression",
              "impl_item",
              "let_declaration",
              "loop_expression",
              "macro_definition",
              "macro_invocation",
              "match_expression",
              "mod_item",
              "struct_item",
              "trait_item",
              "type_item",
              "union_item",
              "use_declaration",
              "while_expression",

              -- Common
              "function",
              "method",
            },
          },
        },
        filter = function(bufnr)
          local filetype = vim.bo[bufnr].filetype
          local exclude_fts = { "markdown" }
          if vim.tbl_contains(exclude_fts, filetype) then
            return false
          end

          return vim.g.snacks_dim ~= false and vim.b[bufnr].snacks_dim ~= false and vim.bo[bufnr].buftype == ""
        end,
      },
    },
  },

  -- Reconfigure LazyVim extras
  {
    "folke/edgy.nvim",
    optional = true,
    dependencies = {
      {
        "folke/lazydev.nvim",
        optional = true,
        opts = function(_, opts)
          opts.library = opts.library or {}
          table.insert(opts.library, { path = "edgy.nvim", words = { "edgy" } })
        end,
      },
    },
    opts = function(_, opts)
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
              return util.min_sidebar_size(30, vim.o.columns, 0.1)
            end,
          },
          right = {
            size = function()
              return util.min_sidebar_size(30, vim.o.columns, 0.1)
            end,
          },
        },
        animate = {
          enabled = vim.g.snacks_animate,
        },
        exit_when_last = true,
        close_when_all_hidden = true,
      }
      opts = vim.tbl_deep_extend("force", opts, overrides)

      -- Move specific items between left/right rather than swapping everything.
      -- This avoids breaking if other plugins add items to opts.left/right after us.
      local function move_items(from, to, predicate)
        local i = 1
        while i <= #from do
          if predicate(from[i]) then
            table.insert(to, table.remove(from, i))
          else
            i = i + 1
          end
        end
      end

      -- crux.nvim file panel
      table.insert(opts.left, {
        title = "CR Files",
        ft = "crux_panel",
        pinned = false,
        size = { width = 35 },
      })

      -- Move neo-tree and terminals from left → right
      for _, config in ipairs(opts.left) do
        if type(config) == "table" and config.ft == "neo-tree" then
          config.pinned = false
        elseif type(config) == "table" and config.ft == "snacks_terminal" then
          config.size.width = function()
            return util.min_sidebar_size(10, vim.o.columns, 0.30)
          end
        end
      end
      move_items(opts.left, opts.right, function(c)
        return type(c) == "table" and (c.ft == "neo-tree" or c.ft == "snacks_terminal" or c.ft == "DiffviewFiles")
      end)

      -- Move grug-far from right → left
      for _, config in ipairs(opts.right) do
        if type(config) == "table" and config.ft == "grug-far" then
          config.size.width = function()
            return util.min_sidebar_size(10, vim.o.columns, 0.25)
          end
        end
      end
      move_items(opts.right, opts.left, function(c)
        return type(c) == "table" and c.ft == "grug-far"
      end)

      return opts
    end,
  },

  -- Other
  -- TODO: auto-detect colorcolumn from active formatter settings (e.g. rustfmt max_width,
  -- prettier printWidth). Would need to read formatter config per buffer.
  {
    "Bekaboo/dropbar.nvim",
    event = "VeryLazy",
    ---@type dropbar_configs_t
    opts = {
      bar = {
        enable = function(buf, win, _)
          local bt = vim.bo[buf].buftype
          local ft = vim.bo[buf].filetype
          if bt ~= "" and bt ~= "terminal" then
            return false
          end
          if vim.tbl_contains(require("util").SPECIAL_FILETYPES, ft) then
            return false
          end
          if vim.api.nvim_win_get_config(win).relative ~= "" then
            return false
          end
          return true
        end,
        truncate = true,
      },
      icons = {
        ui = {
          bar = {
            separator = " › ",
          },
        },
      },
      sources = {
        lsp = { max_depth = 3 },
        treesitter = { max_depth = 3 },
        path = {
          modified = function(sym)
            return sym:merge({
              name = sym.name .. " [+]",
              name_hl = "DiffAdded",
            })
          end,
        },
      },
    },
    keys = {
      {
        "<leader>cb",
        function()
          require("dropbar.api").pick()
        end,
        desc = "Breadcrumb pick",
      },
    },
  },
  {
    "mrjones2014/smart-splits.nvim",
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
      -- Swapping buffers between windows (moved from <leader>w* which was deleted)
      {
        "<C-w>H",
        function()
          require("smart-splits").swap_buf_left()
        end,
        desc = "Swap left",
      },
      {
        "<C-w>J",
        function()
          require("smart-splits").swap_buf_down()
        end,
        desc = "Swap down",
      },
      {
        "<C-w>K",
        function()
          require("smart-splits").swap_buf_up()
        end,
        desc = "Swap up",
      },
      {
        "<C-w>L",
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
  -- TODO: re-enable nvim-ufo
  {
    "kevinhwang91/nvim-ufo",
    enabled = false,
    dependencies = { "kevinhwang91/promise-async" },
  },
  {
    "nvim-zh/colorful-winsep.nvim",
    event = { "WinLeave" },
    opts = {
      animate = {
        enabled = vim.g.snacks_animate,
      },
      -- highlight for Window separator
      hi = {
        bg = "#16161E",
        fg = "#1F3442",
      },
      -- This plugin will not be activated for filetype in the following table.
      no_exec_files = vim.deepcopy(util.SPECIAL_FILETYPES),
      -- Symbols for separator lines, the order: horizontal, vertical, top left, top right, bottom left, bottom right.
      symbols = { "━", "┃", "┏", "┓", "┗", "┛" },
      -- #70: https://github.com/nvim-zh/colorful-winsep.nvim/discussions/70
      only_line_seq = true,
      -- Smooth moving switch
      smooth = true,
      exponential_smoothing = true,
      anchor = {
        left = { height = 1, x = -1, y = -1 },
        right = { height = 1, x = -1, y = 0 },
        up = { width = 0, x = -1, y = 0 },
        bottom = { width = 0, x = 1, y = 0 },
      },
    },
  },
}
