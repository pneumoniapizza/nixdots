-- nvim-treesitter (main branch). Parsers are compiled on first use and need
-- `gcc` + `tree-sitter` on PATH — nvim.nix provides both.
local u = require("core.util")

-- must exist before vim.pack.add so it sees the first install/update
vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local d = ev.data
    if d.spec.name == "nvim-treesitter" and d.kind == "update" then
      pcall(function()
        if not d.active then
          vim.cmd.packadd("nvim-treesitter")
        end
        require("nvim-treesitter").update()
      end)
    end
  end,
})

u.add({
  u.gh("nvim-treesitter/nvim-treesitter", "main"),
  u.gh("nvim-treesitter/nvim-treesitter-context"),
})

local langs = {
  "cpp", "zig", "rust", "go", "python", "nix", "haskell",
  "javascript", "typescript", "html", "css", "json", "bash",
}

-- async, skips what's already installed
u.defer(function()
  require("nvim-treesitter").install(langs)
end)

vim.api.nvim_create_autocmd("FileType", {
  callback = function(ev)
    -- silently does nothing until the parser for this filetype exists
    if pcall(vim.treesitter.start, ev.buf) then
      vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

-- sticky context: keeps the enclosing function/class header pinned at the top
u.defer(function()
  require("treesitter-context").setup({
    max_lines = 3,
    min_window_height = 20,
    multiline_threshold = 1,
    trim_scope = "outer",
  })
end)

vim.keymap.set("n", "[x", function()
  require("treesitter-context").go_to_context(vim.v.count1)
end, { desc = "jump to context" })

Snacks.toggle({
  name = "sticky context",
  get = function() return require("treesitter-context").enabled() end,
  set = function() require("treesitter-context").toggle() end,
}):map("<leader>oc")
