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

u.add({ u.gh("nvim-treesitter/nvim-treesitter", "main") })

local langs = {
  "c", "cpp", "zig", "rust", "go", "gomod", "python", "lua", "nix", "haskell",
  "javascript", "typescript", "tsx", "html", "css", "json", "yaml", "toml",
  "markdown", "markdown_inline", "bash", "fish", "make", "cmake",
  "vim", "vimdoc", "query", "regex", "diff", "git_config", "gitcommit",
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
