require("util").map_toggle("<leader>c<leader>", {
  name = "Codeium",
  get = function()
    return vim.g.codeium_enabled
  end,
  set = function(state)
    if state then
      vim.g.codeium_enabled = true
    else
      vim.g.codeium_enabled = false
    end
  end,
})

return {
  {
    "folke/lazydev.nvim",
    opts = {
      library = {
        { path = "lazy.nvim" },
        { path = "LazyVim" },

        { path = "edgy.nvim", words = { "edgy" } },
        { path = "grapple.nvim", words = { "grapple" } },
        { path = "mason.nvim", words = { "mason" } },
        { path = "nvim-cmp-lsp-rs", words = { "rust" } },
        { path = "nvim-treesitter", words = { "TS", "treesitter" } },
        { path = "rustaceanvim", words = { "rust" } },
        { path = "telescope.nvim", words = { "telescope" } },
        { path = "tokyonight.nvim", words = { "tokyonight" } },
        { path = "which-key.nvim", words = { "wk", "which-key" } },
      },
    },
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      { "https://codeberg.org/FelipeLema/cmp-async-path" },
      { "f3fora/cmp-spell" },
      { "hrsh7th/cmp-path", enabled = false },
    },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local cmp = require("cmp")
      local types = require("cmp.types")

      ---@type cmp.ComparatorFunction
      local function compare_snippets(entry1, entry2)
        local entry1_is_snippet = entry1:get_kind() == types.lsp.CompletionItemKind.Snippet
        local entry2_is_snippet = entry2:get_kind() == types.lsp.CompletionItemKind.Snippet
        if not entry1_is_snippet or not entry2_is_snippet then
          return nil
        end

        local entry1_source = entry1.source.name
        local entry2_source = entry2.source.name
        if entry1_source == entry2_source then
          return nil
        else
          return entry1_source == "nvim_lsp"
        end
      end

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

      ---@type table<integer, integer>
      local modified_kind_priority = {
        [types.lsp.CompletionItemKind.EnumMember] = 0, -- top
        [types.lsp.CompletionItemKind.Keyword] = types.lsp.CompletionItemKind.Method, -- Method=2
        [types.lsp.CompletionItemKind.Variable] = types.lsp.CompletionItemKind.Method, -- Method=2
      }
      ---@param kind integer: kind of completion entry
      local function modified_kind(kind)
        return modified_kind_priority[kind] or kind
      end
      ---kind: Entires with smaller ordinal value of 'kind' will be ranked higher.
      ---(see lsp.CompletionItemKind enum).
      ---Exceptions are that Text(1) will be ranked the lowest, and snippets be the highest.
      ---@type cmp.ComparatorFunction
      local compare_kind = function(entry1, entry2)
        local kind1 = modified_kind(entry1:get_kind())
        local kind2 = modified_kind(entry2:get_kind())
        if kind1 ~= kind2 then
          return kind1 - kind2 < 0
        end
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
      local sources = cmp.config.sources({
        -- group_index = 1
        { name = "nvim_lsp" },
        { name = "snippets", keyword_length = 2 },
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
          table.insert(sources, source)
        end
      end

      local compare = require("cmp.config.compare")
      local comparators = {
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
        compare.offset,
        -- Magic number line for plugins/lang/rust.lua
        compare_snippets,
        compare.exact,
        compare.score,
        compare_under,
        deprioritize(types.lsp.CompletionItemKind.Text),
        recently_used,
        compare.locality,
        compare_kind,
        compare.scopes,
        compare.sort_text,
        compare.length,
        compare.order,
      }

      local prev_format = opts.formatting.format

      local overrides = {
        formatting = {
          ---@param entry cmp.Entry
          ---@param vim_item vim.CompletedItem
          format = function(entry, vim_item)
            local item = prev_format(entry, vim_item)
            -- Allow a few sources to create entries no matter what
            item.dup = ({
              crates = 1,
              nvim_lsp = 1,
              snippets = 1,
            })[entry.source.name] or nil
            return item
          end,
        },
        performance = {
          debounce = 40, -- default: 60
          trottle = 30, -- default: 30
          fetching_timeout = 300, -- default: 500
          max_view_entries = 50, -- default: 200
        },
        sources = sources,
        sorting = {
          comparators = comparators,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
      }

      opts = vim.tbl_deep_extend("force", overrides, opts)
      return opts
    end,
  },
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
  {
    "willothy/flatten.nvim",
    config = true,
    -- TODO: find a way to load when launching LazyGit
    lazy = false,
    priority = 1001,
  },
  {
    "Exafunction/codeium.nvim",
    cmd = "Codeium",
    build = ":Codeium Auth",
    opts = {},
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "Exafunction/codeium.nvim" },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      table.insert(opts.sources, 1, {
        name = "codeium",
        group_index = 1,
        priority = 100,
        max_item_count = 10,
        entry_filter = function(_, _)
          return vim.g.codeium_enabled
        end,
      })
    end,
  },
}
