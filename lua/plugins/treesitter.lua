local map = vim.keymap.set
map("n", "<leader>m", function()
  require("treesj").toggle()
end, { desc = "Split/Join" })
map("n", "<leader>M", function()
  require("treesj").toggle({ split = { recursive = true } })
end, { desc = "Split/Join (Recursive)" })

return {
  -- Reconfigure LazyVim defaults
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      {
        "folke/lazydev.nvim",
        optional = true,
        opts = function(_, opts)
          opts.library = opts.library or {}
          table.insert(opts.library, { path = "nvim-treesitter", words = { "TS", "treesitter" } })
        end,
      },
    },
    ---@param opts lazyvim.TSConfig
    opts = function(_, opts)
      vim.filetype.add({
        extension = { rasi = "rasi", rofi = "rasi", wofi = "rasi" },
        filename = {
          [".envrc"] = "sh",
        },
      })

      -- XXX: For some reason, Treesitter causes Neovim to hang when opening these filetypes
      local disabled_fts = {
        "text",
        "brazil-config",
      }

      ---@type lazyvim.TSConfig
      local overrides = {
        highlight = {
          enable = true,
          disable = disabled_fts,
        },
        indent = {
          enable = true,
          disable = disabled_fts,
        },
        folds = {
          enable = true,
          disable = disabled_fts,
        },
      }

      opts = vim.tbl_deep_extend("force", opts, overrides)
      local ensure_installed = {
        "comment",
        "devicetree", -- For qmk.nvim
        "ini",
        "kdl",
        "sql",
        "tmux",
      }
      opts.ensure_installed = vim.list_extend(opts.ensure_installed or {}, ensure_installed)
      return opts
    end,
  },
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      servers = {
        ts_query_ls = {},
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    opts = { select = { lookahead = true } },
    keys = {
      {
        "aa",
        mode = { "x", "o" },
        function()
          require("nvim-treesitter-textobjects.select").select_textobject("@parameter.outer", "textobjects")
        end,
        desc = "argument",
      },
      {
        "ia",
        mode = { "x", "o" },
        function()
          require("nvim-treesitter-textobjects.select").select_textobject("@parameter.inner", "textobjects")
        end,
        desc = "argument",
      },
      {
        "a=",
        mode = { "x", "o" },
        function()
          require("nvim-treesitter-textobjects.select").select_textobject("@assignment.outer", "textobjects")
        end,
        desc = "assignment",
      },
      {
        "i=",
        mode = { "x", "o" },
        function()
          require("nvim-treesitter-textobjects.select").select_textobject("@assignment.inner", "textobjects")
        end,
        desc = "assignment",
      },
      {
        "l=",
        mode = { "x", "o" },
        function()
          require("nvim-treesitter-textobjects.select").select_textobject("@assignment.lhs", "textobjects")
        end,
        desc = "assignment lhs",
      },
      {
        "r=",
        mode = { "x", "o" },
        function()
          require("nvim-treesitter-textobjects.select").select_textobject("@assignment.rhs", "textobjects")
        end,
        desc = "assignment rhs",
      },
      {
        ">a",
        function()
          require("nvim-treesitter-textobjects.swap").swap_next("@parameter.inner")
        end,
        desc = "Swap next argument",
      },
      {
        "<a",
        function()
          require("nvim-treesitter-textobjects.swap").swap_previous("@parameter.inner")
        end,
        desc = "Swap prev argument",
      },
      {
        ">f",
        function()
          require("nvim-treesitter-textobjects.swap").swap_next("@function.outer")
        end,
        desc = "Swap next function",
      },
      {
        "<f",
        function()
          require("nvim-treesitter-textobjects.swap").swap_previous("@function.outer")
        end,
        desc = "Swap prev function",
      },
      {
        "]z",
        mode = { "n", "x", "o" },
        function()
          require("nvim-treesitter-textobjects.move").goto_next_start("@fold", "folds")
        end,
        desc = "Next fold",
      },
      {
        "[z",
        mode = { "n", "x", "o" },
        function()
          require("nvim-treesitter-textobjects.move").goto_previous_start("@fold", "folds")
        end,
        desc = "Prev fold",
      },
      {
        "]Z",
        mode = { "n", "x", "o" },
        function()
          require("nvim-treesitter-textobjects.move").goto_next_end("@fold", "folds")
        end,
        desc = "Next fold end",
      },
      {
        "[Z",
        mode = { "n", "x", "o" },
        function()
          require("nvim-treesitter-textobjects.move").goto_previous_end("@fold", "folds")
        end,
        desc = "Prev fold end",
      },
    },
  },

  -- Other
  {
    "chrisgrieser/nvim-various-textobjs",
    keys = {
      {
        "ig",
        mode = { "o", "x" },
        function()
          require("various-textobjs").greedyOuterIndentation("inner")
        end,
        desc = "Indentation (greedy)",
      },
      {
        "ag",
        mode = { "o", "x" },
        function()
          require("various-textobjs").greedyOuterIndentation("outer")
        end,
        desc = "Indentation (greedy)",
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
        desc = "File",
      },
      {
        "|",
        mode = { "o", "x" },
        function()
          require("various-textobjs").column()
        end,
        desc = "Column",
      },
    },
    opts = {},
  },
  {
    "m-demare/hlargs.nvim",
    enabled = false,
  },
  {
    "Wansmer/treesj",
    dev = true,
    lazy = true,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = function(_, opts)
      local overrides = {
        use_default_keymaps = false,
        max_join_length = 240,
      }

      opts = vim.tbl_deep_extend("force", opts, overrides)
      return opts
    end,
  },
}
