return {
  "RRethy/vim-illuminate",
  config = function()
          require("illuminate").configure({
              providers = {
                  "lsp",
                  "treesitter",
                  "regex",
              },
              delay = 200,
              filetypes_denylist = {
                  "DiffviewFiles",
                  "DressingInput",
                  "DressingSelect",
                  "Jaq",
                  "NeogitCommitMessage",
                  "NeogitStatus",
                  "NvimTree",
                  "Outline",
                  "TelescopePrompt",
                  "Trouble",
                  "alpha",
                  "dirvish",
                  "fugitive",
                  "harpoon",
                  "lazy",
                  "lir",
                  "minifiles",
                  "neogitstatus",
                  "netrw",
                  "packer",
                  "qf",
                  "spectre_panel",
                  "toggleterm",
              },
              filetypes_allowlist = {},
              modes_denylist = {},
              modes_allowlist = {},
              providers_regex_syntax_denylist = {},
              providers_regex_syntax_allowlist = {},
              under_cursor = true,
          })
  end
}
