" Some examples:
" - @babel/cli
" - lodash.get
" - react-codemirror2/style.css
" - ../dialog_footer.tsx

" Locate the module nearest the cursor.
func! further#parsing#GetPathUnderCursor() abort
  let l:filename = expand('<cfile>')

  if strlen(l:filename)
    return l:filename
  endif

  return v:null
endfunc

" Extract visually selected text. Works with multiline strings.
" Multiline strings should never be necessary.
func! further#parsing#GetSelectedPath() abort
  let l:col_start = col("'<") - 1
  let l:col_end = col("'>") - l:col_start - 1
  let l:lines = getline("'<", "'>")

  let l:lines[0] = l:lines[0][(l:col_start):-1]
  let l:lines[-1] = l:lines[-1][0:(l:col_end)]

  return join(l:lines, "\n")
endfunc
