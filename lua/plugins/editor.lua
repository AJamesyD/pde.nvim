local Util = require("lazyvim.util")

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
    },
    keys = {
      { "<leader>fe", false },
      { "<leader>fE", false },
      {
        "<leader>e",
        function()
          require("neo-tree.command").execute({ toggle = true, dir = vim.loop.cwd() })
        end,
        desc = "Explorer NeoTree",
      },
      { "<leader>E",  false },
      { "<leader>ge", false },
      { "<leader>be", false },
    },
  },
  {
    "folke/flash.nvim",
    keys = {
      { "<c-s>", mode = { "c" }, false },
    },
  },
  {
    "folke/which-key.nvim",
    opts = {
      defaults = {
        ["<leader>fh"] = { name = "+harpoon" },
        ["<leader>gh"] = { name = "+hunks" },
        ["<leader>gw"] = { name = "+worktrees" },
        ["<leader>fm"] = { "which_key_ignore" },
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
        "ThePrimeagen/git-worktree.nvim",
        dependencies = { "nvim-telescope/telescope.nvim" },
        opts = function(_, opts)
          require("telescope").load_extension("git_worktree")
          return opts
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
      { "<leader>s<CR>", "<cmd>Telescope resume<cr>", desc = "Resume" },
      -- undo
      { "<leader>su",    "<CMD>Telescope undo<CR>",   desc = "Undo history" },
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
    "ThePrimeagen/harpoon",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    cmd = { "Harpoon" },
    keys = {
      {
        "<leader>fha",
        function()
          require("harpoon.mark").add_file()
        end,
        desc = "Add file",
      },
      {
        "<leader>fhe",
        function()
          require("harpoon.ui").toggle_quick_menu()
        end,
        desc = "Toggle quick menu",
      },
      {
        "<C-p>",
        function()
          require("harpoon.ui").nav_prev()
        end,
        desc = "Goto previous mark",
      },
      {
        "<C-n>",
        function()
          require("harpoon.ui").nav_next()
        end,
        desc = "Goto next mark",
      },
    },
  },
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
  },
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewToggleFiles" },
  },
  {
    "f-person/git-blame.nvim",
    keys = {
      {
        "<leader>ug",
        "<CMD>GitBlameToggle<CR>",
        desc = "Toggle git blame",
      },
    },
    opts = {
      enabled = false,
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
    "willothy/flatten.nvim",
    lazy = false,
    priority = 1000,
    config = true,
  },
}
