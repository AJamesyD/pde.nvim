return {
  -- Other
  {
    "jmbuhr/otter.nvim",
    optional = true,
    opts = {
      buffers = {
        preambles = {
          typescript = {
            "/* eslint-disable */",
            "export {};",
            "declare const console: Console;",
            "declare const process: NodeJS.Process;",
            "declare const setTimeout: typeof globalThis.setTimeout;",
            "declare const fetch: typeof globalThis.fetch;",
            "declare const URL: typeof globalThis.URL;",
            "declare const Buffer: typeof globalThis.Buffer;",
          },
        },
      },
    },
  },
}
