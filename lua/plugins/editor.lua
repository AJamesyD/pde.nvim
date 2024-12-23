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
    opts = {
      current_line_blame_opts = {
        virt_text_pos = "right_align",
        delay = 500,
      },
    },
  },
  -- Reconfigure LazyVim extras
  {
    "ibhagwan/fzf-lua",
    optional = true,
    keys = {
      { "<leader>,", false },
      { "<leader>/", false },
      { "<leader>:", false },
      { "<leader><space>", "<cmd>FzfLua resume<cr>", desc = "Resume Search" },
      -- find
      { "<leader>fc", false },
      { "<leader>fr", LazyVim.pick("oldfiles"), desc = "Recent (Root Dir)" },
      { "<leader>fR", LazyVim.pick("oldfiles", { cwd = vim.uv.cwd() }), desc = "Recent (cwd)" },
      -- git
      { "<leader>gc", false },
      { "<leader>gs", false },
      -- search
      { '<leader>s"', false },
      { "<leader>sa", false },
      { "<leader>sb", false },
      { "<leader>sc", false },
      { "<leader>sC", false },
      { "<leader>sH", false },
      { "<leader>sM", false },
      { "<leader>sm", false },
      { "<leader>so", false },
      { "<leader>ss", false },
      { "<leader>sS", false },
      -- undo
      -- TODO: undo keymaps
      -- spell
      { "<leader>ss", "<cmd>FzfLua spell_suggest<cr>", desc = "Spelling Suggestions" },
      { "z=", "<CMD>Telescope spell_suggest<CR>", desc = "Spelling Suggestions" },
    },
    opts = function(_, opts)
      local overrides = {
        keymap = {
          fzf = {
            -- use cltr-q to select all items and convert to quickfix list
            ["ctrl-q"] = "select-all+accept",
          },
        },
        oldfiles = {
          cwd_only = true,
          include_current_session = true,
        },
        winopts = {
          height = 0.9,
          width = 0.9,
          row = 0.50,
          col = 0.50,
        },
      }

      opts = vim.tbl_deep_extend("force", opts, overrides)
      return opts
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    optional = true,
    enabled = vim.g.lazyvim_picker == "telescope",
    dependencies = {
      {
        "debugloop/telescope-undo.nvim",
        config = function()
          require("telescope").load_extension("undo")
        end,
      },
      {
        "nvim-telescope/telescope-live-grep-args.nvim",
        -- This will not install any breaking changes.
        -- For major updates, this must be adjusted manually.
        version = "^1.0.0",
        config = function()
          require("telescope").load_extension("live_grep_args")
        end,
      },
      {
        "ThePrimeagen/git-worktree.nvim",
        dependencies = {
          "nvim-telescope/telescope.nvim",
        },
        opts = function(_, opts)
          opts.update_on_change_command = "Telescope find_files"

          require("telescope").load_extension("git_worktree")

          local worktree = require("git-worktree")

          worktree.on_tree_change(function(op, metadata)
            if op == worktree.Operations.Switch then
              local new_path = metadata.path
              local root_files = {
                "pyproject.toml",
                "requirements.txt",
              }
              local venv = require("lspconfig.util").root_pattern(unpack(root_files))(new_path)
              if venv ~= "" then
                require("venv-selector").retrieve_from_cache()
              end
            end
          end)
        end,
      },
    },
    keys = {
      { "<leader>,", false },
      { "<leader>/", false },
      { "<leader>:", false },
      { "<leader><space>", "<cmd>Telescope resume<cr>", desc = "Resume Search" },
      { "<leader><cr>", "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>", desc = "Switch Buffer" },
      -- find
      { "<leader>fc", false },
      { "<leader>fr", LazyVim.pick("oldfiles"), desc = "Recent (Root Dir)" },
      { "<leader>fR", LazyVim.pick("oldfiles", { cwd = vim.uv.cwd() }), desc = "Recent (cwd)" },
      -- git
      { "<leader>gc", false },
      { "<leader>gs", false },
      {
        "<leader>gwc",
        function()
          require("telescope").extensions.git_worktree.create_git_worktree()
        end,
        desc = "New Worktree",
      },
      {
        "<leader>gws",
        function()
          require("telescope").extensions.git_worktree.git_worktrees()
        end,
        desc = "List Worktrees",
      },
      -- search
      { '<leader>s"', false },
      { "<leader>sa", false },
      { "<leader>sb", false },
      { "<leader>sc", false },
      { "<leader>sC", false },
      { "<leader>sH", false },
      { "<leader>sM", false },
      { "<leader>sm", false },
      { "<leader>so", false },
      { "<leader>ss", false },
      { "<leader>sS", false },
      { "<leader>sa", "<cmd>Telescope live_grep_args<cr>", desc = "Grep w/ Args" },
      -- undo
      { "<leader>su", "<CMD>Telescope undo<CR>", desc = "Undo History" },
      -- spell
      { "<leader>ss", "<CMD>Telescope spell_suggest<CR>", desc = "Spelling Suggestions" },
      { "z=", "<CMD>Telescope spell_suggest<CR>", desc = "Spelling Suggestions" },
    },
    opts = function(_, opts)
      local overrides = {
        defaults = {
          path_display = {
            filename_first = {
              reverse_directories = true,
            },
          },
          layout_config = {
            horizontal = { prompt_position = "top", preview_width = 0.6 },
            vertical = { mirror = false },
            width = 0.90,
            height = 0.90,
          },
          sorting_strategy = "ascending",
        },
        pickers = {
          buffers = {
            mappings = {
              n = {
                ["d"] = require("telescope.actions").delete_buffer,
              },
            },
          },
          spell_suggest = {
            theme = "cursor",
          },
        },
      }

      opts = vim.tbl_deep_extend("force", opts, overrides)
      return opts
    end,
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

  -- Other
  {
    "linux-cultist/venv-selector.nvim",
    cmd = { "VenvSelect" },
    branch = "regexp",
  },
  {
    "sindrets/diffview.nvim",
    keys = {
      {
        "<leader>gd",
        "<CMD>DiffviewOpen<CR>",
        desc = "Open Diffview",
      },
      {
        "<leader>gD",
        "<CMD>DiffviewClose<CR>",
        desc = "Close Diffview",
      },
    },
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
    ---@type grapple.settings
    event = { "BufReadPost", "BufNewFile" },
    cmd = "Grapple",
    keys = function()
      local keys = {
        {
          "<leader>H",
          function()
            require("grapple").toggle()
          end,
          desc = "Grapple toggle tag",
        },
        {
          "<leader>h",
          "<cmd>Grapple toggle_tags<cr>",
          desc = "Grapple open tags window",
        },
      }

      for i = 1, 4 do
        table.insert(keys, {
          "<leader>" .. i,
          "<cmd>Grapple select index=" .. i .. "<cr>",
          desc = "Grapple to File " .. i,
        })
      end
      return keys
    end,
    opts = {
      -- Model after vim.g.root_spec, i.e. { "lsp", {".git", "lua"}, "cwd" }
      scope = "lsp",
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
