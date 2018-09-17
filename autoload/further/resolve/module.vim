" High-level:
" If $DIR/package.json then
"   load file($DIR + pkg.main) or
"   load file($DIR + pkg.main + 'index')
" else load index($DIR)

let s:DEFAULT_ENTRY = g:further#constants#DEFAULT_ENTRY

" If the file exists, try to parse it as json, otherwise
" return null. Fail silently if the json is invalid (e.g. json5).
func! further#resolve#module#PackageJson(directory) abort
  let l:pkg_json_path = simplify(a:directory . '/package.json')
  if !filereadable(l:pkg_json_path)
    return v:null
  endif

  let l:contents = readfile(l:pkg_json_path)
  let l:contents = join(l:contents, "\n")

  silent! let l:pkg_json = json_decode(l:contents)
  if l:pkg_json isnot# 0
    return l:pkg_json
  endif

  return v:null
endfunc

" Pull `main` from the package.json file. Try to be clever.
func! s:GetMainPackageExport(pkg_json) abort
  if a:pkg_json is# v:null | return v:null | endif

  " Try several entry point conventions.
  let l:main = get(a:pkg_json, 'main', s:DEFAULT_ENTRY)
  let l:jsnext = get(a:pkg_json, 'jsnext:main', l:main)
  let l:module = get(a:pkg_json, 'module', l:jsnext)

  let l:prefer_module = get(g:, 'further#prefer_modules', v:false)
  return l:prefer_module ? l:module : l:main
endfunc

" Given a directory, find the main export file.
" If the file doesn't exist or can't be inferred, return null.
func! further#resolve#module#EntryPoint(pkg_root) abort
  let l:pkg = further#resolve#module#PackageJson(a:pkg_root)
  let l:main = s:GetMainPackageExport(l:pkg)

  " Entry point was provided.
  if l:main isnot# v:null
    let l:entry_path = simplify(a:pkg_root . '/' . l:main)
    let l:main_export = further#resolve#relative#FileOrIndex(l:entry_path)

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
