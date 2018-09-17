" Support for global module paths (mostly deprecated). Missing
" the `process.config.node_prefix` path since it seems to only
" be available inside Node's runtime as a compilation artifact.
let s:node_path_delimiter = has('win32') ? ';' : ':'
let s:NODE_PATH = split($NODE_PATH, s:node_path_delimiter)
let s:GLOBAL_PATHS = s:NODE_PATH + [
      \   expand('~/.node_modules'),
      \   expand('~/.node_libraries'),
      \ ]

" Coerce every path to an absolute path.
func! s:EnsureAbsolutePath(path) abort
  if a:path[0] is# '/'
    return a:path
  endif

  return fnamemodify(a:path, ':p')
endfunc

" node_modules exception (per spec): if the current path is
" node_modules, don't look in node_modules/node_modules.
func! s:CheckForDoublyNestedNodeModules(file_path, module_folders) abort
  if fnamemodify(a:file_path, ':t') isnot# 'node_modules'
    return
  endif

  " Assume `finddir` found the extra node_modules folder. Remove it.
  let l:decoy_node_modules = simplify(a:file_path . '/node_modules')
  if isdirectory(l:decoy_node_modules)
    call remove(a:module_folders, 0)
  endif
endfunc

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
  call map(l:module_folders, 's:EnsureAbsolutePath(v:val)')
  call s:CheckForDoublyNestedNodeModules(a:file_path, l:module_folders)
  lcd -

  return l:module_folders + s:GLOBAL_PATHS
endfunc
