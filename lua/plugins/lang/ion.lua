vim.api.nvim_create_autocmd("FileType", {
  pattern = "ion",
  callback = function(ev)
    vim.bo[ev.buf].syntax = "ON"
  end,
})

return {}
