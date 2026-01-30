local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Clear search highlight
map("n", "<Esc>", ":nohlsearch<CR>", opts)

-- --- EDITING ---
-- Move lines
map("v", "J", ":m '>+1<CR>gv=gv", opts)
map("v", "K", ":m '<-2<CR>gv=gv", opts)

-- --- CLIPBOARD & REGISTERS ---

-- 1. SYSTEM (Top Priority)
-- Default behavior now interacts with the system Ctrl+C/V
map({ "n", "v" }, "y", [["+y]]) -- Copy to system
map("n", "Y", [["+Y]])
map({ "n", "v" }, "p", [["+p]]) -- Paste from system (replaces text in visual mode)
map({ "n", "v" }, "P", [["+P]]) -- Paste before cursor

-- 2. INTERNAL "SAFE" (With Leader)
-- Uses register "0". This register only stores what you explicitly COPIED (y).
-- It is NEVER polluted by things you deleted (dd). It's your "safe" backup.
map({ "n", "v" }, "<leader>y", [["0y]]) -- Internal Yank (Safe)
map({ "n", "v" }, "<leader>p", [["0p]]) -- Internal Paste (Safe)

-- 3. PASTE DELETED (Mnemonic: Paste Deleted)
-- If you used 'dd' or 'x', the text goes to the default register (").
-- Use this shortcut to recover something you just deleted.
map({ "n", "v" }, "<leader>dp", [[""p]])

-- 4. VIEW REGISTERS (Telescope)
-- When in doubt, open the visual menu to choose what to paste
map("n", '<leader>"', "<cmd>Telescope registers<cr>", opts)

-- 5. Promote Register to System (Utility)
-- <Space> + y + c -> Asks which register to send to the system
map("n", "<leader>yc", function()
	local char = vim.fn.input("Which register to send to system? ")
	if char ~= "" then
		local content = vim.fn.getreg(char)
		if content == "" then
			print(" Register '" .. char .. "' is empty!")
			return
		end
		vim.fn.setreg("+", content)
		print(" Contents of '" .. char .. "' sent to Clipboard!")
	end
end, opts)
