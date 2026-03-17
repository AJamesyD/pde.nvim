return {
  {
    "nvim-neotest/neotest",
    optional = true,
    opts = {
      discovery = {
        filter_dir = function(name)
          local skip = { target = true, node_modules = true, [".venv"] = true, [".git"] = true, __pycache__ = true }
          return not skip[name]
        end,
      },
      adapters = {
        ["neotest-python"] = {
          runner = "pytest",
          dap = { justMyCode = false },
        },
      },
    },
  },
}
