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
