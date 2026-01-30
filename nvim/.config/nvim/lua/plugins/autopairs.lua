return {
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter", -- Only loads when you start typing
		config = true, -- Uses default configuration
		-- Optional: Integration with the autocomplete menu (CMP)
		-- If you press Enter in the suggestion menu, it adjusts the parentheses
		dependencies = { "hrsh7th/nvim-cmp" },
		init = function()
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			local cmp = require("cmp")
			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
		end,
	},
}
