-- Basic settings
vim.opt.scrolloff = 8
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

-- Key mappings
vim.g.mapleader = ' '

-- Normal mode mappings
vim.keymap.set('n', '<leader>e', ':Vex<CR>')
vim.keymap.set('n', '<C-j>', ':cnext<CR>')
vim.keymap.set('n', '<C-k>', ':cprev<CR>')
vim.keymap.set('n', '<leader>y', '"+y')
vim.keymap.set('n', '<leader>Y', 'ggVG"+y')
vim.keymap.set('n', '<leader>d', '"_d')

-- Visual mode mappings
vim.keymap.set('v', '<leader>p', '"_dP')
vim.keymap.set('v', '<leader>y', '"+y')
vim.keymap.set('v', '<leader>d', '"_d')

require("config.lazy")