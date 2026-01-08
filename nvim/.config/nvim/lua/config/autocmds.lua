-- INTEGRAÇÃO COM TMUX (Gerenciamento de Títulos)

-- Permite que o Neovim altere o título da janela do terminal
vim.opt.title = true
vim.opt.titlelen = 0 -- Não trunca nativamente (deixa nossa lógica controlar)

local function set_window_title()
	-- Pega o nome do arquivo atual e o tipo
	local filename = vim.fn.expand("%:t")
	local filetype = vim.bo.filetype

	-- Lógica para buffers especiais (que não são arquivos reais)
	if filename == "" or filetype == "snacks_dashboard" then
		if filetype == "neo-tree" then
			filename = "explorer"
		elseif filetype == "snacks_dashboard" then
			filename = "dashboard"
		elseif filetype == "TelescopePrompt" then
			filename = "telescope"
		else
			filename = "nvim" -- Fallback padrão
		end
	end

	-- Aplica o título
	vim.opt.titlestring = filename
end

-- Gatilhos: Atualiza o título ao entrar no buffer, trocar janela ou ganhar foco
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "FocusGained", "VimResume" }, {
	group = vim.api.nvim_create_augroup("tmux_window_title", { clear = true }),
	callback = set_window_title,
})

-- FEEDBACK VISUAL (UX)

-- Highlight on Yank: Faz o texto piscar ao ser copiado (y)
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Piscar texto ao copiar (Yank)",
	group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank({
			higroup = "IncSearch", -- A cor do destaque (IncSearch inverte as cores, dando alto contraste)
			timeout = 150, -- Duração do efeito em milissegundos
		})
	end,
})
