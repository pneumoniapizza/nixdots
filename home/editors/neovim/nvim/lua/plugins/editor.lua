-- electric pairs, surround, better text objects (mini.nvim is added in ui.lua)
local u = require("core.util")

u.defer(function()
  require("mini.pairs").setup()
  require("mini.surround").setup() -- sa / sd / sr
  require("mini.ai").setup({ n_lines = 300 })
end)
