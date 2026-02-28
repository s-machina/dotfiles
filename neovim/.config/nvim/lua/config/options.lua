-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

local opt = vim.opt

-- UI
opt.relativenumber = true  -- Relative line numbers
opt.cursorline = true      -- Highlight current line
opt.termguicolors = true   -- True color support
opt.signcolumn = "yes"     -- Always show sign column

-- Tabs & Indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true

-- Search
opt.ignorecase = true
opt.smartcase = true

-- Split windows
opt.splitright = true
opt.splitbelow = true

-- Misc
opt.undofile = true        -- Persistent undo
opt.updatetime = 250       -- Faster completion
opt.timeoutlen = 300       -- Faster key sequence completion
opt.clipboard = "unnamedplus"  -- Use system clipboard

-- Clipboard: explicit provider for tmux (avoids read-side warnings)
-- Write uses OSC 52 (tmux intercepts and forwards to outer terminal)
-- Read uses pbpaste on macOS, tmux paste buffer on Linux
if vim.env.TMUX then
  local function paste()
    if vim.fn.executable("pbpaste") == 1 then
      return vim.fn.systemlist("pbpaste")
    end
    return vim.fn.systemlist("tmux save-buffer -")
  end
  vim.g.clipboard = {
    name = "tmux-osc52",
    copy = {
      ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
      ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
    },
    paste = {
      ["+"] = paste,
      ["*"] = paste,
    },
  }
end
