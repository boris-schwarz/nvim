" cflsp after-syntax overlay for Neovim's built-in html.vim.
"
" Makes plain .html files match the Catppuccin / tree-sitter look Zed shows,
" which is easier on the eyes than html.vim's defaults:
"   - tag names blue, not mauve (html.vim links htmlTagName -> Statement)
"   - <!DOCTYPE …> pink, not comment-gray (html.vim lumps it into htmlComment)
"
" Install: copy to <nvim-config>/after/syntax/html.vim
" (The same colours are applied to HTML inside .cfm views by after/syntax/cf.vim.)

" Tag names -> blue. `hi link` (not `def`) so it overrides the link a colorscheme
" already set (catppuccin links htmlTagName -> Statement). Runs on file open, after
" the startup colorscheme, so it wins.
hi link htmlTagName Function

" <!DOCTYPE …> as its own group. Defined here in after/syntax, so it outranks the
" htmlComment region html.vim uses for `<! … >`.
silent! sy clear htmlspDoctype
sy match htmlspDoctype /\c<!doctype\_[^>]*>/
hi def link htmlspDoctype Special
