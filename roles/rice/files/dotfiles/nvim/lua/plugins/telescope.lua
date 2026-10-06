return {
  "nvim-telescope/telescope.nvim",
  config = function()
          local wk = require "which-key"
          wk.add {
            { "<leader>'", "<cmd>Telescope resume<cr>", desc = "Open last fuzzy picker" },
            { "<leader>/", "<cmd>Telescope live_grep<cr>", desc = "Open global search" },
            { "<leader>b", "<cmd>Telescope buffers previewer=false<cr>", desc = "Open buffer picker" },
            { "<leader>d", "<cmd>lua require('telescope.builtin').diagnostics({ bufnr = 0 })<cr>", desc = "Open document diagnostics picker" },
            { "<leader>D", "<cmd>Telescope diagnostics<cr>", desc = "Open workspace diagnostics picker" },
            { "<leader>f", "<cmd>Telescope find_files<cr>", desc = "Open workspace file picker" },
            { "<leader>F", "<cmd>lua require('telescope.builtin').find_files({ cwd = vim.fn.expand('%:p:h') })<cr>", desc = "Open current working directory file picker" },
            { "<leader>j", "<cmd>Telescope jumplist<cr>", desc = "Open jumplist picker" },
            { "<leader>p", "<cmd>lua require('telescope').extensions.projects.projects()<cr>", desc = "Open projects picker" },
            { "<leader>s", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Open document symbol picker" },
            { "<leader>S", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", desc = "Open workspace symbol picker" },
            { "gd", "<cmd>Telescope lsp_definitions<cr>", desc = "Go to definition" },
            { "gi", "<cmd>Telescope lsp_implementations<cr>", desc = "Go to implementation" },
            { "gr", "<cmd>Telescope lsp_references<cr>", desc = "Open symbol references picker" },
          }

          local actions = require("telescope.actions")

          require("telescope").setup({
            defaults = {
              prompt_prefix = " ",
              selection_caret = " ",
              entry_prefix = "   ",
              initial_mode = "insert",
              selection_strategy = "reset",
              path_display = { "smart" },
              color_devicons = true,
              set_env = { ["COLORTERM"] = "truecolor" },
              sorting_strategy = nil,
              layout_strategy = nil,
              layout_config = {},
              file_ignore_patterns = { ".git/", "node_modules" },
              vimgrep_arguments = {
                "rg",
                "--color=never",
                "--no-heading",
                "--with-filename",
                "--line-number",
                "--column",
                "--smart-case",
                "--hidden",
                "--glob=!.git/",
              },

              mappings = {
                i = {
                  ["<C-n>"] = actions.cycle_history_next,
                  ["<C-p>"] = actions.cycle_history_prev,

                  ["<C-j>"] = actions.move_selection_next,
                  ["<C-k>"] = actions.move_selection_previous,
                },
                n = {
                  ["<esc>"] = actions.close,
                  ["j"] = actions.move_selection_next,
                  ["k"] = actions.move_selection_previous,
                  ["q"] = actions.close,
                },
              },
            },

            pickers = {
              live_grep = {
                theme = "dropdown",
              },

              grep_string = {
                theme = "dropdown",
              },

              find_files = {
                previewer = false,
                layout_strategy = "center",
                layout_config = { height = 0.50 },
                  prompt_position = "top",
                  theme = "dropdown",
              },

              buffers = {
                theme = "dropdown",
                previewer = false,
                initial_mode = "normal",
                mappings = {
                   i = {
                     ["<C-d>"] = actions.delete_buffer,
                   },
                   n = {
                     ["dd"] = actions.delete_buffer,
                   },
                },
              },

              planets = {
                show_pluto = true,
                show_moon = true,
              },

              colorscheme = {
                enable_preview = true,
              },

              lsp_references = {
                theme = "dropdown",
                initial_mode = "normal",
              },

              lsp_definitions = {
                theme = "dropdown",
                initial_mode = "normal",
              },

              lsp_declarations = {
                theme = "dropdown",
                initial_mode = "normal",
              },

              lsp_implementations = {
                theme = "dropdown",
                initial_mode = "normal",
              },
            },
          })
  end
}
