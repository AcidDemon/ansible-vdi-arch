return {
  "lewis6991/gitsigns.nvim",
  config = function()
          local wk = require "which-key"
          wk.add {
            { "<leader>g", group = "git" },
            { "<leader>gp", "<cmd>lua require'gitsigns'.preview_hunk_inline()<cr>", desc = "Preview hunk inline" },
            { "<leader>gP", "<cmd>lua require'gitsigns'.preview_hunk()<cr>", desc = "Preview hunk" },
            { "<leader>gb", "<cmd>lua require'gitsigns'.blame_line()<cr>", desc = "Blame line" },
            { "<leader>gB", "<cmd>lua require'gitsigns'.toggle_current_line_blame()<cr>", desc = "Toggle line blame" },
          }

          require("gitsigns").setup({
              signs = {
                  add = { text = "▎ " },
                  change = { text = "▎ " },
                  delete = { text = " " },
                  topdelete = { text = " " },
                  changedelete = { text = "▎ " },
              },
              watch_gitdir = {
                  interval = 1000,
                  follow_files = true,
              },
              attach_to_untracked = true,
              current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
              update_debounce = 200,
              max_file_length = 40000,
              preview_config = {
                  border = "rounded", -- single
                  style = "minimal",
                  relative = "cursor",
                  row = 0,
                  col = 1,
              },
          })
  end
}
