-- Tiny global statusline: mode pill | file | … | lsp  diagnostics  branch  pos
-- Highlight groups (Stl*) are defined by the theme so they follow matugen.
local M = {}

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

local function diagnostics()
  local counts = vim.diagnostic.count(0)
  local sev = vim.diagnostic.severity
  local out = {}
  for _, item in ipairs({
    { sev.ERROR, "StlError", "✘" },
    { sev.WARN, "StlWarn", "▲" },
    { sev.INFO, "StlInfo", "●" },
    { sev.HINT, "StlHint", "◆" },
  }) do
    local n = counts[item[1]]
    if n and n > 0 then
      out[#out + 1] = ("%%#%s#%s %d "):format(item[2], item[3], n)
    end
  end
  return table.concat(out)
end

local function lsp()
  local names = {}
  for _, c in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
    names[#names + 1] = c.name
  end
  return #names > 0 and (" " .. table.concat(names, ",") .. " ") or ""
end

function M.render()
  local mode = vim.api.nvim_get_mode().mode
  local label, group = unpack(modes[mode:sub(1, 1)] or modes.n)
  local branch = vim.b.gitsigns_head
  local modified = vim.bo.modified and " ●" or ""
  local readonly = (vim.bo.readonly or not vim.bo.modifiable) and " [RO]" or ""

  return table.concat({
    "%#StlMode", group, "# ", label, " ",
    "%#StlBody# %<%f", modified, readonly, "%=",
    "%#StlDim#", lsp(),
    diagnostics(),
    "%#StlBranch#", branch and (" ⎇ " .. branch .. " ") or "",
    "%#StlDim# %l:%c  %p%%  ",
  })
end

vim.o.statusline = "%{%v:lua.require'core.statusline'.render()%}"

return M
