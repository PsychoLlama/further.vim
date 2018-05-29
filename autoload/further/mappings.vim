func! further#mappings#Initialize() abort
  if exists('b:further_mappings_defined')
    return
  endif

  let b:further_mappings_defined = 1

  " Normal mode
  nnoremap <silent><buffer>gf :call further#plugin#LocateAndEditFile('n')<cr>
  nnoremap <silent><buffer><C-w>gf :call further#plugin#LocateAndEditFileInNewTab('n')<cr>
  nnoremap <silent><buffer><C-w>f :call further#plugin#LocateAndEditFileInSplit('n')<cr>
  nnoremap <silent><buffer><C-w><C-f> :call further#plugin#LocateAndEditFileInSplit('n')<cr>

  " Visual mode
  vnoremap <silent><buffer>gf :call further#plugin#LocateAndEditFile('v')<cr>
  vnoremap <silent><buffer><C-w>gf :call further#plugin#LocateAndEditFileInNewTab('v')<cr>
  vnoremap <silent><buffer><C-w>f :call further#plugin#LocateAndEditFileInSplit('v')<cr>
  vnoremap <silent><buffer><C-w><C-f> :call further#plugin#LocateAndEditFileInSplit('v')<cr>
endfunc
