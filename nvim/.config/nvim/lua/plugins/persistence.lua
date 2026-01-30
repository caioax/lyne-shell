return {
	"folke/persistence.nvim",
	event = "BufReadPre", -- Only loads when you open a file
	opts = {
		-- Where to save sessions (default is ~/.local/state/nvim/sessions)
		-- dir = vim.fn.expand(vim.fn.stdpath("state") .. "/sessions/"),

		-- Minimum open buffers to save the session
		need = 1,

		-- Save session based on git branch? (Useful when working on multiple features)
		branch = true,
	},
	keys = {
		-- Shortcut to restore the session for the current directory
		{
			"<leader>qs",
			function()
				require("persistence").load()
			end,
			desc = "Restore Session",
		},

		-- Shortcut to restore the LAST session you used (any folder)
		{
			"<leader>ql",
			function()
				require("persistence").load({ last = true })
			end,
			desc = "Restore Last Session",
		},

		-- Shortcut to stop recording the current session (useful for quick tasks)
		{
			"<leader>qd",
			function()
				require("persistence").stop()
			end,
			desc = "Don't Save Current Session",
		},
	},
}
