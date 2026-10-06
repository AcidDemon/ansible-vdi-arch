return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  -- lazy runs non-":" strings as shell commands in the plugin dir; fetches the prebuilt binary (curl, tar)
  build = "cd app && ./install.sh",
  init = function()
    vim.g.mkdp_filetypes = { "markdown" }
  end,
  config = function()
    vim.g.mkdp_auto_start = 0
    vim.g.mkdp_auto_close = 0
    vim.g.mkdp_refresh_slow = 0
    vim.g.mkdp_command_for_global = 0
    vim.g.mkdp_open_to_the_world = 0
    vim.g.mkdp_open_ip = '127.0.0.1'
    vim.g.mkdp_port = '8765'
    vim.g.mkdp_browser = ""
    vim.g.mkdp_echo_preview_url = 1
    vim.g.mkdp_page_title = '${name}'
    vim.g.mkdp_theme = 'dark'
    vim.g.mkdp_preview_options = {
      mkit = {},
      katex = {},
      uml = {},
      maid = {},
      disable_sync_scroll = 0,
      sync_scroll_type = 'middle',
      hide_yaml_meta = 1,
      sequence_diagrams = {},
      flowchart_diagrams = {},
      content_editable = false,
      disable_filename = 0,
      toc = {}
    }
    vim.g.mkdp_markdown_css = ""
    vim.g.mkdp_highlight_css = ""

    local wk = require "which-key"
    wk.add {
      { "<leader>m", group = "Markdown Preview" },
      { "<leader>mp", "<cmd>MarkdownPreview<cr>", desc = "Start preview" },
      { "<leader>ms", "<cmd>MarkdownPreviewStop<cr>", desc = "Stop preview" },
      { "<leader>mt", "<cmd>MarkdownPreviewToggle<cr>", desc = "Toggle preview" },
    }
  end
}
