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
  return further#resolve#relative#FileOrDirectory(l:full_path)
endfunc

" Pull `main` from the package.json file. Try to be clever.
func! s:GetMainPackageExport(pkg_json) abort
  if a:pkg_json is# v:null | return v:null | endif

  " Try several entry point conventions.
  let l:main = get(a:pkg_json, 'main', s:DEFAULT_ENTRY)
  let l:jsnext = get(a:pkg_json, 'jsnext:main', l:main)
  let l:module = get(a:pkg_json, 'module', l:jsnext)

  let l:prefer_module = get(g:, 'further#prefer_module', v:false)
  return l:prefer_module ? l:module : l:main
endfunc

" Given a package directory, find the main export file.
" If the file doesn't exist or can't be inferred, return null.
func! further#resolve#package#EntryFile(pkg_root) abort
  let l:pkg_json_path = simplify(a:pkg_root . '/package.json')
  let l:pkg = s:ReadPackageJson(l:pkg_json_path)
  let l:main = s:GetMainPackageExport(l:pkg)

  " Entry point was provided.
  if l:main isnot# v:null
    let l:entry_path = simplify(a:pkg_root . '/' . l:main)
    let l:main_export = further#resolve#relative#FileOrDirectory(l:entry_path)

    " Fall back to <lib>/index lookup if main field
    " is invalid (yes, that's what the spec says).
    if filereadable(l:main_export)
      return l:main_export
    endif
  endif

  " No entry point specified. Try to resolve `<lib>/index`.
  let l:file_path = simplify(a:pkg_root . '/' . s:DEFAULT_ENTRY)
  return further#resolve#relative#File(l:file_path)
endfunc

" If the file exists, try to parse it as json, otherwise
" return null. Fail silently if the json is invalid (e.g. json5).
func! s:ReadPackageJson(pkg_json_path) abort
  if !filereadable(a:pkg_json_path)
    return v:null
  endif

  let l:contents = readfile(a:pkg_json_path)
  let l:contents = join(l:contents, "\n")

  silent! let l:pkg_json = json_decode(l:contents)
  if l:pkg_json isnot# 0
    return l:pkg_json
  endif

  return v:null
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
  return further#resolve#package#EntryFile(l:pkg_root)
endfunc
