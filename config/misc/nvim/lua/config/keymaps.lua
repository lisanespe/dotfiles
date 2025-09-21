-- Neovim Keymaps
-- Clear space in normal and visual mode (since it's our leader)
vim.keymap.set({'n', 'v'}, '<Space>', '<Nop>', { silent = true })

-- Basic file operations
vim.keymap.set('n', '<leader>w', ':w<CR>', { desc = 'Save file' })
vim.keymap.set('n', '<leader>q', ':q<CR>', { desc = 'Quit' })
vim.keymap.set('n', '<leader>wq', ':wq<CR>', { desc = 'Save and quit' })

-- Clear search highlighting
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })

-- Better window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move to left window' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move to lower window' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move to upper window' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move to right window' })

-- Window splitting
vim.keymap.set('n', '<leader>sv', ':vsplit<CR>', { desc = 'Split window vertically' })
vim.keymap.set('n', '<leader>sh', ':split<CR>', { desc = 'Split window horizontally' })
vim.keymap.set('n', '<leader>sc', ':close<CR>', { desc = 'Close current window' })

-- Buffer navigation
vim.keymap.set('n', '<leader>bn', ':bnext<CR>', { desc = 'Next buffer' })
vim.keymap.set('n', '<leader>bp', ':bprevious<CR>', { desc = 'Previous buffer' })
vim.keymap.set('n', '<leader>bd', ':bdelete<CR>', { desc = 'Delete buffer' })

-- Better indenting (keeps selection)
vim.keymap.set('v', '<', '<gv', { desc = 'Indent left' })
vim.keymap.set('v', '>', '>gv', { desc = 'Indent right' })

-- Move lines up/down
vim.keymap.set('n', '<A-j>', ':m .+1<CR>==', { desc = 'Move line down' })
vim.keymap.set('n', '<A-k>', ':m .-2<CR>==', { desc = 'Move line up' })
vim.keymap.set('v', '<A-j>', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })
vim.keymap.set('v', '<A-k>', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })

-- Quick save with Ctrl+s
vim.keymap.set('n', '<C-s>', ':w<CR>', { desc = 'Quick save' })
vim.keymap.set('i', '<C-s>', '<Esc>:w<CR>a', { desc = 'Quick save in insert mode' })

-- Exit insert mode with jj (optional, some people like this)
-- vim.keymap.set('i', 'jj', '<Esc>', { desc = 'Exit insert mode' })

-- Useful for your dual boot setup - quick exit
vim.keymap.set('n', '<leader>Q', ':qa!<CR>', { desc = 'Force quit all' })

