if !exists('g:sparkupDoMaps') || g:sparkupDoMaps!=0
  inoremap <buffer> <expr> <C-e> col('.')<len(getline('.')) ? "\<End>" : "\<C-g>u\<C-o>:call sparkup#transform()\<cr>"
  inoremap <buffer> <C-n> <C-g>u<C-o>:call sparkup#next()<cr>
  inoremap <buffer> <C-p> <C-g>u<C-o>:call sparkup#prev()<cr>
endif
