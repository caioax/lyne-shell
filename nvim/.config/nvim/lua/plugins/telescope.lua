return {
	"nvim-telescope/telescope.nvim",
	branch = "master",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
	},
	keys = {
		{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
		{ "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Find Text" },
		{ "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Open Buffers" },
	},
	config = function()
		require("telescope").setup({
			defaults = {
				path_display = { "tail" }, -- Show only the file name, hide the long path
				file_ignore_patterns = { "node_modules", ".git" }, -- Ignore heavy folders

				-- === Side preview configuration ===
				sorting_strategy = "ascending", -- Make the list start from the top
				layout_strategy = "horizontal", -- Ensure side-by-side layout
				layout_config = {
					horizontal = {
						prompt_position = "top", -- Search bar at the top
						preview_width = 0.6, -- Preview takes 60% of the width
					},
					width = 0.85,
					height = 0.85,
				},
			},
		})
	end,
}
