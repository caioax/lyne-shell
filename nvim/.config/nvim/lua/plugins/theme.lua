-- Reads the current theme name from ~/.config/nvim/current-theme.txt
local function get_colorscheme()
	local path = vim.fn.expand("~/.config/nvim/current-theme.txt")
	local file = io.open(path, "r")
	if file then
		local name = file:read("*l")
		file:close()
		if name and name ~= "" then
			return vim.trim(name)
		end
	end
	return "tokyonight"
end

-- ============================================================================
-- THEME PLUGINS
-- ============================================================================

return {
	{
		"folke/tokyonight.nvim",
		lazy = true,
		priority = 1000,
		opts = {
			style = "night",
			transparent = false,

			on_highlights = function(hl, c)
				local p = {
					bg = c.bg,
					bg_dark = c.bg_dark,
					bg_float = c.bg_highlight,
					bg_visual = c.bg_visual,
					fg = c.fg,
					fg_dim = c.comment,
					border = c.border_highlight,

					func = c.blue,
					class = c.orange,
					keyword = c.magenta,
					string = c.green,
					number = c.orange,
					property = c.cyan,
					error = c.error,

					git_add = c.git.add,
					git_change = c.git.change,
					git_del = c.git.delete,

					diag_err = c.error,
					diag_warn = c.warning,
					diag_info = c.info,
					diag_hint = c.hint,

					guide = c.fg_gutter,
					scope = c.comment,
				}

				-- General UI
				hl.NormalFloat = { fg = p.fg, bg = p.bg_float }
				hl.FloatBorder = { fg = p.border, bg = p.bg_float }

				hl.Cursor = { bg = p.func, fg = p.bg }
				hl.CursorLine = { bg = p.bg_float }
				hl.CursorLineNr = { fg = p.class, bold = true }

				hl.LineNr = { fg = p.fg_dim }
				hl.SignColumn = { bg = "NONE" }
				hl.EndOfBuffer = { fg = p.bg }

				hl.Visual = { bg = p.bg_visual }
				hl.Search = { fg = p.bg, bg = p.number }
				hl.IncSearch = { fg = p.bg, bg = p.class }

				hl.WinSeparator = { fg = p.border }
				hl.VertSplit = { fg = p.border }
				hl.MatchParen = { fg = p.class, bold = true, underline = true }

				-- Syntax
				hl.Comment = { fg = p.fg_dim, italic = true }
				hl.String = { fg = p.string }
				hl.Number = { fg = p.number }
				hl.Boolean = { fg = p.number, bold = true }

				hl.Function = { fg = p.func, bold = true }
				hl.Identifier = { fg = p.fg }

				hl.Keyword = { fg = p.keyword, italic = true }
				hl.Statement = { fg = p.keyword }
				hl.Conditional = { fg = p.keyword }
				hl.Repeat = { fg = p.keyword }

				hl.Operator = { fg = p.fg_dim }
				hl.Type = { fg = p.class }
				hl.Delimiter = { fg = p.fg_dim }

				-- Treesitter
				hl["@variable"] = { fg = p.fg }
				hl["@variable.builtin"] = { fg = p.keyword }
				hl["@variable.parameter"] = { fg = p.number }

				hl["@variable.member"] = { fg = p.property }
				hl["@property"] = { fg = p.property }

				hl["@function"] = { fg = p.func, bold = true }
				hl["@function.call"] = { fg = p.func }
				hl["@function.builtin"] = { fg = p.func }

				hl["@type"] = { fg = p.class }
				hl["@type.builtin"] = { fg = p.class }
				hl["@constructor"] = { fg = p.class }

				hl["@keyword"] = { fg = p.keyword, italic = true }
				hl["@keyword.import"] = { fg = p.keyword, italic = true }

				hl["@tag"] = { fg = p.class }
				hl["@tag.attribute"] = { fg = p.property }
				hl["@tag.delimiter"] = { fg = p.fg_dim }

				hl["@punctuation.delimiter"] = { fg = p.fg_dim }
				hl["@punctuation.bracket"] = { fg = p.fg_dim }

				-- Telescope
				hl.TelescopeNormal = { bg = p.bg_dark }
				hl.TelescopeBorder = { fg = p.border, bg = p.bg_dark }
				hl.TelescopePromptNormal = { fg = p.fg, bg = p.bg_float }
				hl.TelescopePromptBorder = { fg = p.func, bg = p.bg_float }
				hl.TelescopePromptTitle = { fg = p.bg, bg = p.func, bold = true }
				hl.TelescopeSelection = { bg = p.bg_visual, fg = p.class }

				-- Autocomplete
				hl.Pmenu = { bg = p.bg_float, fg = p.fg_dim }
				hl.PmenuSel = { bg = p.bg_visual, fg = p.fg, bold = true }
				hl.PmenuThumb = { bg = p.border }
				hl.CmpItemAbbrMatch = { fg = p.func, bold = true }
				hl.CmpItemKind = { fg = p.class }

				-- GitSigns
				hl.GitSignsAdd = { fg = p.git_add, bg = "NONE" }
				hl.GitSignsChange = { fg = p.git_change, bg = "NONE" }
				hl.GitSignsDelete = { fg = p.git_del, bg = "NONE" }

				-- Diagnostics
				hl.DiagnosticError = { fg = p.diag_err }
				hl.DiagnosticWarn = { fg = p.diag_warn }
				hl.DiagnosticInfo = { fg = p.diag_info }
				hl.DiagnosticHint = { fg = p.diag_hint }
				hl.DiagnosticUnderlineError = { undercurl = true, sp = p.diag_err }

				-- Indentation
				hl.SnacksIndent = { fg = p.guide }
				hl.SnacksIndentScope = { fg = p.scope }

				-- Neo-tree
				hl.NeoTreeNormal = { bg = p.bg_dark, fg = p.fg }
				hl.NeoTreeNormalNC = { bg = p.bg_dark, fg = p.fg }
				hl.NeoTreeWinSeparator = { fg = p.bg_dark, bg = p.bg_dark }
				hl.NeoTreeEndOfBuffer = { fg = p.bg_dark, bg = p.bg_dark }
				hl.NeoTreeCursorLine = { bg = p.bg_float, bold = true }

				hl.NeoTreeRootName = { fg = p.fg, bold = true, italic = true }
				hl.NeoTreeDirectoryName = { fg = p.func, bold = true }
				hl.NeoTreeDirectoryIcon = { fg = p.func }
				hl.NeoTreeFileName = { fg = p.fg }

				hl.NeoTreeGitAdded = { fg = p.git_add }
				hl.NeoTreeGitModified = { fg = p.git_change }
				hl.NeoTreeGitDeleted = { fg = p.git_del }
				hl.NeoTreeGitConflict = { fg = p.error, bold = true }
				hl.NeoTreeGitUntracked = { fg = p.fg_dim, italic = true }

				hl.NeoTreeIndentMarker = { fg = p.guide }
				hl.NeoTreeExpander = { fg = p.fg_dim }
				hl.NeoTreeSymbolicLinkTarget = { fg = p.property }

				-- Snacks Dashboard
				hl.SnacksDashboardHeader = { fg = p.func }
				hl.SnacksDashboardIcon = { fg = p.func }
				hl.SnacksDashboardDesc = { fg = p.fg }
				hl.SnacksDashboardKey = { fg = p.number, bold = true }
				hl.SnacksDashboardFooter = { fg = p.fg_dim }
				hl.SnacksDashboardSpecial = { fg = p.string }
			end,
		},
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = true,
		priority = 1000,
		opts = { flavour = "mocha" },
	},
	{
		"ellisonleao/gruvbox.nvim",
		lazy = true,
		priority = 1000,
		opts = { contrast = "hard" },
	},
	{
		"Mofiqul/dracula.nvim",
		lazy = true,
		priority = 1000,
	},
	{
		"shaunsingh/nord.nvim",
		lazy = true,
		priority = 1000,
	},
	{
		"rose-pine/neovim",
		name = "rose-pine",
		lazy = true,
		priority = 1000,
		opts = { variant = "main" },
	},
	{
		dir = vim.fn.stdpath("config"),
		name = "theme-loader",
		lazy = false,
		priority = 999,
		config = function()
			local scheme = get_colorscheme()
			local ok, _ = pcall(vim.cmd.colorscheme, scheme)
			if not ok then
				vim.cmd.colorscheme("tokyonight")
			end
		end,
	},
}
