-- Flat, icon-free statusline (lualine-style, no separators):
--
--   [ MODE ][ branch ] filename [+]            enc :: ff :: ft [ 42% ][ 5:4 ]
--
-- Mode blocks (a/z) use the colorscheme's mode colours, branch/progress (b/y) sit on a
-- tinted segment, filename and file info (c/x) sit on the plain bar.
local M = {}

local MODES = { "Normal", "Insert", "Visual", "Replace", "Command", "Terminal" }

local modes = {
  n = { "NORMAL", "Normal" },
  i = { "INSERT", "Insert" },
  v = { "VISUAL", "Visual" },
  V = { "V-LINE", "Visual" },
  ["\22"] = { "V-BLOCK", "Visual" },
  s = { "SELECT", "Visual" },
  S = { "S-LINE", "Visual" },
  R = { "REPLACE", "Replace" },
  c = { "COMMAND", "Command" },
  t = { "TERMINAL", "Terminal" },
  ["!"] = { "SHELL", "Terminal" },
}

local function get(group, attr)
  return vim.api.nvim_get_hl(0, { name = group, link = false })[attr]
end

local function setup_hl()
  local seg = get("Visual", "bg") or get("PmenuSbar", "bg") -- tinted b/y segments
  vim.api.nvim_set_hl(0, "StlSeg", { fg = get("Normal", "fg"), bg = seg })
  vim.api.nvim_set_hl(0, "StlWarnBar", { fg = get("StlWarn", "fg"), bg = get("StlBody", "bg"), bold = true })
  for _, m in ipairs(MODES) do
    -- keep the colorscheme's mode block, just make sure it's bold
    vim.api.nvim_set_hl(0, "StlMode" .. m, {
      fg = get("StlMode" .. m, "fg"),
      bg = get("StlMode" .. m, "bg"),
      bold = true,
    })
  end
end
setup_hl()
vim.api.nvim_create_autocmd("ColorScheme", { callback = setup_hl })

local function esc(s)
  return (s:gsub("%%", "%%%%"))
end

local function fileinfo()
  -- skip empty parts so [No Name] buffers don't end in a dangling "::"
  local parts = {}
  for _, v in ipairs({ vim.o.fileencoding, vim.bo.fileformat, vim.bo.filetype }) do
    if v ~= "" then parts[#parts + 1] = v end
  end
  return table.concat(parts, " :: ")
end

function M.render()
  local mode = vim.api.nvim_get_mode().mode
  local label, g = unpack(modes[mode:sub(1, 1)] or modes.n)
  local out = {}
  local function add(s)
    out[#out + 1] = s
  end

  -- a: mode
  add("%#StlMode" .. g .. "# " .. label .. " ")

  -- b: branch
  local branch = vim.b.gitsigns_head
  if branch and branch ~= "" then
    add("%#StlSeg# " .. esc(branch) .. " ")
  end

  -- c: filename
  add("%#StlBody# ")
  if vim.bo.buftype == "terminal" then
    add("terminal")
  else
    add("%f")
    if vim.bo.modified then add(" %#StlWarnBar#[+]%#StlBody#") end
    if vim.bo.readonly or not vim.bo.modifiable then add(" [-]") end
  end

  add("%=")

  -- x: encoding :: format :: filetype
  add(esc(fileinfo()) .. " ")

  -- y: progress
  add("%#StlSeg# %p%% ")

  -- z: location
  add("%#StlMode" .. g .. "# %l:%c ")

  return table.concat(out)
end

vim.api.nvim_create_autocmd({ "RecordingEnter", "RecordingLeave" }, {
  callback = function()
    vim.schedule(function()
      vim.cmd.redrawstatus()
    end)
  end,
})

vim.o.statusline = "%{%v:lua.require'core.statusline'.render()%}"

return M
