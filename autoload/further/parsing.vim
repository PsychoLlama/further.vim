" Some examples:
" @babel/cli, lodash.get, react-codemirror2/style.css, ../dialog_footer.js
let s:PKG_NAME_CHARS = '\v(\@|\w|\d|_|-|/|\.)'

" Normalize the starting index. If starting on an empty space,
" search forward until locating a word. If no words, return v:null.
func! further#parsing#GetStartColumnIndex(line) abort
  let l:index = col('.') - 1

  while l:index < strlen(a:line)
    let l:char = a:line[l:index]

    if l:char =~? s:PKG_NAME_CHARS
      return l:index
    endif

    " Only search forward through whitespace and quotes.
    if l:char !~# '\v("| |''|`)'
      return v:null
    endif

    let l:index += 1
  endwhile

  return v:null
endfunc

" react-|addons-update
"       ^
"    cursor
" Returns 'react-'
func! further#parsing#ExtractPreceedingExcerpt(line, index) abort
  let l:index = a:index
  let l:excerpt = ''

  while l:index >= 0
    let l:char = a:line[l:index]

    " Stop if the characters don't look like a package anymore.
    if l:char !~? s:PKG_NAME_CHARS
      return l:excerpt
    endif

    let l:excerpt = l:char . l:excerpt
    let l:index -= 1
  endwhile

  return l:excerpt
endfunc

" react-|addons-update
"       ^
"    cursor
" Returns 'addons-update'
func! further#parsing#ExtractPostExcerpt(line, index) abort
  let l:index = a:index + 1
  let l:excerpt = ''

  while l:index <= strlen(a:line)
    let l:char = a:line[l:index]

    " Stop if the characters don't look like a package anymore.
    if l:char !~? s:PKG_NAME_CHARS
      return l:excerpt
    endif

    let l:excerpt .= l:char
    let l:index += 1
  endwhile

  return l:excerpt
endfunc

" Locate the module nearest the cursor.
func! further#parsing#GetPathUnderCursor() abort
  let l:line = getline('.')
  let l:starting_index = further#parsing#GetStartColumnIndex(l:line)

  if l:starting_index is v:null
    return v:null
  endif

  let l:start = further#parsing#ExtractPreceedingExcerpt(l:line, l:starting_index)
  let l:end = further#parsing#ExtractPostExcerpt(l:line, l:starting_index)

  return l:start . l:end
endfunc
