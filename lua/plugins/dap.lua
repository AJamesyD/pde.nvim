return {
  {
    "nvim-neotest/neotest",
    optional = true,
    opts = {
      adapters = {
        ["neotest-python"] = {
          runner = "pytest",
          dap = { justMyCode = false },
        },
      },
    },
  },
}
