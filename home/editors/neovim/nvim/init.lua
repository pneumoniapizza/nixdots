-- init.lua — entry point. Everything real lives in lua/.
vim.loader.enable() -- byte-code cache for lua modules

vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- built-ins and providers we never use
for _, p in ipairs({ "gzip", "tarPlugin", "zipPlugin", "tohtml", "tutor", "2html_plugin" }) do
  vim.g["loaded_" .. p] = 1
end
for _, p in ipairs({ "python3", "node", "ruby", "perl" }) do
  vim.g["loaded_" .. p .. "_provider"] = 0
end

require("core.options")
require("core.keymaps")
require("core.autocmds")
require("theme").setup() -- colours first, so the first paint is already themed
require("core.statusline")
require("plugins")
