setl foldenable foldmethod=syntax foldlevel=1 foldnestmax=2

" Use Java tags if available {{{2
" To generate, unzip the java library source to something like /opt/java, and:
" $ ctags --excmd=number --file-scope=no -f ~/.vim/local/tags/java -R --language-force=java /opt/java/ --java-kinds=-p

if filereadable(glob("~/.vim/local/tags/java"))
    setl tags<
    setl tags+=~/.vim/local/tags/java
endif
