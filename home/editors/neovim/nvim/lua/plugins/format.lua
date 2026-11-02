-- Manual formatting only (SPC l f). Nothing runs on save.
local u = require("core.util")

u.add({ u.gh("stevearc/conform.nvim") })

u.defer(function()
  require("conform").setup({
    formatters_by_ft = {
      c = { "clang-format" },
      cpp = { "clang-format" },
      rust = { "rustfmt" },
      go = { "gofmt" },
      zig = { "zigfmt" },
      nix = { "nixfmt" },
      lua = { "stylua" },
      python = { "ruff_format" },
      javascript = { "prettier" },
      typescript = { "prettier" },
      html = { "prettier" },
      css = { "prettier" },
      json = { "prettier" },
      markdown = { "prettier" },
    },
    default_format_opts = { lsp_format = "fallback" },
  })
end)

vim.keymap.set({ "n", "x" }, "<leader>lf", function()
  require("conform").format()
end, { desc = "format buffer" })
