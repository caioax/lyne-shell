local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Tecla Mestra já foi definida como Espaço no options.lua

-- --- ATALHOS GERAIS ---

-- Limpar o destaque da busca (search highlight) apertando Esc
map("n", "<Esc>", ":nohlsearch<CR>", opts)

-- --- NAVEGAÇÃO DE JANELAS (SPLITS) ---
-- Em vez de Ctrl+w depois h/j/k/l, use direto Ctrl + direção
map("n", "<C-h>", "<C-w>h", opts) -- Esquerda
map("n", "<C-j>", "<C-w>j", opts) -- Baixo
map("n", "<C-k>", "<C-w>k", opts) -- Cima
map("n", "<C-l>", "<C-w>l", opts) -- Direita

-- Redimensionar janelas com Setas
map("n", "<C-Up>", ":resize -2<CR>", opts)
map("n", "<C-Down>", ":resize +2<CR>", opts)
map("n", "<C-Left>", ":vertical resize -2<CR>", opts)
map("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Mover linhas selecionadas para cima/baixo (Modo Visual)
map("v", "J", ":m '>+1<CR>gv=gv", opts)
map("v", "K", ":m '<-2<CR>gv=gv", opts)
