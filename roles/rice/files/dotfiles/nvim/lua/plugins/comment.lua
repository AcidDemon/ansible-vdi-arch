return {
  "numToStr/Comment.nvim",
  config = function()
          local wk = require "which-key"
          wk.add {
            { "<leader>c", "<Plug>(comment_toggle_linewise_current)", desc = "(Un)comment selection" },
            { "<leader>c", "<Plug>(comment_toggle_linewise_visual)", desc = "(Un)comment selection", mode = "v" },
          }

          require("Comment").setup({
              padding = true,
              sticky = true,
              ignore = nil,
              toggler = {
                  line = "gcc",
                  block = "gbc",
              },
              opleader = {
                  line = "gc",
                  block = "gb",
              },
              extra = {
                  above = "gcO",
                  below = "gco",
                  eol = "gcA",
              },
              mappings = {
                  basic = true,
                  extra = true,
              },
              pre_hook = function(...)
                  local loaded, ts_comment = pcall(
                      require,
                      "ts_context_commentstring.integrations.comment_nvim"
                  )
                  if loaded and ts_comment then
                      return ts_comment.create_pre_hook()(...)
                  end
              end,
              post_hook = nil,
          })
  end
}
