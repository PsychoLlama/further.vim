" Given a file path, locate every node_modules
" folder it's capable of drawing from.
" `abort` intentionally omitted. `:lcd` must be reset.
func! further#resolve#path#(file_path)
  let l:module_folders = []
  let l:dir = a:file_path

  if !isdirectory(l:dir)
    let l:dir = fnamemodify(l:dir, ':h')
  endif

  call execute('lcd ' . fnameescape(l:dir))
  let l:module_folders = finddir('node_modules', ';', -1)
  lcd -

  return l:module_folders
endfunc
