-- Basic Neovim Settings
-- Visual
vim.cmd.colorscheme("kanagawa")
--vim.cmd("colorscheme vague")
vim.opt.number = true                -- Show line numbers
vim.opt.relativenumber = true        -- Show relative line numbers
vim.opt.termguicolors = true         -- Enable 24-bit RGB colors
vim.opt.signcolumn = "yes"           -- Always show sign column
vim.opt.wrap = false                 -- Don't wrap lines
vim.opt.cursorline = true            -- Highlight current line

-- Indentation
vim.opt.tabstop = 4                  -- Tab width
vim.opt.shiftwidth = 4               -- Indent width
vim.opt.expandtab = true             -- Use spaces instead of tabs
vim.opt.autoindent = true            -- Auto indent
vim.opt.smartindent = true           -- Smart indent

-- Search
vim.opt.ignorecase = true            -- Ignore case in search
vim.opt.smartcase = true             -- Smart case search
vim.opt.hlsearch = true              -- Highlight search results
vim.opt.incsearch = true             -- Incremental searh 
vim.opt.showmatch = true

-- Performance
vim.opt.updatetime = 250             -- Faster update time
vim.opt.timeoutlen = 300             -- Timeout for key sequences

-- Other
vim.opt.mouse = 'a'                  -- Enable mouse support
vim.opt.clipboard = "unnamedplus"    -- Use system clipboard
vim.opt.undofile = true              -- Enable persistent undo
vim.opt.completeopt = 'menuone,noselect'  -- Better completion

-- Set leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
