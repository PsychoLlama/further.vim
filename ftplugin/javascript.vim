if exists('b:further_mappings_defined')
  finish
endif

let b:further_mappings_defined = 1

nnoremap <silent><buffer>gf :call further#locate_and_edit_file()<cr>
nnoremap <silent><buffer><C-w>gf :call further#locate_and_edit_file_in_new_tab()<cr>
