-- themes (installed via the built-in vim.pack manager, Neovim 0.12+):
--   vscode_modern      — port of VS Code's "Dark Modern"
--   catppuccin-frappe  — switch anytime with :colorscheme catppuccin-frappe
vim.pack.add({
	{ src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
	{ src = "https://github.com/gmr458/vscode_modern_theme.nvim", name = "vscode_modern" },
	-- renders markdown (tables!) in LSP hover floats and completion docs
	{ src = "https://github.com/MeanderingProgrammer/render-markdown.nvim", name = "render-markdown" },
})
require("catppuccin").setup({
	flavour = "frappe",
})
require("vscode_modern").setup({
	cursorline = true,
})
vim.o.background = "dark"
vim.cmd.colorscheme("catppuccin-frappe")

require("render-markdown").setup({
	completions = { lsp = { enabled = true } },
})

-- line numbers: absolute for the current line, relative for the rest (hybrid).
-- makes vertical motions like 5j / 12k easy to count.
vim.o.number = true
vim.o.relativenumber = true

-- cflsp tags cf tag names (<cfoutput>, <cfloop>, …) as `macro` semantic tokens;
-- Catppuccin colours @lsp.type.macro mauve. Recolour to the HTML-tag blue so all
-- tags match. Scoped to the `cf` filetype (other languages' macros keep the theme
-- default) and re-applied on ColorScheme (which clears custom highlight links).
local function cflsp_tag_color()
	vim.api.nvim_set_hl(0, "@lsp.type.macro.cf", { link = "Function" })
end
vim.api.nvim_create_autocmd("ColorScheme", { callback = cflsp_tag_color })
cflsp_tag_color()

-- diagnostics display: Neovim ≥ 0.11 shows only gutter signs by default —
-- show the error message inline at the end of the line too
vim.diagnostic.config({
	virtual_text = true,
	severity_sort = true,
})

-- completion: use Neovim's built-in LSP autocompletion (0.11+). The menu opens
-- automatically on the server's trigger characters (".", "<", "#", '"');
-- <C-y> accepts, <C-n>/<C-p> navigate, <C-x><C-o> triggers manually.
vim.o.completeopt = "menuone,noselect,popup,fuzzy"
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if not (client and client:supports_method("textDocument/completion")) then
			return
		end
		vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })

		-- Built-in autotrigger only fires on the server's trigger chars (. < # " /),
		-- so cf tag attributes (offered after `<cfloop `) never auto-open — a space
		-- isn't a trigger. Also trigger completion while typing inside an open <cf…>
		-- tag, so attributes (collection=, array=, from=, to=, …) pop as you type.
		vim.api.nvim_create_autocmd("TextChangedI", {
			buffer = args.buf,
			callback = function()
				if vim.fn.pumvisible() == 1 then
					return -- menu already open; let built-in completion filter it
				end
				local col = vim.fn.col(".") - 1
				local before = vim.api.nvim_get_current_line():sub(1, col)
				local lt = before:match(".*()<") -- byte pos of the last '<'
				if not lt then
					return
				end
				local frag = before:sub(lt):lower() -- from that '<' to the cursor
				-- inside an unclosed <cf…> tag, past the tag name (a space seen)
				if not frag:find(">") and frag:match("^<cf%w*%s") then
					vim.lsp.completion.get()
				end
			end,
		})
	end,
})

-- cflsp — see C:/rust/cflsp-rs/docs/editors/neovim.md

vim.filetype.add({
	extension = { cfml = "cf" },
})

vim.lsp.config("cflsp", {
	-- installed copy (cargo install --path crates/cflsp) so the build output in
	-- target/release never gets locked by the running editor
	cmd = { "cflsp", "--stdio" },
	filetypes = { "cfml", "cf" },
	root_markers = { "Application.cfc", "Application.cfm", "box.json", ".git" },
	init_options = {
		cfdocs = { path = "C:/home/cfdocs" },
		engine = { name = "lucee", version = "6" },
	},
	settings = {
		cflsp = {
			-- mappings = { ["/model"] = "./model" },
			-- NOTE: empty Lua tables serialize as JSON arrays — only add keys with values
			lints = {
				-- ColdBox config convention: configure() writes unscoped on purpose
				["missing-var-scope"] = { exclude = { "config/**" } },
			},
		},
	},
})

vim.lsp.enable("cflsp")
