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
  },
  {
    "folke/persistence.nvim",
    enabled = false,
  },
  -- PRUNED 2026-03-22: palette-safe, remove after 4 weeks
  {
    "folke/trouble.nvim",
    keys = {
      { "<leader>xL", false },
    },
  },
  {
    "folke/which-key.nvim",
    dependencies = {
      {
        "folke/lazydev.nvim",
        optional = true,
        opts = function(_, opts)
          opts.library = opts.library or {}
          table.insert(opts.library, { path = "which-key.nvim", words = { "wk", "which-key" } })
        end,
      },
    },
    ---@param opts wk.Opts
    opts = function(_, opts)
      local overrides = {
        preset = "modern",
      }

      local spec_overrides = {
        { "<leader>F", hidden = true },
        { "<leader>w", group = "worktrees" },
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
      { "<leader>/", LazyVim.pick("grep"), desc = "Grep (Root Dir)" },
      { "<leader>:", false },
      { "<leader><space>", false },
      -- find
      { "<leader>fc", false },
      { "<leader>fr", function() Snacks.picker.recent({ filter = { cwd = LazyVim.root() }}) end, desc = "Recent (Root Dir)" },
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
      -- PRUNED 2026-03-22: palette-safe, remove after 4 weeks
      { "<leader>sb", false },
      { "<leader>sj", false },
      { "<leader>si", false },
      { "<leader>sB", false },
      { "<leader>sl", false },

      { "<leader>S", false },
      { "<leader>n", false },
      { "<leader>sH", false },
      { "<leader>sm", false },
      { "<leader>sM", false },
      { "<leader>so", false },
      { "<leader>ss", false },
      { "<leader>sS", false },
      { "z=", function() Snacks.picker.spelling() end, desc = "Spelling Suggestions" },
      { "<leader>su", function() Snacks.picker.undo() end, desc = "Undo History" },
      { "<leader>.", function() Snacks.picker.resume() end, desc = "Resume Last Picker" },
    },
    ---@type snacks.Config
    opts = {
      gh = {},
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
      {
        "<leader>wc",
        function()
          require("worktrees").new_worktree()
        end,
        desc = "New Worktree",
      },
      {
        "<leader>ws",
        function()
          Snacks.picker.worktrees()
        end,
        desc = "List Worktrees",
      },
      {
        "<leader>wd",
        function()
          require("worktrees").remove_worktree()
        end,
        desc = "Remove Worktree",
      },
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

  -- TODO: re-enable diffview.nvim or swap for codediff.nvim
  {
    "sindrets/diffview.nvim",
    enabled = false,
  },
  {
    "cbochs/grapple.nvim",
    event = { "BufReadPost", "BufNewFile" },
    cmd = "Grapple",
    dependencies = {
      {
        "folke/lazydev.nvim",
        optional = true,
        opts = function(_, opts)
          opts.library = opts.library or {}
          table.insert(opts.library, { path = "grapple.nvim", words = { "grapple" } })
        end,
      },
    },
    keys = {
      { "<leader>h", "<cmd>Grapple toggle<cr>", desc = "Grapple toggle tag" },
      { "<leader><space>", "<cmd>Grapple toggle_tags<cr>", desc = "Grapple open tags" },
      { "]g", "<cmd>Grapple cycle_tags next<cr>", desc = "Next Grapple tag" },
      { "[g", "<cmd>Grapple cycle_tags prev<cr>", desc = "Prev Grapple tag" },
    },
    config = function(_, opts)
      require("grapple").setup(opts)

      -- Dynamically register <leader>1-9 based on actual tag count.
      -- GrappleUpdate fires after tag/untag/toggle/select/cycle_tags.
      -- GrappleScopeChanged fires on scope switches (e.g. branch change).
      local function sync_keymaps()
        local count = #(require("grapple").tags() or {})
        for i = 1, 4 do
          if i <= count then
            vim.keymap.set("n", "<leader>" .. i, "<cmd>Grapple select index=" .. i .. "<cr>", {
              desc = "Grapple → " .. i,
            })
          else
            pcall(vim.keymap.del, "n", "<leader>" .. i)
          end
        end
        -- Clean up any stale slots from previous config
        for i = 5, 9 do
          pcall(vim.keymap.del, "n", "<leader>" .. i)
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
