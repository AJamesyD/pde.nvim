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
      close_if_last_window = true,
      enable_git_status = false,
      enable_diagnostics = false,
      window = {
        width = 30,
      },
      buffers = {
        show_unloaded = false,
      },
    },
    keys = {
      { "<leader>ge", false },
      { "<leader>be", false },
    },
  },
  {
    "stevearc/oil.nvim",
    enabled = false,
    event = "VeryLazy",
    keys = {
      {
        "-",
        "<cmd>Oil<cr>",
        desc = "Open Oil",
      },
      {
        "<leader>o",
        "<cmd>Oil<cr>",
        desc = "Open Oil",
      },
    },
    opts = {
      columns = {
        "icon",
        "size",
        "mtime",
      },
    },
  },
  {
    "nvim-pack/nvim-spectre",
    opts = {
      find_engine = {
        ["rg"] = {
          options = {
            ["ignore-case"] = {
              value = "--ignore-case",
              icon = "[I]",
              desc = "ignore case",
            },
            ["hidden"] = {
              value = "--hidden",
              desc = "hidden file",
              icon = "[H]",
            },
            ["backreferences"] = {
              value = "--pcre2",
              desc = "backreferences",
              icon = "[B]",
            },
          },
        },
      },
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
        function()
          if vim.g.flash_enabled then
            require("flash").jump()
          end
        end,
        desc = "Flash",
      },
      {
        "S",
        mode = { "n", "x", "o" },
        function()
          if vim.g.flash_enabled then
            require("flash").treesitter()
          end
        end,
        desc = "Flash Treesitter",
      },
      {
        "r",
        mode = "o",
        function()
          if vim.g.flash_enabled then
            require("flash").remote()
          end
        end,
        desc = "Remote Flash",
      },
      {
        "R",
        mode = { "o", "x" },
        function()
          if vim.g.flash_enabled then
            require("flash").treesitter_search()
          end
        end,
        desc = "Treesitter Search",
      },
      {
        "<leader>uS",
        function()
          vim.g.flash_enabled = not vim.g.flash_enabled
        end,
        desc = "Toggle Flash",
      },
    },
  },
  {
    "folke/which-key.nvim",
    opts = {
      preset = "modern",
      spec = {
        { "<leader>F",  hidden = true },
        { "<leader>gw", group = "+worktrees" },
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
          {
            "linux-cultist/venv-selector.nvim",
            optional = true,
            branch = "regexp",
            event = "VeryLazy",
          },
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
      {
        "folke/noice.nvim",
        optional = true,
        dependencies = { "nvim-telescope/telescope.nvim" },
        opts = function(_, opts)
          require("telescope").load_extension("noice")
          return opts
        end,
      },
    },
    keys = {
      { "<leader>,",       false },
      { "<leader>/",       false },
      { "<leader>:",       false },
      { "<leader><space>", false },
      -- buffer
      { "<leader>be",      "<cmd>Telescope buffers<cr>", desc = "Expore buffers" },
      -- find
      { "<leader>fc",      false },
      { "<leader>fp",      "<cmd>Telescope project<cr>", desc = "Projects" },
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
      { '<leader>s"',    false },
      { "<leader>sa",    false },
      { "<leader>sH",    false },
      { "<leader>sM",    false },
      { "<leader>sm",    false },
      { "<leader>sR",    false },
      { "<leader>sa",    "<cmd>Telescope live_grep_args<cr>", desc = "Grep w/ args" },
      { "<leader>s<CR>", "<cmd>Telescope resume<cr>",         desc = "Resume" },
      -- undo
      { "<leader>su",    "<CMD>Telescope undo<CR>",           desc = "Undo history" },
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
    },
  },
  {
    "sindrets/diffview.nvim",
    cmd = {
      "DiffviewOpen",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
      "DiffviewRefresh",
      "DiffviewFileHistory",
    },
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
    "chrisgrieser/nvim-various-textobjs",
    lazy = false,
    keys = {
      {
        "ig",
        mode = { "o", "x" },
        function()
          require("various-textobjs").greedyOuterIndentation("inner")
        end,
        desc = "Greedy outer indentation",
      },
      {
        "ag",
        mode = { "o", "x" },
        function()
          require("various-textobjs").greedyOuterIndentation("outer")
        end,
        desc = "Greedy outer indentation",
      },
      {
        "iS",
        mode = { "o", "x" },
        function()
          require("various-textobjs").subword("inner")
        end,
        desc = "Subword",
      },
      {
        "aS",
        mode = { "o", "x" },
        function()
          require("various-textobjs").subword("outer")
        end,
        desc = "Subword",
      },
      {
        "gG",
        mode = { "o", "x" },
        function()
          require("various-textobjs").entireBuffer()
        end,
        desc = "Entire buffer",
      },
      {
        "|",
        mode = { "o", "x" },
        function()
          require("various-textobjs").column()
        end,
        desc = "Column",
      },
      {
        "iv",
        mode = { "o", "x" },
        function()
          require("various-textobjs").value("inner")
        end,
        desc = "Value",
      },
      {
        "av",
        mode = { "o", "x" },
        function()
          require("various-textobjs").value("outer")
        end,
        desc = "Value",
      },
      {
        "ik",
        mode = { "o", "x" },
        function()
          require("various-textobjs").key("inner")
        end,
        desc = "Key",
      },
      {
        "ak",
        mode = { "o", "x" },
        function()
          require("various-textobjs").key("outer")
        end,
        desc = "Key",
      },
    },
    opts = {},
  },
  {
    "cbochs/grapple.nvim",
    opts = {
      scope = "git_branch", -- also try out "git_branch"
    },
    event = { "BufReadPost", "BufNewFile" },
    cmd = "Grapple",
    keys = function()
      local keys = {
        { "<leader>H", "<cmd>Grapple toggle<cr>",      desc = "Grapple toggle tag" },
        { "<leader>h", "<cmd>Grapple toggle_tags<cr>", desc = "Grapple open tags window" },
      }

      for i = 1, 5 do
        table.insert(keys, {
          "<leader>" .. i,
          "<cmd>Grapple select index=" .. i .. "<cr>",
          desc = "Grapple to File " .. i,
        })
      end
      return keys
    end,
  },
}
