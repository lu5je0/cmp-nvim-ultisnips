" Retrieves additional snippet information that is not directly accessible
" using the UltiSnips API functions. Returns a list of tables (one table
" per snippet) with the keys "trigger", "description", "options" and "value".
"
" If 'expandable_only' is 1, only expandable snippets are returned, otherwise all
" snippets for the current filetype are returned.
function! cmp_nvim_ultisnips#get_current_snippets(expandable_only)
pythonx << EOF
import vim
from UltiSnips import UltiSnips_Manager, vim_helper

expandable_only = vim.eval("a:expandable_only")

is_add_postfix_snippets = False
if expandable_only == "True":
    before = vim_helper.buf.line_till_cursor

    snippets = UltiSnips_Manager._snips(before, True)

    if len(before) > 2 and before[-2] == ".":
        is_add_postfix_snippets = True

    print(snippets)
else:
    snippets = UltiSnips_Manager._snips("", True)

snippets_info = []
vim.command('let g:_cmpu_current_snippets = []')
for snippet in snippets:
    vim.command(
      "call add(g:_cmpu_current_snippets, {"\
        "'trigger': pyxeval('str(snippet._trigger)'),"\
        "'description': pyxeval('str(snippet._description)'),"\
        "'options': pyxeval('str(snippet._opts)'),"\
        "'value': pyxeval('str(snippet._value)'),"\
      "})"
    )
def add_postfix_snippets(snippet):
    vim.command(
      "call add(g:_cmpu_current_snippets, {"\
        "'trigger': '" + snippet + "',"\
        "'description': '" + snippet + "',"\
        "'options': 'w',"\
        "'value': 'postfix snippets',"\
      "})"
    )

if is_add_postfix_snippets:
    add_postfix_snippets(".for")
    add_postfix_snippets(".log")
    add_postfix_snippets(".if")
    add_postfix_snippets(".par")
    add_postfix_snippets(".arg")
    add_postfix_snippets(".print")

EOF
return g:_cmpu_current_snippets
endfunction

" Define silent mappings
imap <silent> <Plug>(cmpu-expand)
\ <C-r>=[UltiSnips#CursorMoved(), UltiSnips#ExpandSnippet()][1]<cr>

imap <silent> <Plug>(cmpu-jump-forwards)
\ <C-r>=[UltiSnips#CursorMoved(), UltiSnips#JumpForwards()][1]<cr>

imap <silent> <Plug>(cmpu-jump-backwards)
\ <C-r>=[UltiSnips#CursorMoved(), UltiSnips#JumpBackwards()][1]<cr>
