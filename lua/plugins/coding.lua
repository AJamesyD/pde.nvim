return {
  {
    "folke/lazydev.nvim",
    opts = {
      library = {
        { path = "edgy.nvim", words = { "edgy" } },
        { path = "mason.nvim", words = { "mason" } },
        { path = "tokyonight.nvim", words = { "tokyonight" } },
      },
    },
  },
  {
    "hrsh7th/nvim-cmp",
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local cmp = require("cmp")

      ---@param kind integer: kind of completion entry
      local function deprio(kind)
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
      local modified_priority = {
        [types.lsp.CompletionItemKind.Variable] = 1, -- high
        [types.lsp.CompletionItemKind.Keyword] = 0, -- top
        [types.lsp.CompletionItemKind.Snippet] = 0, -- top
        [types.lsp.CompletionItemKind.Text] = 100, -- bottom
      }
      ---@param kind integer: kind of completion entry
      local function modified_kind(kind)
        return modified_priority[kind] or kind
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
        deprio(types.lsp.CompletionItemKind.Text),
        compare.offset,
        compare.exact,
        compare.score,
        compare_under,
        recently_used,
        compare.locality,
        compare_kind,
        compare.scopes,
        compare.sort_text,
        compare.length,
        compare.order,
      }

      local overrides = {
        completion = {
          keyword_length = 2, -- default: 1
        },
        performance = {
          debounce = 40, -- default: 60
          trottle = 30, -- default: 30
          fetching_timeout = 250, -- default: 500
          max_view_entries = 50, -- default: 200
        },
        sources = cmp.config.sources({
          { name = "nvim_lsp", keyword_length = 1 },
          { name = "path" },
        }, {
          { name = "buffer", keyword_length = 5 },
          { name = "path" },
        }),
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
