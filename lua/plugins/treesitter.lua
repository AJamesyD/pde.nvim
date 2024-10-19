return {
  {
    "nvim-treesitter/nvim-treesitter",
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
            },
          },
          move = {
            enable = true,
            set_jumps = true,
          },
          swap = {
            enable = true,
            swap_next = {
              [">f"] = { query = "@function.outer", desc = "Swap next function" },
              [">a"] = { query = "@parameter.inner", desc = "Swap next argument" },
            },
            swap_previous = {
              ["<f"] = { query = "@function.outer", desc = "Swap previous function" },
              ["<a"] = { query = "@parameter.inner", desc = "Swap previous argument" },
            },
          },
        },
      }

      opts = vim.tbl_deep_extend("force", opts, overrides)
      local ensure_installed = {
        "comment",
        "ini",
        "kdl",
        "tmux",
      }
      opts.ensure_installed = vim.list_extend(opts.ensure_installed or {}, ensure_installed)
      return opts
    end,
  },
  {
    "m-demare/hlargs.nvim",
    config = true,
  },
}
