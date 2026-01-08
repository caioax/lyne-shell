local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Limpar o destaque da busca
map("n", "<Esc>", ":nohlsearch<CR>", opts)

-- --- EDIÇÃO ---
-- Mover linhas
map("v", "J", ":m '>+1<CR>gv=gv", opts)
map("v", "K", ":m '<-2<CR>gv=gv", opts)

-- --- CLIPBOARD & REGISTRADORES ---

-- 1. Copiar/Colar com o Sistema
map({ "n", "v" }, "<leader>y", [["+y]]) -- Copia para o sistema
map("n", "<leader>Y", [["+Y]])
map({ "n", "v" }, "<leader>p", [["+p]]) -- Cola do sistema

-- 2. Copiar/Colar Interno
-- 'p' sempre cola o último YANK (Registrador 0), ignorando deletes.
map({ "n", "v" }, "p", [["0p]])
map({ "n", "v" }, "P", [["0P]])
-- 3. Colar o que foi deletado/recortado
-- Se você deu 'dd' e quer colar isso, usa esse atalho.
map({ "n", "v" }, "<leader>d", [[""p]])

-- 4. Menu Visual de Registradores (Telescope)
-- Mostra todas as "gavetas" para você escolher o que colar.
map("n", '<leader>"', "<cmd>Telescope registers<cr>", opts)

-- 5. Promover Registrador para o Sistema
-- Atalho: <Space> + y + c
-- Ação: Pergunta qual registrador você quer mandar para o clipboard do sistema.
map("n", "<leader>yc", function()
	local char = vim.fn.input("Register to copy to system: ")
	if char ~= "" then
		local content = vim.fn.getreg(char)
		if content == "" then
			print(" Register '" .. char .. "' is empty!")
			return
		end
		vim.fn.setreg("+", content)
		print(" Register '" .. char .. "' copied to system clipboard!")
	end
end, opts)
