return {
  -- Configure core
  {
    "LazyVim/LazyVim",
    ---@type LazyVimOptions
    opts = {
      colorscheme = "tokyonight-night",
      icons = {
        kinds = {
          Snippet = " ",
          Variable = "󰫧 ",
          Supermaven = " ",
        },
      },
      kind_filter = {
        lua = {
          "Class",
          "Constructor",
          "Enum",
          "Field",
          "Function",
          "Interface",
          "Method",
          "Module",
          "Namespace",
          "Object",
          -- "Package", -- remove package since luals uses it for control flow structures
          "Property",
          "Struct",
          "Trait",
        },
      },
    },
  },
}
