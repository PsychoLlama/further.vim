if exists('b:further_initialized')
  finish
endif

let b:further_initialized = 1

" Get content immediately following the cursor.
function! further#get_content_following_cursor() abort
  let l:column = getcurpos()[2] - 1
  let l:line = getline('.')

  return strpart(l:line, l:column)
endfunction

" Figure out if the import uses single or double quotes.
function! further#get_string_delimiter(following_cursor) abort
  return a:following_cursor =~# "'" ? "'" : '"'
endfunction

" Extract the file path from an import or require(...).
function! further#get_file_path(delimiter) abort
  let l:prev_reg_contents = getreg('"')

  " Yank string contents then return to original position.
  let l:cmd = 'm2yi' . a:delimiter . '`2'
  execute 'normal! ' . l:cmd
  let l:file_path = getreg('"')

  " Restore previous register contents.
  call setreg('"', l:prev_reg_contents)

  return l:file_path
endfunction

" Locate the module nearest the cursor.
function! further#get_file_under_cursor() abort
  let l:following_cursor = further#get_content_following_cursor()
  let l:delimiter = further#get_string_delimiter(l:following_cursor)

  return further#get_file_path(l:delimiter)
endfunction

" Query `require.resolve` for an absolute file path.
function! further#resolve_file_location(path) abort
  let l:current_dir = expand('%:p:h')
  let l:cd_cmd = 'cd ' . shellescape(l:current_dir)
  let l:node_expr = '' .
        \ 'try {' .
        \ '  require.resolve(' . shellescape(a:path) . ')' .
        \ '} catch (error) {' .
        \ '  ""' .
        \ '}'

  let l:node_cmd = 'node -p ' . shellescape(l:node_expr)

  return substitute(system(l:cd_cmd . ' && ' . l:node_cmd), "\n", '', '')
endfunction

" Resolve an absolute path to the module beneath the cursor.
function! further#resolve_path_under_cursor() abort
  let l:file_name = further#get_file_under_cursor()
  let l:file_path = further#resolve_file_location(l:file_name)

  if !filereadable(l:file_path)
    echom 'Can''t find module "' . l:file_name . '".'
  endif

  return l:file_path
endfunction

" Format a path relative to the current file's directory.
function! further#get_local_file_name(module) abort
  if a:module[0] ==# '/'
    return a:module
  endif

  let l:current_dir = expand('%:p:h')
  let l:prefix = '/'

  " ~/current/dir + / + some-file.ext
  return l:current_dir . l:prefix . a:module
endfunction

" Execute a command once the file path is resolved.
function! s:do_action_when_found(action) abort
  if !executable('node')
    echoerr 'Node executable not found (required by further.vim)'
    return
  endif

  let l:file_name = further#get_file_under_cursor()
  let l:file_path = further#get_local_file_name(l:file_name)

  " Before asking Node, see if the file exists as a relative path.
  if !filereadable(l:file_path)
    let l:file_path = further#resolve_file_location(l:file_name)
  endif

  if exists('*FurtherMapModuleName')
    let l:file_path = g:FurtherMapModuleName(l:file_path, l:file_name)
  endif

  if filereadable(l:file_path)
    execute a:action . ' ' . l:file_path
  else
    echom 'Can''t find module "' . l:file_name . '".'
  endif
endfunction

" Edit the resolved file location in the current pane.
function! further#locate_and_edit_file() abort
  call s:do_action_when_found('edit')
endfunction

" Edit the resolved file location in a new tab.
function! further#locate_and_edit_file_in_new_tab() abort
  call s:do_action_when_found('tabedit')
endfunction
