-- seamless <C-h/j/k/l> between nvim splits and tmux panes (pairs with the tmux module)
local dirs = { h = "L", j = "D", k = "U", l = "R" }

local function nav(key)
  return function()
    local win = vim.api.nvim_get_current_win()
    vim.cmd("wincmd " .. key)
    if vim.api.nvim_get_current_win() == win and vim.env.TMUX then
      vim.system({ "tmux", "select-pane", "-" .. dirs[key] })
    end
  end
end

for key in pairs(dirs) do
  vim.keymap.set("n", "<C-" .. key .. ">", nav(key), { desc = "focus " .. key .. " (nvim/tmux)" })
end
