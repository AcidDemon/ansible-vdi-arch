return {
  {
    "Olical/conjure",
    ft = { "clojure", "fennel", "janet" },
    config = function()
      vim.g["conjure#mapping#doc_word"] = "gk"
      vim.g["conjure#highlight#enabled"] = true
      vim.g["conjure#log#hud#enabled"] = true

      local ok, wk = pcall(require, "which-key")
      if ok then
        wk.add({
          { "<localleader>e", group = "Conjure: eval" },
          { "<localleader>l", group = "Conjure: log" },
          { "<localleader>t", group = "Conjure: test" },
          { "<localleader>c", group = "Conjure: connect" },
        })
      end
    end
  },
  {
    "guns/vim-sexp",
    ft = { "clojure", "scheme", "lisp", "timl", "fennel", "janet" },
    config = function()
      vim.g.sexp_enable_insert_mode_mappings = 0
    end
  },
  {
    "tpope/vim-sexp-mappings-for-regular-people",
    dependencies = { "guns/vim-sexp", "tpope/vim-repeat" },
    ft = { "clojure", "scheme", "lisp", "timl", "fennel", "janet" },
  }
}
