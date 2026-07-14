-- alternate theme: port of VS Code's "Dark Modern".
-- switch anytime with :colorscheme vscode_modern
return {
	"gmr458/vscode_modern_theme.nvim",
	lazy = false,
	priority = 900,
	config = function()
		require("vscode_modern").setup({
			cursorline = true,
		})
	end,
}
