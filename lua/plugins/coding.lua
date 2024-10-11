return {
  {
    "folke/lazydev.nvim",
    opts = {
      library = {
        { path = "edgy.nvim", words = { "edgy" } },
        { path = "nvim-cmp-lsp-rs", words = { "rust" } },
        { path = "mason.nvim", words = { "mason" } },
        { path = "rustaceanvim", words = { "rust" } },
        { path = "tokyonight.nvim", words = { "tokyonight" } },
      },
    },
  },
  {
    "hrsh7th/nvim-cmp",
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local cmp = require("cmp")

      ---@type cmp.SourceConfig[]
      local sources = cmp.config.sources({
        -- group_index = 1
        { name = "snippets" }, -- Source first for dedup
        { name = "nvim_lsp", keyword_length = 1 },
        { name = "path" },
      }, {
        -- group_index = 2
        { name = "buffer", keyword_length = 5 },
        { name = "path" },
      })
      ---@param source cmp.SourceConfig
      for _, source in ipairs(opts.sources or {}) do
        if not vim.tbl_contains({ "snippets", "nvim_lsp", "buffer", "path" }, source.name) then
          table.insert(sources, source)
        end
      end

      ---@type table<integer, integer>
      local modified_offset_priority = {
        snippets = 1,
        nvim_lsp = 1,
      }
      ---@param offset integer: kind of completion entry
      local function modified_offset(offset)
        return modified_offset_priority[offset] or offset
      end
      ---@type cmp.ComparatorFunction
      local compare_offset = function(entry1, entry2)
        local offset1 = modified_offset(entry1:get_offset())
        local offset2 = modified_offset(entry2:get_offset())
        if offset1 ~= offset2 then
          return offset1 - offset2 < 0
        end
      end

      ---@param kind integer: kind of completion entry
      local deprio = function(kind)
        ---@type cmp.ComparatorFunction
        return function(entry1, entry2)
          if entry1:get_kind() == kind then
            return false
          elseif entry2:get_kind() == kind then
            return true
          end
        end
      end

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

      local types = require("cmp.types")
      ---@type table<integer, integer>
      local modified_kind_priority = {
        [types.lsp.CompletionItemKind.Variable] = types.lsp.CompletionItemKind.Method, -- Method=2
        [types.lsp.CompletionItemKind.Keyword] = 0, -- top
        [types.lsp.CompletionItemKind.Snippet] = 0, -- top
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
          local bucket_size_millis = 1000 * 60 * 60 -- 1 hr
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
        compare.exact,
        compare.score,
        compare_offset,
        compare_under,
        -- Magic number line for plugins/lang/rust.lua
        deprio(types.lsp.CompletionItemKind.Text),
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
        completion = {
          keyword_length = 2, -- default: 1
        },
        formatting = {
          ---@param entry cmp.Entry
          ---@param vim_item vim.CompletedItem
          format = function(entry, vim_item)
            local item = prev_format(entry, vim_item)
            -- Allow a few sources to create entries no matter what
            -- NOTE: Expecting preference for snippets over lsp provided snippets
            item.dup = ({
              crates = 1,
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

      opts = vim.tbl_deep_extend("force", opts, overrides)
      return opts
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      {
        "Exafunction/codeium.nvim",
        cmd = "Codeium",
        build = ":Codeium Auth",
        opts = {},
        keys = {
          {
            "<leader>c<leader>",
            function()
              vim.g.codeium_enabled = not vim.g.codeium_enabled
            end,
            desc = "Toggle Codeium",
          },
        },
      },
    },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      table.insert(opts.sources, 1, {
        name = "codeium",
        group_index = 1,
        priority = 100,
        max_item_count = 5,
        entry_filter = function(_, _)
          return vim.g.codeium_enabled
        end,
      })
    end,
  },
  {
    "supermaven-inc/supermaven-nvim",
    enabled = false,
    build = ":SupermavenUseFree",
    keys = {
      {
        "<leader>c<CR>",
        "<cmd>SupermavenToggle<CR>",
        desc = "Toggle Supermaven",
      },
    },
    opts = {
      keymaps = {
        accept_suggestion = "<C-S-y>",
        clear_suggestion = "<C-n>",
        accept_word = "<C-y>",
      },
    },
  },
  {
    "jackMort/ChatGPT.nvim",
    enabled = false,
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "folke/trouble.nvim",
      "nvim-telescope/telescope.nvim",
    },
    opts = {
      openai_params = {
        model = "gpt-4-turbo-preview",
      },
      openai_edit_params = {
        model = "gpt-4-turbo-preview",
      },
    },
    config = true,
  },
}
