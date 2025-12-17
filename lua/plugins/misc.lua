return {
  {
    "kawre/leetcode.nvim",
    dependencies = {
      -- include a picker of your choice, see picker section for more details
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
    opts = {
      lang = "rust",
      injector = {
        ["rust"] = {
          before = { "#[allow(dead_code)]", "fn main(){}", "#[allow(dead_code)]", "struct Solution;" },
        }, ---@type table<lc.lang, lc.inject>
      },
      hooks = {
        ---@type fun(question: lc.ui.Question)[]
        ["question_enter"] = {
          function(question)
            if question.lang ~= "rust" then
              return
            end
            local problem_dir = vim.fn.stdpath("data") .. "/leetcode/Cargo.toml"
            local content = [[
                  [package]
                  name = "leetcode"
                  edition = "2021"

                  [lib]
                  name = "%s"
                  path = "%s"

                  [dependencies]
                  anyhow = "1.0"
                  chrono = "0.4"
                  itertools = "0.14.0"
                  rand = "0.9"
                  regex = "1"
                  serde = "1.0"
                  serde_json = "1.0"
                ]]
            local file = io.open(problem_dir, "w")
            if file then
              local formatted = (content:gsub(" +", "")):format(question.q.frontend_id, question:path())
              file:write(formatted)
              file:close()
            else
              print("Failed to open file: " .. problem_dir)
            end

            vim.cmd("RustAnalyzer restart")
          end,
        },
      },
    },
  },
}
