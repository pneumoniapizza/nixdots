-- blink.cmp (+ friendly-snippets for snippets in basically every language)
-- fuzzy = "lua": the prebuilt rust matcher is a downloaded binary, which doesn't
-- run on NixOS without patching. The lua matcher is plenty fast.
local u = require("core.util")

u.add({
  u.gh("saghen/blink.cmp", vim.version.range("1.*")),
  u.gh("rafamadriz/friendly-snippets"),
})

require("blink.cmp").setup({
  keymap = { preset = "enter" }, -- RET accepts, C-n/C-p select, Tab/S-Tab jump snippets
  appearance = { nerd_font_variant = "mono" },
  completion = {
    list = { selection = { preselect = true, auto_insert = false } },
    menu = { border = "rounded", draw = { treesitter = { "lsp" } } },
    documentation = { auto_show = true, auto_show_delay_ms = 250, window = { border = "rounded" } },
  },
  signature = { enabled = true, window = { border = "rounded" } },
  sources = { default = { "lsp", "path", "snippets", "buffer" } },
  fuzzy = { implementation = "lua" },
})
