" Implements the node module resolution algorithm.
" See: https://nodejs.org/api/modules.html#modules_all_together

func! s:IsRelativeImport(path) abort
  let l:first_char = a:path[0]
  return l:first_char is# '.' || l:first_char is# '/'
endfunc

" Detect and resolve different types of imports. Offloads
" heavy lifting to logic in the resolve/ directory.
func! further#resolve#Import(context, import) abort
  if s:IsRelativeImport(a:import)
    return further#resolve#relative#ImportPath(a:context, a:import)
  endif

  return further#resolve#package#(a:context, a:import)
endfunc
