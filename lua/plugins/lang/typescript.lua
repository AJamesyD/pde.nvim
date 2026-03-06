return {
  -- Other
  {
    "jmbuhr/otter.nvim",
    optional = true,
    opts = {
      buffers = {
        preambles = {
          typescript = {
            "// @ts-nocheck",
            "/* eslint-disable */",
          },
        },
      },
    },
  },
}
