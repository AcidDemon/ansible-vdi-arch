return {
  "dhruvasagar/vim-table-mode",
  config = function()
          local table_mode_loaded = false
      local function load_table_mode()
        if table_mode_loaded then return end
        table_mode_loaded = true

        -- must precede packadd
        vim.g.table_mode_corner = '|'
        vim.g.table_mode_corner_corner = '|'
        vim.g.table_mode_header_fillchar = '-'
        vim.g.table_mode_auto_align = 1
        vim.g.table_mode_tableize_auto_border = 1
        vim.g.table_mode_map_prefix = '<Leader>T'
        vim.g.table_mode_syntax = 1
        vim.g.table_mode_delimiter = '|'

        vim.cmd("packadd vim-table-mode")
      end

      local wk = require "which-key"
      wk.add {
        { "<leader>T", group = "Table Mode" },
        { "<leader>Tt", function() load_table_mode(); vim.cmd("TableModeToggle") end, desc = "Toggle table mode" },
        { "<leader>Tr", function() load_table_mode(); vim.cmd("TableModeRealign") end, desc = "Realign table" },
        { "<leader>Td", function() load_table_mode(); vim.cmd("TableModeDeleteColumn") end, desc = "Delete column" },
        { "<leader>Ti", function() load_table_mode(); vim.cmd("TableModeInsertColumn") end, desc = "Insert column" },
      }
  end
}
