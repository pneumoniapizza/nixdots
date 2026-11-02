-- hunk signs (diff-hl) + hunk actions. Magit-equivalent is lazygit on SPC g g.
local u = require("core.util")

u.add({ u.gh("lewis6991/gitsigns.nvim") })

u.defer(function()
  require("gitsigns").setup({
    signs = {
      add = { text = "▎" },
      change = { text = "▎" },
      delete = { text = "▁" },
      topdelete = { text = "▔" },
      changedelete = { text = "▎" },
      untracked = { text = "▎" },
    },
    on_attach = function(buf)
      local gs = require("gitsigns")
      local function m(lhs, rhs, desc)
        vim.keymap.set("n", lhs, rhs, { buffer = buf, desc = desc })
      end
      m("]h", function() gs.nav_hunk("next") end, "next hunk")
      m("[h", function() gs.nav_hunk("prev") end, "previous hunk")
      m("<leader>gs", gs.stage_hunk, "stage hunk")
      m("<leader>gr", gs.reset_hunk, "reset hunk")
      m("<leader>gp", gs.preview_hunk, "preview hunk")
      m("<leader>gB", function() gs.blame_line({ full = true }) end, "blame line")
    end,
  })
end)
