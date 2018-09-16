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
  let l:file_path = further#resolve#relative#File(a:path)

  " Check for files before directories.
  if l:file_path isnot# v:null
    return l:file_path
  endif

  " Not a file. Maybe it's a directory?
  if isdirectory(a:path)
    let l:file = simplify(a:path . '/' . s:DEFAULT_ENTRY)
    return further#resolve#relative#File(l:file)
  endif

  return v:null
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
