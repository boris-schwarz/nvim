" cflsp after-syntax overlay for the bundled cf.vim (vim-coldfusion, 2017).
" Three fixes:
"   1. Strings with a literal `}`/`)`/`>` no longer truncate (keepend bug).
"   2. Embedded CSS / JavaScript in .cfm views get real highlighting —
"      cf.vim disabled these for performance, so <style>/<script> were left
"      uncolored (and CSS `{}` was mis-parsed as code braces).
"   3. Plain HTML tags / entities get real highlighting — cf.vim parses non-cf
"      tags but leaves the tag name uncolored (it consumes it in a transparent
"      region start with no matchgroup), so ordinary markup rendered as Normal.
"
" Everything here is re-applied every time the syntax is sourced (not guarded),
" so the overrides survive a cf.vim reload — a colorscheme change or `:e` re-runs
" syntax/cf.vim (restoring its originals), and this must re-beat them. cf.vim
" clears all items before each reload, so re-defining can't accumulate.
"
" Install: copy to <nvim-config>/after/syntax/cf.vim

" ---------------------------------------------------------------------------
" 0. Embedded CSS / JavaScript syntaxes.
" NOTE: `:syntax include` does NOT clear b:current_syntax, and css.vim/javascript.vim
" both start with `if exists('b:current_syntax') | finish` — so it must be unlet
" *before every include*, or the sub-syntax silently defines nothing.
" ---------------------------------------------------------------------------
unlet! b:current_syntax
sy include @cflspCss syntax/css.vim
unlet! b:current_syntax
sy include @cflspJs syntax/javascript.vim
unlet! b:current_syntax
let b:current_syntax = 'cfml'

" Declare every custom highlight group up front, before any region/match uses it
" as a matchgroup or containedin target. With a colorscheme like catppuccin whose
" ColorScheme autocmd re-runs highlighting, a `hi`/synIDtrans pass can otherwise
" reference a group a moment before its `sy` command (re)creates it → E28. The
" `default` keyword means a real colorscheme link still wins. cflspStyle/cflspScript
" are transparent containers (their content is coloured by the CSS/JS sub-syntax).
" Zed/tree-sitter-like markup colours: tag names blue (Function), <!DOCTYPE> pink
" (Special). (Frappé: Function #8caaee blue, Special #f4b8e4 pink.)
hi def link cflspHtmlTag   Function
hi def link cflspHtmlEntity Special
hi def link cflspDoctype   Special
hi def link cflspStyle     NONE
hi def link cflspScript    NONE

" ---------------------------------------------------------------------------
" 1. String truncation fix — `extend` lets a string survive the container's
"    keepend, so a `}` inside a string stays part of the string.
" ---------------------------------------------------------------------------
sy clear cfmlSingleQuotedValue
sy region cfmlSingleQuotedValue
  \ extend
  \ matchgroup=cfmlSingleQuote
  \ start=/'/
  \ skip=/''/
  \ end=/'/
  \ contains=cfmlHashSurround

sy clear cfmlDoubleQuotedValue
sy region cfmlDoubleQuotedValue
  \ extend
  \ matchgroup=cfmlDoubleQuote
  \ start=/"/
  \ skip=/""/
  \ end=/"/
  \ contains=cfmlHashSurround

hi link cfmlSingleQuotedValue String
hi link cfmlDoubleQuotedValue String

" ---------------------------------------------------------------------------
" 2. Wrap <style>/<script> blocks in regions that own them (defined here in
"    after/syntax so they outrank cf.vim's generic brace/SGML matches).
" ---------------------------------------------------------------------------
" `containedin=cfmlOutputTagRegion` so they also fire inside <cfoutput>…</cfoutput>
" (common in views — the whole page body is often wrapped in one cfoutput).
silent! sy clear cflspStyle
sy region cflspStyle
  \ keepend extend
  \ matchgroup=cfmlTagName
  \ start=+<style\>[^>]*>+
  \ end=+</style>+
  \ contains=@cflspCss
  \ containedin=cfmlOutputTagRegion

silent! sy clear cflspScript
sy region cflspScript
  \ keepend extend
  \ matchgroup=cfmlTagName
  \ start=+<script\>\%(\_[^>]*\)\?>+
  \ end=+</script>+
  \ contains=@cflspJs
  \ containedin=cfmlOutputTagRegion

" ---------------------------------------------------------------------------
" 3. Colour plain HTML markup. cf.vim parses non-cf tags (its `cfmlSGMLTag*`
"    regions, active even inside <cfoutput>) but consumes `<div` in the region's
"    *start match*, which is `transparent` with no `matchgroup` — so the tag name
"    renders as Normal (uncoloured). That's the "funny" look next to coloured cf
"    tags and CSS/JS. Redefine those regions (same names, so they stay wired into
"    cf.vim's `contains=` lists) with a matchgroup, so the `<tag`/`>`/`</tag>`
"    delimiters+name get a colour. Attributes keep cf.vim's links
"    (cfmlAttrName->Type, cfmlAttrValue->Special).
" ---------------------------------------------------------------------------
" the (\<cf|\<style>|\<script>)@! guard leaves <cf…>, <style> and <script> to
" cf.vim and the CSS/JS regions above.
sy clear cfmlSGMLTagStart
sy region cfmlSGMLTagStart
  \ keepend transparent
  \ matchgroup=cflspHtmlTag
  \ start="\v(\<cf|\<style>|\<script>)@!\zs\<\w+"
  \ end=">"
  \ contains=@cfmlAttribute,@cfmlComment,cfmlAttrEqualSign,cfmlTagBracket,cfmlHashSurround

sy clear cfmlSGMLTagEnd
sy region cfmlSGMLTagEnd
  \ keepend transparent
  \ matchgroup=cflspHtmlTag
  \ start="\v(\<\/cf)@!\zs\<\/\w+"
  \ end=">"

" HTML entities (`&amp;`, `&#169;`, `&#x1F600;`) — cf.vim doesn't match these.
" containedin=ALLBUT,<real groups> so entities show in markup text (incl. inside
" <cfoutput>) but not inside comments/strings. Only real *group* names here —
" listing a cluster (e.g. @cfmlComment) as a group triggers E28.
" (cflspHtmlEntity's link is declared up top so it exists before any re-highlight.)
silent! sy clear cflspHtmlEntity
sy match cflspHtmlEntity
  \ containedin=ALLBUT,cfmlCommentBlock,cfmlCommentLine,cfmlSingleQuotedValue,cfmlDoubleQuotedValue
  \ /&\%(#\d\+\|#[xX]\x\+\|[a-zA-Z][a-zA-Z0-9]*\);/

" `<!DOCTYPE html>` — cf.vim leaves it uncoloured; give it its own colour.
silent! sy clear cflspDoctype
sy match cflspDoctype
  \ containedin=ALLBUT,cfmlCommentBlock,cfmlCommentLine,cfmlSingleQuotedValue,cfmlDoubleQuotedValue
  \ /\c<!doctype\_[^>]*>/
