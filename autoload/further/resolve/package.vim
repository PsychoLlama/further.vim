let s:DEFAULT_ENTRY = g:further#constants#DEFAULT_ENTRY

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

" Scan every node_modules folder for a directory matching
" node_modules/<package-name>
func! s:ResolveModuleFromPath(pkg, path) abort
  for l:module_directory in a:path
    let l:pkg_path = l:module_directory . '/' . a:pkg

    if isdirectory(l:pkg_path)
      return l:pkg_path
    endif
  endfor

  return v:null
endfunc

" Find the absolute library path, given a library name.
" Org-scoped packages are fully supported.
" e.g. further#resolve#package#ByName('react')
func! further#resolve#package#ByName(context, pkg_name) abort
  let l:paths = further#resolve#path#(a:context)
  let l:abs_path = s:ResolveModuleFromPath(a:pkg_name, l:paths)

  if l:abs_path isnot# v:null
    return l:abs_path
  endif

  return v:null
endfunc

" Resolve libary imports with a trailing import path, e.g.
" import @org/pkg/package.json
func! further#resolve#package#WithPath(context, pkg_path) abort
  let l:parsed_import = s:ParseImport(a:pkg_path)
  let l:pkg_name = l:parsed_import.pkg_name
  let l:pkg_root = further#resolve#package#ByName(a:context, l:pkg_name)

  if l:pkg_root is# v:null
    return v:null
  endif

  let l:full_path = simplify(l:pkg_root . '/' . l:parsed_import.path)
  return further#resolve#relative#Module(l:full_path)
endfunc

" Split between package#ByName and package#WithPath.
func! further#resolve#package#(context, import) abort
  let l:parsed_import = s:ParseImport(a:import)

  " import 'package/src/file'
  if strlen(l:parsed_import.path)
    return further#resolve#package#WithPath(a:context, a:import)
  endif

  " import 'package'
  let l:pkg_name = l:parsed_import.pkg_name
  let l:pkg_root = further#resolve#package#ByName(a:context, l:pkg_name)
  return further#resolve#module#EntryPoint(l:pkg_root)
endfunc
