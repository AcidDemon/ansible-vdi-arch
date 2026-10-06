return {
  "nvim-neorg/neorg",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-neorg/neorg-telescope",
    "nvim-neorocks/lua-utils.nvim",
    "pamiors/pathlib.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  ft = "norg",
  config = function()
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "norg",
      callback = function(ev)
        vim.treesitter.start()
        vim.opt_local.conceallevel = 2

        -- Buffer-local <CR> to follow links (overrides global clear-search mapping)
        vim.keymap.set("n", "<CR>", "<Plug>(neorg.esupports.hop.hop-link)", {
          buffer = ev.buf,
          desc = "Follow Neorg link",
        })
      end,
    })

    require("neorg").setup({
      load = {
        ["core.defaults"] = {},
        ["core.concealer"] = {},
        ["core.dirman"] = {
          config = {
            workspaces = {
              notes = vim.fn.expand("~/Documents/Neorg"),
              nix   = vim.fn.expand("~/Documents/Neorg/nix"),
            },
            default_workspace = "notes",
          },
        },
        ["core.completion"] = {
          config = {
            engine = "nvim-cmp",
          },
        },
        ["core.journal"] = {
          config = {
            strategy = "flat",
            workspace = "notes",
          },
        },
        ["core.export"] = {},
        ["core.export.markdown"] = {},
        ["core.summary"] = {},
        ["core.integrations.telescope"] = {},
      },
    })

    local wk = require "which-key"
    wk.add {
      { "<leader>n", group = "Neorg" },
      { "<leader>nn", "<cmd>Neorg index<cr>", desc = "Open workspace index" },
      { "<leader>nw", "<cmd>Neorg workspace<cr>", desc = "Switch workspace" },
      { "<leader>nr", "<cmd>Neorg return<cr>", desc = "Close and return" },
      { "<leader>nj", "<cmd>Neorg journal today<cr>", desc = "Journal today" },
      { "<leader>ny", "<cmd>Neorg journal yesterday<cr>", desc = "Journal yesterday" },
      { "<leader>nt", "<cmd>Neorg journal tomorrow<cr>", desc = "Journal tomorrow" },
      { "<leader>ns", function() require("telescope").extensions.neorg.find_norg_files() end, desc = "Find norg files" },
      { "<leader>nh", function() require("telescope").extensions.neorg.search_headings() end, desc = "Search headings" },
      { "<leader>nl", function() require("telescope").extensions.neorg.find_linkable() end, desc = "Find linkable" },
      { "<leader>ne", "<cmd>Neorg export to-file<cr>", desc = "Export current file" },
    }
  end
}
