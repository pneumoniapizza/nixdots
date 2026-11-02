local M = {}

--- GitHub plugin spec for vim.pack. `version` is a branch/tag/commit or a vim.VersionRange.
function M.gh(repo, version)
  return { src = "https://github.com/" .. repo, version = version }
end

--- Install (no prompt) and load plugins.
function M.add(specs)
  vim.pack.add(specs, { confirm = false })
end

--- Run after startup so it never blocks the first paint. Errors are reported, not fatal.
function M.defer(fn)
  vim.schedule(function()
    local ok, err = pcall(fn)
    if not ok then
      vim.notify(tostring(err), vim.log.levels.ERROR)
    end
  end)
end

return M
