" ~/.vim/autoload/util.vim
function! util#redir_execute(cmd) abort
    let l:output = ''
    try
        redir => l:output
        silent! execute a:cmd
        redir END
    catch
        redir END
        let l:output = ''
    endtry
    return l:output
endfunction
