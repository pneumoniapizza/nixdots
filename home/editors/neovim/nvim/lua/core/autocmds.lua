local group = vim.api.nvim_create_augroup("user", { clear = true })
local function au(event, opts)
  opts.group = group
  vim.api.nvim_create_autocmd(event, opts)
end

au("TextYankPost", {
  callback = function()
    vim.hl.on_yank({ timeout = 120 })
  end,
})

-- pick up external changes (git checkout, formatters, …)
au({ "FocusGained", "TermClose", "TermLeave" }, { command = "checktime" })

au("VimResized", { command = "tabdo wincmd =" })

-- restore last cursor position
au("BufReadPost", {
  callback = function(ev)
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(ev.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- q closes throwaway windows
au("FileType", {
  pattern = { "help", "qf", "man", "checkhealth" },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = ev.buf, silent = true })
  end,
})

au("TermOpen", {
  callback = function()
    vim.wo.number = false
    vim.wo.relativenumber = false
    vim.wo.signcolumn = "no"
  end,
})
