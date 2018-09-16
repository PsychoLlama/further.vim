" Public APIs. Be careful.

" Given an import string, resolve the full module path.
" @param  {string} import - The import string (e.g. 'lodash/package')
" @param  {string} [context] - Originating file or directory.
" @return {string|v:null} - Absolute path to the module (or null).
func! further#Resolve(...) abort
  let l:context = get(a:, 2, expand('%:p'))
  let l:import = a:1

  " The import context is the importing file's parent directory.
  if filereadable(l:context)
    let l:context = fnamemodify(l:context, ':h')
  endif

  return further#resolve#Import(l:context, l:import)
endfunc

" Enable further in the current buffer. Cannot be undone.
" @return {void}
func! further#Initialize() abort
  call further#mappings#Initialize()
endfunc
