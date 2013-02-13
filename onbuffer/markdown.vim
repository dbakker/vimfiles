setl tw=80
setl cms=<!--\ %s\ -->
" 4 spaces means something different than 2 in Markdown
setl ts=2 sw=2 sts=2 et
au BufWritePre <buffer> retab

" Automatically update markdown titles
fun! MarkdownAutoTitle()
  for i in range(line("'["), line("']")+1)
    if getline(i)=~'^\s*\(-\+\|=\+\)$'
      let prev=getline(i-1)
      if len(getline(i))!=len(prev)
        let symbol = matchstr(getline(i), '\(-\|=\)')
        let line = matchstr(prev, '^\s*')
        let line .= repeat(symbol, len(prev)-len(line))
        call setline(i, line)
      endif
    endif
  endfor
endf

au InsertLeave <buffer> call MarkdownAutoTitle()

