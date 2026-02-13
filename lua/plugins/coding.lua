return {
  -- Reconfigure LazyVim defaults
  {
    "saghen/blink.cmp",
    optional = true,
    dependencies = {
      -- TODO: Possibly integrate https://github.com/zjp-CN/nvim-cmp-lsp-rs?
      {
        "saghen/blink.compat",
        optional = false,
      },
    },
    ---@param opts blink.cmp.Config
    opts = function(_, opts)
      ---@type blink.cmp.Config
      ---@diagnostic disable-next-line: missing-fields
      local overrides = {
        completion = {
          menu = {
            border = "rounded",
          },
          documentation = {
            window = { border = "rounded" },
          },
        },
        -- experimental signature help support
        signature = {
          enabled = true,
          window = {
            border = "rounded",
          },
        },

        sources = {
          -- adding any nvim-cmp sources here will enable them
          -- with blink.compat
          compat = {
            "avante_commands",
            "avante_mentions",
            "avante_files",
          },
          default = function(ctx)
            local success, node = pcall(vim.treesitter.get_node)
            if success and node and vim.tbl_contains({ "comment", "line_comment", "block_comment" }, node:type()) then
              return { "buffer" }
            else
              return { "lsp", "path", "snippets" }
            end
          end,
        },

        keymap = {
          preset = "enter",
          ["<S-Tab>"] = { "select_prev", "fallback" },
          ["<Tab>"] = { "select_next", "fallback" },
          ["<C-space>"] = {
            function(cmp)
              cmp.show({ providers = { "lsp" } })
            end,
          },
        },
      }

      opts = vim.tbl_deep_extend("force", opts, overrides)
      return opts
    end,
  },
  {
    "folke/lazydev.nvim",
    opts = function(_, opts)
      local library_overrides = {
        { path = "lazy.nvim" },
        { path = "LazyVim" },

        { path = "avante.nvim", words = { "avante" } },
        { path = "blink.cmp", words = { "blink" } },
        { path = "conform.nvim", words = { "conform" } },
        { path = "edgy.nvim", words = { "edgy" } },
        { path = "grapple.nvim", words = { "grapple" } },
        { path = "leetcode.nvim", words = { "leetcode" } },
        { path = "mason.nvim", words = { "mason" } },
        { path = "nvim-treesitter", words = { "TS", "treesitter" } },
        { path = "rustaceanvim", words = { "rust" } },
        { path = "snacks.nvim", words = { "snacks" } },
        { path = "telescope.nvim", words = { "telescope" } },
        { path = "tokyonight.nvim", words = { "tokyonight" } },
        { path = "which-key.nvim", words = { "wk", "which-key" } },
      }

      opts.library = vim.list_extend(opts.library or {}, library_overrides)
      return opts
    end,
  },

  -- Reconfigure LazyVim extras
  {
    "nvim-mini/mini.surround",
    optional = true,
    opts = {
      mappings = {
        add = "sa", -- Add surrounding in Normal and Visual modes
        delete = "sd", -- Delete surrounding
        find = "sf", -- Find surrounding (to the right)
        find_left = "sF", -- Find surrounding (to the left)
        highlight = "sh", -- Highlight surrounding
        replace = "sr", -- Replace surrounding
        update_n_lines = "sn", -- Update `n_lines`

        suffix_last = "l", -- Suffix to search with "prev" method
        suffix_next = "n", -- Suffix to search with "next" method
      },
    },
  },

  -- Other
  {
    "willothy/flatten.nvim",
    config = true,
    -- TODO: find a way to load when launching LazyGit
    lazy = false,
    priority = 1001,
  },
}
