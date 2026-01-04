local opt = vim.opt

opt.number = true          -- Mostra número da linha
opt.relativenumber = true  -- Números relativos (bom para pular linhas com j/k)
opt.tabstop = 4            -- Tamanho do Tab
opt.shiftwidth = 4         -- Tamanho da indentação
opt.expandtab = true       -- Converte Tab em Espaços
opt.autoindent = true      -- Mantém indentação na nova linha
opt.wrap = false           -- Não quebra linha longa visualmente
opt.ignorecase = true      -- Busca ignora maiúscula/minúscula...
opt.smartcase = true       -- ...a menos que você digite uma maiúscula
opt.cursorline = true      -- Destaca a linha atual
opt.termguicolors = true   -- Cores reais (24-bit)
opt.scrolloff = 8          -- Mantém 8 linhas de margem ao rolar a tela
opt.clipboard = "unnamedplus" -- Integra com o clipboard do sistema (Ctrl+C / Ctrl+V)

-- Leader Key
vim.g.mapleader = " "
vim.g.maplocalleader = " "
