return {
  "windwp/nvim-autopairs",
  config = function()
          require("nvim-autopairs").setup({
              check_ts = true, -- treesitter integration
              disable_filetype = { "TelescopePrompt", "spectre_panel" },
              disable_in_macro = false,
              disable_in_visualblock = false,
              enable_afterquote = true,
              enable_check_bracket_line = false,
              enable_moveright = true,
              ignored_next_char = string.gsub([[ [%w%%%'%[%"%.] ]], "%s+", ""),
              map_bs = true,
              map_c_w = false,
              map_char = {
                  all = "(",
                  tex = "{",
              },
              fast_wrap = {
                  map = "<M-e>",
                  chars = { "{", "[", "(", '"', "'" },
                  pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
                  offset = 0,
                  end_key = "$",
                  keys = "qwertyuiopzxcvbnmasdfghjkl",
                  check_comma = true,
                  highlight = "PmenuSel",
                  highlight_grey = "LineNr",
              },
              ts_config = {
                  lua = { "string", "source" },
                  javascript = { "string", "template_string" },
                  java = false,
              },
          })

          local cmp_autopairs = require("nvim-autopairs.completion.cmp")
          local cmp = require("cmp")

          cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done({}))
  end
}
