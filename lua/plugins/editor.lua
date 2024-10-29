local function sync_grapple_tags_to_bufferline_pinned()
  local grapple = require("grapple")
  local bufferline_groups = require("bufferline.groups")
  local bufferline_ui = require("bufferline.ui")

  local grapple_tagged_paths = {}
  for _, tag in ipairs(grapple.tags() or {}) do
    local absolute_path = tag.path
    local uri = vim.uri_from_fname(absolute_path)
    local bufnr = vim.uri_to_bufnr(uri)

    table.insert(grapple_tagged_paths, absolute_path)

    ---@type bufferline.Buffer
    ---@diagnostic disable-next-line: missing-fields
    local bufferline_buf = {
      id = bufnr,
    }
    if not bufferline_groups._is_pinned(bufferline_buf) then
      bufferline_groups.add_element("pinned", bufferline_buf)
      bufferline_ui.refresh()
    end
  end

  local pinned_paths = (vim.g["BufferlinePinnedBuffers"] or ""):split(",")
  for _, path in ipairs(pinned_paths) do
    if not vim.tbl_contains(grapple_tagged_paths, path) then
      local uri = vim.uri_from_fname(path)
      local bufnr = vim.uri_to_bufnr(uri)
      ---@type bufferline.Buffer
      ---@diagnostic disable-next-line: missing-fields
      local bufferline_buf = {
        id = bufnr,
      }
      if bufferline_groups._is_pinned(bufferline_buf) then
        bufferline_groups.remove_element("pinned", bufferline_buf)
        bufferline_ui.refresh()
      end
    end
  end
end

return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    dependencies = {
      {
        "antosha417/nvim-lsp-file-operations",
        priority = 1000,
      },
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
      event_handlers = {
        {
          event = "neo_tree_buffer_enter",
          handler = function()
            vim.opt.relativenumber = true
            vim.opt.number = true
          end,
        },
      },
    },
    keys = {
      { "<leader>ge", false },
      { "<leader>be", false },
    },
  },
  {
    "folke/flash.nvim",
    lazy = false,
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
    opts = {
      preset = "modern",
      spec = {
        { "<leader>F", hidden = true },
        { "<leader>gw", group = "worktrees" },
      },
      triggers = {
        { "<auto>", mode = "nixsotc" },
        -- For mini.surround
        { "s", mode = { "n", "v" } },
      },
    },
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      {
        "debugloop/telescope-undo.nvim",
        config = function()
          require("telescope").load_extension("undo")
        end,
      },
      {
        "nvim-telescope/telescope-project.nvim",
        config = function()
          require("telescope").load_extension("project")
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
              local venv = vim.fn.findfile("pyproject.toml", vim.fn.getcwd() .. ";")
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
      -- buffer
      { "<leader>be", "<cmd>Telescope buffers<cr>", desc = "Expore buffers" },
      -- find
      { "<leader>fc", false },
      { "<leader>fp", "<cmd>Telescope project<cr>", desc = "Projects" },
      -- git
      {
        "<leader>gwc",
        function()
          require("telescope").extensions.git_worktree.create_git_worktree()
        end,
        desc = "Create git worktree",
      },
      {
        "<leader>gws",
        function()
          require("telescope").extensions.git_worktree.git_worktrees()
        end,
        desc = "Git worktrees",
      },
      -- search
      { '<leader>s"', false },
      { "<leader>sa", false },
      { "<leader>sH", false },
      { "<leader>sM", false },
      { "<leader>sm", false },
      { "<leader>sR", false },
      { "<leader>sa", "<cmd>Telescope live_grep_args<cr>", desc = "Grep w/ args" },
      { "<leader>s<CR>", "<cmd>Telescope resume<cr>", desc = "Resume" },
      -- undo
      { "<leader>su", "<CMD>Telescope undo<CR>", desc = "Undo history" },
      -- spell
      { "z=", "<CMD>Telescope spell_suggest<CR>", desc = "Spelling Suggestions" },
    },
    opts = {
      defaults = {
        file_ignore_patterns = {
          "%.venv/.*",
          "venv/.*",
          ".*%.out/.*",
          "node_modules/.*",
          "dist/.*",
        },
        sorting_strategy = "ascending",
        layout_config = {
          horizontal = { prompt_position = "top", preview_width = 0.55 },
          vertical = { mirror = false },
          width = 0.87,
          height = 0.80,
          preview_cutoff = 120,
        },
      },
      pickers = {
        spell_suggest = {
          theme = "cursor",
        },
      },
    },
  },
  {
    "linux-cultist/venv-selector.nvim",
    branch = "regexp",
    event = "VeryLazy",
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
    opts = function(opts)
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
              { desc = "Explorer Diffview", silent = true, nowait = true, noremap = true },
            },
            {
              "n",
              "<leader>ge",
              actions.toggle_files,
              { desc = "Explorer Diffview", silent = true, nowait = true, noremap = true },
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

      opts = vim.tbl_deep_extend("force", overrides, opts)
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
  {
    "lewis6991/gitsigns.nvim",
    keys = {
      {
        "<leader>ug",
        "<CMD>Gitsigns toggle_current_line_blame<CR>",
        desc = "Toggle git line blame",
      },
    },
    opts = {
      current_line_blame_opts = {
        virt_text_pos = "right_align",
        delay = 500,
      },
    },
  },
  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    opts = {
      timeout = 500,
    },
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
            sync_grapple_tags_to_bufferline_pinned()
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
    config = function(_, opts)
      local grapple = require("grapple")
      grapple.setup(opts)

      vim.api.nvim_create_autocmd("FileType", {
        desc = "Schedule sync of grapple/bufferline tags/pins",
        pattern = "grapple",
        callback = function(event)
          local bufnr = event.buf

          vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave" }, {
            desc = "Sync grapple/bufferline tags/pins",
            buffer = bufnr,
            callback = function()
              vim.schedule(sync_grapple_tags_to_bufferline_pinned)
            end,
          })
        end,
      })
    end,
  },
  {
    "hedyhli/outline.nvim",
    optional = true,
    opts = {
      outline_window = {
        show_numbers = true,
        show_relative_numbers = true,
      },
    },
  },
  {
    "stevearc/aerial.nvim",
    optional = true,
    opts = {
      layout = {
        win_opts = {
          number = true,
          relativenumber = true,
          statuscolumn = vim.opt.statuscolumn["_value"],
        },
      },
      highlight_mode = "last",
      highlight_on_hover = true,
    },
  },
}
