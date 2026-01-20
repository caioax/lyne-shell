return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		-- 1. Import Tokyo Night colors
		-- We load the palette to use it in your custom configuration
		local colors = require("tokyonight.colors").setup()

		-- 2. Map Tokyo Night colors to your 'p' variable
		local p = {
			bg = colors.bg,
			bg_dark = colors.bg_dark,
			bg_float = colors.bg_highlight, -- Lighter background
			fg = colors.fg,
			fg_dim = colors.comment, -- Dimmed text (gray)
			func = colors.blue,
			string = colors.green,
			class = colors.orange,
			error = colors.red,
			number = colors.yellow,
			diag_err = colors.error,
			diag_warn = colors.warning,
			diag_info = colors.info,
		}

		-- 3. Define your Custom Theme using the mapped colors
		local custom_theme = {
			normal = {
				a = { bg = p.func, fg = p.bg, gui = "bold" },
				b = { bg = p.bg_float, fg = p.fg },
				c = { bg = p.bg_dark, fg = p.fg_dim },
			},
			insert = {
				a = { bg = p.string, fg = p.bg_dark, gui = "bold" },
				b = { bg = p.bg_float, fg = p.fg },
				c = { bg = p.bg_dark, fg = p.fg_dim },
			},
			visual = {
				a = { bg = p.class, fg = p.bg_dark, gui = "bold" },
				b = { bg = p.bg_float, fg = p.fg },
				c = { bg = p.bg_dark, fg = p.fg_dim },
			},
			replace = {
				a = { bg = p.error, fg = p.bg, gui = "bold" },
				b = { bg = p.bg_float, fg = p.fg },
				c = { bg = p.bg_dark, fg = p.fg_dim },
			},
			command = {
				a = { bg = p.number, fg = p.bg, gui = "bold" },
				b = { bg = p.bg_float, fg = p.fg },
				c = { bg = p.bg_dark, fg = p.fg_dim },
			},
			inactive = {
				a = { bg = p.bg_dark, fg = p.fg_dim, gui = "bold" },
				b = { bg = p.bg_dark, fg = p.fg_dim },
				c = { bg = p.bg_dark, fg = p.fg_dim },
			},
		}

		-- 4. Setup Lualine
		require("lualine").setup({
			options = {
				theme = custom_theme, -- Using your custom theme
				component_separators = { left = "|", right = "|" },
				section_separators = { left = "", right = "" },
				globalstatus = true,
				disabled_filetypes = { statusline = { "dashboard", "alpha", "starter" } },
			},
			sections = {
				lualine_a = {
					{ "mode", separator = { left = "" }, right_padding = 2 },
				},
				lualine_b = {
					"branch",
					{ "diff", colored = true },
				},
				lualine_c = {
					{ "filename", path = 1 },
				},
				lualine_x = {
					{
						"diagnostics",
						sources = { "nvim_diagnostic" },
						symbols = { error = " ", warn = " ", info = " " },
						diagnostics_color = {
							error = { fg = p.diag_err },
							warn = { fg = p.diag_warn },
							info = { fg = p.diag_info },
						},
					},
					"filetype",
				},
				lualine_y = { "progress" },
				lualine_z = {
					{ "location", separator = { right = "" }, left_padding = 2 },
				},
			},
		})
	end,
}
