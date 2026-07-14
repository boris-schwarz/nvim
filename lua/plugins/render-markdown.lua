-- renders markdown (tables!) in LSP hover floats and completion docs
return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	opts = {
		completions = { lsp = { enabled = true } },
	},
}
