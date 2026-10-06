vim.loader.enable()

-- General
vim.opt.undofile = true
vim.opt.numberwidth = 4
vim.opt.compatible = false
vim.opt.mouse = "nv" -- No mouse in cmdline mode
vim.opt.synmaxcol = 2500
vim.opt.history = 2000
vim.opt.clipboard = "unnamedplus"
-- OSC 52 only over SSH; in the local X11 session nvim auto-detects xclip
if os.getenv("SSH_TTY") then
  vim.g.clipboard = {
    name = 'OSC 52',
    copy = {
      ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
      ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
    },
    paste = {
      ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
      ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
    },
  }
end
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.switchbuf = "uselast"
vim.opt.re = 0
vim.opt.showcmd = false
vim.opt.autoread = true
vim.opt.autowrite = true
vim.opt.autowriteall = true
vim.opt.modeline = false
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.completeopt = { "menuone", "noselect" }

-- Formatting
vim.opt.iskeyword:append("-") -- Hyphenated words
vim.opt.fillchars.eob = " " -- Hide EOB tildes
vim.opt.fileencoding = "utf-8"
vim.opt.wrap = false
vim.opt.textwidth = 80
vim.opt.conceallevel = 0 -- Show backticks in markdown
vim.opt.linebreak = true
vim.opt.formatoptions:remove({ "c", "r", "o" })
vim.opt.whichwrap:append("h,l,<,>,[,],~")

-- Searching
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.infercase = true
vim.opt.incsearch = true
vim.opt.wrapscan = true

-- Tabs & Indents
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smarttab = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.shiftround = true
vim.opt.foldenable = false
vim.opt.foldmethod = "indent"

-- Timing
vim.opt.timeout = true
vim.opt.ttimeout = true
vim.opt.timeoutlen = 300
vim.opt.ttimeoutlen = 10
vim.opt.updatetime = 200
vim.opt.redrawtime = 1500

-- Editor UI
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.cursorcolumn = false
vim.opt.showmode = true
vim.opt.shortmess:append("c") -- Hide completion messages
vim.opt.scrolloff = 2
vim.opt.sidescrolloff = 5
vim.opt.ruler = false
vim.opt.list = false
vim.opt.hlsearch = true

vim.opt.showtabline = 0
vim.opt.helpheight = 12
vim.opt.winwidth = 30
vim.opt.winminwidth = 10
vim.opt.winheight = 1
vim.opt.winminheight = 1

vim.opt.showcmd = true
vim.opt.cmdheight = 1
vim.opt.cmdwinheight = 5
vim.opt.equalalways = false
vim.opt.laststatus = 3
vim.opt.signcolumn = "yes"
vim.opt.colorcolumn = ""
vim.opt.pumheight = 15

vim.cmd([[ set nu rnu ]])
