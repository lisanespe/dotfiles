local vim = vim
local Plug = vim.fn['plug#']

vim.call('plug#begin', '~/dotfiles/config/misc/nvim/plugged')

Plug('https://github.com/vague-theme/vague.nvim')
Plug('https://github.com/rebelot/kanagawa.nvim')
vim.call('plug#end')
