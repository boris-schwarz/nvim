-- cflsp — see C:/rust/cflsp-rs/docs/editors/neovim.md

vim.filetype.add({
	extension = { cfml = "cf" },
})

-- cflsp tags cf tag names (<cfoutput>, <cfloop>, …) as `macro` semantic tokens;
-- Catppuccin colours @lsp.type.macro mauve. Recolour to the HTML-tag blue so all
-- tags match. Scoped to the `cf` filetype (other languages' macros keep the theme
-- default) and re-applied on ColorScheme (which clears custom highlight links).
local function cflsp_tag_color()
	vim.api.nvim_set_hl(0, "@lsp.type.macro.cf", { link = "Function" })
end
vim.api.nvim_create_autocmd("ColorScheme", { callback = cflsp_tag_color })
cflsp_tag_color()

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

-- only where the binary is installed (Windows dev machine); other machines skip it
if vim.fn.executable("cflsp") == 1 then
	vim.lsp.enable("cflsp")
end
