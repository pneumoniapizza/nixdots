-- Discord Rich Presence (cord.nvim). Shows file/language/workspace in Discord.
--   :Cord toggle    enable/disable presence
--   :Cord status    connection state
--   SPC D           toggle presence
local u = require("core.util")

u.add({ u.gh("vyfor/cord.nvim") })

u.defer(function()
  require("cord").setup({
    display = {
      theme = "default",
      flavor = "dark",
    },
    idle = {
      enabled = true,
      timeout = 300000, -- 5 min
      show_status = true,
    },
    text = {
      workspace = function(opts)
        return "In " .. opts.workspace
      end,
    },
  })
end)

vim.keymap.set("n", "<leader>D", "<cmd>Cord toggle<cr>", { desc = "toggle discord presence" })
