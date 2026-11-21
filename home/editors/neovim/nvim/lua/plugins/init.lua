-- Plugin manager = built-in vim.pack (nvim 0.12+). Pins live in nvim-pack-lock.json.
--   :PackUpdate   review + update plugins
-- Order matters a little: ui (icons) → completion (lsp capabilities) → lsp.
vim.api.nvim_create_user_command("PackUpdate", function()
  vim.pack.update()
end, { desc = "update plugins" })

for _, mod in ipairs({ "ui", "editor", "git", "treesitter", "session", "completion", "lsp", "format" }) do
  local ok, err = pcall(require, "plugins." .. mod)
  if not ok then
    -- one broken/offline plugin must not take the rest of the config down
    vim.schedule(function()
      vim.notify(("plugins.%s: %s"):format(mod, err), vim.log.levels.ERROR)
    end)
  end
end
