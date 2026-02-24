return {
  -- Other
  {
    "jmbuhr/otter.nvim",
    optional = true,
    opts = {
      buffers = {
        preambles = {
          javascript = {
            "/* eslint-disable no-unused-vars */",
          },
        },
      },
    },
  },
}

