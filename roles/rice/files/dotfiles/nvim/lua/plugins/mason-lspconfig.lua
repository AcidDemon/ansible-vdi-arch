return {
  "williamboman/mason-lspconfig.nvim",
  dependencies = { "williamboman/mason.nvim" },
  config = function()
    require("mason-lspconfig").setup({
      ensure_installed = {
        "ansiblels",
        "astro",
        "bashls",
        "cssls",
        "diagnosticls",
        "dockerls",
        "emmet_ls",
        "eslint",
        "graphql",
        "html",
        "jsonls",
        "prismals",
        "sqlls",
        "tailwindcss",
        "ts_ls",
        "vimls",
        "yamlls",
      },
    })
  end
}
