return {
  {
    "hrsh7th/nvim-cmp",
    optional = true,
    dependencies = { "codeium.nvim" },
    opts = function(_, opts)
      table.insert(opts.sources, 1, {
        name = "codeium",
        group_index = 1,
        priority = 100,
        entry_filter = function(_, _)
          return vim.g.codeium_enabled
        end,
      })
      return opts
    end,
  },
  {
    "Exafunction/codeium.nvim",
    optional = true,
    cmd = "Codeium",
    build = ":Codeium Auth",
    opts = function(_, opts)
      require("snacks")
        .toggle({
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
        :map("<leader>ac")

      LazyVim.cmp.actions.ai_accept = function()
        if require("codeium.virtual_text").get_current_completion_item() then
          LazyVim.create_undo()
          vim.api.nvim_input(require("codeium.virtual_text").accept())
          return true
        end
      end

      local overrides = {
        enable_cmp_source = vim.g.ai_cmp,
        virtual_text = {
          enabled = not vim.g.ai_cmp,
          key_bindings = {
            accept = false, -- handled by nvim-cmp / blink.cmp
            next = "<M-]>",
            prev = "<M-[>",
          },
        },
      }

      opts = vim.tbl_deep_extend("force", opts, overrides)
      return opts
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
