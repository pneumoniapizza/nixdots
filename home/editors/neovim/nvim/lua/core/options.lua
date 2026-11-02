local o = vim.o

-- look
o.termguicolors = true
o.number = true
o.relativenumber = true
o.signcolumn = "yes"
o.cursorline = true
o.colorcolumn = "80"
o.laststatus = 3 -- one global statusline
o.showmode = false
o.cmdheight = 1
o.winborder = "rounded"
o.pumheight = 12
o.list = true
o.listchars = "tab:» ,trail:·,nbsp:␣"
o.fillchars = "eob: "
o.wrap = false
o.scrolloff = 8
o.sidescrolloff = 8
o.smoothscroll = true

-- windows
o.splitright = true
o.splitbelow = true
o.splitkeep = "screen"

-- editing
o.expandtab = true
o.tabstop = 2
o.shiftwidth = 2
o.softtabstop = 2
o.ignorecase = true
o.smartcase = true
o.inccommand = "split"
o.virtualedit = "block"
o.confirm = true
o.mouse = "a"
o.jumpoptions = "view"
o.completeopt = "menu,menuone,noselect"
vim.opt.shortmess:append("I") -- no intro screen

-- files: no swap/backup litter, persistent undo
o.swapfile = false
o.backup = false
o.undofile = true
o.autoread = true

-- timing
o.updatetime = 200
o.timeoutlen = 300

-- system clipboard (deferred: it shells out to wl-paste, don't pay for it at startup)
vim.schedule(function()
  o.clipboard = "unnamedplus"
end)
