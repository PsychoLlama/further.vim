" Get content immediately following the cursor.
func! further#parsing#GetContentFollowingCursor() abort
  let l:column = getcurpos()[2] - 1
  let l:line = getline('.')

  return strpart(l:line, l:column)
endfunc

" Figure out if the import uses single or double quotes.
func! further#parsing#GetDelimiterType(following_cursor) abort
  return a:following_cursor =~# "'" ? "'" : '"'
endfunc

" Extract the file path from an import or require(...).
func! further#parsing#ExtractFilePath(delimiter) abort
  let l:prev_reg_contents = getreg('"')

  " Yank string contents then return to original position.
  let l:cmd = 'm2yi' . a:delimiter . '`2'
  execute 'normal! ' . l:cmd
  let l:file_path = getreg('"')

  " Restore previous register contents.
  call setreg('"', l:prev_reg_contents)

  return l:file_path
endfunc

" Locate the module nearest the cursor.
func! further#parsing#GetPathUnderCursor() abort
  let l:following_cursor = further#parsing#GetContentFollowingCursor()
  let l:delimiter = further#parsing#GetDelimiterType(l:following_cursor)

  return further#parsing#ExtractFilePath(l:delimiter)
endfunc
