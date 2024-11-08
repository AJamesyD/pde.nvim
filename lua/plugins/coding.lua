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

        { path = "avante.nvim", words = { "avante" } },
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
      { "zjp-CN/nvim-cmp-lsp-rs" },
      { "ryo33/nvim-cmp-rust" },
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

      ---@type table<integer, integer>
      local modified_kind_priority = {
        [types.lsp.CompletionItemKind.EnumMember] = 0,
        [types.lsp.CompletionItemKind.Variable] = 0,
        [types.lsp.CompletionItemKind.Value] = 0,

        [types.lsp.CompletionItemKind.Field] = 1,
        [types.lsp.CompletionItemKind.Property] = 1,

        [types.lsp.CompletionItemKind.Method] = 2,

        [types.lsp.CompletionItemKind.Module] = 3,
        [types.lsp.CompletionItemKind.Function] = 3,
        [types.lsp.CompletionItemKind.Text] = 99,
      }
      ---@param kind integer: kind of completion entry
      local function modified_kind(kind)
        return modified_kind_priority[kind] or kind
      end
      ---kind: Entires with smaller ordinal value of 'kind' will be ranked higher.
      ---(see lsp.CompletionItemKind enum).
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

      local compare_sort_text = function(entry1, entry2) -- score by lsp, if available
        local t1 = entry1.completion_item.sortText
        local t2 = entry2.completion_item.sortText
        if t1 ~= nil and t2 ~= nil and t1 ~= t2 then
          return t1 < t2
        end
      end

      ---@type cmp.SourceConfig[]
      local sources_overrides = cmp.config.sources({
        -- group_index = 1
        { name = "nvim_lsp" },
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
        -- XXX: Lots of duplicated code between deprioritize, compare_kind, cmp_lsp_rs, ...
        compare.exact,
        compare.score,
        deprioritize(types.lsp.CompletionItemKind.Text),
        -- deprioritize `.box`, `.mut`, etc.
        cmp_rs.deprioritize_postfix,
        -- deprioritize `Borrow::borrow` and `BorrowMut::borrow_mut`
        cmp_rs.deprioritize_borrow,
        -- deprioritize `Deref::deref` and `DerefMut::deref_mut`
        cmp_rs.deprioritize_deref,
        rs_comparators.inherent_import_inscope,
        -- deprioritize `Into::into`, `Clone::clone`, etc.
        cmp_rs.deprioritize_common_traits,
        deprioritize(types.lsp.CompletionItemKind.Snippet),
        compare_under,
        recently_used,
        compare.locality,
        -- compare_kind, -- Redundant w/ cmp_lsp_rs?
        -- compare_sort_text, -- Perf?
        compare.length,
        compare.order,
      }

      for _, source in ipairs(sources_overrides) do
        cmp_lsp_rs.filter_out.entry_filter(source)
      end

      local prev_format = opts.formatting.format or function(_, v)
        return v
      end

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
            })[entry.source.name] or nil
            return item
          end,
        },
        performance = {
          debounce = 40, -- default: 60
          throttle = 30, -- default: 30
          fetching_timeout = 300, -- default: 500
          max_view_entries = 75, -- default: 200
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
      }

      -- TODO: See if there is a way to parameterize array merge behavior in vim.tbl_deep_extend
      opts.sources = sources_overrides

      opts.sorting = opts.sorting or {}
      opts.sorting.comparators = comparators_overrides

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
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    version = false, -- set this if you want to always pull the latest change
    opts = {
      provider = "openai",
      ---@type AvanteSupportedProvider
      openai = {
        endpoint = "https://api.openai.com/v1",
        -- TODO: Make toggle-able
        model = "gpt-4o-mini",
        timeout = 30000, -- Timeout in milliseconds
        temperature = 0,
        max_tokens = 4096,
        ["local"] = false,
      },
      behavior = {
        -- auto_set_keymaps = false,
        history = {
          max_tokens = 4096,
        },
      },
      history = {
        max_tokens = 8192,
      },
      windows = {
        -- For use with edgy.nvim
        width = 100,
        height = 100,
        input = {
          -- For use with edgy.nvim
          height = 100,
        },
      },
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      -- "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      -- "zbirenbaum/copilot.lua", -- for providers='copilot'
      {
        -- Make sure to set this up properly if you have lazy=true
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  },
  {
    "folke/edgy.nvim",
    optional = true,
    opts = function(_, opts)
      -- Will get swapped to right by other edgy conf
      ---@type Edgy.View.Opts[]
      local left_overrides = {
        {
          title = "Avante",
          ft = "Avante",
          size = {
            width = MyUtils.min_sidebar_size(40, vim.o.columns, 0.20),
          },
        },
        {
          title = "Avante Input",
          ft = "AvanteInput",
          size = {
            height = MyUtils.min_sidebar_size(10, vim.o.lines, 0.10),
          },
        },
      }

      opts.left = opts.left or {}
      opts.left = vim.list_extend(left_overrides, opts.left or {})
      return opts
    end,
  },
}
