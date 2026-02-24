return {
  -- Other
  {
    "jmbuhr/otter.nvim",
    optional = true,
    opts = {
      buffers = {
        preambles = {
          typescript = {
            "export {};",
            "declare function fetch(input: RequestInfo, init?: RequestInit): Promise<Response>;",
            "declare const console: Console;",
            "declare const process: NodeJS.Process;",
          },
        },
      },
    },
  },
}

