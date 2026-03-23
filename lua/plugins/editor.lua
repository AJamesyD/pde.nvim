---@param item snacks.picker.finder.Item
---@param filter snacks.picker.Filter
---@return boolean
local function snacks_file_filter(item, filter)
  -- Hide dotfiles except those in allowed_dotfiles
  local allowed_dotfiles = {
    ".cargo",
    ".config",
    ".claude",
    ".kiro",
  }
  for part in (item.file or ""):gmatch("[^/]+") do
    if part:sub(1, 1) == "." and not vim.tbl_contains(allowed_dotfiles, part) then
      return false
    end
  end
  return true
end

return {
  -- Reconfigure LazyVim defaults
  {
    "nvim-neo-tree/neo-tree.nvim",
    dependencies = {
      {
        "antosha417/nvim-lsp-file-operations",
        priority = 1000,
      },
    },
    keys = {
      { "<leader>ge", false },
      { "<leader>be", false },
    },
    opts = {
      auto_clean_after_session_restore = true,
      close_if_last_window = true,
      enable_git_status = false,
      enable_cursor_hijack = true,
      sources = {
        "filesystem",
        "buffers",
      },
      buffers = {
        bind_to_cwd = false, -- Keep same as filesystem.bind_to_cwd
        group_empty_dirs = true,
        show_unloaded = false,
        terminals_first = true,
      },
      filesystem = {
        scan_mode = "deep",
        filtered_items = {
          force_visible_in_empty_folder = true,
          always_show = {
            ".cargo",
            ".config",
            ".gitignore",
            ".rustfmt.toml",
          },
          always_show_by_pattern = {
            ".*rc",
            ".bash*",
            ".env*",
            ".zsh*",
          },
        },
        hijack_netrw_behavior = "open_current",
      },
      default_component_configs = {
        name = {
          highlight_opened_files = true,
        },
        symlink_targets = {
          enabled = true,
        },
      },
      window = {
        width = 40,
      },
    },
  },
  {
    "folke/flash.nvim",
    enabled = false,
    opts = {
      search = {
        multi_window = false,
      },
      modes = {
        char = {
          jump_labels = true,
          multi_line = false,
        },
      },
    },
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        false,
      },
      {
        "<C-space>",
        mode = { "n", "x", "o" },
        false,
      },
      {
        "S",
        mode = { "n", "x", "o" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter",
      },
      {
        "r",
        mode = "o",
        function()
          require("flash").remote()
        end,
        desc = "Remote Flash",
      },
      {
        "R",
        mode = { "o", "x" },
        function()
          require("flash").treesitter_search()
        end,
        desc = "Treesitter Search",
      },
    },
  },
  -- Disable persistence.nvim session keybindings (shpool handles persistence)
  {
    "folke/persistence.nvim",
    keys = function()
      return {}
    end,
  },
  {
    "folke/which-key.nvim",
    ---@param opts wk.Opts
    opts = function(_, opts)
      local overrides = {
        preset = "modern",
      }

      local spec_overrides = {
        { "<leader>F", hidden = true },
        { "<leader>gw", group = "worktrees" },
        { "<leader>a", group = "AI" },
        { "s", group = "surround" },
      }
      opts.spec = vim.list_extend(opts.spec or {}, spec_overrides)

      local triggers_overrides = {
        { "<auto>", mode = "nixsotc" },
        -- For mini.surround
        { "s", mode = { "n", "v" } },
      }
      opts.triggers = vim.list_extend(opts.triggers or {}, triggers_overrides)

      opts = vim.tbl_deep_extend("force", opts, overrides)
      return opts
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    keys = {
      { "<leader>ghw", "<cmd>Gitsigns toggle_word_diff<cr>", desc = "Toggle Word Diff" },
    },
    opts = {
      diff_opts = {
        algorithm = "histogram",
        ignore_whitespace_change = true,
        linematch = 60,
      },
      current_line_blame_opts = {
        virt_text_pos = "right_align",
        delay = 500,
      },
    },
  },

  -- Reconfigure LazyVim extras
  {
    "folke/snacks.nvim",
    -- stylua: ignore
    keys = {
      { "<leader>/", false },
      { "<leader>:", false },
      { "<leader><space>", function() Snacks.picker.smart() end, desc = "Smart Find" },
      -- find
      { "<leader>fc", false },
      { "<leader>fr", LazyVim.pick("oldfiles"), desc = "Recent (Root Dir)" },
      { "<leader>fR", function() Snacks.picker.recent({ filter = { cwd = true }}) end, desc = "Recent (cwd)" },
      -- git
      { "<leader>gc", false },
      -- search
      { '<leader>s"', false },
      { "<leader>sa", false },
      { "<leader>sc", false },
      { "<leader>sC", false },
      { "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
      { "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, desc = "Buffer Diagnostics" },
      { "<leader>sH", false },
      { "<leader>sm", false },
      { "<leader>sM", false },
      { "<leader>so", false },
      { "<leader>ss", false },
      { "<leader>sS", false },
      { "z=", function() Snacks.picker.spelling() end, desc = "Spelling Suggestions" },
      { "<leader>su", function() Snacks.picker.undo() end, desc = "Undo History" },
    },
    ---@type snacks.Config
    opts = {
      gitbrowse = {
        what = "permalink",
      },
      picker = {
        sources = {
          files = {
            hidden = true,
            filter = { filter = snacks_file_filter },
          },
          grep = {
            hidden = true,
            filter = { filter = snacks_file_filter },
          },
        },
        layout = {
          layout = {
            width = 0.9,
            height = 0.9,
          },
        },
        layouts = {
          select = {
            layout = {
              relative = "cursor",
              min_width = 80,
              max_width = 120,
            },
          },
        },
      },
    },
  },
  {
    "Juksuu/worktrees.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "folke/snacks.nvim",
    },
    keys = {
      { "<leader>gwc", function() require("worktrees").new_worktree() end, desc = "New Worktree" },
      { "<leader>gws", function() Snacks.picker.worktrees() end, desc = "List Worktrees" },
      { "<leader>gwd", function() require("worktrees").remove_worktree() end, desc = "Remove Worktree" },
    },
    opts = {
      worktree_path = "..",
    },
  },
  {
    "folke/edgy.nvim",
    optional = true,
    opts = function(_, opts)
      -- Will get swapped to right by other edgy conf
      opts.left = opts.left or {}
      table.insert(opts.left, 1, {
        title = "Diffview Files",
        ft = "DiffviewFiles",
      })

      opts.bottom = opts.bottom or {}
      table.insert(opts.bottom, {
        title = "Diffview File History",
        ft = "DiffviewFileHistory",
        size = { height = 0.4 },
      })
    end,
  },
  {
    "hedyhli/outline.nvim",
    optional = true,
    opts = function(_, opts)
      local util = require("util")

      local overrides = {
        outline_window = {
          position = "right",
        },
        outline_items = {
          show_symbol_details = false,
        },
        symbols = {
          filter = {
            default = util.OUTLINE_SYMBOLS,
            -- lua_ls emits tables as Object/Array; use exclusion filter instead
            -- to avoid hiding the entire structure. Excludes only literal values
            -- and control flow (lua_ls emits for/if as Package).
            lua = { "String", "Number", "Boolean", "Package", exclude = true },
            rust = util.OUTLINE_SYMBOLS_RUST,
          },
        },
      }

      opts = vim.tbl_deep_extend("force", opts, overrides)
      return opts
    end,
  },

  {
    "stevearc/aerial.nvim",
    optional = true,
    opts = function(_, opts)
      local util = require("util")

      -- Filetype map: prefer treesitter for Lua because lua_ls emits
      -- tables as Object/Array with unhelpful [1], [2] names.
      -- Treesitter parses Lua grammar directly for better symbols.
      opts.backends = {
        _ = { "lsp", "treesitter" },
        lua = { "treesitter", "lsp" },
      }

      local overrides = {
        highlight_on_hover = true,
        filter_kind = {
          _ = util.OUTLINE_SYMBOLS,
          rust = util.OUTLINE_SYMBOLS_RUST,
        },
      }
      opts = vim.tbl_deep_extend("force", opts, overrides)
      return opts
    end,
  },

  -- Other
  {
    "linux-cultist/venv-selector.nvim",
    cmd = { "VenvSelect" },
    branch = "main",
  },
  -- codediff.nvim: diff engine with C FFI, move detection, two-tier highlights
  {
    "AJamesyD/codediff.nvim",
    dev = true,
    cmd = "CodeDiff",
    keys = {
      {
        "<leader>gd",
        function()
          local ok, lifecycle = pcall(require, "codediff.ui.lifecycle")
          if not ok then
            vim.cmd("CodeDiff")
            return
          end
          for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
            if lifecycle.get_session(tab) then
              vim.cmd(vim.api.nvim_tabpage_get_number(tab) .. "tabclose")
              return
            end
          end
          vim.cmd("CodeDiff")
        end,
        desc = "Toggle CodeDiff",
      },
      {
        "<leader>gf",
        "<CMD>CodeDiff history %<CR>",
        desc = "File History (CodeDiff)",
      },
    },
    opts = {
      diff = {
        compute_moves = true,
        original_position = "left",
        jump_to_first_change = true,
      },
      explorer = {
        position = "right",
        focus_on_select = true,
      },
      keymaps = {
        view = {
          -- Remap hunk/file nav to avoid ]c/[c and ]f/[f treesitter collisions
          ["]c"] = false,
          ["[c"] = false,
          ["]f"] = false,
          ["[f"] = false,
          ["]h"] = "next_hunk",
          ["[h"] = "prev_hunk",
          ["]F"] = "next_file",
          ["[F"] = "prev_file",
        },
      },
    },
    config = function(_, opts)
      require("codediff").setup(opts)

      local function is_codediff_tab(tabpage)
        local ok, lifecycle = pcall(require, "codediff.ui.lifecycle")
        return ok and lifecycle.get_session(tabpage or vim.api.nvim_get_current_tabpage()) ~= nil
      end

      -- Skip lualine winbar on CodeDiff tabs (diff buffers have filetype=""
      -- which passes lualine's disabled_filetypes check).
      local lualine_ok, lualine = pcall(require, "lualine")
      if lualine_ok and lualine.winbar then
        local orig_winbar = lualine.winbar
        lualine.winbar = function(...)
          if is_codediff_tab() then
            return nil
          end
          return orig_winbar(...)
        end
      end

      -- Prevent edgy.nvim from running layout on CodeDiff tabs.
      -- edgy hooks BufWinEnter/WinResized globally and resizes windows
      -- at edge positions, which breaks CodeDiff's own layout engine.
      local edgy_ok, edgy_layout = pcall(require, "edgy.layout")
      if edgy_ok and edgy_layout.update then
        local original_update = edgy_layout.update
        edgy_layout.update = function(...)
          if is_codediff_tab() then
            return
          end
          return original_update(...)
        end
      end
    end,
  },

  {
    "sindrets/diffview.nvim",
    enabled = false,
    cmd = {
      "DiffviewOpen",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
      "DiffviewRefresh",
      "DiffviewFileHistory",
    },
    opts = function(_, opts)
      local actions = require("diffview.config").actions
      local overrides = {
        enhanced_diff_hl = true,
        file_panel = {
          win_config = {
            position = "right",
          },
        },
        keymaps = {
          disable_defaults = true,
          view = {
            {
              "n",
              "<leader>e",
              actions.toggle_files,
              { desc = "Explorer Diffview", silent = true, nowait = true, remap = false },
            },
            {
              "n",
              "<leader>ge",
              actions.toggle_files,
              { desc = "Explorer Diffview", silent = true, nowait = true, remap = false },
            },
            { "n", "[x", actions.prev_conflict, { desc = "Prev Conflict" } },
            { "n", "]x", actions.next_conflict, { desc = "Next Conflict" } },
            { "n", "<leader>go", actions.conflict_choose("ours"), { desc = "Choose OURS" } },
            { "n", "<leader>gt", actions.conflict_choose("theirs"), { desc = "Choose THEIRS" } },
            { "n", "<leader>gb", actions.conflict_choose("base"), { desc = "Choose BASE" } },
            { "n", "<leader>gO", actions.conflict_choose_all("ours"), { desc = "Choose OURS (whole file)" } },
            { "n", "<leader>gT", actions.conflict_choose_all("theirs"), { desc = "Choose THEIRS (whole file)" } },
            { "n", "<leader>gB", actions.conflict_choose_all("base"), { desc = "Choose BASE (whole file)" } },
          },
          diff1 = {
            -- Mappings in single window diff layouts
            { "n", "g?", actions.help({ "view", "diff1" }), { desc = "Open the help panel" } },
          },
          diff2 = {
            -- Mappings in 2-way diff layouts
            { "n", "g?", actions.help({ "view", "diff2" }), { desc = "Open the help panel" } },
          },
          diff3 = {
            -- Mappings in 3-way diff layouts
            { "n", "g?", actions.help({ "view", "diff3" }), { desc = "Open the help panel" } },
          },
          diff4 = {
            -- Mappings in 4-way diff layouts
            { "n", "g?", actions.help({ "view", "diff4" }), { desc = "Open the help panel" } },
          },
          file_panel = {
            { "n", "j", actions.next_entry, { desc = "Down" } },
            { "n", "<down>", actions.next_entry, { desc = "Down" } },
            { "n", "k", actions.prev_entry, { desc = "Up" } },
            { "n", "<up>", actions.prev_entry, { desc = "Up" } },
            { "n", "<CR>", actions.select_entry, { desc = "Open Diff" } },
            { "n", "o", actions.select_entry, { desc = "Open Diff" } },
            { "n", "l", actions.select_entry, { desc = "Open Diff" } },
            { "n", "<2-LeftMouse>", actions.select_entry, { desc = "Open Diff" } },
            { "n", "<Tab>", actions.toggle_stage_entry, { desc = "Toggle Staged" } },
            { "n", "S", actions.stage_all, { desc = "Stage All" } },
            { "n", "U", actions.unstage_all, { desc = "Unstage All" } },
            { "n", "X", actions.restore_entry, { desc = "Restore File" } },
            { "n", "zo", actions.open_fold, { desc = "Open fold" } },
            { "n", "h", actions.close_fold, { desc = "Close fold" } },
            { "n", "zc", actions.close_fold, { desc = "Close fold" } },
            { "n", "za", actions.toggle_fold, { desc = "Toggle fold" } },
            { "n", "zR", actions.open_all_folds, { desc = "Expand all folds" } },
            { "n", "zM", actions.close_all_folds, { desc = "Close all folds" } },
            { "n", "<c-b>", actions.scroll_view(-0.25), { desc = "Scroll the view up" } },
            { "n", "<c-f>", actions.scroll_view(0.25), { desc = "Scroll the view down" } },
            -- {
            --   "n",
            --   "<tab>",
            --   actions.select_next_entry,
            --   { desc = "Open the diff for the next file" },
            -- },
            -- {
            --   "n",
            --   "<s-tab>",
            --   actions.select_prev_entry,
            --   { desc = "Open the diff for the previous file" },
            -- },
            -- {
            --   "n",
            --   "i",
            --   actions.listing_style,
            --   { desc = "Toggle between 'list' and 'tree' views" },
            -- },
            -- {
            --   "n",
            --   "f",
            --   actions.toggle_flatten_dirs,
            --   { desc = "Flatten empty subdirectories in tree listing style" },
            -- },
            -- {
            --   "n",
            --   "R",
            --   actions.refresh_files,
            --   { desc = "Update stats and entries in the file list" },
            -- },
            { "n", "<leader>e", actions.toggle_files, { desc = "Explorer Diffview" } },
            { "n", "<leader>ge", actions.toggle_files, { desc = "Explorer Diffview" } },
            { "n", "[x", actions.prev_conflict, { desc = "Prev Conflict" } },
            { "n", "]x", actions.next_conflict, { desc = "Next Conflict" } },
            { "n", "g?", actions.help("file_panel"), { desc = "Open help panel" } },
            { "n", "<leader>gO", actions.conflict_choose_all("ours"), { desc = "Choose OURS (whole file)" } },
            { "n", "<leader>gT", actions.conflict_choose_all("theirs"), { desc = "Choose THEIRS (whole file)" } },
            { "n", "<leader>gB", actions.conflict_choose_all("base"), { desc = "Choose BASE (whole file)" } },
          },
          file_history_panel = {
            { "n", "g!", actions.options, { desc = "Option panel" } },
            { "n", "y", actions.copy_hash, { desc = "Copy Commit Hash" } },
            { "n", "X", actions.restore_entry, { desc = "Restore File" } },
            { "n", "zo", actions.open_fold, { desc = "Expand fold" } },
            { "n", "zc", actions.close_fold, { desc = "Close fold" } },
            { "n", "h", actions.close_fold, { desc = "Close fold" } },
            { "n", "za", actions.toggle_fold, { desc = "Toggle fold" } },
            { "n", "zR", actions.open_all_folds, { desc = "Expand all folds" } },
            { "n", "zM", actions.close_all_folds, { desc = "Close all folds" } },
            { "n", "j", actions.next_entry, { desc = "Down" } },
            { "n", "<down>", actions.next_entry, { desc = "Down" } },
            { "n", "k", actions.prev_entry, { desc = "Up" } },
            { "n", "<up>", actions.prev_entry, { desc = "Up" } },
            { "n", "<CR>", actions.select_entry, { desc = "Open File" } },
            { "n", "<S-CR>", actions.open_in_diffview, { desc = "Open File in Diffview" } },
            { "n", "o", actions.select_entry, { desc = "Open File" } },
            { "n", "l", actions.select_entry, { desc = "Open File" } },
            { "n", "<2-LeftMouse>", actions.select_entry, { desc = "Open File" } },
            { "n", "<c-b>", actions.scroll_view(-0.25), { desc = "Scroll the view up" } },
            { "n", "<c-f>", actions.scroll_view(0.25), { desc = "Scroll the view down" } },
            { "n", "<leader>e", actions.toggle_files, { desc = "Explorer Diffview" } },
            { "n", "<leader>ge", actions.toggle_files, { desc = "Explorer Diffview" } },
            { "n", "g?", actions.help("file_history_panel"), { desc = "Open help panel" } },
          },
          option_panel = {
            { "n", "<tab>", actions.select_entry, { desc = "Changeoption" } },
            { "n", "q", actions.close, { desc = "Close" } },
            { "n", "g?", actions.help("option_panel"), { desc = "Open help panel" } },
          },
          help_panel = {
            { "n", "q", actions.close, { desc = "Close" } },
            { "n", "<esc>", actions.close, { desc = "Close" } },
          },
        },
      }

      opts = vim.tbl_deep_extend("force", opts, overrides)
      return opts
    end,
  },
  {
    "cbochs/grapple.nvim",
    event = { "BufReadPost", "BufNewFile" },
    cmd = "Grapple",
    keys = {
      { "<leader>H", "<cmd>Grapple toggle<cr>", desc = "Grapple toggle tag" },
      { "<leader>h", "<cmd>Grapple toggle_tags<cr>", desc = "Grapple open tags window" },
      { "]h", "<cmd>Grapple cycle_tags next<cr>", desc = "Next Grapple Tag" },
      { "[h", "<cmd>Grapple cycle_tags prev<cr>", desc = "Prev Grapple Tag" },
    },
    config = function(_, opts)
      require("grapple").setup(opts)

      -- Dynamically register <leader>1-9 based on actual tag count.
      -- GrappleUpdate fires after tag/untag/toggle/select/cycle_tags.
      -- GrappleScopeChanged fires on scope switches (e.g. branch change).
      local function sync_keymaps()
        local count = #(require("grapple").tags() or {})
        for i = 1, 9 do
          if i <= count then
            vim.keymap.set("n", "<leader>" .. i, "<cmd>Grapple select index=" .. i .. "<cr>", {
              desc = "Grapple → " .. i,
            })
          else
            pcall(vim.keymap.del, "n", "<leader>" .. i)
          end
        end
      end

      local group = vim.api.nvim_create_augroup("grapple_sync_keymaps", { clear = true })
      vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = { "GrappleUpdate", "GrappleScopeChanged" },
        callback = sync_keymaps,
      })
      -- Re-sync on BufEnter: grapple may load before any file buffer exists
      -- (e.g. via statusline component), so the initial tags() call can't
      -- resolve the scope. This also handles implicit scope changes when
      -- navigating between projects.
      vim.api.nvim_create_autocmd("BufEnter", {
        group = group,
        callback = function()
          if vim.bo.buftype == "" then
            sync_keymaps()
          end
        end,
      })
    end,
    ---@type grapple.settings
    opts = {
      -- Default: lsp → git → cwd. We insert git_branch so tags are
      -- per-branch when LSP root isn't available, with git root as a
      -- secondary fallback (covers detached HEAD where git_branch fails).
      scope = "lsp",
      quick_select = "asdfghjkl",
      default_scopes = {
        lsp = {
          fallback = "git_branch",
        },
        git_branch = {
          fallback = "git",
        },
      },
    },
  },
  {
    "stevearc/quicker.nvim",
    event = "FileType qf",
    ---@module "quicker"
    ---@type quicker.SetupOptions
    opts = {},
  },
}
