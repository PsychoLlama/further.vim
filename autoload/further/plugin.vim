" Execute a command once the file path is resolved.
func! s:DoActionWhenFound(action, mode) abort
  if !executable('node')
    echoerr 'Node executable not found (required by further.vim)'
    return
  endif

  let l:context = expand('%:p:h')
  let l:file_name = a:mode is# 'n'
        \ ? further#parsing#GetPathUnderCursor()
        \ : further#parsing#GetSelectedPath()

  if l:file_name is v:null
    echohl Error
    echo 'No file or module under cursor'
    echohl Clear

    return
  endif

  let l:file_path = further#resolve#Import(l:context, l:file_name)
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

func! further#plugin#LocateAndEditFileInSplit(mode) abort range
  call s:DoActionWhenFound('split', a:mode)
endfunc
