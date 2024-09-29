return {
  {
    "nvim-treesitter/nvim-treesitter",
    ---@type TSConfig
    ---@diagnostic disable-next-line: missing-fields
    opts = {
      ensure_installed = {
        "ini",
        "kdl",
        "tmux",
      },
      auto_install = true,
      highlight = {
        enable = true,
        disable = function(_, bufnr)
          return vim.api.nvim_buf_line_count(bufnr) > 10000
        end,
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
    },
  },
  {
    "m-demare/hlargs.nvim",
    config = true,
  },
}
