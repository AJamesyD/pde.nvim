return {
  {
    "nvim-treesitter/nvim-treesitter",
    cmd = { "TSInstallFromGrammar" },
    ---@param opts TSConfig
    ---@diagnostic disable-next-line: missing-fields
    opts = function(_, opts)
      vim.filetype.add({
        extension = { rasi = "rasi", rofi = "rasi", wofi = "rasi" },
        filename = {
          [".envrc"] = "sh",
        },
      })

      ---@type TSConfig
      ---@diagnostic disable-next-line: missing-fields
      local overrides = {
        auto_install = true,
        highlight = {
          enable = true,
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["aa"] = { query = "@parameter.outer", desc = "argument" },
              ["ia"] = { query = "@parameter.inner", desc = "argument" },
              ["a="] = { query = "@assignment.outer", desc = "assignment" },
              ["i="] = { query = "@assignment.inner", desc = "assignment" },
              ["l="] = { query = "@assignment.lhs", desc = "assignment" },
              ["r="] = { query = "@assignment.rhs", desc = "assignment" },
            },
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              ["]f"] = { query = "@function.outer", desc = "Next Function" },
              ["]c"] = { query = "@class.outer", desc = "Next Class" },
              ["]a"] = { query = "@parameter.inner", desc = "Next Parameter" },
              ["]z"] = { query = "@fold", desc = "Next Fold" },
            },
            goto_next_end = {
              ["]F"] = { query = "@function.outer", desc = "Next Function end" },
              ["]C"] = { query = "@class.outer", desc = "Next Class end" },
              ["]A"] = { query = "@parameter.inner", desc = "Next Parameter end" },
              ["]z"] = { query = "@fold", desc = "Next Fold end" },
            },
            goto_previous_start = {
              ["[f"] = { query = "@function.outer", desc = "Prev Function" },
              ["[c"] = { query = "@class.outer", desc = "Prev Class" },
              ["[a"] = { query = "@parameter.inner", desc = "Prev Parameter" },
              ["[z"] = { query = "@fold", desc = "Next Fold" },
            },
            goto_previous_end = {
              ["[F"] = { query = "@function.outer", desc = "Prev Function end" },
              ["[C"] = { query = "@class.outer", desc = "Prev Class end" },
              ["[A"] = { query = "@parameter.inner", desc = "Prev Parameter end" },
              ["[Z"] = { query = "@fold", desc = "Prev Fold end" },
            },
          },
          swap = {
            enable = true,
            swap_next = {
              [">f"] = { query = "@function.outer", desc = "Swap next function" },
              [">a"] = { query = "@parameter.inner", desc = "Swap next argument" },
            },
            swap_previous = {
              ["<f"] = { query = "@function.outer", desc = "Swap prev function" },
              ["<a"] = { query = "@parameter.inner", desc = "Swap prev argument" },
            },
          },
        },
      }

      opts = vim.tbl_deep_extend("force", overrides, opts)
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
  -- TODO: Install and enable ts_query_ls
  -- {
  --   "neovim/nvim-lspconfig",
  --   ---@class PluginLspOpts
  --   opts = {
  --     servers = {
  --       ts_query_ls = {
  --         settings = {
  --           parser_install_directories = {
  --             -- If using nvim-treesitter with lazy.nvim
  --             vim.fs.joinpath(vim.fn.stdpath("data"), "/lazy/nvim-treesitter/parser/"),
  --           },
  --           -- This setting is provided by default
  --           parser_aliases = {
  --             ecma = "javascript",
  --             jsx = "javascript",
  --             php_only = "php",
  --           },
  --           -- E.g. zed support
  --           language_retrieval_patterns = {
  --             "languages/src/([^/]+)/[^/]+\\.scm$",
  --           },
  --         },
  --       },
  --     },
  --   },
  -- },
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
    config = true,
  },
}
