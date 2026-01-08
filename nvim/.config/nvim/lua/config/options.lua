local opt = vim.opt

opt.number = true -- Mostra número da linha
opt.relativenumber = true -- Números relativos
opt.tabstop = 4 -- Tamanho do Tab
opt.shiftwidth = 4 -- Tamanho da indentação
opt.expandtab = true -- Converte Tab em Espaços
opt.autoindent = true -- Mantém indentação na nova linha
opt.wrap = true -- Quebra linha longa visualmente
opt.ignorecase = true -- Busca ignora maiúscula/minúscula...
opt.smartcase = true -- ...a menos que você digite uma maiúscula
opt.cursorline = true -- Destaca a linha atual
opt.termguicolors = true -- Cores reais (24-bit)
opt.scrolloff = 8 -- Mantém 8 linhas de margem ao rolar a tela
-- opt.clipboard = "unnamedplus" -- Integra com o clipboard do sistema

-- Leader Key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ============================================================================
-- CONFIGURAÇÃO DE DOBRAS (FOLDS)
-- ============================================================================
opt.foldmethod = "expr" -- Usa a inteligência do Treesitter para saber onde dobrar
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"

opt.foldlevel = 99 -- Começa com tudo aberto (só dobra se for nível 99+)
opt.foldlevelstart = 99 -- Garante que arquivos novos abram expandidos
opt.foldenable = true -- Habilita o sistema (mas começa aberto por causa do 99)
