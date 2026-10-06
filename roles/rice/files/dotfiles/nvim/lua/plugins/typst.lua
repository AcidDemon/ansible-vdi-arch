return {
  "chomosuke/typst-preview.nvim",
  ft = "typst",
  config = function()
    require("typst-preview").setup({
      -- Use tinymist from PATH (provided by dev.typst module)
      dependencies_bin = {
        ["tinymist"] = "tinymist",
      },
    })

    vim.g.typst_preview_open_cmd = 'zathura %s'

    local wk = require("which-key")
    wk.add({
      { "<leader>T", group = "Typst" },
      { "<leader>Tp", "<cmd>TypstPreview<cr>", desc = "Start live preview" },
      { "<leader>Ts", "<cmd>TypstPreviewStop<cr>", desc = "Stop preview" },
      { "<leader>Tt", "<cmd>TypstPreviewToggle<cr>", desc = "Toggle preview" },
      { "<leader>Tu", "<cmd>TypstPreviewUpdate<cr>", desc = "Update preview" },
      { "<leader>Tf", "<cmd>TypstPreviewFollowCursor<cr>", desc = "Follow cursor" },
      { "<leader>TF", "<cmd>TypstPreviewNoFollowCursor<cr>", desc = "Stop following cursor" },
      { "<leader>Tc", "<cmd>TypstPreviewFollowCursorToggle<cr>", desc = "Toggle follow cursor" },
      { "<leader>TS", "<cmd>TypstPreviewSyncCursor<cr>", desc = "Sync cursor position" },
    })
  end
}
