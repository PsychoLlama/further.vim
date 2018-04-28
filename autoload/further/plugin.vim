" Query `require.resolve` for an absolute file path.
func! further#plugin#ResolveFileLocation(path) abort
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
endfunc

" Format a path relative to the current file's directory.
func! further#plugin#GetLocalFileName(module) abort
  if a:module[0] ==# '/'
    return a:module
  endif

  let l:current_dir = expand('%:p:h')
  let l:prefix = '/'

  " ~/current/dir + / + some-file.ext
  return l:current_dir . l:prefix . a:module
endfunc

" Execute a command once the file path is resolved.
func! s:DoActionWhenFound(action, mode) abort
  if !executable('node')
    echoerr 'Node executable not found (required by further.vim)'
    return
  endif

  let l:file_name = a:mode is# 'n'
        \ ? further#parsing#GetPathUnderCursor()
        \ : further#parsing#GetSelectedPath()

  if l:file_name is v:null
    echohl Error
    echo 'No file or module under cursor'
    echohl Clear

    return
  endif

  let l:file_path = further#plugin#GetLocalFileName(l:file_name)

  " Before asking Node, see if the file exists as a relative path.
  if !filereadable(l:file_path)
    let l:file_path = further#plugin#ResolveFileLocation(l:file_name)
  endif

  if exists('*FurtherMapModuleName')
    let l:file_path = g:FurtherMapModuleName(l:file_path, l:file_name)
  endif

  if filereadable(l:file_path)
    execute a:action . ' ' . l:file_path
  else
    echom 'Can''t find module "' . l:file_name . '".'
  endif
endfunc

" Edit the resolved file location in the current pane.
func! further#plugin#LocateAndEditFile(mode) abort range
  call s:DoActionWhenFound('edit', a:mode)
endfunc

" Edit the resolved file location in a new tab.
func! further#plugin#LocateAndEditFileInNewTab(mode) abort range
  call s:DoActionWhenFound('tabedit', a:mode)
endfunc
