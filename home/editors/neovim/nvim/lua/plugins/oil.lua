-- oil.nvim: edit the filesystem like a buffer. Rename/move/delete by editing
-- lines, then :w to apply.
--   -         open the parent directory
--   SPC f o   open oil at the current file's directory
--   (in oil)  <CR> open · - up · g? help · g. toggle hidden · <C-p> preview
local u = require("core.util")

u.add({ u.gh("stevearc/oil.nvim") })

require("oil").setup({
  default_file_explorer = true,
  columns = { "icon" },
  skip_confirm_for_simple_edits = true,
  delete_to_trash = true,
  view_options = { show_hidden = true },
  float = { border = "none" },
  keymaps = {
    ["<C-h>"] = false, -- keep window navigation
    ["<C-l>"] = false,
    ["<Esc>"] = { "actions.close", mode = "n" },
    ["q"] = { "actions.close", mode = "n" },
  },
})

vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "open parent directory" })
vim.keymap.set("n", "<leader>fo", "<cmd>Oil<cr>", { desc = "oil (file's directory)" })
