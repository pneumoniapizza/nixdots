-- SPC m …  per-filetype build/run/test      SPC c …  compile / recompile
local M = {}

local actions = {
  zig  = { build = "zig build", run = "zig build run", test = "zig build test" },
  rust = { build = "cargo build", run = "cargo run", test = "cargo test", check = "cargo check", clippy = "cargo clippy" },
  go   = { build = "go build ./...", run = "go run .", test = "go test ./..." },
  c    = { build = "make", run = "make run", test = "make test" },
  cpp  = { build = "make", run = "make run", test = "make test" },
  html = { run = function() return "xdg-open " .. vim.fn.shellescape(vim.fn.expand("%:p")) end },
}

local root_markers = { ".git", "flake.nix", "Cargo.toml", "go.mod", "build.zig", "Makefile" }
local last

function M.exec(cmd)
  last = cmd
  vim.cmd("silent! wall")
  local root = vim.fs.root(0, root_markers) or vim.uv.cwd()
  vim.cmd("botright 14new")
  vim.fn.jobstart(cmd, { term = true, cwd = root })
  vim.cmd("stopinsert")
end

function M.action(name)
  local set = actions[vim.bo.filetype]
  local cmd = set and set[name]
  if type(cmd) == "function" then
    cmd = cmd()
  end
  if not cmd then
    return vim.notify(("no '%s' action for %s"):format(name, vim.bo.filetype), vim.log.levels.WARN)
  end
  M.exec(cmd)
end

function M.compile()
  vim.ui.input({ prompt = "compile: ", default = last or "make -k" }, function(cmd)
    if cmd and cmd ~= "" then
      M.exec(cmd)
    end
  end)
end

function M.recompile()
  if last then
    M.exec(last)
  else
    M.compile()
  end
end

local map = vim.keymap.set
map("n", "<leader>mb", function() M.action("build") end, { desc = "build" })
map("n", "<leader>mr", function() M.action("run") end, { desc = "run" })
map("n", "<leader>mt", function() M.action("test") end, { desc = "test" })
map("n", "<leader>mk", function() M.action("check") end, { desc = "check" })
map("n", "<leader>mc", function() M.action("clippy") end, { desc = "clippy" })
map("n", "<leader>cc", M.compile, { desc = "compile" })
map("n", "<leader>cr", M.recompile, { desc = "recompile" })

return M
