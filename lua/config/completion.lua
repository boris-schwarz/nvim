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
