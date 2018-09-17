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

" Path could be a file or a module directory.
" - path.{ext-list}
" - path/package.json => main
" - path/index.{ext-list}
func! further#resolve#relative#Module(path) abort
  let l:file_path = further#resolve#relative#File(a:path)

  " Check for files before directories.
  if l:file_path isnot# v:null
    return l:file_path
  endif

  " Not a file. Either it's a module or it's invalid.
  return further#resolve#module#EntryPoint(a:path)
endfunc

" Resolve the path either as path.{ext} or path/index.{ext}.
" Do NOT check for a package.json.
func! further#resolve#relative#FileOrIndex(path) abort
  let l:file_path = further#resolve#relative#File(a:path)

  " Check for files before directories.
  if l:file_path isnot# v:null
    return l:file_path
  elseif !isdirectory(a:path)
    return v:null
  endif

  " Try $path/index
  let l:index = simplify(a:path . '/' . s:DEFAULT_ENTRY)
  return further#resolve#relative#File(l:index)
endfunc

" Resolve absolute and relative import paths. Context path
" should be parent directory of the file doing the import.
func! further#resolve#relative#(context, import) abort
  let l:import_path = a:import

  if !s:IsAbsolute(a:import)
    let l:import_path = simplify(a:context . '/' . a:import)
  endif

  return further#resolve#relative#Module(l:import_path)
endfunc
