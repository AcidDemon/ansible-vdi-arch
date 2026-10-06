return {
  "catppuccin/nvim",
  config = function()
          require("catppuccin").setup({
              flavour = "mocha", -- latte, frappe, macchiato, mocha
              background = {
                  light = "latte",
                  dark = "mocha",
              },
              transparent_background = true,
              show_end_of_buffer = false,
              term_colors = false,
              compile = {
                  enabled = true,
                  path = vim.fn.stdpath("cache") .. "/catppuccin",
              },
              integrations = {
                  alpha = true,
                  cmp = true,
                  gitsigns = true,
                  harpoon = true,
                  mason = true,
                  nvimtree = true,
                  treesitter = true,
                  treesitter_context = true,
                  which_key = true,
                  telescope = {
                      enabled = true
                  },
                  illuminate = {
                      enabled = true,
                      scope_color = "blue",
                      lsp = false
                  },
                  -- Special
                  indent_blankline = {
                      enabled = true,
                      color_indent_levels = false,
                  },
                  dap = {
                      enabled = true,
                      enable_ui = true,
                  },
                  native_lsp = {
                      enabled = true,
                      virtual_text = {
                          errors = { "italic" },
                          hints = { "italic" },
                          warnings = { "italic" },
                          information = { "italic" },
                          ok = { "italic" },
                      },
                      underlines = {
                          errors = { "underline" },
                          hints = { "underline" },
                          warnings = { "underline" },
                          information = { "underline" },
                          ok = { "underline" },
                      },
                      inlay_hints = {
                          background = true,
                      },
                  },
              },
          })

          vim.cmd "colorscheme catppuccin-mocha"
  end
}
