-- Per-directory session restore (persistence.nvim). Sessions save on exit,
-- nothing is restored automatically — you choose.
--   dashboard `s`   restore this directory's session
--   SPC p s         restore this directory's session
--   SPC p l         restore the last session (any directory)
--   SPC p S         pick a session
--   SPC p d         don't save the current session
local u = require("core.util")

u.add({ u.gh("folke/persistence.nvim") })

vim.o.sessionoptions = "buffers,curdir,tabpages,winsize,help,globals,skiprtp,folds"

require("persistence").setup({ need = 1 })

local map = vim.keymap.set
map("n", "<leader>ps", function() require("persistence").load() end, { desc = "restore session" })
map("n", "<leader>pl", function() require("persistence").load({ last = true }) end, { desc = "restore last session" })
map("n", "<leader>pS", function() require("persistence").select() end, { desc = "select session" })
map("n", "<leader>pd", function() require("persistence").stop() end, { desc = "don't save this session" })
