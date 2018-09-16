" Implements the node module resolution algorithm.
" See: https://nodejs.org/api/modules.html#modules_all_together

func! s:IsRelativeImport(path) abort
  let l:first_char = a:path[0]
  return l:first_char is# '.' || l:first_char is# '/'
endfunc

" Parse a library import into two parts:
" (given '@org/scope/path/to/export')
" - the package name (@org/scope)
" - the import path (path/to/export)
func! s:ParseImport(import_path) abort
  let l:is_org = a:import_path[0] is# '@'
  let l:path_parts = split(a:import_path, '/')
  let l:pkg = join(l:path_parts[0:l:is_org], '/')
  let l:path = join(l:path_parts[l:is_org + 1:], '/')

  return { 'pkg_name': l:pkg, 'path': l:path }
endfunc

" Detect and resolve different types of imports. Offloads
" heavy lifting to logic in the resolve/ directory.
func! further#resolve#Import(context, import) abort
  if s:IsRelativeImport(a:import)
    return further#resolve#relative#ImportPath(a:context, a:import)
  endif

  let l:parsed_import = s:ParseImport(a:import)

  if strlen(l:parsed_import.path)
    return further#resolve#package#WithPath(a:context, a:import)
  endif

  let l:pkg_name = l:parsed_import.pkg_name
  let l:pkg_root = further#resolve#package#(a:context, l:pkg_name)
  return further#resolve#package#EntryFile(l:pkg_root)
endfunc
