return {
  -- Reconfigure LazyVim defaults
  {
    "saghen/blink.cmp",
    optional = true,
    dependencies = {
      {
        "saghen/blink.compat",
        optional = false,
      },
      { "AJamesyD/blink-cmp-rust.nvim", dev = true, opts = {} },
    },
    ---@param opts blink.cmp.Config
    opts = function(_, opts)
      local ok, rust_cmp = pcall(require, "blink-cmp-rust")

      ---@type blink.cmp.Config
      ---@diagnostic disable-next-line: missing-fields
      local overrides = {
        -- experimental signature help support
        signature = {
          enabled = true,
        },

        completion = {
          keyword = { range = "full" },
        },

        sources = {
          -- adding any nvim-cmp sources here will enable them
          -- with blink.compat
          compat = {
            "avante_commands",
            "avante_mentions",
            "avante_files",
          },
          ---@diagnostic disable-next-line: redundant-parameter, unused-local
          default = function(ctx)
            local success, node = pcall(vim.treesitter.get_node)
            if success and node and vim.tbl_contains({ "comment", "line_comment", "block_comment" }, node:type()) then
              return { "buffer" }
            else
              return { "lsp", "path", "snippets" }
            end
          end,
          providers = {
            buffer = { min_keyword_length = 3 },
            path = { min_keyword_length = 0 },
          },
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

      -- Wire blink-cmp-rust if available
      if ok then
        local existing_transform = opts.sources
          and opts.sources.providers
          and opts.sources.providers.lsp
          and opts.sources.providers.lsp.transform_items

        overrides.sources.providers = vim.tbl_deep_extend("force", overrides.sources.providers, {
          lsp = {
            transform_items = function(ctx, items)
              if existing_transform then
                items = existing_transform(ctx, items)
              end
              return rust_cmp.transform_items(ctx, items)
            end,
          },
        })

        local default_sorts = opts.fuzzy and opts.fuzzy.sorts
        overrides.fuzzy = {
          ---@diagnostic disable-next-line: assign-type-mismatch
          sorts = function()
            local base = type(default_sorts) == "function" and default_sorts()
              or default_sorts
              or { "score", "sort_text" }
            if vim.bo.filetype == "rust" then
              return vim.list_extend({ rust_cmp.compare }, base)
            end
            return base
          end,
        }
      end

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
    -- TODO: find a way to only load when launching LazyGit
    enabled = false,
    lazy = false,
    config = true,
    priority = 1001,
  },
}
