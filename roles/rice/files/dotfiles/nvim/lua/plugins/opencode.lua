return {
  "nickjvandyke/opencode.nvim",
  config = function()
    vim.g.opencode_opts = vim.g.opencode_opts or {}
    vim.o.autoread = true
  end
}
