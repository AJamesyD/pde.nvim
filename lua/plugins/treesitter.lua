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
    event = "LazyFile",
    config = true,
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
