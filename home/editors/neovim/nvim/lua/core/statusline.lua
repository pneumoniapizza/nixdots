local M = {}

local function nf(code)
  return vim.fn.nr2char(code)
end

local ARROW_R, ARROW_L = nf(0xe0b0), nf(0xe0b2)
-- Swap any glyph here (browse codepoints at https://www.nerdfonts.com/cheat-sheet),
-- or set one to "" to drop it.
local ICON = {
  branch = nf(0xec6f), -- git-branch
  modified = nf(0xeb8a), -- circle-small-filled
  readonly = nf(0xea75), -- lock
  search = nf(0xea6d), -- search
  rec = nf(0xeba7), -- record
  error = nf(0xea87), -- error
  warn = nf(0xea6c), -- warning
  info = nf(0xea74), -- info
  hint = nf(0xea61), -- lightbulb
}
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
  local bar = get("StlBody", "bg")
  local seg = get("Visual", "bg") or get("PmenuSbar", "bg") -- wallpaper-tinted
  local seg_fg = get("Normal", "fg")
  local function set(name, spec)
    vim.api.nvim_set_hl(0, name, spec)
  end

  -- on the bar
  set("StlAdd", { fg = get("Added", "fg"), bg = bar })
  set("StlChange", { fg = get("Changed", "fg"), bg = bar })
  set("StlRemove", { fg = get("Removed", "fg"), bg = bar })
  set("StlLsp", { fg = get("StlModeVisual", "bg"), bg = bar })

  -- on the tinted segment
  set("StlSeg", { fg = seg_fg, bg = seg })
  set("StlSegDim", { fg = get("StlDim", "fg"), bg = seg })
  set("StlSegWarn", { fg = get("StlWarn", "fg"), bg = seg, bold = true })
  set("StlSegFt", { fg = get("StlModeNormal", "bg"), bg = seg, bold = true })
  set("StlArrowSeg", { fg = seg, bg = bar }) -- segment ↔ bar
  for _, m in ipairs(MODES) do
    local c = get("StlMode" .. m, "bg")
    set("StlSegFile" .. m, { fg = c, bg = seg, bold = true })
    set("StlArrow" .. m, { fg = c, bg = seg }) -- mode block ↔ segment
  end
end
setup_hl()
vim.api.nvim_create_autocmd("ColorScheme", { callback = setup_hl })

local function esc(s)
  return (s:gsub("%%", "%%%%"))
end

--- file-type icon (mini.icons picks the glyph and hue; we put it on the segment bg)
local function file_icon()
  local mi = package.loaded["mini.icons"]
  local name = vim.fn.expand("%:t")
  if mi and name ~= "" then
    local ok, glyph, hl = pcall(mi.get, "file", name)
    if ok and glyph then
      vim.api.nvim_set_hl(0, "StlIcon", { fg = get(hl, "fg"), bg = get("StlSeg", "bg") })
      return "%#StlIcon#" .. glyph .. " "
    end
  end
  return ""
end

local function diff_part()
  local d = vim.b.gitsigns_status_dict
  if not d then
    return ""
  end
  local out = {}
  if (d.added or 0) > 0 then out[#out + 1] = "%#StlAdd#+" .. d.added end
  if (d.changed or 0) > 0 then out[#out + 1] = "%#StlChange#~" .. d.changed end
  if (d.removed or 0) > 0 then out[#out + 1] = "%#StlRemove#-" .. d.removed end
  return #out > 0 and (" " .. table.concat(out, " ")) or ""
end

local function diag_part()
  local counts = vim.diagnostic.count(0)
  local sev = vim.diagnostic.severity
  local out = {}
  for _, item in ipairs({
    { sev.ERROR, "StlError", ICON.error },
    { sev.WARN, "StlWarn", ICON.warn },
    { sev.INFO, "StlInfo", ICON.info },
    { sev.HINT, "StlHint", ICON.hint },
  }) do
    local n = counts[item[1]]
    if n and n > 0 then
      out[#out + 1] = ("%%#%s#%s %d"):format(item[2], item[3], n)
    end
  end
  return #out > 0 and (table.concat(out, " ") .. "%#StlBody#  ") or ""
end

local function lsp_part()
  local names = {}
  for _, c in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
    names[#names + 1] = c.name
  end
  return #names > 0 and ("%#StlLsp#" .. esc(table.concat(names, ",")) .. "%#StlBody#  ") or ""
end

local function search_part()
  if vim.v.hlsearch == 0 then
    return ""
  end
  local ok, sc = pcall(vim.fn.searchcount, { maxcount = 999, timeout = 50 })
  if not ok or not sc.total or sc.total == 0 then
    return ""
  end
  return ("%%#StlInfo#%s %d/%d%%#StlBody#  "):format(ICON.search, sc.current, sc.total)
end

function M.render()
  local mode = vim.api.nvim_get_mode().mode
  local label, g = unpack(modes[mode:sub(1, 1)] or modes.n)
  local wide = vim.o.columns >= 100
  local out = {}
  local function add(s)
    out[#out + 1] = s
  end

  -- left: [mode]▶[ file ]▶ git
  add("%#StlMode" .. g .. "# " .. label .. " ")
  local rec = vim.fn.reg_recording()
  if rec ~= "" then
    add("%#StlModeReplace# " .. ICON.rec .. " @" .. rec .. " ")
  end
  add("%#StlArrow" .. g .. "#" .. ARROW_R .. "%#StlSeg# ")

  if vim.bo.buftype == "terminal" then
    add("%#StlSegFile" .. g .. "#terminal")
  else
    add(file_icon() .. "%#StlSegFile" .. g .. "#%t")
    if vim.bo.modified then add(" %#StlSegWarn#" .. ICON.modified) end
    if vim.bo.readonly or not vim.bo.modifiable then add(" %#StlSegDim#" .. ICON.readonly) end
  end
  add("%#StlSeg# %#StlArrowSeg#" .. ARROW_R .. "%#StlBody#")

  local branch = vim.b.gitsigns_head
  if branch and branch ~= "" then
    add(" %#StlBranch#" .. ICON.branch .. " " .. esc(branch))
    if wide then
      add(diff_part())
    end
  end

  add("%#StlBody#%=")

  -- right: search · diagnostics · lsp ◀[ filetype ]◀[position]
  add(search_part())
  add(diag_part())
  local ft = vim.bo.filetype
  if wide then
    add(lsp_part())
    add("%#StlArrowSeg#" .. ARROW_L .. "%#StlSegFt# " .. ((ft ~= "" and vim.bo.buftype == "") and esc(ft) .. " " or ""))
  else
    add("%#StlArrowSeg#" .. ARROW_L .. "%#StlSeg# ")
  end
  add("%#StlArrow" .. g .. "#" .. ARROW_L .. "%#StlMode" .. g .. "# %l:%c  %p%% ")

  return table.concat(out)
end

vim.api.nvim_create_autocmd({ "DiagnosticChanged", "LspAttach", "LspDetach", "RecordingEnter", "RecordingLeave" }, {
  callback = function()
    vim.schedule(function()
      vim.cmd.redrawstatus()
    end)
  end,
})

vim.o.statusline = "%{%v:lua.require'core.statusline'.render()%}"

return M
