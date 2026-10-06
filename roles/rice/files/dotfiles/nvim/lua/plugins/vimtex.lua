return {
  "lervag/vimtex",
  ft = "tex",
  config = function()
    vim.g.vimtex_compiler_method = 'latexmk'
    vim.g.vimtex_compiler_latexmk = {
      options = {
        '-pdf',
        '-shell-escape',
        '-verbose',
        '-file-line-error',
        '-synctex=1',
        '-interaction=nonstopmode',
      },
    }

    vim.g.vimtex_view_method = 'zathura'

    -- Disable VimTeX's own indentation in favour of treesitter/default
    vim.g.vimtex_indent_enabled = 0

    -- Conceal settings for LaTeX math symbols
    vim.g.vimtex_syntax_conceal = {
      accents = 1,
      cites = 1,
      fancy = 1,
      greek = 1,
      math_bounds = 1,
      math_delimiters = 1,
      math_fracs = 1,
      math_super_sub = 1,
      math_symbols = 1,
      sections = 0,
      styles = 1,
    }

    -- Use treesitter for syntax highlighting, VimTeX only for its features
    vim.g.vimtex_syntax_enabled = 0

    -- Quickfix settings
    vim.g.vimtex_quickfix_mode = 0

    local wk = require("which-key")
    wk.add({
      { "<leader>L", group = "LaTeX" },
      { "<leader>Lc", "<cmd>VimtexCompile<cr>", desc = "Toggle continuous compilation" },
      { "<leader>Ls", "<cmd>VimtexCompileSS<cr>", desc = "Compile single-shot" },
      { "<leader>Lv", "<cmd>VimtexView<cr>", desc = "View PDF" },
      { "<leader>Le", "<cmd>VimtexErrors<cr>", desc = "Show errors" },
      { "<leader>Lt", "<cmd>VimtexTocToggle<cr>", desc = "Toggle table of contents" },
      { "<leader>Ll", "<cmd>VimtexLog<cr>", desc = "Show compiler log" },
      { "<leader>LC", "<cmd>VimtexClean<cr>", desc = "Clean auxiliary files" },
      { "<leader>Li", "<cmd>VimtexInfo<cr>", desc = "Show VimTeX info" },
    })
  end
}
