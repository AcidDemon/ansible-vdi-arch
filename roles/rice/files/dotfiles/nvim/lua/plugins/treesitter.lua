return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    local ts = require("nvim-treesitter")

    local parsers = {
      "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline",
      "rust", "python", "javascript", "typescript", "tsx", "json", "yaml", "toml", "bash"
    }

    -- neorg parsers are not in the registry
    local parser_config = require("nvim-treesitter.parsers")
    parser_config.norg = {
      install_info = {
        url = "https://github.com/nvim-neorg/tree-sitter-norg",
        files = { "src/parser.c", "src/scanner.c" },
        branch = "main",
      },
    }
    parser_config.norg_meta = {
      install_info = {
        url = "https://github.com/nvim-neorg/tree-sitter-norg-meta",
        files = { "src/parser.c" },
        branch = "main",
      },
    }

    local installed = ts.get_installed()
    local to_install = vim.tbl_filter(function(lang)
      return not vim.tbl_contains(installed, lang)
    end, parsers)

    if #to_install > 0 then
      ts.install(to_install)
    end

    -- parser -> filetype
    local filetypes = {}
    for _, lang in ipairs(parsers) do
      local fts = vim.treesitter.language.get_filetypes(lang)
      for _, ft in ipairs(fts) do
        table.insert(filetypes, ft)
      end
    end
    -- Ensure norg filetype is explicitly registered
    table.insert(filetypes, "norg")

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("TreesitterSetup", { clear = true }),
      pattern = filetypes,
      callback = function(args)
        pcall(vim.treesitter.start, args.buf)
        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })

    vim.opt.foldmethod = "expr"
    vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.opt.foldlevel = 99 -- Start with all folds open
  end,
}
