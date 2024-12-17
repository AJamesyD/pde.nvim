return {
  -- Reconfigure LazyVim defaults
  {
    "saghen/blink.cmp",
    optional = true,
    dependencies = {
      { "jmbuhr/otter.nvim" },
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
          compat = { "otter" },
          default = { "lsp", "path", "snippets" },
        },

        keymap = {
          preset = "enter",
          ["<S-Tab>"] = { "select_prev", "fallback" },
          ["<Tab>"] = { "select_next", "fallback" },
        },
      }

      opts = vim.tbl_deep_extend("force", opts, overrides)
      return opts
    end,
  },
  {
    -- NOTE: Overrides nvim-cmp with magazine
    "iguanacucumber/magazine.nvim",
    name = "nvim-cmp", -- Otherwise highlighting gets messed up
    optional = true,
    dependencies = {
      --* the sources *--
      { "iguanacucumber/mag-nvim-lsp", name = "cmp-nvim-lsp", opts = {} },
      { "iguanacucumber/mag-nvim-lua", name = "cmp-nvim-lua" },
      { "iguanacucumber/mag-buffer", name = "cmp-buffer" },
      { "iguanacucumber/mag-cmdline", name = "cmp-cmdline" },
    },
  },
  {
    "nvim-cmp",
    optional = true,
    dependencies = {
      { "https://codeberg.org/FelipeLema/cmp-async-path" },
      { "f3fora/cmp-spell" },
      { "ryo33/nvim-cmp-rust" },
      { "zjp-CN/nvim-cmp-lsp-rs" },
      { "jmbuhr/otter.nvim" },
      { "hrsh7th/cmp-path", enabled = false },
    },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local cmp = require("cmp")
      local types = require("cmp.types")

      ---@param kind lsp.CompletionItemKind: kind of completion entry
      local deprioritize = function(kind)
        ---@type cmp.ComparatorFunction
        return function(entry1, entry2)
          if entry1:get_kind() == kind then
            return false
          elseif entry2:get_kind() == kind then
            return true
          end
        end
      end

      ---compare_under: deprioritize functions/methods that have leading underscores
      ---@type cmp.ComparatorFunction
      local compare_under = function(entry1, entry2)
        local _, entry1_under = entry1.completion_item.label:find("^_+")
        local _, entry2_under = entry2.completion_item.label:find("^_+")
        entry1_under = entry1_under or 0
        entry2_under = entry2_under or 0
        if entry1_under > entry2_under then
          return false
        elseif entry1_under < entry2_under then
          return true
        end
      end

      ---@param fun cmp.ComparatorFunction
      ---@return cmp.ComparatorFunction
      local reverse_compare = function(fun)
        ---@type cmp.ComparatorFunction
        local nested_func = function(entry1, entry2)
          return fun(entry2, entry1)
        end
        return nested_func
      end

      ---recently_used: Entries that are used recently will be ranked higher.
      ---We bucket times in order to ensure fallback to other comparators
      ---@type cmp.ComparatorFunctor
      local recently_used = setmetatable({
        records = {},
        add_entry = function(self, e)
          local bucket_size_millis = 1000 * 60 * 5 -- 5 minutes
          self.records[e.completion_item.label] = math.floor(vim.uv.now() / bucket_size_millis)
        end,
      }, {
        ---@type fun(self: table, entry1: cmp.Entry, entry2: cmp.Entry): boolean|nil
        __call = function(self, entry1, entry2)
          local t1 = self.records[entry1.completion_item.label] or -1
          local t2 = self.records[entry2.completion_item.label] or -1
          if t1 ~= t2 then
            return t1 > t2
          end
        end,
      })

      ---@type cmp.SourceConfig[]
      local sources_overrides = cmp.config.sources({
        -- group_index = 1
        { name = "lazydev" },
        { name = "nvim_lsp" },
        { name = "otter" },
        { name = "async_path" },
        {
          name = "spell",
          option = {
            keep_all_entries = false,
            enable_in_context = function()
              return require("cmp.config.context").in_treesitter_capture("spell")
            end,
            preselect_correct_word = true,
          },
        },
        { name = "snippets" },
      }, {
        -- group_index = 2
        {
          name = "spell",
          option = {
            keep_all_entries = false,
            enable_in_context = function()
              return require("cmp.config.context").in_treesitter_capture("spell")
            end,
            preselect_correct_word = true,
          },
        },
        { name = "buffer", keyword_length = 5 },
        { name = "async_path" },
      })
      ---@param source cmp.SourceConfig
      for _, source in ipairs(opts.sources or {}) do
        if not vim.tbl_contains({ "snippets", "nvim_lsp", "buffer", "path" }, source.name) then
          table.insert(sources_overrides, source)
        end
      end

      local compare = require("cmp.config.compare")
      local cmp_rs = require("cmp-rust")
      local cmp_lsp_rs = require("cmp_lsp_rs")
      local rs_comparators = cmp_lsp_rs.comparators
      local comparators_overrides = {
        --- Default ---
        -- compare.offset,
        -- compare.exact,
        -- -- compare.scopes,
        -- compare.score,
        -- compare.recently_used,
        -- compare.locality,
        -- compare.kind,
        -- -- compare.sort_text,
        -- compare.length,
        -- compare.order,

        --- My Overrides ---
        compare.exact,
        compare.score,
        -- deprioritize `.box`, `.mut`, etc.
        cmp_rs.deprioritize_postfix,
        -- deprioritize `Borrow::borrow` and `BorrowMut::borrow_mut`
        cmp_rs.deprioritize_borrow,
        -- deprioritize `Deref::deref` and `DerefMut::deref_mut`
        cmp_rs.deprioritize_deref,
        -- deprioritize `Into::into`, `Clone::clone`, etc.
        cmp_rs.deprioritize_common_traits,
        -- XXX: For some reason the inherent/trait methods are show up backwards?
        -- TODO: Fork and fix
        reverse_compare(rs_comparators.inherent_import_inscope),
        compare_under,
        recently_used,
        deprioritize(types.lsp.CompletionItemKind.Text),
        deprioritize(types.lsp.CompletionItemKind.Snippet),
        compare.locality,
      }

      for _, source in ipairs(sources_overrides) do
        cmp_lsp_rs.filter_out.entry_filter(source)
      end

      local prev_format = opts.formatting.format or function(_, v)
        return v
      end

      ---@type cmp.ConfigSchema
      local overrides = {
        ---@diagnostic disable-next-line: missing-fields
        formatting = {
          format = function(entry, vim_item)
            local item = prev_format(entry, vim_item)
            -- Allow a few sources to create entries no matter what
            item.dup = ({
              crates = 1,
              nvim_lsp = 1,
            })[entry.source.name] or nil
            return item
          end,
        },
        ---@diagnostic disable-next-line: missing-fields
        performance = {
          debounce = 40, -- default: 60
          throttle = 30, -- default: 30
          fetching_timeout = 500, -- default: 500
          max_view_entries = 100, -- default: 200
        },
        ---@diagnostic disable-next-line: missing-fields
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
      }

      -- TODO: See if there is a way to parameterize array merge behavior in vim.tbl_deep_extend
      opts.sources = sources_overrides

      opts.sorting = opts.sorting or {}
      opts.sorting.comparators = comparators_overrides

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
        { path = "edgy.nvim", words = { "edgy" } },
        { path = "grapple.nvim", words = { "grapple" } },
        { path = "mason.nvim", words = { "mason" } },
        { path = "nvim-cmp-lsp-rs", words = { "rust" } },
        { path = "nvim-treesitter", words = { "TS", "treesitter" } },
        { path = "overseer.nvim", words = { "overseer" } },
        { path = "rustaceanvim", words = { "rust" } },
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
    "echasnovski/mini.surround",
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
