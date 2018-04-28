func! further#mappings#Initialize() abort
  if exists('b:further_mappings_defined')
    return
  endif

  let b:further_mappings_defined = 1

  nnoremap <silent><buffer>gf :call further#plugin#LocateAndEditFile()<cr>
  nnoremap <silent><buffer><C-w>gf :call further#plugin#LocateAndEditFileInNewTab()<cr>
endfunc
