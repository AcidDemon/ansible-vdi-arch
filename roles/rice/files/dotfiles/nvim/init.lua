require("options.options")
require("options.autocmds")
require("options.filetype")

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- rocks/hererocks disabled: plugin deps are listed explicitly in the specs
require("lazy").setup("plugins", {
  rocks = {
    enabled = false,
  }
})

-- after lazy: plugins must be on the runtime path first
require("options.keymaps")
