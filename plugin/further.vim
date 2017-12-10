scriptencoding utf-8

function! s:setup_mappings() abort
  nnoremap <silent><buffer>gf :call further#locate_and_edit_file()<cr>
  nnoremap <silent><buffer><C-w>gf :call further#locate_and_edit_file_in_new_tab()<cr>
endfunction

augroup further_plugin
  autocmd!
  autocmd FileType javascript :call <SID>setup_mappings()
augroup END
