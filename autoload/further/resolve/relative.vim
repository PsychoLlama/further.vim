let s:DEFAULT_ENTRY = g:further#constants#DEFAULT_ENTRY
let s:CUSTOM_EXTENSIONS = g:further#constants#CUSTOM_EXTENSIONS
let s:BUILT_IN_EXTENSIONS = g:further#constants#BUILT_IN_EXTENSIONS
let s:DEFAULT_EXTENSIONS = g:further#constants#DEFAULT_EXTENSIONS

" If the file exists with any whitelisted extension,
" return the path. Otherwise return null.
func! further#resolve#relative#File(path) abort
  " Always check for an exact match first.
  let l:extensions = ['']
        \ + s:BUILT_IN_EXTENSIONS
        \ + s:DEFAULT_EXTENSIONS
        \ + s:CUSTOM_EXTENSIONS

  " Return the first result that points to a readable file.
  for l:extension in l:extensions
    let l:file_path = a:path . l:extension

    if filereadable(l:file_path)
      return l:file_path
    endif
  endfor

  return v:null
endfunc

func! s:IsAbsolute(import) abort
  return a:import[0] is# '/'
endfunc

" Resolve the path as either a file or a directory.
func! further#resolve#relative#FileOrDirectory(path) abort
  let l:file = a:path
  if isdirectory(l:file)
    let l:file = simplify(l:file . '/' . s:DEFAULT_ENTRY)
  endif

  return further#resolve#relative#File(l:file)
endfunc

" Resolve absolute and relative import paths. Context path
" should be parent directory of the file doing the import.
func! further#resolve#relative#(context, import) abort
  if s:IsAbsolute(a:import)
    return further#resolve#relative#FileOrDirectory(a:import)
  endif

  let l:import_path = simplify(a:context . '/' . a:import)
  return further#resolve#relative#FileOrDirectory(l:import_path)
endfunc
