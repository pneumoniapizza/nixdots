-- Discord rich presence (presence.nvim). Pure Lua over Discord's IPC socket,
-- so nothing to compile and nothing extra needed in default.nix.
--   :DiscordToggle   pause / resume presence
local u = require("core.util")

u.add({ u.gh("andweeb/presence.nvim") })

u.defer(function()
  local presence = require("presence")

  presence.setup({
    auto_update = true,
    neovim_image_text = "Neovim",
    main_image = "neovim", -- "neovim" | "file" (file-type icon)
    log_level = nil,
    debounce_timeout = 10,
    enable_line_number = false,
    blacklist = {}, -- lua patterns matched against the repo/dir name, e.g. { "private%-.*" }
    buttons = true, -- shows a "View Repository" button when a git remote exists
    file_assets = {},
    show_time = true,

    editing_text = "Editing %s",
    file_explorer_text = "Browsing %s",
    git_commit_text = "Committing changes",
    plugin_manager_text = "Managing plugins",
    reading_text = "Reading %s",
    workspace_text = "Working on %s",
    line_number_text = "Line %s out of %s",
  })

  local active = true
  vim.api.nvim_create_user_command("DiscordToggle", function()
    if active then
      presence:cancel()
    else
      presence:update()
    end
    active = not active
    vim.notify("discord presence " .. (active and "on" or "off"))
  end, { desc = "toggle discord rich presence" })
end)
