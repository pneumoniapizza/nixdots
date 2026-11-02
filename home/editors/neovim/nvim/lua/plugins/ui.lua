-- icons, picker, explorer, dashboard, notifications, which-key, terminal
local u = require("core.util")

u.add({
  u.gh("echasnovski/mini.nvim"), -- icons here, pairs/surround/ai in editor.lua
  u.gh("folke/snacks.nvim"),
  u.gh("folke/which-key.nvim"),
})

require("mini.icons").setup()
require("mini.icons").mock_nvim_web_devicons()

-- dashboard ---------------------------------------------------------------
-- No logo: a greeting + date, your keys, recent files, projects. Colours come
-- from the theme's own groups (Statement = primary, Function = tertiary), so
-- they follow matugen live.
local function fg_of(group)
  return vim.api.nvim_get_hl(0, { name = group, link = false }).fg or 0xffffff
end

local function set_hl()
  vim.api.nvim_set_hl(0, "DashGreeting", { fg = fg_of("Statement"), bold = true })
  vim.api.nvim_set_hl(0, "DashDate", { fg = fg_of("Function"), italic = true })
  vim.api.nvim_set_hl(0, "DashRule", { fg = fg_of("Comment") })
end
set_hl()
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_hl })

local function greeting()
  local h = tonumber(os.date("%H"))
  if h < 5 then
    return "still up?"
  elseif h < 12 then
    return "good morning"
  elseif h < 18 then
    return "good afternoon"
  end
  return "good evening"
end

local function plugin_count()
  local ok, plugins = pcall(vim.pack.get)
  return ok and #plugins or 0
end

local function sections()
  return {
    { align = "center", padding = 1, text = { { "", hl = "DashRule" } } },
    function()
      return {
        { align = "center", text = { { greeting(), hl = "DashGreeting" } } },
        { align = "center", padding = 1, text = { { os.date("%A, %d %B"), hl = "DashDate" } } },
        { align = "center", padding = 1, text = { { "──────────────────────────", hl = "DashRule" } } },
      }
    end,
    { section = "keys", gap = 1, padding = 2 },
    { title = "recent files", section = "recent_files", limit = 5, indent = 2, padding = 1 },
    { title = "projects", section = "projects", limit = 4, indent = 2, padding = 1 },
    function()
      local v = vim.version()
      local info = ("v%d.%d.%d  ·  %d plugins"):format(v.major, v.minor, v.patch, plugin_count())
      return { { align = "center", text = { { info, hl = "DashRule" } } } }
    end,
  }
end

require("snacks").setup({
  bigfile = { enabled = true },
  quickfile = { enabled = true },
  input = { enabled = true },
  notifier = { enabled = true, style = "compact", timeout = 3000 },
  indent = { enabled = true, animate = { enabled = false } },
  explorer = { enabled = true, replace_netrw = true },
  picker = {
    enabled = true,
    ui_select = true,
    sources = {
      projects = {
        dev = { "~/projects", "~/dev", "~/dotfiles" },
        patterns = { ".git", "flake.nix", "Cargo.toml", "go.mod", "build.zig", "Makefile" },
      },
      explorer = { hidden = true, layout = { layout = { position = "left", width = 30 } } },
    },
    win = { input = { keys = { ["<Esc>"] = { "close", mode = { "n", "i" } } } } },
  },
  dashboard = {
    enabled = true,
    width = 56,
    preset = {
      keys = {
        { key = "f", desc = "find file", action = ":lua Snacks.dashboard.pick('files')" },
        { key = "g", desc = "grep", action = ":lua Snacks.dashboard.pick('live_grep')" },
        { key = "r", desc = "recent", action = ":lua Snacks.dashboard.pick('oldfiles')" },
        { key = "s", desc = "restore session", action = ":lua require('persistence').load()" },
        { key = "p", desc = "projects", action = ":lua Snacks.picker.projects()" },
        { key = "c", desc = "config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
        { key = "q", desc = "quit", action = ":qa" },
      },
    },
    sections = sections(),
  },
})

-- which-key (leader groups mirror the old emacs layout)
local wk = require("which-key")
wk.setup({ preset = "helix", delay = 300, icons = { mappings = false } })
wk.add({
  { "<leader>b", group = "buffer" },
  { "<leader>w", group = "window" },
  { "<leader>d", group = "diagnostics" },
  { "<leader>f", group = "find" },
  { "<leader>t", group = "tree" },
  { "<leader>p", group = "projects" },
  { "<leader>g", group = "git" },
  { "<leader>l", group = "lsp" },
  { "<leader>m", group = "mode" },
  { "<leader>c", group = "compile" },
  { "<leader>o", group = "options" },
})

local map = vim.keymap.set

map("n", "<leader><space>", function() Snacks.picker.smart() end, { desc = "find file" })
map("n", "<leader>x", function() Snacks.picker.commands() end, { desc = "commands" })

map("n", "<leader>bb", function() Snacks.picker.buffers() end, { desc = "switch buffer" })
map("n", "<leader>bd", function() Snacks.bufdelete() end, { desc = "kill buffer" })

map("n", "<leader>ff", function() Snacks.picker.files() end, { desc = "file" })
map("n", "<leader>fg", function() Snacks.picker.grep() end, { desc = "grep" })
map("n", "<leader>fw", function() Snacks.picker.grep_word() end, { desc = "grep word" })
map("n", "<leader>fl", function() Snacks.picker.lines() end, { desc = "line" })
map("n", "<leader>fi", function() Snacks.picker.lsp_symbols() end, { desc = "symbols" })
map("n", "<leader>fr", function() Snacks.picker.recent() end, { desc = "recent" })
map("n", "<leader>fh", function() Snacks.picker.help() end, { desc = "help" })
map("n", "<leader>fk", function() Snacks.picker.keymaps() end, { desc = "keymaps" })

map("n", "<leader>pp", function() Snacks.picker.projects() end, { desc = "switch project" })

map("n", "<leader>tt", function() Snacks.explorer() end, { desc = "toggle tree" })
map("n", "<leader>tf", function() Snacks.explorer.reveal() end, { desc = "reveal current file" })

map("n", "<leader>gg", function() Snacks.lazygit() end, { desc = "lazygit" })
map("n", "<leader>gl", function() Snacks.picker.git_log() end, { desc = "log" })
map("n", "<leader>gb", function() Snacks.picker.git_branches() end, { desc = "branches" })
map("n", "<leader>gS", function() Snacks.picker.git_status() end, { desc = "status" })

map({ "n", "t" }, "<leader>'", function() Snacks.terminal() end, { desc = "terminal" })

map("n", "<leader>u", function()
  vim.cmd("packadd nvim.undotree | Undotree")
end, { desc = "undo tree" })

-- toggles (SPC o …)
Snacks.toggle.option("relativenumber", { name = "relative numbers" }):map("<leader>or")
Snacks.toggle.option("wrap", { name = "wrap" }):map("<leader>ow")
Snacks.toggle.diagnostics():map("<leader>od")
Snacks.toggle.inlay_hints():map("<leader>oh")
Snacks.toggle({
  name = "transparent background",
  get = function() return vim.g.transparent == true end,
  set = function(on)
    vim.g.transparent = on
    vim.cmd.colorscheme("matugen")
  end,
}):map("<leader>ot")
