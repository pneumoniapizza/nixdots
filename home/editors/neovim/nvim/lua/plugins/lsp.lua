-- Native vim.lsp. Servers come from nix (nvim.nix), not mason.
-- nvim-lspconfig is only used for its default server definitions (lsp/*.lua).
local u = require("core.util")

u.add({ u.gh("neovim/nvim-lspconfig") })

vim.diagnostic.config({
  severity_sort = true,
  underline = true,
  update_in_insert = false,
  virtual_text = { prefix = "●", spacing = 2 },
  float = { border = "rounded", source = true },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "✘",
      [vim.diagnostic.severity.WARN] = "▲",
      [vim.diagnostic.severity.INFO] = "●",
      [vim.diagnostic.severity.HINT] = "◆",
    },
  },
})

vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
      diagnostics = { globals = { "vim", "Snacks" } },
      telemetry = { enable = false },
    },
  },
})

vim.lsp.config("nixd", {
  settings = { nixd = { formatting = { command = { "nixfmt" } } } },
})

-- add `haskell-language-server` to nvim.nix and "hls" here when you want it
vim.lsp.enable({
  "clangd", "zls", "rust_analyzer", "gopls", "nixd", "lua_ls",
  "basedpyright", "vtsls", "html", "cssls",
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local function m(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, desc = desc })
    end
    m("gd", vim.lsp.buf.definition, "definition")
    m("gD", vim.lsp.buf.declaration, "declaration")
    m("<leader>lr", vim.lsp.buf.rename, "rename")
    m("<leader>la", vim.lsp.buf.code_action, "code actions")
    m("<leader>ls", function() Snacks.picker.lsp_symbols() end, "symbols")
    -- K hover, grr references, gri implementation, gO outline: neovim defaults
  end,
})

-- diagnostics (SPC d …); ]d / [d are neovim defaults
local map = vim.keymap.set
map("n", "<leader>dn", function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = "next" })
map("n", "<leader>dp", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "previous" })
map("n", "<leader>dl", function() Snacks.picker.diagnostics() end, { desc = "search (project)" })
map("n", "<leader>db", function() Snacks.picker.diagnostics_buffer() end, { desc = "buffer list" })
map("n", "<leader>dd", vim.diagnostic.open_float, { desc = "line detail" })
