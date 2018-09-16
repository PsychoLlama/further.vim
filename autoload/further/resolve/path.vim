" Support for global module paths (mostly deprecated). Missing
" the `process.config.node_prefix` path since it seems to only
" be available inside Node's runtime as a compilation artifact.
let s:node_path_delimiter = has('win32') ? ';' : ':'
let s:NODE_PATH = split($NODE_PATH, s:node_path_delimiter)
let s:GLOBAL_PATHS = s:NODE_PATH + [
      \   expand('~/.node_modules'),
      \   expand('~/.node_libraries'),
      \ ]

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

  return l:module_folders + s:GLOBAL_PATHS
endfunc
