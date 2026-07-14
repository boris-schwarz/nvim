return {
	"nvim-neo-tree/neo-tree.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	-- Load at startup so it can intercept directory arguments (`nvim .`)
	-- and show itself as a sidebar instead of letting netrw take the window.
	lazy = false,
	keys = {
		{ "<leader>t", "<cmd>Neotree toggle<cr>", desc = "Toggle file tree" },
	},
	opts = {
		window = {
			width = 25,
			mappings = {
				-- Free up H so the global <S-h> buffer-cycle reaches the tree.
				["H"] = "none",
				-- Relocate neo-tree's show/hide-dotfiles to zh.
				["zh"] = "toggle_hidden",
			},
		},
		filesystem = {
			-- When opening a directory (e.g. `nvim .`), show neo-tree as a
			-- left sidebar instead of taking over the whole window.
			hijack_netrw_behavior = "open_default",
		},
	},
}
