local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "clear search highlight" })
map({ "n", "i", "x" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "save" })

-- windows  (SPC w …)
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")
map("n", "<leader>wh", "<C-w>h", { desc = "focus left" })
map("n", "<leader>wj", "<C-w>j", { desc = "focus down" })
map("n", "<leader>wk", "<C-w>k", { desc = "focus up" })
map("n", "<leader>wl", "<C-w>l", { desc = "focus right" })
map("n", "<leader>wv", "<cmd>vsplit<cr>", { desc = "split right" })
map("n", "<leader>ws", "<cmd>split<cr>", { desc = "split below" })
map("n", "<leader>wd", "<C-w>c", { desc = "close window" })
map("n", "<leader>wo", "<C-w>o", { desc = "only this window" })
map("n", "<leader>w=", "<C-w>=", { desc = "balance" })

-- buffers  (SPC b …; picker + delete live in plugins/ui.lua)
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "next buffer" })
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "previous buffer" })

-- visual-mode quality of life
map("x", "<", "<gv")
map("x", ">", ">gv")
map("x", "J", ":m '>+1<cr>gv=gv", { desc = "move lines down" })
map("x", "K", ":m '<-2<cr>gv=gv", { desc = "move lines up" })

-- terminal
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "leave terminal mode" })

-- config
map("n", "<leader>i", function()
  vim.cmd.edit(vim.fn.stdpath("config") .. "/init.lua")
end, { desc = "open init file" })
map("n", "<leader>r", "<cmd>restart<cr>", { desc = "restart nvim" })

require("core.modes") -- SPC m … and SPC c …
