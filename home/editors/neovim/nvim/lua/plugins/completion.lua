-- blink.cmp (+ friendly-snippets for snippets in basically every language)
-- fuzzy = "lua": the prebuilt rust matcher is a downloaded binary, which doesn't
-- run on NixOS without patching. The lua matcher is plenty fast.
local u = require("core.util")

u.add({
  u.gh("saghen/blink.cmp", vim.version.range("1.*")),
  u.gh("rafamadriz/friendly-snippets"),
})

require("blink.cmp").setup({
  keymap = {
    preset = "enter",
    ['<Tab>'] = { 'select_next', 'snippet_forward', 'fallback' },
    ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
  },
  appearance = { nerd_font_variant = "normal" },
  completion = {
    list = { selection = { preselect = true, auto_insert = false } },
    -- VS Code look: borderless panel on Pmenu background, selected row
    -- highlighted, icon + label + dim detail, docs in a flat side panel.
    menu = {
      border = "none",
      max_height = 10,
      scrollbar = false,
      winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,CursorLine:PmenuSel,Search:None",
      draw = {
        treesitter = { "lsp" },
        padding = { 1, 1 },
        gap = 1,
        columns = { { "kind_icon" }, { "label", "label_description", gap = 1 } },
      },
    },
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 300,
      window = {
        border = "none",
        max_width = 60,
        max_height = 14,
        winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,EndOfBuffer:Pmenu",
        direction_priority = {
          menu_north = { "e", "w", "n", "s" },
          menu_south = { "e", "w", "s", "n" },
        },
      },
    },
  },
  signature = { enabled = true, window = { border = "none", winhighlight = "Normal:Pmenu,FloatBorder:Pmenu" } },
  sources = { default = { "lsp", "path", "snippets", "buffer" } },
  fuzzy = { implementation = "lua" },
})
