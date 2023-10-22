return {
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewToggleFiles" },
  },
  {
    "f-person/git-blame.nvim",
    keys = {
      {
        "<leader>ug",
        "<CMD>GitBlameToggle<CR>",
        desc = "Toggle git blame",
      },
    },
    opts = {
      enabled = false,
    },
  },
}
