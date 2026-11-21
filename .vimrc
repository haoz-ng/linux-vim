" ╔══════════════════════════════════════════════════════════════════════════╗
" ║  Author   : haozxje                                                      ║
" ║  Version  : 7.67                                                         ║
" ║  Modified : 2026-11-19                                                   ║
" ║  Desc     : Personal GVIM configuration — themes, keymaps, WinList       ║
" ║             (always-on) + on-demand NERDTree, statusline with            ║
" ║             [CL:TL], panel-aware tab label & window title, diff,         ║
" ║             folding, auto-save, quick replace/delete, mark highlight.    ║
" ╚══════════════════════════════════════════════════════════════════════════╝

if has('gui_running')
    autocmd GUIEnter * silent! call system("wmctrl -ir " . v:windowid . " -b add,maximized_vert,maximized_horz")
endif

if has('gui_running')
    map <silent> <F11> :silent! call system("wmctrl -ir " . v:windowid . " -b toggle,maximized_vert,maximized_horz")<CR>
endif

set hlsearch
set encoding=utf-8
set fileencoding=utf-8
set termencoding=utf-8
set guifont=Consolas\ Regular\ 9
set ignorecase
set smartcase
set autoread
set shortmess+=A

if !isdirectory(expand('~/.vim/swp'))
    silent! call mkdir(expand('~/.vim/swp'), 'p')
endif
set directory=~/.vim/swp//,/tmp//
set number
set mouse=a
set showtabline=2
set guitablabel=%{GuiTabLabel()}
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set wrap
set linebreak
set breakindent
let &showbreak = '↪ '
set laststatus=2
set cursorcolumn
set cursorline
set foldlevel=99
set lazyredraw
set synmaxcol=500
set timeoutlen=300
set updatetime=1000

function! s:IsPanelBuf(bufnr) abort
    let l:name = bufname(a:bufnr)
    let l:bt   = getbufvar(a:bufnr, '&buftype')
    return l:name =~# '^NERD_tree'
        \ || l:name ==# '__WindowList__'
        \ || l:bt   ==# 'quickfix'
        \ || l:bt   ==# 'help'
        \ || l:bt   ==# 'nofile'
endfunction

function! GuiTabLabel() abort
    let l:buflist = tabpagebuflist(v:lnum)
    let l:winnr   = tabpagewinnr(v:lnum)
    let l:cur     = l:buflist[l:winnr - 1]

    let l:bufnr = l:cur
    if s:IsPanelBuf(l:cur)
        for l:bn in l:buflist
            if !s:IsPanelBuf(l:bn)
                let l:bufnr = l:bn
                break
            endif
        endfor
    endif

    let l:fname   = bufname(l:bufnr)
    let l:name    = l:fname ==# '' ? '[No Name]' : fnamemodify(l:fname, ':t')
    let l:mod     = getbufvar(l:bufnr, '&modified')  ? ' [M]' : ''
    let l:ro      = getbufvar(l:bufnr, '&readonly')  ? ' [RO]'  : ''
    return l:name . l:mod . l:ro
endfunction

au CursorHold,CursorHoldI * silent! checktime

if !has('gui_running') && has('termguicolors')
    if &term =~# 'tmux\|screen' || $COLORTERM =~# 'truecolor\|24bit'
        let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
        let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
    endif
    set termguicolors
endif

syntax enable
syntax on
set background=dark
colorscheme haoz

filetype plugin on
au BufNewFile,BufRead *.md setlocal ft=md

function! s:MdLeadCodes(text) abort
    let l:out = []
    for l:c in split(strcharpart(a:text, 0, 8), '\zs')
        if l:c ==# ' '
            call add(l:out, 'sp')
        elseif l:c ==# "\t"
            call add(l:out, 'TAB')
        else
            call add(l:out, printf('U+%04X', char2nr(l:c)))
        endif
    endfor
    return '[' . join(l:out, ' ') . ']'
endfunction

command! -nargs=0 MdSyn call s:MdSynShow()
function! s:MdSynShow() abort
    let l:lnum = line('.')
    let l:col  = col('.')
    let l:txt  = getline(l:lnum)
    echo printf('line %d col %d  ft=%s  b:current_syntax=%s',
          \ l:lnum, l:col, &filetype, get(b:, 'current_syntax', '<none>'))
    echo printf('  char=%-14s syn=%-16s fg=%s',
          \ strtrans(l:txt[l:col - 1]),
          \ synIDattr(synID(l:lnum, l:col, 1), 'name'),
          \ synIDattr(synIDtrans(synID(l:lnum, l:col, 1)), 'fg#'))
    echo printf('  indent()=%d  lead=%s', indent(l:lnum), s:MdLeadCodes(l:txt))
    echo printf('  text=%s', strpart(l:txt, 0, 70))
endfunction

function! s:MdSlug(text) abort
    let l:t = tolower(a:text)
    let l:t = substitute(l:t, '\s*{[^}]*}\s*$', '', '')
    let l:t = substitute(l:t, '^\s*#\+\s*', '', '')
    let l:t = substitute(l:t, '\[\([^]]*\)\]([^)]*)', '\1', 'g')
    let l:t = substitute(l:t, '[`*_~]', '', 'g')
    let l:t = substitute(l:t, '[^[:alnum:]]\+', '-', 'g')
    let l:t = substitute(l:t, '^-*', '', '')
    return substitute(l:t, '-*$', '', '')
endfunction

function! s:MdSlugLoose(text) abort
    return substitute(tolower(s:MdSlug(a:text)), '[^a-z0-9]\+', '', 'g')
endfunction

function! s:MdLinksOnLine(line) abort
    let l:out = []
    let l:start = 0
    while 1
        let [l:m, l:s, l:e] = matchstrpos(a:line, '\[[^]]*\]([^)]\+)', l:start)
        if l:s == -1
            break
        endif
        call add(l:out, [matchstr(l:m, '(\zs[^)]\+\ze)'), l:s, l:e])
        let l:start = l:s + 1
    endwhile
    return l:out
endfunction

function! s:MdGoHeader(lnum) abort
    if mode() =~# "[vV\<C-v>]"
        silent! execute "normal! \<Esc>"
    endif
    call cursor(a:lnum, 1)
    silent! normal! zv
    normal! zz
    silent! call feedkeys("\<Esc>", 'n')
endfunction

function! MdFollowLink() abort
    let l:line = getline('.')
    let l:pos = col('.') - 1
    let l:links = s:MdLinksOnLine(l:line)
    let l:target = ''
    for [l:t, l:s, l:e] in l:links
        if l:pos >= l:s && l:pos < l:e
            let l:target = l:t
            break
        endif
    endfor
    if l:target ==# '' && len(l:links) == 1
        let l:target = l:links[0][0]
    endif
    if l:target ==# ''
        echo 'No link under cursor'
        return
    endif
    if l:target !~# '^#'
        echo 'Only in-file links (#anchor): ' . l:target
        return
    endif

    let l:raw   = substitute(l:target, '^#', '', '')
    let l:raw   = substitute(l:raw, '%\(\x\x\)', '\=nr2char(str2nr(submatch(1), 16))', 'g')
    let l:want  = s:MdSlug(l:raw)
    let l:loose = s:MdSlugLoose(l:raw)
    let l:bare  = substitute(l:loose, '-*[0-9]\+$', '', '')
    let l:found = 0
    let l:n = 1
    while l:n <= line('$')
        let l:l = getline(l:n)
        if l:l =~# '^\s*#\{1,6}\s'
            let l:s1 = s:MdSlug(l:l)
            let l:s2 = s:MdSlugLoose(l:l)
            if l:s1 ==# l:want || l:s2 ==# l:loose
                let l:found = l:n
                break
            endif
            if l:found == 0 && strlen(l:bare) > 2 && strlen(l:s2) > 2
                        \ && (stridx(l:s2, l:bare) == 0 || stridx(l:bare, l:s2) == 0)
                let l:found = l:n
            endif
        endif
        let l:n = l:n + 1
    endwhile
    if l:found > 0
        call s:MdGoHeader(l:found)
        return
    endif
    echo 'No header matches: [' . l:want . ']'
endfunction

command! -nargs=0 MdLink call MdFollowLink()
autocmd FileType md nnoremap <buffer> <silent> <C-]> :<C-U>call MdFollowLink()<CR>
autocmd FileType md nnoremap <buffer> <silent> <2-LeftMouse>
      \ <LeftMouse>:<C-U>call MdFollowLink()<CR><Esc>

let g:md_fenced_languages = [
      \ 'systemverilog', 'sv=systemverilog',
      \ 'verilog',       'v=verilog',
      \ 'c', 'cpp', 'python', 'sh', 'tcl', 'make', 'json', 'yaml', 'vim',
      \ ]

if has('conceal')
  au FileType md setlocal conceallevel=2 concealcursor=nc
endif

highlight Normal      ctermbg=black guibg=#000000
highlight LineNr      ctermbg=black guibg=#000000
highlight NonText     ctermbg=black guibg=#000000
highlight EndOfBuffer ctermbg=black guibg=#000000
highlight SignColumn  ctermbg=black guibg=#000000
highlight FoldColumn  ctermbg=black guibg=#000000

highlight CursorLine   guibg=#363636
highlight CursorColumn guibg=#363636
highlight CursorLineNr guifg=#00ffff guibg=#001933
highlight Cursor       guibg=#00ffff

highlight Visual       guibg=#003366

highlight Folded     ctermfg=White ctermbg=DarkBlue guifg=#ffffff guibg=#003366
highlight Search     guibg=#003366 guifg=NONE gui=NONE ctermbg=DarkBlue ctermfg=NONE
highlight VertSplit  guifg=#00ffff guibg=#191E2A
highlight SpecialKey ctermbg=17    guibg=#001933    guifg=#00ffff
highlight TabLineSel ctermfg=159   ctermbg=0 guifg=#afffff guibg=#000000 cterm=NONE gui=NONE
highlight TabLine     ctermfg=245  ctermbg=0 guifg=#888888 guibg=#000000 cterm=NONE gui=NONE
highlight TabLineFill ctermfg=0   ctermbg=0 guifg=#000000 guibg=#000000 cterm=NONE gui=NONE

let g:netrw_liststyle    = 1
let g:netrw_banner       = 1
let g:netrw_browse_split = 0
let g:netrw_sizestyle    = "H"

function! s:NetrwHighlights() abort
    silent! highlight netrwDir       guifg=#00aaff  guibg=#000000 gui=bold    ctermfg=39  ctermbg=0
    silent! highlight netrwClassify  guifg=#00aaff  guibg=#000000 gui=NONE    ctermfg=39  ctermbg=0
    silent! highlight netrwLink      guifg=#00ffcc  guibg=#000000 gui=italic  ctermfg=43  ctermbg=0
    silent! highlight netrwSymLink   guifg=#00ffcc  guibg=#000000 gui=italic  ctermfg=43  ctermbg=0
    silent! highlight netrwExe       guifg=#98c379  guibg=#000000 gui=bold    ctermfg=114 ctermbg=0
    silent! highlight netrwDateSep   guifg=#555555  guibg=#000000 gui=NONE    ctermfg=240 ctermbg=0
    silent! highlight netrwSizeDate  guifg=#666666  guibg=#000000 gui=NONE    ctermfg=241 ctermbg=0
    silent! highlight netrwHidFile   guifg=#e06c75  guibg=#000000 gui=italic  ctermfg=204 ctermbg=0
    silent! highlight netrwGray      guifg=#5c6370  guibg=#000000 gui=NONE    ctermfg=59  ctermbg=0
    silent! highlight netrwComment   guifg=#5c6370  guibg=#000000 gui=italic  ctermfg=59  ctermbg=0
    silent! highlight netrwCmdSep    guifg=#555555  guibg=#000000 gui=NONE    ctermfg=240 ctermbg=0
    silent! highlight netrwVersion   guifg=#555555  guibg=#000000 gui=NONE    ctermfg=240 ctermbg=0
    silent! highlight netrwList      guifg=#e5c07b  guibg=#000000 gui=NONE    ctermfg=180 ctermbg=0
    silent! highlight netrwHelpCmd   guifg=#61afef  guibg=#000000 gui=bold    ctermfg=75  ctermbg=0
    silent! highlight netrwBanner    guifg=#61afef  guibg=#000000 gui=bold    ctermfg=75  ctermbg=0
    silent! highlight netrwPlain     guifg=#abb2bf  guibg=#000000 gui=NONE    ctermfg=145 ctermbg=0
    silent! highlight netrwNormal    guifg=#abb2bf  guibg=#000000 gui=NONE    ctermfg=145 ctermbg=0
    silent! highlight netrwSpecial   guifg=#c678dd  guibg=#000000 gui=NONE    ctermfg=176 ctermbg=0
    silent! highlight netrwMarkFile  guifg=#000000  guibg=#e5c07b gui=bold    ctermfg=0   ctermbg=180
    silent! highlight link netrwCursorLine CursorLine
endfunction

augroup NetrwColors
    autocmd!
    autocmd FileType netrw call s:NetrwHighlights()
    autocmd FileType netrw setlocal signcolumn=no
    autocmd FileType netrw setlocal statusline=\ 【netrw】\ %{getcwd()}
    autocmd ColorScheme *  call s:NetrwHighlights()
augroup END

if has('gui_running')
    set guicursor=n-v-c:ver25-blinkon0,i:ver25-blinkon500-blinkoff500,r:hor20-blinkon500-blinkoff500
else
    let &t_SI = "\e[6 q"
    let &t_EI = "\e[2 q"
endif

let g:haoz_vimrc_version = 'V?'
let s:haoz_self = expand('<sfile>:p')
if !filereadable(s:haoz_self) && exists('$MYVIMRC')
    let s:haoz_self = $MYVIMRC
endif
if filereadable(s:haoz_self)
    for s:haoz_line in readfile(s:haoz_self, '', 20)
        let s:haoz_v = matchstr(s:haoz_line, 'Version\s*:\s*\zs\d\+\.\d\+')
        if s:haoz_v !=# ''
            let g:haoz_vimrc_version = 'V' . s:haoz_v
            break
        endif
    endfor
    unlet! s:haoz_line s:haoz_v
endif
unlet! s:haoz_self

set statusline=%F
set statusline+=%#LineNr#
set statusline+=%=
set statusline+=%#StatusLinePos#\ [CL%l:TL%L]
set statusline+=%#StatusLinePos#%{StatusIndent()}
set statusline+=%#StatusLinePos#%{StatusFiletype()}
set statusline+=%#StatusLinePos#[%{g:haoz_vimrc_version}]
set statusline+=%#CursorColumn#

function! s:DetectIndent() abort
    let l:last    = min([line('$'), 400])
    let l:tabs    = 0
    let l:spaces  = 0
    let l:gcd     = 0

    for l:lnum in range(1, l:last)
        let l:lead = matchstr(getline(l:lnum), '^\s\+')
        if l:lead ==# '' | continue | endif

        if stridx(l:lead, "\t") >= 0
            let l:tabs += 1
        else
            let l:spaces += 1
            let l:n = strlen(l:lead)
            let l:a = l:gcd
            let l:b = l:n
            while l:b != 0
                let [l:a, l:b] = [l:b, l:a % l:b]
            endwhile
            let l:gcd = l:a
        endif
    endfor

    let l:total = l:tabs + l:spaces
    if l:total == 0
        return &expandtab ? printf('[%dsp]', &shiftwidth)
                          \ : printf('[%dtb]', &tabstop)
    endif

    if l:tabs > 0 && l:spaces > 0
        \ && l:tabs * 10 >= l:total && l:spaces * 10 >= l:total
        return '[mix]'
    endif

    if l:tabs > l:spaces
        return printf('[%dtb]', &tabstop)
    endif

    let l:step = (l:gcd >= 2) ? l:gcd : &shiftwidth
    return printf('[%dsp]', l:step)
endfunction

function! StatusIndent() abort
    let l:tick = get(b:, 'changedtick', 0)
    if get(b:, 'indent_cache_tick', -1) == l:tick
        \ && exists('b:indent_cache')
        return b:indent_cache
    endif
    if mode() =~# '^[iR]' && exists('b:indent_cache')
        \ && exists('b:indent_cache_rt')
        \ && reltimefloat(reltime(b:indent_cache_rt)) < 1.0
        return b:indent_cache
    endif
    let b:indent_cache      = s:DetectIndent()
    let b:indent_cache_tick = l:tick
    let b:indent_cache_rt   = reltime()
    return b:indent_cache
endfunction

function! StatusFiletype() abort
    let l:ft = &filetype

    if line('$') == 1 && getline(1) ==# ''
        if l:ft ==# '' || l:ft ==# 'log'
            return '[none]'
        endif
    endif

    if l:ft ==# ''
        let l:ft = exists('b:current_syntax') ? b:current_syntax : 'none'
    endif
    return '[' . l:ft . ']'
endfunction

highlight StatusLine   guifg=#00ffff guibg=#001933
highlight StatusLineNC guifg=#888888 guibg=#001933
highlight link StatusLinePos StatusLine

function! StatusLineSetNormal() abort
    silent! highlight StatusLine guifg=#00ffff guibg=#001933
endfunction

function! StatusLineSetInsert() abort
    silent! highlight StatusLine guifg=#00ffff guibg=#661900
endfunction

function! StatusLineSetReplace() abort
    silent! highlight StatusLine guifg=#00ffff guibg=#006619
endfunction

augroup DynamicStatusLine
    autocmd!
    autocmd InsertEnter  * if v:insertmode ==# 'r' || v:insertmode ==# 'v'
                         \ | call StatusLineSetReplace()
                         \ | else
                         \ | call StatusLineSetInsert()
                         \ | endif
    autocmd InsertChange * if v:insertmode ==# 'r' || v:insertmode ==# 'v'
                         \ | call StatusLineSetReplace()
                         \ | else
                         \ | call StatusLineSetInsert()
                         \ | endif
    autocmd InsertLeave  * call StatusLineSetNormal()
augroup END

autocmd FileType c,cpp,java,scala                           let b:comment_leader = '\/\/'
autocmd FileType sh,csh,ruby,python,tcsh                    let b:comment_leader = '#'
autocmd FileType conf,fstab                                 let b:comment_leader = '#'
autocmd FileType tex                                        let b:comment_leader = '%'
autocmd FileType mail                                       let b:comment_leader = '>'
autocmd FileType vim                                        let b:comment_leader = '"'
autocmd FileType nasm                                       let b:comment_leader = ';'
autocmd BufReadPre,FileReadPre *.v,*.sv,*.svh,*.svt,*.svti let b:comment_leader = '\/\/'
autocmd BufReadPre,FileReadPre *.csh,*.txt,*.config         let b:comment_leader = '#'

function! CommentLine()
    let line = getline('.')
    if line =~ '\S'
        silent! call setline('.', substitute(line, '^\(\s*\)\(.*\)', '\1' . b:comment_leader . ' \2', ''))
    endif
endfunction

function! UncommentLine()
    if getline('.') =~? '^\s*' . b:comment_leader
        execute 'silent! s/^\(\s*\)' . b:comment_leader . ' \s\?/\1/'
    endif
endfunction

function! CommentRange(start, end)
    for lnum in range(a:start, a:end)
        let line = getline(lnum)
        if line =~ '\S'
            silent! call setline(lnum, substitute(line, '^\(\s*\)\(.*\)', '\1' . b:comment_leader . ' \2', ''))
        endif
    endfor
endfunction

function! UncommentRange(start, end)
    for lnum in range(a:start, a:end)
        let line = getline(lnum)
        if line =~? '^\s*' . b:comment_leader
            silent! call setline(lnum, substitute(line, '^\(\s*\)' . b:comment_leader . ' \?', '\1', ''))
        endif
    endfor
endfunction

function! ToggleCommentLine()
    let cl = exists('b:comment_leader') ? b:comment_leader : '//'
    let line = getline('.')
    if line =~ '^\s*' . cl
        silent! call UncommentLine()
    else
        silent! call CommentLine()
    endif
endfunction

function! ToggleCommentRange(start, end)
    let cl = exists('b:comment_leader') ? b:comment_leader : '//'
    let all_commented = 1
    for lnum in range(a:start, a:end)
        if getline(lnum) !~ '^\s*' . cl
            let all_commented = 0
            break
        endif
    endfor
    if all_commented
        silent! call UncommentRange(a:start, a:end)
    else
        silent! call CommentRange(a:start, a:end)
    endif
endfunction

nnoremap <silent> cc :call ToggleCommentLine()<CR>
vnoremap <silent> cc :<C-u>call ToggleCommentRange(line("'<"), line("'>"))<CR>

function! HaozTimestamp() abort
    return strftime('%Y%m%d-%H%M')
endfunction

let s:haoz_tag        = 'haozxje'
let s:haoz_tag_legacy = ['haoz']

function! s:HaozTagText() abort
    return '[' . s:haoz_tag . '-' . HaozTimestamp() . '] '
endfunction

function! s:HaozTagPattern(cl) abort
    let l:names   = [s:haoz_tag] + s:haoz_tag_legacy
    let l:alt     = join(map(copy(l:names), 'escape(v:val, "/\\.*$^~[]")'), '\|')
    let l:bracket = '\[\%(' . l:alt . '\)-\d\{8}-\d\{4\}\]'
    let l:colon   = '\%(' . l:alt . '\):\%(\s*\[\d\{8}-\d\{4}\]\)\?'
    return escape(a:cl, '/\.*$^~[]') . '\s*\%(' . l:bracket . '\|' . l:colon . '\)'
endfunction

function! ToggleCommentSyntaxHaoz() abort
    let l:comment = exists('b:comment_leader') ? b:comment_leader : '//'
    let l:comment = substitute(l:comment, '\\/\\/', '//', 'g')
    let l:pattern = '\s*' . s:HaozTagPattern(l:comment) . '\s*.*$'
    let l:current_line = getline('.')
    if l:current_line =~ l:pattern
        silent! call setline('.', substitute(l:current_line, l:pattern, '', ''))
    else
        silent! call setline('.', l:current_line . ' ' . l:comment
            \ . ' ' . s:HaozTagText())
    endif
endfunction

nnoremap <silent> hh :call ToggleCommentSyntaxHaoz()<CR>
vnoremap <silent> hh :call ToggleCommentSyntaxHaoz()<CR>

function! ToggleHaozCommentAtBeginning() abort
    let cl = exists('b:comment_leader') ? b:comment_leader : '//'
    let cl = substitute(cl, '\\/\\/', '//', 'g')
    let line = getline('.')
    let indent = matchstr(line, '^\s*')
    let content = substitute(line, '^\s*', '', '')
    let pattern = '^' . s:HaozTagPattern(cl) . '\s*'
    if content =~ pattern
        let new_content = substitute(content, pattern, '', '')
        silent! call setline('.', indent . new_content)
    else
        if content != ''
            silent! call setline('.', indent . cl
                \ . ' ' . s:HaozTagText() . content)
        endif
    endif
endfunction

function! ToggleHaozCommentRangeAtBeginning(start, end) abort
    let cl = exists('b:comment_leader') ? b:comment_leader : '//'
    let cl = substitute(cl, '\\/\\/', '//', 'g')
    let tag   = s:HaozTagPattern(cl)
    let strip = '^' . tag . '\s*'
    let all_have_haoz = 1
    for lnum in range(a:start, a:end)
        let content = substitute(getline(lnum), '^\s*', '', '')
        if content != '' && content !~ '^' . tag
            let all_have_haoz = 0
            break
        endif
    endfor
    for lnum in range(a:start, a:end)
        let line = getline(lnum)
        let indent = matchstr(line, '^\s*')
        let content = substitute(line, '^\s*', '', '')
        if content != ''
            if all_have_haoz
                silent! call setline(lnum,
                    \ indent . substitute(content, strip, '', ''))
            elseif content !~ '^' . tag
                silent! call setline(lnum, indent . cl
                    \ . ' ' . s:HaozTagText() . content)
            endif
        endif
    endfor
endfunction

nnoremap <silent> ch :call ToggleHaozCommentAtBeginning()<CR>
vnoremap <silent> ch :<C-u>call ToggleHaozCommentRangeAtBeginning(line("'<"), line("'>"))<CR>

let g:haoz_sentences = get(g:, 'haoz_sentences', [
    \ '$display("[haozxje][%t][%6d][x] - ", $realtime, `__LINE__ );',
    \ ])

function! HaozInsertSentenceLine(text) abort
    if a:text ==# ''
        echo 'Sentence is empty - nothing inserted'
        return
    endif
    if !&modifiable || &readonly
        echo 'Buffer is not writable (readonly / nomodifiable)'
        return
    endif
    let l:indent = matchstr(getline('.'), '^\s*')
    let l:text   = l:indent . substitute(a:text, '^\s\+', '', '')
    try
        call append(line('.'), l:text)
    catch
        echo 'Insert failed: ' . v:exception
        return
    endtry
    call cursor(line('.') + 1, strlen(l:indent) + 1)
    silent! normal! zv
    silent! redraw
    echo 'Sentence inserted (line ' . line('.') . ', press u to undo)'
endfunction

function! HaozSentenceMenu() abort
    if empty(g:haoz_sentences)
        echo 'g:haoz_sentences is empty'
        return
    endif
    if exists('*popup_menu')
        call popup_menu(g:haoz_sentences, {
            \ 'title': ' Insert sentence ',
            \ 'callback': {id, idx -> HaozSentenceMenuPick(idx)},
            \ })
    else
        let l:menu = ['Pick a sentence to insert (Enter = cancel):']
        for l:i in range(len(g:haoz_sentences))
            call add(l:menu, (l:i + 1) . '. ' . g:haoz_sentences[l:i])
        endfor
        let l:pick = inputlist(l:menu)
        if l:pick > 0
            call HaozSentenceMenuPick(l:pick)
        endif
    endif
endfunction

function! HaozSentenceMenuPick(idx) abort
    if a:idx < 1 || a:idx > len(g:haoz_sentences)
        return
    endif
    call HaozInsertSentenceLine(g:haoz_sentences[a:idx - 1])
endfunction

command! -nargs=+ SentenceAdd  call add(g:haoz_sentences, <q-args>)
command! -nargs=0 SentenceList echo join(map(copy(g:haoz_sentences),
    \ 'v:key + 1 . ". " . v:val'), "\n")
command! -nargs=0 SentenceShow echo join(map(copy(g:haoz_sentences),
    \ 'v:key + 1 . ". " . string(v:val)'), "\n")

augroup autosave
    autocmd!
    autocmd BufRead      * if &filetype == "" | setlocal ft=log | endif
    autocmd TextChanged  * call s:AutoSaveSchedule()
    autocmd InsertLeave  * call s:AutoSaveNow()
    autocmd BufLeave     * call s:AutoSaveNow()
    autocmd FocusLost    * call s:AutoSaveNow()
    autocmd VimLeavePre  * call s:AutoSaveNow()
augroup END

let s:autosave_timer = -1

function! s:AutoSaveWritable() abort
    return &modified && !&readonly && &modifiable
        \ && &buftype ==# '' && bufname('%') !=# ''
endfunction

function! s:AutoSaveNow(...) abort
    if s:autosave_timer != -1
        call timer_stop(s:autosave_timer)
        let s:autosave_timer = -1
    endif
    if !s:AutoSaveWritable()
        return
    endif
    silent! write
endfunction

function! s:AutoSaveSchedule() abort
    if !s:AutoSaveWritable()
        return
    endif
    if mode() =~# '^[iR]'
        return
    endif
    if s:autosave_timer != -1
        call timer_stop(s:autosave_timer)
    endif
    let s:autosave_timer = timer_start(get(g:, 'autosave_delay', 800),
        \ {-> s:AutoSaveNow()})
endfunction

noremap <C-n> :tabnew<CR>
noremap <C-\> :vs<CR><C-w>w

nnoremap <F5>  :edit!<CR>
function! CopyFullPath() abort
    let l:path = expand('%:p')
    call setreg('"', l:path)
    if has('clipboard')
        call setreg('+', l:path)
    else
        silent! call ClipPush()
    endif
    echo "Copied full path: " . l:path
endfunction

nnoremap <silent> <F12> :call CopyFullPath()<CR>
inoremap <silent> <F12> <C-o>:call CopyFullPath()<CR>

nnoremap <C-a> ggVG
nnoremap <silent> <S-l> :nohlsearch<CR>
nnoremap <C-l> V
inoremap <C-l> <Esc>V

function! s:ClipTools() abort
    if executable('wl-copy') && executable('wl-paste')
        return ['wl-copy', 'wl-paste --no-newline']
    elseif executable('xclip')
        return ['xclip -selection clipboard -in', 'xclip -selection clipboard -out']
    elseif executable('xsel')
        return ['xsel --clipboard --input', 'xsel --clipboard --output']
    elseif executable('clip.exe') && executable('powershell.exe')
        return ['clip.exe', 'powershell.exe -NoProfile -Command Get-Clipboard -Raw']
    elseif executable('pbcopy')
        return ['pbcopy', 'pbpaste']
    endif
    return []
endfunction

function! ClipPush() abort
    let l:tools = s:ClipTools()
    if !empty(l:tools)
        silent call system(l:tools[0] . ' >/dev/null 2>&1', @")
    endif
endfunction

function! ClipPull() abort
    let l:tools = s:ClipTools()
    if empty(l:tools) | return '' | endif
    let l:text = system(l:tools[1])
    if !v:shell_error
        call setreg('"', substitute(l:text, '\r', '', 'g'))
    endif
    return ''
endfunction

if has('clipboard')
    vnoremap <C-c> "+y
    nnoremap <C-c> "+yy
    nnoremap <C-v> "+p
    inoremap <C-v> <C-r>+
    vnoremap <C-v> "+p
    cnoremap <C-v> <C-r>+
    vnoremap <C-x> "+d
    nnoremap <C-x> "+dd
else
    vnoremap <silent> <C-c> y:call ClipPush()<CR>
    nnoremap <silent> <C-c> yy:call ClipPush()<CR>
    nnoremap <silent> <C-v> :call ClipPull()<CR>p
    inoremap <silent> <C-v> <C-r>=ClipPull()<CR><C-r><C-o>"
    vnoremap <silent> <C-v> :<C-u>call ClipPull()<CR>gvp
    cnoremap <C-v> <C-r>=ClipPull()<CR><C-r>"
    vnoremap <silent> <C-x> d:call ClipPush()<CR>
    nnoremap <silent> <C-x> dd:call ClipPush()<CR>
endif

if !has('gui_running')
    set pastetoggle=<F2>
endif

nnoremap V <C-v>

nnoremap <C-d> :let @/='\<'.expand('<cword>').'\>'<CR>viw
inoremap <C-d> <Esc>viw

nnoremap <C-f> :let @/ = '\<'.expand('<cword>').'\>'<CR>:set hlsearch<CR>
vnoremap <C-f> "zy:let @/ = escape(@z, '/\')<CR>:set hlsearch<CR>

inoremap <S-Left>    <Left><C-o>v
inoremap <S-Right>   <C-o>v
inoremap <S-Up>      <Left><C-o>v<Up><Right>
inoremap <S-Down>    <C-o>v<Down><Left>
inoremap <S-Home>    <C-o>v<Home>
inoremap <S-End>     <C-o>v<End>
imap     <C-S-Left>  <S-Left><C-Left>
imap     <C-S-Right> <S-Right><C-Right>

vnoremap <S-Left>  <Left>
vnoremap <S-Right> <Right>
vnoremap <S-Up>    <Up>
vnoremap <S-Down>  <Down>
vnoremap <S-Home>  <Home>
vnoremap <S-End>   <End>

nnoremap <S-Left>  v<Left>
nnoremap <S-Right> v<Right>
nnoremap <S-Up>    v<Up>
nnoremap <S-Down>  v<Down>
nnoremap <S-Home>  v<Home>
nnoremap <S-End>   v<End>

nnoremap <C-Right>   w
nnoremap <C-Left>    b
vnoremap <C-Right>   e
vnoremap <C-Left>    b
nnoremap <C-S-Right> vew
nnoremap <C-S-Left>  vb
vnoremap <C-S-Right> e
vnoremap <C-S-Left>  b
inoremap <C-Right>   <C-o>w
inoremap <C-Left>    <C-o>b

nnoremap <C-Up>   :tabprevious<CR>
nnoremap <C-Down> :tabnext<CR>

nnoremap <silent> <M-Left>  :call WinListNavLeft()<CR>
nnoremap <silent> <M-Right> :call WinListNavRight()<CR>

function! WinListNavLeft() abort
    let l:cur = winnr()
    wincmd h
    if winnr() == l:cur
        let l:rightmost = -1
        for l:i in range(1, winnr('$'))
            if !WinListIsSpecial(winbufnr(l:i)) && !WinListIsNERDTree(winbufnr(l:i))
                let l:rightmost = l:i
            endif
        endfor
        if l:rightmost != -1 && l:rightmost != l:cur
            execute l:rightmost . 'wincmd w'
        endif
    endif
    if WinListIsSpecial() || WinListIsNERDTree()
        silent! call WinListNavLeft()
    endif
endfunction

function! WinListNavRight() abort
    let l:cur = winnr()
    wincmd l
    if winnr() == l:cur
        for l:i in range(1, winnr('$'))
            if !WinListIsSpecial(winbufnr(l:i)) && !WinListIsNERDTree(winbufnr(l:i))
                execute l:i . 'wincmd w'
                break
            endif
        endfor
    endif
    if WinListIsSpecial() || WinListIsNERDTree()
        silent! call WinListNavRight()
    endif
endfunction

function! GoToTab(n) abort
    let l:target = a:n == 0 ? 10 : a:n
    if l:target <= tabpagenr('$')
        execute 'tabnext ' . l:target
    endif
endfunction

nnoremap <silent> 1 :call GoToTab(1)<CR>
nnoremap <silent> 2 :call GoToTab(2)<CR>
nnoremap <silent> 3 :call GoToTab(3)<CR>
nnoremap <silent> 4 :call GoToTab(4)<CR>
nnoremap <silent> 5 :call GoToTab(5)<CR>
nnoremap <silent> 6 :call GoToTab(6)<CR>
nnoremap <silent> 7 :call GoToTab(7)<CR>
nnoremap <silent> 8 :call GoToTab(8)<CR>
nnoremap <silent> 9 :call GoToTab(9)<CR>
nnoremap <silent> 0 :call GoToTab(0)<CR>

inoremap <Home> <C-o>^
nnoremap <Home> ^

function! NormalModeTab()
    let sw = &shiftwidth
    let line = getline('.')
    let col = col('.') - 1
    let lead = matchstr(line, '^\s*')
    let leadlen = strlen(lead)
    if col <= leadlen
        let next = ((col / sw) + 1) * sw
        let newline = repeat(' ', next) . substitute(line, '^\s*', '', '')
        silent! call setline('.', newline)
        silent! call cursor(line('.'), next + 1)
    else
        execute "normal! i" . repeat(" ", sw) . "\<Esc>"
    endif
endfunction

function! NormalModeShiftTab()
    let sw = &shiftwidth
    let line = getline('.')
    let col = col('.') - 1
    let lead = matchstr(line, '^\s*')
    let leadlen = strlen(lead)
    if col <= leadlen && leadlen > 0
        let n = min([sw, leadlen])
        let newline = repeat(' ', leadlen - n) . substitute(line, '^\s*', '', '')
        silent! call setline('.', newline)
        silent! call cursor(line('.'), col - n + 1 > 0 ? col - n + 1 : 1)
    else
        let before = matchstr(line[:col-1], '\s*$')
        let n = min([sw, strlen(before)])
        if n > 0
            execute "normal! " . n . "dh"
        endif
    endif
endfunction

function! VisualModeTab()
    let sw = &shiftwidth
    let l1 = line("'<")
    let l2 = line("'>")
    for i in range(l1, l2)
        let line = getline(i)
        let lead = matchstr(line, '^\s*')
        let leadlen = strlen(lead)
        let next = ((leadlen / sw) + 1) * sw
        let newline = repeat(' ', next) . substitute(line, '^\s*', '', '')
        silent! call setline(i, newline)
    endfor
endfunction

function! VisualModeShiftTab()
    let sw = &shiftwidth
    let l1 = line("'<")
    let l2 = line("'>")
    for i in range(l1, l2)
        let line = getline(i)
        let lead = matchstr(line, '^\s*')
        let leadlen = strlen(lead)
        let last = ((leadlen - 1) / sw) * sw
        if last < 0 | let last = 0 | endif
        let newline = repeat(' ', last) . substitute(line, '^\s*', '', '')
        silent! call setline(i, newline)
    endfor
endfunction

vnoremap <silent> <Tab>   :<C-u>call VisualModeTab()<CR>gv
vnoremap <silent> <S-Tab> :<C-u>call VisualModeShiftTab()<CR>gv

nnoremap <C-z> u
inoremap <C-z> <C-o>u
vnoremap <C-z> <Esc>u

nnoremap <S-Del> dd

function! ToggleCase()
    if mode() ==# 'v' || mode() ==# 'V' || mode() ==# "\<C-v>"
        normal! g~
    else
        normal! g~iw
    endif
endfunction

vnoremap <C-U> :<C-u>call ToggleCase()<CR>
nnoremap <C-U> :<C-u>call ToggleCase()<CR>

nnoremap n nzz
nnoremap N Nzz

nnoremap <M-z> :set wrap!<CR>

nnoremap x     <Nop>
nnoremap <Del> <Nop>
nnoremap o     <Nop>

augroup filtype_verilog
    autocmd!
    autocmd FileType Verilog,verilog_systemverilog call HaozSvFoldSetup()
    autocmd BufNewFile,BufRead *.v,*.sv,*.svh,*.svt,*.svti call HaozSvFoldSetup()
    autocmd FileType md call HaozMdFoldSetup()
augroup END

function! HaozSvFoldSetup() abort
    setlocal foldmethod=indent
    setlocal foldenable
    if get(b:, 'haoz_fold_lvl', -1) != 3
        setlocal foldlevel=3
        let b:haoz_fold_lvl = 3
    endif
    let b:haoz_fold_home = 3
    nnoremap <buffer> <silent> zo :<C-U>call HaozFoldToggleAll()<CR>
    nnoremap <buffer> <silent> zA :<C-U>call HaozFoldToggleRecursive()<CR>
endfunction

function! HaozMdFoldSetup() abort
    setlocal foldmethod=expr
    setlocal foldexpr=HaozMdFoldLevel(v:lnum)
    setlocal foldenable
    setlocal foldtext=HaozMdFoldText()
    if get(b:, 'haoz_fold_lvl', -1) != 2
        setlocal foldlevel=2
        let b:haoz_fold_lvl = 2
    endif
    let b:haoz_fold_home = 2
    nnoremap <buffer> <silent> zo :<C-U>call HaozFoldToggleAll()<CR>
    silent! unlet! b:md_fold_tick
endfunction
command! -nargs=0 MdRefold call HaozMdFoldSetup() | echo 'md fold refreshed'
function! s:HaozMdBuildFoldLevels() abort
    let l:lines = getline(1, '$')
    let l:fm_end = 0
    if !empty(l:lines) && l:lines[0] =~# '^---\s*$'
        let l:i = 1
        while l:i < len(l:lines) && l:i <= 200
            if l:lines[l:i] =~# '^---\s*$'
                let l:fm_end = l:i + 1
                break
            endif
            let l:i += 1
        endwhile
    endif
    let l:out = []
    let l:n = 0
    for l:l in l:lines
        let l:n += 1
        if l:l !~# '\S'
            call add(l:out, '=')
        elseif l:fm_end > 0 && l:n <= l:fm_end + 1
            if l:n == 1
                call add(l:out, '>1')
            elseif l:n <= l:fm_end
                call add(l:out, '1')
            else
                call add(l:out, '0')
            endif
        else
            call add(l:out, '>' . (indent(l:n) / 4 + 1))
        endif
    endfor
    return l:out
endfunction

function! HaozMdFoldLevel(lnum) abort
    if get(b:, 'md_fold_tick', -1) != b:changedtick
        let b:md_fold_cache = s:HaozMdBuildFoldLevels()
        let b:md_fold_tick = b:changedtick
    endif
    return get(b:md_fold_cache, a:lnum - 1, '=')
endfunction

function! HaozMdFoldText() abort
    let l:line = getline(v:foldstart)
    if l:line =~# '^---\s*$'
        let l:title = '[front-matter]'
    else
        let l:title = substitute(l:line, '^#\+\s*', '', '')
        if empty(l:title)
            let l:title = l:line
        endif
    endif
    return '▸ ' . l:title . '  ⋯ ' . (v:foldend - v:foldstart + 1) . ' dòng '
endfunction

function! HaozFoldToggleRecursive() abort
    if foldlevel('.') == 0
        return
    endif
    if foldclosed('.') != -1
        normal! zO
        return
    endif
    let l:closed = []
    let l:n = 1
    while l:n <= line('$')
        if foldclosed(l:n) == l:n
            call add(l:closed, l:n)
        endif
        let l:n = l:n + 1
    endwhile
    let l:cur = line('.')
    normal! zc
    let l:top = foldclosed(l:cur)
    let l:bot = foldclosedend(l:cur)
    if l:top == -1
        return
    endif
    for l:s in l:closed
        if l:s > l:top && l:s <= l:bot
            normal! zO
            return
        endif
    endfor
endfunction

function! HaozFoldToggleAll() abort
    if !&foldenable
        return
    endif
    let l:home = get(b:, 'haoz_fold_home', 0)

    let l:any_closed = 0
    let l:n = 1
    while l:n <= line('$')
        if foldclosed(l:n) == l:n
            let l:any_closed = 1
            break
        endif
        let l:n = l:n + 1
    endwhile

    if l:any_closed && &l:foldlevel <= l:home
        normal! zR
    else
        let &l:foldlevel = l:home
    endif
endfunction

runtime macros/matchit.vim

augroup markdown_fix
    autocmd!
    autocmd FileType markdown,md hi! link markdownError NONE
augroup END

let g:indentLine_color_gui = '#363636'
let g:indentLine_char      = '┆'

let g:bookmark_highlight_lines = 1
highlight BookmarkLine ctermbg=17 guibg=#001933
highlight BookmarkSign ctermbg=17 guibg=#001933 guifg=#00ffff
let g:bookmark_sign   = '=='
let g:bookmark_center = 1

if has('gui_running')
    set guioptions-=mT
endif

set title
set titleold=
function! GuiTitle() abort
    let l:ntabs = tabpagenr('$')

    let l:bn = bufnr('%')
    if s:IsPanelBuf(l:bn)
        for l:i in range(1, winnr('$'))
            let l:cand = winbufnr(l:i)
            if !s:IsPanelBuf(l:cand)
                let l:bn = l:cand
                break
            endif
        endfor
    endif

    let l:name = bufname(l:bn)
    let l:title = l:name ==# '' ? '[No Name]' : fnamemodify(l:name, ':t')
    let l:full  = l:name ==# '' ? '' : fnamemodify(l:name, ':p:h:t')

    let l:mod = getbufvar(l:bn, '&modified') ? ' [+]' : ''
    let l:ro  = getbufvar(l:bn, '&readonly') ? ' [RO]' : ''

    let l:tabinfo = l:ntabs > 1
        \ ? printf(' (%d/%d)', tabpagenr(), l:ntabs)
        \ : ''

    return (l:full ==# '' ? '' : l:full . ' — ')
        \ . l:title . l:mod . l:ro . l:tabinfo . ' — GVIM'
endfunction

set titlestring=%{GuiTitle()}

function! ToggleGvimMenuToolbar()
    if has('gui_running')
        let l:opts = &guioptions
        if l:opts =~# 'm' && l:opts =~# 'T'
            set guioptions-=m
            set guioptions-=T
        else
            set guioptions+=mT
        endif
    endif
endfunction

nnoremap <F10> :call ToggleGvimMenuToolbar()<CR>

augroup auto_toggle_gvim_toolbar
    autocmd!
    autocmd GUIEnter * silent! call ToggleGvimMenuToolbar()
augroup END

augroup diffcolors
    autocmd!
    autocmd ColorScheme * silent! call s:DiffHighlights()
augroup END

function! s:DiffHighlights()
    if &background ==# 'dark'
        silent! highlight DiffAdd     guibg=#29762e guifg=NONE gui=NONE
        silent! highlight DiffChange  guibg=#304e75 guifg=NONE gui=NONE
        silent! highlight DiffDelete  guibg=#772e2e guifg=NONE gui=NONE
        silent! highlight DiffText    guibg=#aa3a3a guifg=NONE gui=NONE
        silent! highlight DiffRemoved guibg=#772e2e guifg=NONE gui=NONE
        silent! highlight DiffFile    guibg=#304e75 guifg=NONE gui=NONE
        silent! highlight DiffNewFile guibg=#29762e guifg=NONE gui=NONE
    else
        silent! highlight DiffAdd     guibg=#cce8cc guifg=NONE gui=NONE
        silent! highlight DiffChange  guibg=#cce0fa guifg=NONE gui=NONE
        silent! highlight DiffDelete  guibg=#facccc guifg=NONE gui=NONE
        silent! highlight DiffText    guibg=#ffbaba guifg=NONE gui=NONE
        silent! highlight DiffRemoved guibg=#facccc guifg=NONE gui=NONE
        silent! highlight DiffFile    guibg=#cce0fa guifg=NONE gui=NONE
        silent! highlight DiffNewFile guibg=#cce8cc guifg=NONE gui=NONE
    endif
endfunction

autocmd VimEnter * silent! call s:DiffHighlights()

if &diff
    nnoremap dn ]c
    nnoremap db [c
    nnoremap df dp
endif

autocmd FilterReadPre * if &diff | nnoremap <buffer> df dp | endif
autocmd VimEnter      * if &diff | nnoremap <buffer> df dp | endif

function! UnfoldAllDiffWindows()
    let curr_win = win_getid()
    for i in range(1, winnr('$'))
        execute i . 'wincmd w'
        if &diff
            setlocal nofoldenable foldmethod=manual
            silent! normal! zR
        endif
    endfor
    silent! call win_gotoid(curr_win)
endfunction

augroup Difffoldfix
    autocmd!
    autocmd VimEnter * silent! call UnfoldAllDiffWindows()
augroup END

if has("autocmd")
    au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
endif

autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

let g:winlist_min_width    = 15
let g:winlist_max_width    = 50
let g:winlist_padding      = 2
let g:winlist_width        = 50

let NERDTreeShowHidden     = 1
let g:NERDTreeWinPos       = "left"
let g:NERDTreeWinSize      = 50

let g:winlist_always       = 1

let g:netrw_expanding         = 0
let g:netrw_explore_active    = 0
let g:netrw_back_buf          = -1
let g:netrw_back_path         = ''

let g:panel_nerdtree_lines = 0
let g:panel_nerdtree_open  = 0

if !exists('g:winlist_tab_open')
    let g:winlist_tab_open = {}
endif
if !exists('g:winlist_last_active')
    let g:winlist_last_active = {}
endif

let g:winlist_opening      = 0
let g:winlist_file_opening = 0
let g:panel_opening        = 0

function! WinListHalfHeight() abort
    let l:total = &lines - 2
    return max([5, l:total / 2])
endfunction

function! WinListEnsureTabID(...) abort
    let l:t = a:0 > 0 ? a:1 : tabpagenr()
    if gettabvar(l:t, 'winlist_tab_id', '') ==# ''
        call settabvar(l:t, 'winlist_tab_id',
            \ printf('tab_%d_%s', l:t, reltimestr(reltime())))
    endif
endfunction

function! WinListGetTabID(...) abort
    let l:t = a:0 > 0 ? a:1 : tabpagenr()
    return gettabvar(l:t, 'winlist_tab_id', '')
endfunction

function! WinListFindTabByID(tid) abort
    for l:t in range(1, tabpagenr('$'))
        if gettabvar(l:t, 'winlist_tab_id', '') ==# a:tid
            return l:t
        endif
    endfor
    return -1
endfunction

function! s:AssignAllTabIDs() abort
    for l:t in range(1, tabpagenr('$'))
        call WinListEnsureTabID(l:t)
    endfor
endfunction

augroup WinListTabID
    autocmd!
    autocmd VimEnter * call s:AssignAllTabIDs()
    autocmd TabNew   * call WinListEnsureTabID()
    autocmd TabEnter * call WinListEnsureTabID()
augroup END

function! WinListBufName(...) abort
    return '__WindowList__'
endfunction

function! s:PanelWidth() abort
    let l:w = g:winlist_width
    let l:w = max([l:w, g:winlist_min_width])
    let l:w = min([l:w, g:winlist_max_width])
    let l:w = min([l:w, max([g:winlist_min_width, &columns / 2])])
    return l:w
endfunction

function! s:CurrentContentBuf() abort
    if !WinListIsSpecial()
        return bufnr('%')
    endif

    let l:saved = get(g:winlist_last_active, tabpagenr(), -1)
    if l:saved > 0 && bufexists(l:saved)
        return l:saved
    endif

    let l:w = WinListFindNormalWin()
    return l:w == -1 ? -1 : winbufnr(l:w)
endfunction

function! WinListIsNERDTree(...) abort
    let l:bn = a:0 > 0 ? a:1 : bufnr('%')
    return bufname(l:bn) =~# '^NERD_tree'
endfunction

function! WinListIsWinList(...) abort
    let l:bn = a:0 > 0 ? a:1 : bufnr('%')
    return bufname(l:bn) ==# '__WindowList__'
endfunction

function! WinListIsSpecial(...) abort
    let l:bn   = a:0 > 0 ? a:1 : bufnr('%')
    let l:name = bufname(l:bn)
    let l:bt   = getbufvar(l:bn, '&buftype')
    return l:name =~# '^NERD_tree'
        \ || l:name ==# '__WindowList__'
        \ || l:bt   ==# 'quickfix'
        \ || l:bt   ==# 'help'
        \ || l:bt   ==# 'nofile'
endfunction

function! WinListFindNormalWin() abort
    for l:i in range(1, winnr('$'))
        if !WinListIsSpecial(winbufnr(l:i))
            return l:i
        endif
    endfor
    return -1
endfunction

function! WinListFindAnchorWin() abort
    let l:w = WinListFindNormalWin()
    if l:w != -1 | return l:w | endif
    for l:i in range(1, winnr('$'))
        let l:bn = winbufnr(l:i)
        if WinListIsNERDTree(l:bn) || WinListIsWinList(l:bn)
            continue
        endif
        if getbufvar(l:bn, '&filetype') ==# 'netrw'
            return l:i
        endif
    endfor
    return -1
endfunction

function! WinListIsOpen() abort
    return bufwinnr(WinListBufName()) != -1
endfunction

function! WinListIsOpenAnywhere() abort
    let l:bn = bufnr(WinListBufName())
    if l:bn == -1
        return 0
    endif
    for l:t in range(1, tabpagenr('$'))
        if index(tabpagebuflist(l:t), l:bn) >= 0
            return 1
        endif
    endfor
    return 0
endfunction

function! NERDTreeIsOpen() abort
    for l:i in range(1, winnr('$'))
        if WinListIsNERDTree(winbufnr(l:i))
            return 1
        endif
    endfor
    return 0
endfunction

function! CombinedPanelIsOpen() abort
    return WinListIsOpen()
endfunction

function! s:TabHasSessionPicker() abort
    let l:pbuf = get(g:, 'session_picker_buf', '__SessionPicker__')
    for l:i in range(1, winnr('$'))
        if bufname(winbufnr(l:i)) ==# l:pbuf
            return 1
        endif
    endfor
    return 0
endfunction

function! WinListCheckAutoCloseTab() abort
    if g:winlist_opening      | return | endif
    if g:winlist_file_opening | return | endif
    if g:panel_opening        | return | endif
    if get(g:, 'netrw_expanding', 0) | return | endif
    if s:TabHasSessionPicker()        | return | endif

    let l:real = 0
    for l:i in range(1, winnr('$'))
        let l:bn = winbufnr(l:i)
        if !WinListIsWinList(l:bn) && !WinListIsNERDTree(l:bn)
            let l:bt = getbufvar(l:bn, '&buftype')
            if l:bt ==# '' || l:bt ==# 'acwrite'
                let l:real += 1
            endif
        endif
    endfor

    if l:real == 0
        call timer_start(200, {-> s:DelayedAutoClose()})
    endif
endfunction

function! s:DelayedAutoClose() abort
    if g:winlist_opening      | return | endif
    if g:winlist_file_opening | return | endif
    if g:panel_opening        | return | endif
    if get(g:, 'netrw_expanding', 0) | return | endif
    if s:TabHasSessionPicker()        | return | endif

    let l:real = 0
    for l:i in range(1, winnr('$'))
        let l:bn = winbufnr(l:i)
        if !WinListIsWinList(l:bn) && !WinListIsNERDTree(l:bn)
            let l:bt = getbufvar(l:bn, '&buftype')
            if l:bt ==# '' || l:bt ==# 'acwrite'
                let l:real += 1
            endif
        endif
    endfor

    if l:real == 0
        if tabpagenr('$') <= 1
            qall!
        else
            silent! tabclose
        endif
    endif
endfunction

function! WinListLockSplitWidths() abort
    for l:i in range(1, winnr('$'))
        let l:bn = winbufnr(l:i)
        if !WinListIsSpecial(l:bn) && !WinListIsNERDTree(l:bn)
            silent! call setwinvar(l:i, '&winfixwidth', 1)
        endif
    endfor
endfunction

function! WinListUnlockSplitWidths() abort
    for l:i in range(1, winnr('$'))
        let l:bn = winbufnr(l:i)
        if !WinListIsSpecial(l:bn) && !WinListIsNERDTree(l:bn)
            silent! call setwinvar(l:i, '&winfixwidth', 0)
        endif
    endfor
endfunction

function! SyncNERDTreeWidth() abort
    for l:i in range(1, winnr('$'))
        if WinListIsNERDTree(winbufnr(l:i))
            let l:cur = winnr()
            execute 'noautocmd ' . l:i . 'wincmd w'
            execute 'vertical resize ' . s:PanelWidth()
            execute 'noautocmd ' . l:cur . 'wincmd w'
            return
        endif
    endfor
endfunction

function! WinListFixWidth() abort
    if g:netrw_expanding  | return | endif
    if !WinListIsOpen()   | return | endif
    let l:wnr = bufwinnr(WinListBufName())
    if winwidth(l:wnr) == s:PanelWidth() | return | endif

    let l:cur = winnr()
    silent! call WinListLockSplitWidths()
    execute 'noautocmd ' . l:wnr . 'wincmd w'
    execute 'vertical resize ' . s:PanelWidth()
    execute 'noautocmd ' . l:cur . 'wincmd w'
    silent! call WinListUnlockSplitWidths()
    silent! call SyncNERDTreeWidth()
endfunction

function! WinListFixPanelHeights() abort
    if !WinListIsOpen() | return | endif

    let l:wl_wnr = bufwinnr(WinListBufName())
    let l:nt_wnr = -1
    for l:i in range(1, winnr('$'))
        if WinListIsNERDTree(winbufnr(l:i))
            let l:nt_wnr = l:i
            break
        endif
    endfor

    if l:wl_wnr == -1 || l:nt_wnr == -1 | return | endif

    let l:half = WinListHalfHeight()
    let l:cur  = winnr()

    execute 'noautocmd ' . l:wl_wnr . 'wincmd w'
    execute 'resize ' . l:half

    execute 'noautocmd ' . l:nt_wnr . 'wincmd w'
    execute 'resize ' . l:half

    execute 'noautocmd ' . l:cur . 'wincmd w'
endfunction

let s:shortpath_cache = {}

function! WinListShortPath(fullpath) abort
    if a:fullpath ==# '' | return '[No Name]' | endif
    let l:hit = get(s:shortpath_cache, a:fullpath, v:null)
    if l:hit isnot v:null
        return l:hit
    endif

    let l:parts = split(a:fullpath, '/')
    if len(l:parts) > 5
        let l:parts = l:parts[-5:]
        let l:res = '…/' . join(l:parts, '/')
    else
        let l:res = (a:fullpath[0] ==# '/' ? '/' : '') . join(l:parts, '/')
    endif

    if len(s:shortpath_cache) > 500
        let s:shortpath_cache = {}
    endif
    let s:shortpath_cache[a:fullpath] = l:res
    return l:res
endfunction

function! s:WinListTextWidth() abort
    let l:wnr = bufwinnr(WinListBufName())
    if l:wnr == -1
        return max([10, s:PanelWidth() - 1])
    endif
    let l:w = winwidth(l:wnr)
    if getwinvar(l:wnr, '&number')
        let l:w -= str2nr(getwinvar(l:wnr, '&numberwidth')) + 1
    endif
    return max([10, l:w])
endfunction

function! WinListBuildAllTabLines() abort
    let l:cur_tab = tabpagenr()
    let l:lines   = []
    let l:textw   = s:WinListTextWidth()

    for l:t in range(1, tabpagenr('$'))
        call WinListEnsureTabID(l:t)
        let l:tid = gettabvar(l:t, 'winlist_tab_id', string(l:t))

        let l:wins_in_tab = tabpagebuflist(l:t)
        let l:split_count = 0
        for l:bn in l:wins_in_tab
            if !WinListIsWinList(l:bn) && !WinListIsNERDTree(l:bn)
                let l:bt = getbufvar(l:bn, '&buftype')
                if l:bt ==# '' || l:bt ==# 'acwrite'
                    let l:split_count += 1
                endif
            endif
        endfor

        let l:split_label = l:split_count == 1
            \ ? '[1 split]'
            \ : '[' . l:split_count . ' splits]'
        let l:active_mark = (l:t == l:cur_tab) ? ' ◀' : ''
        call add(l:lines,
            \ printf('=== Tab %d  %s%s ===§%s',
            \        l:t, l:split_label, l:active_mark, l:tid))

        if l:t == l:cur_tab
            let l:active_buf = s:CurrentContentBuf()
        else
            let l:active_buf = get(g:winlist_last_active, l:t, -1)
        endif

        let l:display_idx = 0

        for l:bn in l:wins_in_tab
            if WinListIsWinList(l:bn) || WinListIsNERDTree(l:bn)
                continue
            endif
            let l:display_idx += 1

            let l:fullpath = bufname(l:bn)
            let l:fname    = l:fullpath ==# '' ? '[No Name]'
                           \ : fnamemodify(l:fullpath, ':t')
            let l:mod      = getbufvar(l:bn, '&modified') ? ' [+]' : ''
            let l:prefix   = (l:t == l:cur_tab
                           \ && l:bn == l:active_buf) ? '> ' : '  '

            let l:entry = printf('%s%d: %s%s',
                \ l:prefix, l:display_idx, l:fname, l:mod)

            if l:prefix ==# '> '
                let l:pad = l:textw - 1 - strwidth(l:entry)
                if l:pad > 0
                    let l:entry .= repeat(' ', l:pad)
                endif
            endif

            call add(l:lines, l:entry)

            if l:fullpath !=# ''
                let l:abspath = fnamemodify(l:fullpath, ':p')
                let l:dirpath = fnamemodify(l:abspath, ':h')
                call add(l:lines, '     ' . WinListShortPath(l:dirpath))
            else
                call add(l:lines, '     -')
            endif
        endfor
    endfor

    silent! call s:SnapshotAllTabLayouts()

    return l:lines
endfunction

function! WinListStatusLine() abort
    let l:cur   = tabpagenr()
    let l:total = tabpagenr('$')

    let l:out = '%#WinListSLLabel# Tabs '

    for l:t in range(1, l:total)
        if l:t == l:cur
            let l:out .= '%#WinListSLActive#[' . l:t . ']'
        else
            let l:out .= '%#WinListSLInactive# ' . l:t . ' '
        endif
    endfor

    let l:out .= '%=%#WinListSLCounter# ' . l:cur . '/' . l:total . ' '

    return l:out
endfunction

function! WinListSetupHighlight() abort
    silent! highlight default WinListHeader     guifg=#61AFEF ctermfg=75  gui=bold
    silent! highlight default WinListHeaderID   guifg=bg      ctermfg=0   gui=NONE
    silent! highlight default WinListHeaderNum  guifg=#98c379 ctermfg=114 gui=bold
    silent! highlight default WinListSplitCnt   guifg=#e5c07b ctermfg=180 gui=bold
    silent! highlight default WinListActivTab   guifg=#e06c75 ctermfg=204 gui=bold
    silent! highlight default WinListNumber     guifg=#98c379 ctermfg=114 gui=bold
    silent! highlight WinListActive     guifg=#ffffff guibg=#003366 ctermfg=231 ctermbg=DarkBlue gui=bold
    silent! highlight WinListActiveNum  guifg=#98c379 guibg=#003366 ctermfg=114 ctermbg=DarkBlue gui=bold
    silent! highlight WinListActiveMod  guifg=#E06C75 guibg=#003366 ctermfg=204 ctermbg=DarkBlue gui=bold
    silent! highlight WinListActiveMark guifg=#E06C75 guibg=#003366 ctermfg=204 ctermbg=DarkBlue gui=bold
    silent! highlight default WinListModified   guifg=#E06C75 ctermfg=204 gui=bold
    silent! highlight default WinListSpecial    guifg=#5C6370 ctermfg=59  gui=italic
    silent! highlight default WinListPath       guifg=#7a8a9a ctermfg=66

    silent! highlight default WinListSLLabel    guifg=#00ffff guibg=#001933 gui=bold   ctermfg=51  ctermbg=17
    silent! highlight default WinListSLActive   guifg=#98c379 guibg=#001933 gui=bold   ctermfg=114 ctermbg=17
    silent! highlight default WinListSLInactive guifg=#5c6370 guibg=#001933 gui=NONE   ctermfg=59  ctermbg=17
    silent! highlight default WinListSLCounter  guifg=#e5c07b guibg=#001933 gui=NONE   ctermfg=180 ctermbg=17
endfunction
silent! call WinListSetupHighlight()

augroup WinListHighlight
    autocmd!
    autocmd ColorScheme * silent! call WinListSetupHighlight()
    augroup WinListBufSettings
        autocmd!
        autocmd FileType winlist setlocal wrap linebreak
                               \ nonumber norelativenumber nolist
                               \ cursorline buftype=nofile noswapfile nobuflisted
                               \ winfixwidth winfixheight signcolumn=no
    augroup END
augroup END

function! WinListApplySyntax() abort
    if get(b:, 'winlist_syntax_done', 0) && exists('b:current_syntax')
        return
    endif
    silent! syntax clear

    syntax match WinListHeader   /^=== Tab \d\+.*===/
    syntax match WinListHeaderID /§[^ ]*$/                         conceal
    syntax match WinListHeaderNum /\d\+/
        \ contained containedin=WinListHeader
    syntax match WinListSplitCnt  /\[\d\+ splits\?\]/
        \ contained containedin=WinListHeader
    syntax match WinListActivTab  /◀/
        \ contained containedin=WinListHeader

    setlocal conceallevel=2 concealcursor=nvic

    syntax match WinListActive     /^>.*$/
        \ contains=WinListActiveMark,WinListActiveNum,WinListActiveMod
    syntax match WinListActiveMark /^>/              contained
    syntax match WinListActiveNum  /\d\+:/           contained
    syntax match WinListActiveMod  /\[+\]/           contained
    syntax match WinListNumber     /\d\+:/           contained
    syntax match WinListNumber     /^\s\+\d\+:/
    syntax match WinListModified   /\[+\]/
    syntax match WinListSpecial    /\[[^\]+]\+\]/
    syntax match WinListPath       /^\s\+[…\/].*/

    let b:current_syntax      = 'winlist'
    let b:winlist_syntax_done = 1
endfunction

function! WinListApplyStatusLine() abort
    let l:wl_wnr = bufwinnr(WinListBufName())
    if l:wl_wnr == -1 | return | endif
    let l:cur = winnr()
    execute 'noautocmd ' . l:wl_wnr . 'wincmd w'
    setlocal statusline=%!WinListStatusLine()
    execute 'noautocmd ' . l:cur . 'wincmd w'
endfunction

function! WinListRefresh() abort
    if g:winlist_opening | return | endif
    if g:panel_opening   | return | endif
    if !WinListIsOpen()  | return | endif

    let l:wl_winnr = bufwinnr(WinListBufName())
    let l:cur_win  = winnr()

    if l:cur_win != l:wl_winnr
        \ && !WinListIsSpecial()
        \ && !WinListIsNERDTree(winbufnr(l:cur_win))
        let g:winlist_last_active[tabpagenr()] = bufnr('%')
    endif

    let l:lines = WinListBuildAllTabLines()

    execute 'noautocmd ' . l:wl_winnr . 'wincmd w'
    setlocal modifiable
    silent! %delete _
    silent! call setline(1, l:lines)
    setlocal nomodifiable nomodified
    setlocal statusline=%!WinListStatusLine()
    silent! call WinListApplySyntax()

    execute 'noautocmd ' . l:cur_win . 'wincmd w'
endfunction

function! WinListRefreshAllTabs() abort
    if g:winlist_opening | return | endif
    if g:panel_opening   | return | endif
    if g:netrw_expanding | return | endif

    let l:save_lz = &lazyredraw
    set lazyredraw

    let l:cur_tab = tabpagenr()
    let l:cur_win = winnr()

    if !WinListIsSpecial() && !WinListIsNERDTree()
        let g:winlist_last_active[l:cur_tab] = bufnr('%')
    endif

    silent! call s:SnapshotAllTabLayouts()

    if WinListIsOpenAnywhere()
        let l:lines  = WinListBuildAllTabLines()
        let l:wl_buf = WinListBufName()
        let l:wl_wnr = bufwinnr(l:wl_buf)

        if l:wl_wnr != -1
            let l:restore_win = winnr()
            execute 'noautocmd ' . l:wl_wnr . 'wincmd w'
            setlocal modifiable
            silent! %delete _
            silent! call setline(1, l:lines)
            setlocal nomodifiable nomodified
            setlocal statusline=%!WinListStatusLine()
            silent! call WinListApplySyntax()
            execute 'noautocmd ' . l:restore_win . 'wincmd w'
        endif
    endif

    let &lazyredraw = l:save_lz
endfunction

let s:wl_last_refresh  = reltime()
let s:wl_refresh_timer = -1

function! WinListRefreshSoon() abort
    if g:winlist_opening || g:panel_opening || g:netrw_expanding
        return
    endif

    if !WinListIsSpecial() && !WinListIsNERDTree()
        let g:winlist_last_active[tabpagenr()] = bufnr('%')
    endif

    if reltimefloat(reltime(s:wl_last_refresh)) >= 0.04
        let s:wl_last_refresh = reltime()
        silent! call WinListRefreshAllTabs()
        return
    endif

    if s:wl_refresh_timer != -1
        return
    endif
    let s:wl_refresh_timer = timer_start(60, {-> s:WinListRefreshTick()})
endfunction

function! s:WinListRefreshTick(...) abort
    let s:wl_refresh_timer = -1
    if mode() !~# '^\%(n\|no\)$'
        let s:wl_refresh_timer = timer_start(120, {-> s:WinListRefreshTick()})
        return
    endif
    if g:winlist_opening || g:panel_opening || g:netrw_expanding
        return
    endif
    if !WinListIsSpecial() && !WinListIsNERDTree()
        let g:winlist_last_active[tabpagenr()] = bufnr('%')
    endif
    let s:wl_last_refresh = reltime()
    silent! call WinListRefreshAllTabs()
endfunction

function! s:SetupWinListWindow() abort
    setlocal winfixwidth
    setlocal buftype=nofile bufhidden=hide
    setlocal noswapfile nobuflisted
    setlocal wrap linebreak number norelativenumber
    setlocal cursorline filetype=winlist signcolumn=no
    setlocal statusline=%!WinListStatusLine()

    nnoremap <silent> <nowait> <buffer> <LeftMouse>   <LeftMouse>
    nnoremap <silent> <nowait> <buffer> <2-LeftMouse> :call WinListMouseJump()<CR>
    nnoremap <silent> <nowait> <buffer> <CR>          :call WinListJump()<CR>
    nnoremap <silent> <nowait> <buffer> q             :call CombinedPanelClose()<CR>
    nnoremap <silent> <nowait> <buffer> r             :call WinListRefreshAllTabs()<CR>
endfunction

function! CombinedPanelOpen() abort
    if g:panel_opening   | return | endif
    if g:winlist_opening | return | endif

    if WinListIsOpen()
        silent! call WinListRefreshAllTabs()
        silent! call WinListFixWidth()
        return
    endif

    let l:safe = WinListFindAnchorWin()
    if l:safe == -1
        call timer_start(100, {-> CombinedPanelOpen()})
        return
    endif

    let g:panel_opening   = 1
    let g:winlist_opening = 1

    try
        execute 'noautocmd ' . l:safe . 'wincmd w'

        execute 'topleft vertical split ' . WinListBufName()
        execute 'vertical resize ' . s:PanelWidth()
        call s:SetupWinListWindow()

        let g:winlist_tab_open[tabpagenr()] = 1

        let l:back = WinListFindAnchorWin()
        if l:back != -1
            execute 'noautocmd ' . l:back . 'wincmd w'
        endif
    finally
        let g:panel_opening   = 0
        let g:winlist_opening = 0
    endtry

    silent! call WinListRefreshAllTabs()
endfunction

function! PanelOpenWithNERDTree() abort
    if g:panel_opening | return | endif
    if !exists(':NERDTree')
        echo 'NERDTree is not installed.'
        return
    endif
    if NERDTreeIsOpen() && WinListIsOpen()
        silent! call WinListRefreshAllTabs()
        return
    endif

    let g:panel_opening = 1

    try
        if !NERDTreeIsOpen()
            let l:cwd = filereadable(expand('%:p'))
                \ ? fnamemodify(expand('%:p'), ':h')
                \ : getcwd()
            execute 'NERDTree ' . fnameescape(l:cwd)
            execute 'vertical resize ' . s:PanelWidth()
            setlocal winfixwidth
        endif

        let l:nt = -1
        for l:i in range(1, winnr('$'))
            if WinListIsNERDTree(winbufnr(l:i))
                let l:nt = l:i
                break
            endif
        endfor

        if l:nt != -1 && !WinListIsOpen()
            let l:half = WinListHalfHeight()

            execute 'noautocmd ' . l:nt . 'wincmd w'
            execute 'aboveleft ' . l:half . 'split ' . WinListBufName()
            call s:SetupWinListWindow()
            execute 'vertical resize ' . s:PanelWidth()

            let l:nt2 = -1
            for l:i in range(1, winnr('$'))
                if WinListIsNERDTree(winbufnr(l:i))
                    let l:nt2 = l:i
                    break
                endif
            endfor
            if l:nt2 != -1
                execute 'noautocmd ' . l:nt2 . 'wincmd w'
                execute 'resize ' . l:half
                setlocal winfixwidth winfixheight
            endif

            let g:winlist_tab_open[tabpagenr()] = 1
        endif

        let g:panel_nerdtree_open = 1
    finally
        let g:panel_opening = 0
    endtry

    let l:back = WinListFindNormalWin()
    if l:back != -1
        execute 'noautocmd ' . l:back . 'wincmd w'
    endif

    silent! call WinListRefreshAllTabs()
endfunction

function! NERDTreePanelToggle() abort
    if NERDTreeIsOpen()
        silent! NERDTreeClose
        let g:panel_nerdtree_open = 0

        let l:back = WinListFindNormalWin()
        if l:back != -1
            execute 'noautocmd ' . l:back . 'wincmd w'
        endif
        silent! call WinListRefreshAllTabs()
    else
        silent! call PanelOpenWithNERDTree()
        call timer_start(80, {-> s:FocusNERDTreeWindow()})
    endif
endfunction

function! CombinedPanelClose() abort
    if WinListIsOpen()
        let l:wl_wnr = bufwinnr(WinListBufName())
        execute 'noautocmd ' . l:wl_wnr . 'wincmd c'
        let g:winlist_tab_open[tabpagenr()] = 0
    endif

    let l:back = WinListFindNormalWin()
    if l:back != -1
        execute 'noautocmd ' . l:back . 'wincmd w'
    endif
endfunction

function! CombinedPanelToggle() abort
    if CombinedPanelIsOpen()
        silent! call CombinedPanelClose()
    else
        silent! call CombinedPanelOpen()
        call timer_start(80, {-> s:FocusWinListPanel()})
    endif
endfunction

function! s:FocusWinListPanel() abort
    let l:wl_wnr = bufwinnr(WinListBufName())
    if l:wl_wnr != -1
        execute l:wl_wnr . 'wincmd w'
    endif
endfunction

function! s:FocusNERDTreeWindow() abort
    for l:i in range(1, winnr('$'))
        if WinListIsNERDTree(winbufnr(l:i))
            execute l:i . 'wincmd w'
            return
        endif
    endfor
endfunction

autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1
    \ && exists('b:NERDTree') && b:NERDTree.isTabTree()
    \ | call feedkeys(":quit\<CR>:\<BS>") | endif

autocmd VimEnter * silent! call NERDTreeAddKeyMap({
      \ 'key':      '<2-LeftMouse>',
      \ 'scope':    'FileNode',
      \ 'callback': 'OpenSmart',
      \ 'override': 1 })
autocmd VimEnter * silent! call NERDTreeAddKeyMap({
      \ 'key':      '<CR>',
      \ 'scope':    'FileNode',
      \ 'callback': 'OpenSmart',
      \ 'override': 1 })
autocmd VimEnter * silent! call NERDTreeAddKeyMap({
      \ 'key':      'T',
      \ 'scope':    'FileNode',
      \ 'callback': 'OpenInNewTabAtEnd',
      \ 'override': 1 })
autocmd VimEnter * silent! call NERDTreeAddKeyMap({
      \ 'key':      'T',
      \ 'scope':    'DirNode',
      \ 'callback': 'OpenInNewTabAtEnd',
      \ 'override': 1 })
autocmd VimEnter * silent! call NERDTreeAddKeyMap({
      \ 'key':      'T',
      \ 'scope':    'Node',
      \ 'callback': 'OpenInNewTabAtEnd',
      \ 'override': 1 })

function! OpenInNewTabAtEnd(node) abort
    let l:path  = a:node.path.str()
    let l:cur   = tabpagenr()
    let l:ntabs = tabpagenr('$')

    if tabpagenr() != l:ntabs
        silent! execute 'tabnext ' . l:ntabs
    endif

    silent! execute 'tabnew ' . fnameescape(l:path)
    if tabpagenr('$') != l:ntabs + 1
        echo 'T: cannot open a new tab for ' . fnamemodify(l:path, ':t')
        silent! execute 'tabnext ' . l:cur
        return
    endif

    if tabpagenr() != l:cur && l:cur <= tabpagenr('$')
        silent! execute 'tabnext ' . l:cur
    endif

    silent! call WinListRefreshAllTabs()

    echo printf('T: %s -> tab %d/%d (last)',
        \ fnamemodify(l:path, ':t'), l:ntabs + 1, l:ntabs + 1)
endfunction

function! OpenSmart(node)
    let l:path = a:node.path.str()
    let g:winlist_file_opening = 1

    let l:normal_wins = []
    for l:i in range(1, winnr('$'))
        let l:bn = winbufnr(l:i)
        if !WinListIsSpecial(l:bn) && !WinListIsNERDTree(l:bn)
            silent! call add(l:normal_wins, l:i)
        endif
    endfor

    if len(l:normal_wins) == 0
        let l:last_win = winnr('$')
        execute 'noautocmd ' . l:last_win . 'wincmd w'
        execute 'rightbelow vertical split ' . fnameescape(l:path)
        call timer_start(50, {-> s:CloseNERDTreeAfterOpen()})
    else
        let l:rightmost = l:normal_wins[-1]
        execute 'noautocmd ' . l:rightmost . 'wincmd w'
        execute 'rightbelow vertical split ' . fnameescape(l:path)
    endif

    call timer_start(300, {-> s:ClearFileOpening()})
endfunction

function! s:CloseNERDTreeAfterOpen() abort
    for l:i in range(1, winnr('$'))
        if WinListIsNERDTree(winbufnr(l:i))
            execute 'noautocmd ' . l:i . 'wincmd w'
            silent! close
            break
        endif
    endfor
    let g:panel_nerdtree_open = 0
    silent! call WinListRefreshAllTabs()
endfunction

function! s:ClearFileOpening() abort
    let g:winlist_file_opening = 0
endfunction

function! WinListMouseJump() abort
    let l:lnum = 0

    if exists('*getmousepos')
        let l:mpos = getmousepos()
        if l:mpos.winid == win_getid()
            let l:lnum = l:mpos.line
            call cursor(l:lnum, max([1, l:mpos.column]))
        endif
    endif

    if l:lnum == 0
        let l:lnum = line('.')
    endif

    if l:lnum > 0 && getline(l:lnum) =~# '^[> ]*\d\+:'
        call WinListJump()
    endif
endfunction

function! WinListJump() abort
    let l:line = getline('.')
    let l:m    = matchlist(l:line, '^[> ]*\(\d\+\):')
    if empty(l:m) | return | endif
    let l:display_idx = str2nr(l:m[1])

    let l:header_tid = ''
    for l:lnum in range(1, line('.'))
        let l:hdr = matchlist(getline(l:lnum), '^=== Tab \d\+ .*===§\(.\+\)$')
        if !empty(l:hdr)
            let l:header_tid = l:hdr[1]
        endif
    endfor

    let l:real_tab = -1
    if l:header_tid !=# ''
        let l:real_tab = WinListFindTabByID(l:header_tid)
    endif

    if l:real_tab == -1
        echo "WinList: tab no longer exists."
        return
    endif

    if l:real_tab != tabpagenr()
        execute 'tabnext ' . l:real_tab
    endif

    let l:count    = 0
    let l:real_win = -1
    for l:i in range(1, winnr('$'))
        let l:bn = winbufnr(l:i)
        if WinListIsWinList(l:bn) || WinListIsNERDTree(l:bn)
            continue
        endif
        let l:count += 1
        if l:count == l:display_idx
            let l:real_win = l:i
            break
        endif
    endfor

    if l:real_win != -1
        execute l:real_win . 'wincmd w'
        silent! call WinListRefresh()
    endif
endfunction

function! WinListOpen() abort
    silent! call CombinedPanelOpen()
endfunction

function! WinListClose() abort
    silent! call CombinedPanelClose()
endfunction

function! WinListToggle() abort
    silent! call CombinedPanelToggle()
endfunction

function! WinListOpenInAllTabs() abort
    let l:cur = tabpagenr()
    tabdo silent! call CombinedPanelOpen()
    execute 'tabnext ' . l:cur
endfunction

function! WinListOnTabLeave() abort
    let g:winlist_tab_open[tabpagenr()] = WinListIsOpen() ? 1 : 0
endfunction

function! WinListOnTabEnter() abort
    if !get(g:, 'winlist_always', 1) | return | endif
    call timer_start(20, {-> s:EnsureWinListInTab(tabpagenr())})
endfunction

function! s:EnsureWinListInTab(tabnr) abort
    if tabpagenr() != a:tabnr        | return | endif
    if get(g:, 'netrw_expanding', 0) | return | endif
    if WinListIsOpen()
        silent! call WinListRefreshAllTabs()
    else
        silent! call CombinedPanelOpen()
    endif
endfunction

function! WinListOnTabNew() abort
    let l:tabnr = tabpagenr()
    let g:winlist_tab_open[l:tabnr] = 1
endfunction

augroup WinListAuto
    autocmd!
    autocmd BufWritePost * silent! call WinListRefreshSoon()
    autocmd BufReadPost  * silent! call WinListRefreshSoon()
    autocmd BufAdd       * silent! call WinListRefreshSoon()
    autocmd BufDelete    * silent! call WinListRefreshSoon()
    autocmd BufWipeout   * silent! call WinListRefreshSoon()

    autocmd WinEnter * silent! call WinListCheckAutoCloseTab()
    autocmd WinEnter * silent! call WinListRefreshSoon()
    autocmd BufEnter * silent! call WinListRefreshSoon()

    autocmd TabEnter * silent! call WinListApplyStatusLine()

    autocmd TabLeave * silent! call WinListOnTabLeave()
    autocmd TabEnter * silent! call WinListOnTabEnter()
    autocmd TabNew   * silent! call WinListOnTabNew()

    autocmd VimResized * silent! call WinListRefreshSoon()
augroup END

augroup WinListStartup
    autocmd!
    autocmd VimEnter * call timer_start(60, {-> s:StartupWinList()})
augroup END

function! s:StartupWinList() abort
    if !get(g:, 'winlist_always', 1) | return | endif
    if get(g:, 'netrw_expanding', 0)  | return | endif
    if WinListIsOpen()                | return | endif

    if &buftype ==# '' && expand('%') ==# ''
        let l:dir = argc() > 0 ? fnamemodify(argv(0), ':p') : getcwd()
        if isdirectory(l:dir)
            silent! execute 'edit ' . fnameescape(l:dir)
        endif
    endif

    silent! call CombinedPanelOpen()
endfunction

nnoremap <silent> wl :call WinListToggle()<CR>

noremap <silent> <C-b> :call NERDTreePanelToggle()<CR>

nnoremap <silent> <leader>w  :call WinListToggle()<CR>
nnoremap <silent> <leader>W  :call WinListFixWidth()<CR>
nnoremap <silent> <leader>wa :call WinListOpenInAllTabs()<CR>
nnoremap <silent> <leader>wh :call WinListFixPanelHeights()<CR>

command! WinList        call WinListOpen()
command! WinListClose   call WinListClose()
command! WinListFix     call WinListFixWidth()
command! WinListRefresh call WinListRefreshAllTabs()
command! WinListAllTabs call WinListOpenInAllTabs()
command! WinListFixH    call WinListFixPanelHeights()

let g:splitexpand_active  = 0
let g:splitexpand_timer   = 0
let g:splitexpand_pending = 0

function! SplitExpandCurrentWin() abort
    let l:total       = winnr('$')
    let l:cur         = winnr()
    let l:avail_width = &columns

    let l:wl_wnr = bufwinnr(WinListBufName())
    if l:wl_wnr != -1
        let l:avail_width -= winwidth(l:wl_wnr) + 1
    endif

    for l:i in range(1, l:total)
        if WinListIsNERDTree(winbufnr(l:i))
            let l:avail_width -= winwidth(l:i) + 1
        endif
    endfor

    let l:normal_wins = []
    for l:i in range(1, l:total)
        let l:bn = winbufnr(l:i)
        if !WinListIsSpecial(l:bn) && !WinListIsNERDTree(l:bn)
            silent! call add(l:normal_wins, l:i)
        endif
    endfor

    if len(l:normal_wins) <= 1 | return | endif

    if l:wl_wnr != -1
        call setwinvar(l:wl_wnr, '&winfixwidth', 1)
    endif
    for l:i in range(1, l:total)
        if WinListIsNERDTree(winbufnr(l:i))
            call setwinvar(l:i, '&winfixwidth', 1)
        endif
    endfor

    let l:min_w  = 1
    let l:main_w = l:avail_width - (len(l:normal_wins) - 1) * (l:min_w + 1)
    if l:main_w < 1 | let l:main_w = 1 | endif

    for l:i in l:normal_wins
        call setwinvar(l:i, '&winfixwidth', 0)
        if l:i == l:cur
            execute l:i . 'wincmd w'
            execute 'vertical resize ' . l:main_w
        else
            execute l:i . 'wincmd w'
            execute 'vertical resize ' . l:min_w
        endif
    endfor

    execute l:cur . 'wincmd w'
    let g:splitexpand_active = 1
endfunction

function! SplitExpandRestore() abort
    let l:total  = winnr('$')
    let l:cur    = winnr()
    let l:wl_wnr = bufwinnr(WinListBufName())

    let l:normal_wins = []
    for l:i in range(1, l:total)
        let l:bn = winbufnr(l:i)
        if !WinListIsSpecial(l:bn) && !WinListIsNERDTree(l:bn)
            silent! call add(l:normal_wins, l:i)
        endif
    endfor

    for l:i in l:normal_wins
        call setwinvar(l:i, '&winfixwidth', 0)
    endfor

    if l:wl_wnr != -1
        execute 'noautocmd ' . l:wl_wnr . 'wincmd w'
        execute 'vertical resize ' . s:PanelWidth()
        call setwinvar(l:wl_wnr, '&winfixwidth', 1)
    endif

    execute l:cur . 'wincmd w'
    execute 'wincmd ='

    if l:wl_wnr != -1
        silent! call WinListFixWidth()
    endif

    let g:splitexpand_active = 0
endfunction

function! SplitExpandHandleEnter() abort
    if g:splitexpand_pending
        if g:splitexpand_timer != 0
            silent! call timer_stop(g:splitexpand_timer)
            let g:splitexpand_timer = 0
        endif
        let g:splitexpand_pending = 0
        silent! call SplitExpandRestore()
    else
        let g:splitexpand_pending = 1
        let g:splitexpand_timer   = timer_start(350, {-> s:SplitExpandTimeout()})
    endif
endfunction

function! s:SplitExpandTimeout() abort
    let g:splitexpand_pending = 0
    let g:splitexpand_timer   = 0
endfunction

function! SplitExpandCtrlEnter() abort
    if g:splitexpand_active
        silent! call SplitExpandRestore()
    endif
    if g:splitexpand_timer != 0
        silent! call timer_stop(g:splitexpand_timer)
        let g:splitexpand_timer = 0
    endif
    let g:splitexpand_pending = 0
    silent! call SplitExpandCurrentWin()
endfunction

function! s:SplitExpandCheckStillValid() abort
    let l:normal_wins = 0
    for l:i in range(1, winnr('$'))
        let l:bn = winbufnr(l:i)
        if !WinListIsSpecial(l:bn) && !WinListIsNERDTree(l:bn)
            let l:normal_wins += 1
        endif
    endfor
    if l:normal_wins <= 1
        let g:splitexpand_active = 0
    endif
endfunction

augroup SplitExpandReset
    autocmd!
    autocmd WinEnter    * if g:splitexpand_active | call s:SplitExpandCheckStillValid() | endif
    autocmd BufWinLeave * let g:splitexpand_active = 0
augroup END

nnoremap <silent> <CR>   :call SplitExpandHandleEnter()<CR>
nnoremap <silent> <C-CR> :call SplitExpandCtrlEnter()<CR>

function! s:HasNetrwWindow() abort
    for l:i in range(1, winnr('$'))
        if getbufvar(winbufnr(l:i), '&filetype') ==# 'netrw'
            return 1
        endif
    endfor
    return 0
endfunction

function! s:IsNetrwBuffer() abort
    return &filetype ==# 'netrw' || bufname('%') =~# '^netrw'
endfunction

function! s:NetrwBack() abort
    let l:bn   = get(g:, 'netrw_back_buf', -1)
    let l:path = get(g:, 'netrw_back_path', '')

    if l:bn > 0 && bufexists(l:bn) && l:bn != bufnr('%')
        silent! execute 'buffer ' . l:bn
        return
    endif

    if l:path !=# '' && filereadable(l:path)
        silent! execute 'edit ' . fnameescape(l:path)
        return
    endif

    let l:alt = bufnr('#')
    if l:alt > 0 && bufexists(l:alt) && getbufvar(l:alt, '&filetype') !=# 'netrw'
        silent! execute 'buffer ' . l:alt
        return
    endif

    echo 'Ctrl-O: no previous buffer to return to.'
endfunction

function! SmartCtrlO() abort
    if s:IsNetrwBuffer()
        silent! call s:NetrwBack()
        return
    endif

    if !exists(':Explore')
        echo ':Explore (netrw) not available - cannot open explorer.'
        return
    endif

    if get(g:, 'netrw_explore_active', 0) && !s:HasNetrwWindow()
        let g:netrw_explore_active = 0
        let g:netrw_expanding      = 0
    endif

    let g:netrw_back_buf  = bufnr('%')
    let g:netrw_back_path = expand('%:p')

    let g:netrw_expanding      = 1
    let g:netrw_explore_active = 1

    silent! execute 'Explore'
endfunction

function! SmartCtrlORestore() abort
    if !get(g:, 'netrw_explore_active', 0) | return | endif
    let g:netrw_explore_active = 0
    let g:netrw_expanding      = 0
endfunction

augroup NetrwExpandRestore
    autocmd!
    autocmd BufLeave    * if &filetype ==# 'netrw' | call SmartCtrlORestore() | endif
    autocmd BufWinLeave * if &filetype ==# 'netrw' | call SmartCtrlORestore() | endif
augroup END

noremap <silent> <C-o> :call SmartCtrlO()<CR>

function! s:DefineEAsEdit() abort
    silent! delcommand E
    command! -nargs=? -bang -complete=file E edit<bang> <args>
endfunction

augroup ForceEAsEdit
    autocmd!
    autocmd VimEnter * call s:DefineEAsEdit()
augroup END

silent! call s:DefineEAsEdit()

if !exists('g:closed_file_stack')
    let g:closed_file_stack = []
endif

let g:closed_file_stack_max = 20

function! s:ClosedEntryPath(e) abort
    return type(a:e) == type({}) ? get(a:e, 'path', '') : a:e
endfunction

function! s:ContentWinOrdinal(bn) abort
    let l:c = 0
    for l:i in range(1, winnr('$'))
        if !WinListIsSpecial(winbufnr(l:i)) && !WinListIsNERDTree(winbufnr(l:i))
            let l:c += 1
            if winbufnr(l:i) == a:bn
                return l:c
            endif
        endif
    endfor
    return 0
endfunction

function! s:ContentWinNr(n) abort
    let l:c = 0
    for l:i in range(1, winnr('$'))
        if !WinListIsSpecial(winbufnr(l:i)) && !WinListIsNERDTree(winbufnr(l:i))
            let l:c += 1
            if l:c == a:n | return l:i | endif
        endif
    endfor
    return 0
endfunction

function! ClosedFileStackPush() abort
    let l:name = expand('%:p')
    let l:bt   = &buftype

    if l:name ==# ''               | return | endif
    if l:bt   !=# ''               | return | endif
    if l:name =~# 'NERD_tree'      | return | endif
    if l:name =~# '__WindowList__' | return | endif
    if !filereadable(l:name)       | return | endif

    let l:tabidx = tabpagenr()
    let l:ord    = s:ContentWinOrdinal(bufnr('%'))

    let l:entry = {
        \ 'path':   l:name,
        \ 'tabid':  WinListGetTabID(),
        \ 'tabidx': l:tabidx,
        \ 'ord':    l:ord,
        \ 'w':      winwidth(0),
        \ }

    call filter(g:closed_file_stack,
        \ 'type(v:val) == type({})'
        \ . ' ? (v:val.path !=# l:name'
        \ . '    && !(get(v:val, "tabidx", -1) == l:tabidx'
        \ . '         && get(v:val, "ord", -1) == l:ord))'
        \ . ' : v:val !=# l:name')
    call insert(g:closed_file_stack, l:entry, 0)

    if len(g:closed_file_stack) > g:closed_file_stack_max
        let g:closed_file_stack = g:closed_file_stack[:g:closed_file_stack_max - 1]
    endif
endfunction

function! ReopenLastClosedFile() abort
    if empty(g:closed_file_stack)
        echo 'No recently closed files.'
        return 0
    endif

    let l:entry = remove(g:closed_file_stack, 0)
    let l:path  = s:ClosedEntryPath(l:entry)

    if l:path ==# '' || !filereadable(l:path)
        echo 'File no longer readable: ' . l:path
        return 0
    endif

    let l:is_dict = type(l:entry) == type({})
    let l:tabid   = l:is_dict ? get(l:entry, 'tabid',  '') : ''
    let l:tabidx  = l:is_dict ? get(l:entry, 'tabidx', 0)  : 0
    let l:ord     = l:is_dict ? get(l:entry, 'ord',    0)  : 0
    let l:width   = l:is_dict ? get(l:entry, 'w',      0)  : 0

    if get(g:, 'tab_restore_debug', 0)
        echo printf('FILE RESTORE: %s tabid=%s tabidx=%d ord=%d w=%d',
            \ fnamemodify(l:path, ':t'), l:tabid, l:tabidx, l:ord, l:width)
    endif

    let l:tab = l:tabid ==# '' ? -1 : WinListFindTabByID(l:tabid)

    if l:tab == -1 && !empty(get(g:, 'last_restored_tab', {}))
        let l:lrt = g:last_restored_tab
        if get(l:lrt, 'index', -1) == l:tabidx
            \ && get(l:lrt, 'tabnr', 0) >= 1
            \ && get(l:lrt, 'tabnr', 0) <= tabpagenr('$')
            let l:tab = l:lrt.tabnr
            let g:last_restored_tab = {}
        endif
    endif

    call s:RestoreLog(printf('POP-WIN %s tabidx=%d ord=%d -> tab %d',
        \ fnamemodify(l:path, ':t'), l:tabidx, l:ord, l:tab))

    if l:tab == -1 && l:tabidx > 0
        let l:n_before = tabpagenr('$')
        silent! execute 'tabnew'
        if tabpagenr('$') == l:n_before + 1
            silent! execute 'edit ' . fnameescape(l:path)

            let g:last_restored_tab = {'tabnr': tabpagenr(), 'index': l:tabidx}

            silent! call CombinedPanelOpen()

            let l:target = max([0, min([l:tabidx - 1, tabpagenr('$') - 1])])
            silent! execute 'tabmove ' . l:target

            if l:width > 0 && winwidth(0) != l:width
                silent! execute 'vertical resize ' . l:width
            endif

            silent! call WinListRefreshAllTabs()
            echo printf('Ctrl-Shift-T: rebuilding tab %d with %s',
                \ tabpagenr(), fnamemodify(l:path, ':t'))
            return 1
        endif
    elseif l:tab != -1 && l:tab != tabpagenr()
        silent! execute 'tabnext ' . l:tab
    endif

    let l:n_wins = 0
    for l:i in range(1, winnr('$'))
        if !WinListIsSpecial(winbufnr(l:i)) && !WinListIsNERDTree(winbufnr(l:i))
            let l:n_wins += 1
        endif
    endfor

    let l:anchor = s:ContentWinNr(max([1, l:ord - 1]))
    if l:anchor == 0
        let l:anchor = s:ContentWinNr(l:n_wins)
    endif

    if l:anchor == 0
        silent! execute 'edit ' . fnameescape(l:path)
    else
        execute 'noautocmd ' . l:anchor . 'wincmd w'
        if l:ord <= 1
            silent! execute 'leftabove vsplit ' . fnameescape(l:path)
        else
            silent! execute 'rightbelow vsplit ' . fnameescape(l:path)
        endif
    endif

    if l:width > 0 && winwidth(0) != l:width
        silent! execute 'vertical resize ' . l:width
    endif

    silent! call WinListRefreshAllTabs()
    echo printf('Ctrl-Shift-T: %s -> tab %d, position %d, width %d',
        \ fnamemodify(l:path, ':t'), tabpagenr(), l:ord, winwidth(0))
    return 1
endfunction

function! SmartClose() abort
    silent! call ClosedFileStackPush()
    quit
endfunction

noremap <silent> <C-w> :call SmartClose()<CR>

nnoremap <silent> <C-S-t> :call ReopenLastClosed()<CR>
inoremap <silent> <C-S-t> <Esc>:call ReopenLastClosed()<CR>

if !exists('g:closed_tab_stack')
    let g:closed_tab_stack = []
endif
if !exists('g:tab_layout_cache')
    let g:tab_layout_cache = {}
endif

let g:closed_tab_stack_max = 10

let g:tab_snapshot_last = reltime()

if !exists('g:restore_log')
    let g:restore_log = []
endif

if !exists('g:last_restored_tab')
    let g:last_restored_tab = {}
endif

function! s:RestoreLog(msg) abort
    call add(g:restore_log, strftime('%H:%M:%S') . '  ' . a:msg)
    while len(g:restore_log) > 40
        call remove(g:restore_log, 0)
    endwhile
endfunction

function! ClosedInfo() abort
    echomsg '── closed_tab_stack (newest first) ──'
    if empty(g:closed_tab_stack)
        echomsg '  (empty)'
    else
        let l:i = 0
        for l:s in g:closed_tab_stack
            let l:i += 1
            echomsg printf('  %d) tab %d  tid=%s  dir=%s  active=%d  wins=%s',
                \ l:i, get(l:s, 'index', -1), get(l:s, 'tid', '?'),
                \ get(l:s, 'dir', '?'), get(l:s, 'active', 0),
                \ string(map(copy(get(l:s, 'wins', [])),
                \            'fnamemodify(v:val.path, ":t")')))
        endfor
    endif
    echomsg '── closed_file_stack (newest first) ──'
    if empty(g:closed_file_stack)
        echomsg '  (empty)'
    else
        let l:i = 0
        for l:e in g:closed_file_stack
            let l:i += 1
            if type(l:e) == type({})
                echomsg printf('  %d) %s  tabid=%s  tabidx=%d  ord=%d  w=%d',
                    \ l:i, fnamemodify(get(l:e, 'path', ''), ':t'),
                    \ get(l:e, 'tabid', ''), get(l:e, 'tabidx', 0),
                    \ get(l:e, 'ord', 0), get(l:e, 'w', 0))
            else
                echomsg printf('  %d) %s  (legacy entry)', l:i, l:e)
            endif
        endfor
    endif
    echomsg '── open tabs / Tab-ID ──'
    for l:t in range(1, tabpagenr('$'))
        echomsg printf('  tab %d  tid=%s  wins=%s', l:t,
            \ gettabvar(l:t, 'winlist_tab_id', '?'),
            \ string(map(copy(tabpagebuflist(l:t)), 'fnamemodify(bufname(v:val), ":t")')))
    endfor
    echomsg '── restore_log (old -> new) ──'
    if empty(g:restore_log)
        echomsg '  (empty)'
    else
        for l:m in g:restore_log
            echomsg '  ' . l:m
        endfor
    endif
endfunction
command! ClosedInfo call ClosedInfo()

function! s:CollectLayoutLeaves(node, out) abort
    if a:node[0] ==# 'leaf'
        call add(a:out, a:node[1])
        return
    endif
    for l:child in a:node[1:]
        call s:CollectLayoutLeaves(l:child, a:out)
    endfor
endfunction

function! s:PruneLayout(node) abort
    if a:node[0] ==# 'leaf'
        let l:bn = winbufnr(a:node[1])
        if l:bn <= 0 | return [] | endif
        if WinListIsWinList(l:bn) || WinListIsNERDTree(l:bn) | return [] | endif
        if WinListIsSpecial(l:bn) | return [] | endif
        return a:node
    endif

    let l:kids = []
    for l:child in a:node[1:]
        let l:p = s:PruneLayout(l:child)
        if !empty(l:p)
            call add(l:kids, l:p)
        endif
    endfor

    if empty(l:kids)     | return []       | endif
    if len(l:kids) == 1  | return l:kids[0] | endif
    return [a:node[0]] + l:kids
endfunction

function! s:SnapshotTabLayout(tabnr) abort
    try
        call WinListEnsureTabID(a:tabnr)
        let l:tid = WinListGetTabID(a:tabnr)
        if l:tid ==# '' | return {} | endif

        let l:root = []
        let l:wids = []
        if exists('*winlayout')
            let l:root = winlayout(a:tabnr)
            call s:CollectLayoutLeaves(l:root, l:wids)
        endif

        let l:wins = []
        for l:wid in l:wids
            let l:bn = winbufnr(l:wid)
            if l:bn <= 0 | continue | endif
            if WinListIsWinList(l:bn) || WinListIsNERDTree(l:bn) | continue | endif
            if WinListIsSpecial(l:bn) | continue | endif
            let l:name  = bufname(l:bn)
            let l:apath = l:name ==# '' ? '' : fnamemodify(l:name, ':p')
            call add(l:wins, {
                \ 'nr':   l:bn,
                \ 'path': l:apath,
                \ 'name': l:name ==# '' ? '[No Name]' : fnamemodify(l:name, ':t'),
                \ 'w':    winwidth(l:wid),
                \ 'h':    winheight(l:wid),
                \ })
        endfor

        if empty(l:wins)
            for l:bn in tabpagebuflist(a:tabnr)
                if l:bn <= 0 | continue | endif
                if WinListIsWinList(l:bn) || WinListIsNERDTree(l:bn) | continue | endif
                if WinListIsSpecial(l:bn) | continue | endif
                let l:name  = bufname(l:bn)
                let l:apath = l:name ==# '' ? '' : fnamemodify(l:name, ':p')
                call add(l:wins, {
                    \ 'nr':   l:bn,
                    \ 'path': l:apath,
                    \ 'name': l:name ==# '' ? '[No Name]' : fnamemodify(l:name, ':t'),
                    \ 'w':    0,
                    \ 'h':    0,
                    \ })
            endfor
        endif

        if empty(l:wins) | return {} | endif

        let l:dir = 'row'
        let l:pruned = empty(l:root) ? [] : s:PruneLayout(l:root)
        if type(l:pruned) == type([]) && !empty(l:pruned)
            if l:pruned[0] ==# 'col'
                let l:dir = 'col'
            endif
        endif

        let l:active_buf = (a:tabnr == tabpagenr())
            \ ? s:CurrentContentBuf()
            \ : get(g:winlist_last_active, a:tabnr, -1)

        let l:active = 0
        let l:i = 0
        for l:w in l:wins
            let l:i += 1
            if l:w.nr == l:active_buf
                let l:active = l:i
            endif
        endfor

        return {
            \ 'index':  a:tabnr,
            \ 'tid':    l:tid,
            \ 'wins':   l:wins,
            \ 'dir':    l:dir,
            \ 'active': l:active,
            \ 'seen':   localtime(),
            \ }
    catch
        return {}
    endtry
endfunction

function! s:PushClosedTab(snap) abort
    if empty(a:snap) || empty(get(a:snap, 'wins', [])) | return | endif

    call s:RestoreLog(printf('PUSH-TAB index=%d tid=%s wins=%s',
        \ get(a:snap, 'index', -1), get(a:snap, 'tid', '<none>'),
        \ string(map(copy(a:snap.wins), 'fnamemodify(v:val.path, ":t")'))))

    if !empty(g:closed_tab_stack)
        let l:top = g:closed_tab_stack[0]
        if get(l:top, 'index', -1) == a:snap.index
            \ && map(copy(l:top.wins), 'v:val.nr') == map(copy(a:snap.wins), 'v:val.nr')
            return
        endif
    endif

    call insert(g:closed_tab_stack, a:snap, 0)
    if len(g:closed_tab_stack) > g:closed_tab_stack_max
        let g:closed_tab_stack = g:closed_tab_stack[: g:closed_tab_stack_max - 1]
    endif
endfunction

function! s:SnapshotAllTabLayouts() abort
    if reltimefloat(reltime(g:tab_snapshot_last)) < 0.2
        return
    endif
    let g:tab_snapshot_last = reltime()

    let l:live = {}
    for l:t in range(1, tabpagenr('$'))
        call WinListEnsureTabID(l:t)
        let l:tid = WinListGetTabID(l:t)
        let l:live[l:tid] = 1
        let l:snap = s:SnapshotTabLayout(l:t)
        if !empty(l:snap)
            let g:tab_layout_cache[l:tid] = l:snap
        endif
    endfor

    for l:tid in keys(g:tab_layout_cache)
        if !has_key(l:live, l:tid)
            call s:PushClosedTab(remove(g:tab_layout_cache, l:tid))
        endif
    endfor
endfunction

function! s:OpenSnapshotBuf(w) abort
    let l:nr   = get(a:w, 'nr', -1)
    let l:path = get(a:w, 'path', '')
    if l:path !=# '' && l:path !~# '^\%(/\|\a:[/\\]\)'
        let l:path = fnamemodify(l:path, ':p')
    endif
    if l:path !=# '' && filereadable(l:path)
        silent! execute 'edit ' . fnameescape(l:path)
        if fnamemodify(bufname('%'), ':p') ==# l:path
            return 1
        endif
        silent! execute 'edit! ' . fnameescape(l:path)
        return fnamemodify(bufname('%'), ':p') ==# l:path ? 1 : 0
    endif
    if l:nr > 0 && bufexists(l:nr) && bufname(l:nr) ==# ''
        silent! execute 'buffer ' . l:nr
        return bufnr('%') == l:nr ? 1 : 0
    endif
    return 0
endfunction

function! s:NormalWinId(n) abort
    let l:c = 0
    for l:i in range(1, winnr('$'))
        if !WinListIsSpecial(winbufnr(l:i)) && !WinListIsNERDTree(winbufnr(l:i))
            let l:c += 1
            if l:c == a:n
                return win_getid(l:i)
            endif
        endif
    endfor
    return 0
endfunction

function! s:FocusNormalWin(n) abort
    if a:n <= 0 | return | endif
    let l:wid = s:NormalWinId(a:n)
    if l:wid != 0
        silent! call win_gotoid(l:wid)
    endif
endfunction

function! s:ApplySnapshotSizes(snap) abort
    if !exists('*win_execute') | return | endif
    let l:j = 0
    for l:w in a:snap.wins
        let l:j += 1
        let l:wid = s:NormalWinId(l:j)
        if l:wid == 0 | continue | endif
        let l:size = (a:snap.dir ==# 'col') ? l:w.h : l:w.w
        if l:size <= 0 | continue | endif
        let l:cmd = (a:snap.dir ==# 'col')
            \ ? 'resize ' . l:size : 'vertical resize ' . l:size
        silent! call win_execute(l:wid, l:cmd)
    endfor
endfunction

function! ReopenLastClosedTab() abort
    if empty(g:closed_tab_stack)
        echo 'No recently closed tabs.'
        return 0
    endif

    let l:snap     = g:closed_tab_stack[0]
    let l:n_before = tabpagenr('$')

    call s:RestoreLog(printf('POP-TAB index=%d tid=%s wins=%s fe=%s',
        \ get(l:snap, 'index', -1), get(l:snap, 'tid', '<none>'),
        \ string(map(copy(l:snap.wins), 'fnamemodify(v:val.path, ":t")')),
        \ empty(g:closed_file_stack) ? 'none'
        \   : s:ClosedEntryPath(g:closed_file_stack[0])))

    if get(g:, 'tab_restore_debug', 0)
        echo printf('TAB RESTORE: index=%d dir=%s active=%d wins=%s',
            \ l:snap.index, l:snap.dir, l:snap.active,
            \ string(map(copy(l:snap.wins), 'fnamemodify(v:val.path, ":t")')))
    endif

    let g:panel_opening = 1
    let l:newtab  = 0
    let l:missing = []
    try
        silent! execute 'tabnew'

        if tabpagenr('$') != l:n_before + 1
            echo 'Ctrl-Shift-T: could not create a new tab - state kept.'
            return 0
        endif
        let l:newtab = tabpagenr()

        let g:last_restored_tab = {'tabnr': l:newtab, 'index': l:snap.index}

        if get(l:snap, 'tid', '') !=# ''
            silent! call settabvar(l:newtab, 'winlist_tab_id', l:snap.tid)
        endif

        let l:i = 0
        for l:w in l:snap.wins
            if tabpagenr() != l:newtab
                silent! execute 'tabnext ' . l:newtab
            endif
            if l:i > 0
                silent! execute 'belowright '
                    \ . (l:snap.dir ==# 'col' ? 'split' : 'vsplit')
            endif
            if !s:OpenSnapshotBuf(l:w)
                call add(l:missing, l:w.path ==# '' ? '[No Name]' : l:w.path)
            endif
            let l:i += 1
        endfor

        if len(l:missing) == len(l:snap.wins)
            if tabpagenr('$') > 1
                silent! close
            endif
            echo 'Ctrl-Shift-T: could not open any file of the closed tab - kept in stack.'
            return 0
        endif

        let l:target = l:snap.index - 1
        let l:target = max([0, min([l:target, tabpagenr('$') - 1])])
        silent! execute 'tabmove ' . l:target
    finally
        let g:panel_opening = 0
    endtry

    silent! call CombinedPanelOpen()
    silent! call s:ApplySnapshotSizes(l:snap)

    silent! call s:FocusNormalWin(l:snap.active)
    silent! call WinListRefreshAllTabs()

    call s:RestoreLog(printf('RESTORED-TAB index=%d (%d cửa sổ)',
        \ l:snap.index, len(l:snap.wins)))

    echo printf('Ctrl-Shift-T: tab %d (%d windows: %s)',
        \ l:snap.index, len(l:snap.wins),
        \ join(map(copy(l:snap.wins), 'fnamemodify(v:val.path, ":t")'), ', '))

    if !empty(l:missing)
        echo 'Ctrl-Shift-T: could not open ' . join(l:missing, ', ')
    endif

    call remove(g:closed_tab_stack, 0)
    return 1
endfunction

function! ReopenLastClosed() abort
    if empty(g:closed_tab_stack) && empty(g:closed_file_stack)
        echo 'Ctrl-Shift-T: nothing left to restore (empty stack).'
        call s:RestoreLog('EMPTY (không còn gì để khôi phục)')
        return 0
    endif

    if !empty(g:closed_tab_stack)
        call ReopenLastClosedTab()
    else
        silent! call ReopenLastClosedFile()
    endif
endfunction

let g:session_max         = 20
let g:session_picker_buf  = '__SessionPicker__'

function! s:SessionsDir() abort
    let l:dir = expand('~/.gvim_sessions')
    if !isdirectory(l:dir)
        silent! call mkdir(l:dir, 'p')
    endif
    return l:dir
endfunction

function! s:SessionFiles() abort
    let l:files = glob(s:SessionsDir() . '/session-*.json', 1, 1)
    if empty(l:files) | return [] | endif
    return sort(l:files, {a, b -> getftime(b) - getftime(a)})
endfunction

function! s:SessionRead(path) abort
    try
        return json_decode(join(readfile(a:path), "\n"))
    catch
        return {}
    endtry
endfunction

function! s:PruneSessions() abort
    let l:files = s:SessionFiles()
    if len(l:files) <= g:session_max | return | endif
    for l:f in l:files[g:session_max :]
        silent! call delete(l:f)
    endfor
endfunction

function! s:SessionSnapshot() abort
    let l:tabs = []
    for l:t in range(1, tabpagenr('$'))
        let l:s = s:SnapshotTabLayout(l:t)
        if empty(l:s) | continue | endif
        call add(l:tabs, {
            \ 'wins':   l:s.wins,
            \ 'dir':    l:s.dir,
            \ 'active': l:s.active,
            \ })
    endfor
    return {'saved': strftime('%Y-%m-%d %H:%M:%S'), 'tabs': l:tabs}
endfunction

function! s:SaveSession(...) abort
    let l:label = a:0 > 0 ? substitute(a:1, '[^0-9A-Za-z._-]', '-', 'g') : ''
    let l:label = substitute(l:label, '^-\+\|-\+$', '', 'g')

    let l:data = s:SessionSnapshot()
    if empty(l:data.tabs)
        echo printf('SaveSession: nothing to save (winlayout=%d tabs=%d bufs=%s)',
            \ exists('*winlayout'), tabpagenr('$'), string(tabpagebuflist()))
        return ''
    endif

    let l:data.label = l:label
    let l:stamp = strftime('%Y%m%d-%H%M%S')
    let l:name  = 'session-' . (l:label ==# '' ? '' : l:label . '-') . l:stamp . '.json'
    let l:path  = s:SessionsDir() . '/' . l:name
    try
        call writefile([json_encode(l:data)], l:path)
    catch
        echo 'SaveSession: cannot write ' . l:path
        return ''
    endtry
    call s:PruneSessions()
    echo 'Session saved: ' . l:name . '  (' . len(l:data.tabs) . ' tabs)'
    return l:path
endfunction

function! s:AskNameAndSave() abort
    let l:label = input('Session name (Enter = default, Ctrl-C = cancel): ')
    echo ''
    silent! redraw
    call s:SaveSession(l:label)
endfunction

function! s:BuildTabFromSnapshot(snap, index) abort
    let l:n_before = tabpagenr('$')
    silent! execute 'tabnew'
    if tabpagenr('$') != l:n_before + 1
        return 0
    endif
    let l:newtab = tabpagenr()

    let l:i   = 0
    let l:any = 0
    for l:w in get(a:snap, 'wins', [])
        if tabpagenr() != l:newtab
            silent! execute 'tabnext ' . l:newtab
        endif
        if l:i > 0
            silent! execute 'belowright '
                \ . (get(a:snap, 'dir', 'row') ==# 'col' ? 'split' : 'vsplit')
        endif
        if s:OpenSnapshotBuf(l:w) | let l:any = 1 | endif
        let l:i += 1
    endfor

    if !l:any
        if tabpagenr('$') > 1 | silent! close | endif
        return 0
    endif

    silent! call CombinedPanelOpen()
    silent! call s:ApplySnapshotSizes(a:snap)
    silent! call s:FocusNormalWin(get(a:snap, 'active', 0))

    let l:target = max([0, min([a:index - 1, tabpagenr('$') - 1])])
    silent! execute 'tabmove ' . l:target
    return 1
endfunction

function! s:RestoreSession(sess) abort
    if type(a:sess) != type({}) | return 0 | endif
    let l:tabs = get(a:sess, 'tabs', [])
    if empty(l:tabs)
        echo 'Session: the file has no tab.'
        return 0
    endif

    let l:old_tid     = WinListGetTabID()
    let l:old_special = (WinListIsSpecial() || bufname('%') ==# '') ? 1 : 0

    let l:restored = 0
    let l:i = 0
    for l:t in l:tabs
        let l:i += 1
        if s:BuildTabFromSnapshot(l:t, l:i) | let l:restored += 1 | endif
    endfor

    if l:restored == 0
        echo 'Session: could not open any tab.'
        return 0
    endif

    if l:old_special && l:old_tid !=# '' && tabpagenr('$') > 1
        let l:oldt = WinListFindTabByID(l:old_tid)
        if l:oldt != -1
            silent! execute 'tabnext ' . l:oldt
            silent! execute 'tabclose'
        endif
    endif

    silent! execute 'tabnext 1'
    silent! call WinListRefreshAllTabs()
    echo printf('Session restored: %d tab(s) (%s).', l:restored,
        \ get(a:sess, 'saved', '?'))
    return 1
endfunction

function! s:SessionPickerLines() abort
    let l:L = []
    let l:files = s:SessionFiles()
    if empty(l:files)
        call add(l:L, 'No saved sessions yet.')
        call add(l:L, 'Press <F3> to save the current session, then <F2> to revisit it.')
        call add(l:L, 'Directory: ' . s:SessionsDir())
        return l:L
    endif

    for l:f in l:files
        let l:s    = s:SessionRead(l:f)
        let l:tabs = get(l:s, 'tabs', [])
        let l:nw   = 0
        for l:t in l:tabs
            let l:nw += len(get(l:t, 'wins', []))
        endfor
        let l:label = get(l:s, 'label', '')
        call add(l:L, printf('=== %s%s   (%d tabs, %d windows) ===§%s',
            \ get(l:s, 'saved', fnamemodify(l:f, ':t:r')),
            \ l:label ==# '' ? '' : '   [' . l:label . ']',
            \ len(l:tabs), l:nw, l:f))
        let l:i = 0
        for l:t in l:tabs
            let l:i += 1
            let l:names = []
            for l:w in get(l:t, 'wins', [])
                call add(l:names, get(l:w, 'name',
                    \ fnamemodify(get(l:w, 'path', ''), ':t')))
            endfor
            call add(l:L, printf('   Tab %d  [%d split%s]  %s', l:i,
                \ len(l:names), len(l:names) == 1 ? '' : 's',
                \ join(l:names, '  →  ')))
        endfor
    endfor
    return l:L
endfunction

function! s:SessionPickerSetup() abort
    setlocal buftype=nofile bufhidden=hide noswapfile nobuflisted
    setlocal nowrap nolist nonumber norelativenumber
    setlocal cursorline signcolumn=no
    setlocal filetype=sessions
    setlocal conceallevel=2 concealcursor=nvic

    silent! highlight default SessionHeader guifg=#61AFEF ctermfg=75  gui=bold
    silent! highlight default SessionTab    guifg=#98c379 ctermfg=114 gui=NONE
    silent! highlight default SessionHint   guifg=#5c6370 ctermfg=59  gui=italic

    silent! syntax clear
    silent! syntax match SessionHeader /^=== .*===/
    silent! syntax match SessionHeaderHide /§.*$/   conceal
    silent! syntax match SessionTab    /^\s\+Tab \d\+.*$/

    nnoremap <silent> <nowait> <buffer> <CR>          :call <SID>SessionPickRestore()<CR>
    nnoremap <silent> <nowait> <buffer> <2-LeftMouse> :call <SID>SessionPickRestore()<CR>
    nnoremap <silent> <nowait> <buffer> q             :call <SID>SessionPickerClose()<CR>
    nnoremap <silent> <nowait> <buffer> r             :call <SID>SessionPickerFill()<CR>
endfunction

function! s:SessionPickerFill() abort
    setlocal modifiable
    silent! %delete _
    silent! call setline(1, s:SessionPickerLines())
    setlocal nomodifiable nomodified
    silent! call s:SessionPickerSetup()
endfunction

function! s:SessionPickerClose() abort
    if bufname('%') !=# g:session_picker_buf
        let l:wnr = bufwinnr(g:session_picker_buf)
        if l:wnr == -1 | return | endif
        execute l:wnr . 'wincmd w'
    endif

    let l:prev = get(b:, 'picker_prev_buf', -1)
    if l:prev > 0 && bufexists(l:prev) && bufname(l:prev) !=# g:session_picker_buf
        silent! execute 'buffer ' . l:prev
    else
        silent! enew
    endif
endfunction

function! SessionPicker() abort
    if bufwinnr(g:session_picker_buf) != -1
        call s:SessionPickerClose()
        return
    endif

    let l:prev = bufnr('%')
    silent! execute 'keepalt edit ' . fnameescape(g:session_picker_buf)
    if bufname('%') !=# g:session_picker_buf
        silent! enew
        silent! execute 'file ' . g:session_picker_buf
        if bufname('%') !=# g:session_picker_buf
            echo 'SessionPicker: cannot open the picker buffer.'
            return
        endif
    endif
    let b:picker_prev_buf = l:prev

    silent! call s:SessionPickerFill()
    setlocal statusline=\ 【Sessions】\ Enter:\ restore\ ·\ q:\ close\ ·\ r:\ reload
    echo 'Pick a session and press Enter (double-click also works); q to close.'
endfunction

function! s:SessionPickRestore() abort
    let l:path = ''
    for l:lnum in range(line('.'), 1, -1)
        let l:m = matchlist(getline(l:lnum), '§\(.\+\)$')
        if !empty(l:m)
            let l:path = l:m[1]
            break
        endif
    endfor

    if l:path ==# ''
        echo 'Session: this line does not belong to any session.'
        return
    endif
    if !filereadable(l:path)
        echo 'Session: file no longer exists: ' . l:path
        return
    endif

    let l:sess = s:SessionRead(l:path)
    if empty(l:sess)
        echo 'Session: cannot read ' . fnamemodify(l:path, ':t')
        return
    endif

    silent! call s:RestoreSession(l:sess)
endfunction

if has('gui_running')
    nnoremap <silent> <F2> :call SessionPicker()<CR>
    inoremap <silent> <F2> <Esc>:call SessionPicker()<CR>
    nnoremap <silent> <F3> :call <SID>AskNameAndSave()<CR>
    inoremap <silent> <F3> <Esc>:call <SID>AskNameAndSave()<CR>
endif
command! -nargs=? SaveSession call <SID>SaveSession(<q-args>)
command! SessionPicker call SessionPicker()

function! QuickReplace(args) abort
    let l:idx         = -1
    let l:search_from = 0
    while 1
        let l:found = stridx(a:args, '---', l:search_from)
        if l:found == -1 | break | endif
        let l:idx         = l:found
        let l:search_from = l:found + 1
    endwhile

    if l:idx == -1
        echo "Usage: :R <old word(s)> --- <new word(s)>"
        echo "  e.g. :R i am haoz --- haoz"
        echo "  e.g. :R foo.bar[0] --- baz->qux"
        echo "  e.g. :R assign a = b; --- assign a = b + 1;"
        return
    endif

    let l:old = trim(a:args[0 : l:idx - 1])
    let l:new = trim(a:args[l:idx + 3 :])

    if l:old ==# '' || l:new ==# ''
        echo "Usage: :R <old word(s)> --- <new word(s)>"
        return
    endif

    let l:escaped_old = escape(l:old, '\/')
    let l:pattern      = '\V\C' . l:escaped_old

    let l:escaped_new = escape(l:new, '\/&~')

    let l:count = 0
    let l:lnum  = 1
    while l:lnum <= line('$')
        let l:line = getline(l:lnum)
        let l:pos  = 0
        while 1
            let l:found = stridx(l:line, l:old, l:pos)
            if l:found == -1 | break | endif
            let l:count += 1
            let l:pos    = l:found + max([1, len(l:old)])
        endwhile
        let l:lnum += 1
    endwhile

    if l:count == 0
        echo "No match found for: " . l:old
        return
    endif

    execute 'silent! %substitute/' . l:pattern . '/' . l:escaped_new . '/g'

    set hlsearch
    let @/ = '\V\C' . escape(l:new, '\/')

    echo printf("Replaced %d occurrence%s: [%s] -> [%s]  (Press <S-l> to clear)",
        \ l:count,
        \ l:count == 1 ? '' : 's',
        \ l:old,
        \ l:new)
endfunction

command! -nargs=+ R call QuickReplace(<q-args>)

function! QuickDelete(args) abort
    let l:target = trim(a:args)

    if l:target ==# ''
        echo "Usage: :D <word(s)/text to delete>"
        echo "  e.g. :D haoz"
        echo "  e.g. :D foo.bar[0]"
        echo "  e.g. :D assign a = b;"
        return
    endif

    let l:escaped = escape(l:target, '\/')
    let l:pattern = '\V\C' . l:escaped

    let l:count         = 0
    let l:affected_lnum = []
    let l:lnum = 1
    while l:lnum <= line('$')
        let l:line = getline(l:lnum)
        let l:pos  = 0
        let l:hit_on_line = 0
        while 1
            let l:found = stridx(l:line, l:target, l:pos)
            if l:found == -1 | break | endif
            let l:count += 1
            let l:hit_on_line = 1
            let l:pos = l:found + max([1, len(l:target)])
        endwhile
        if l:hit_on_line
            call add(l:affected_lnum, l:lnum)
        endif
        let l:lnum += 1
    endwhile

    if l:count == 0
        echo "No match found for: " . l:target
        return
    endif

    execute 'silent! %substitute/' . l:pattern . '//g'

    let l:parts = []
    for l:n in l:affected_lnum
        call add(l:parts, '\%' . l:n . 'l')
    endfor
    let l:linepattern = join(l:parts, '\|')

    set hlsearch
    let @/ = '\%(' . l:linepattern . '\).*'

    echo printf("Deleted %d occurrence%s: [%s]  (Press <S-l> to clear)",
        \ l:count,
        \ l:count == 1 ? '' : 's',
        \ l:target)
endfunction

command! -nargs=+ D call QuickDelete(<q-args>)

nnoremap <S-l> :nohlsearch<CR>

function! s:MarkedHighlights() abort
    silent! highlight default MarkedWord guibg=#7a333d guifg=NONE gui=NONE ctermbg=95 ctermfg=NONE
    silent! highlight default MarkedLine guibg=#7a333d guifg=NONE gui=NONE ctermbg=95 ctermfg=NONE
endfunction
call s:MarkedHighlights()

augroup MarkedHighlightColors
    autocmd!
    autocmd ColorScheme * call s:MarkedHighlights()
augroup END

if !exists('g:marked_store')
    let g:marked_store = {}
endif

function! s:MarkGuardOK() abort
    if WinListIsSpecial() || WinListIsNERDTree()
        return 0
    endif
    if &buftype !=# ''
        return 0
    endif
    return 1
endfunction

function! s:EnsureBufStore() abort
    let l:bn = bufnr('%')
    if !has_key(g:marked_store, l:bn)
        let g:marked_store[l:bn] = {}
    endif
    return l:bn
endfunction

function! s:ClearWindowMatches() abort
    if exists('w:marked_ids')
        for l:id in w:marked_ids
            silent! call matchdelete(l:id)
        endfor
    endif
    let w:marked_ids = []
endfunction

let s:maxpos = 8

function! s:ApplyMarksForCurrentBuffer() abort
    call s:ClearWindowMatches()
    let l:bn = bufnr('%')
    if !has_key(g:marked_store, l:bn) | return | endif

    let l:last = line('$')
    for [l:key, l:entry] in items(g:marked_store[l:bn])
        let l:valid = []
        for l:p in l:entry.pos
            if l:p[0] >= 1 && l:p[0] <= l:last && l:p[2] >= 1
                call add(l:valid, l:p)
            endif
        endfor
        if empty(l:valid)
            call remove(g:marked_store[l:bn], l:key)
            continue
        endif
        if len(l:valid) != len(l:entry.pos)
            let g:marked_store[l:bn][l:key].pos = l:valid
        endif

        let l:i = 0
        while l:i < len(l:valid)
            let l:chunk = l:valid[l:i : (l:i + s:maxpos - 1)]
            let l:id = 0
            silent! let l:id = matchaddpos(l:entry.group, l:chunk)
            if l:id > 0
                call add(w:marked_ids, l:id)
            endif
            let l:i += s:maxpos
        endwhile
    endfor
endfunction

augroup MarkedBufferSync
    autocmd!
    autocmd BufLeave             * call s:ClearWindowMatches()
    autocmd BufEnter,BufWinEnter * call s:ApplyMarksForCurrentBuffer()
augroup END

augroup MarkedBufWipe
    autocmd!
    autocmd BufWipeout * if has_key(g:marked_store, str2nr(expand('<abuf>')))
                       \ |   call remove(g:marked_store, str2nr(expand('<abuf>')))
                       \ | endif
augroup END

function! s:GetWordAtCursorPos() abort
    let l:cword = expand('<cword>')
    if l:cword ==# '' | return [] | endif

    let l:line     = getline('.')
    let l:pattern  = '\<' . escape(l:cword, '\.*$^~[]\') . '\>'
    let l:curcol   = col('.') - 1
    let l:startpos = 0

    while 1
        let [l:match, l:start, l:end] = matchstrpos(l:line, l:pattern, l:startpos)
        if l:start == -1 | break | endif
        if l:curcol >= l:start && l:curcol < l:end
            return [line('.'), l:start + 1, l:end - l:start]
        endif
        let l:startpos = l:end
    endwhile

    return []
endfunction

function! ToggleMarkWord() abort
    if !s:MarkGuardOK() | return | endif

    let l:pos = s:GetWordAtCursorPos()
    if empty(l:pos) | return | endif

    let l:bn = s:EnsureBufStore()
    let [l:lnum, l:col, l:len] = l:pos
    let l:key = printf('word_%d_%d_%d', l:lnum, l:col, l:len)

    if has_key(g:marked_store[l:bn], l:key)
        call remove(g:marked_store[l:bn], l:key)
        echo "Unmarked word"
    else
        let g:marked_store[l:bn][l:key] = {'group': 'MarkedWord', 'pos': [[l:lnum, l:col, l:len]]}
        echo "Marked word"
    endif

    call s:ApplyMarksForCurrentBuffer()
endfunction

function! s:GetVisualSelectionPositions() abort
    let l:mode  = visualmode()
    let l:start = getpos("'<")
    let l:end   = getpos("'>")
    let l:slnum = l:start[1]
    let l:scol  = l:start[2]
    let l:elnum = l:end[1]
    let l:ecol  = l:end[2]
    let l:positions = []

    if l:mode ==# "\<C-v>"
        let l:c1 = min([l:scol, l:ecol])
        let l:c2 = max([l:scol, l:ecol])
        for l:lnum in range(l:slnum, l:elnum)
            let l:linelen = strlen(getline(l:lnum))
            let l:cc2 = min([l:c2, l:linelen])
            if l:cc2 >= l:c1 && l:linelen > 0
                call add(l:positions, [l:lnum, l:c1, l:cc2 - l:c1 + 1])
            endif
        endfor
    elseif l:mode ==# 'V'
        for l:lnum in range(l:slnum, l:elnum)
            let l:len = strlen(getline(l:lnum))
            if l:len > 0
                call add(l:positions, [l:lnum, 1, l:len])
            endif
        endfor
    else
        if l:slnum == l:elnum
            let l:linelen = strlen(getline(l:slnum))
            let l:ecol2   = min([l:ecol, l:linelen])
            if l:ecol2 >= l:scol
                call add(l:positions, [l:slnum, l:scol, l:ecol2 - l:scol + 1])
            endif
        else
            let l:firstlen = strlen(getline(l:slnum))
            if l:firstlen >= l:scol
                call add(l:positions, [l:slnum, l:scol, l:firstlen - l:scol + 1])
            endif
            for l:lnum in range(l:slnum + 1, l:elnum - 1)
                let l:len = strlen(getline(l:lnum))
                if l:len > 0
                    call add(l:positions, [l:lnum, 1, l:len])
                endif
            endfor
            let l:lastlen = strlen(getline(l:elnum))
            let l:ecol2    = min([l:ecol, l:lastlen])
            if l:ecol2 >= 1
                call add(l:positions, [l:elnum, 1, l:ecol2])
            endif
        endif
    endif

    return l:positions
endfunction

function! ToggleMarkSelection() abort
    if !s:MarkGuardOK() | return | endif

    let l:positions = s:GetVisualSelectionPositions()
    if empty(l:positions) | return | endif
    if len(l:positions) > 500
        echo 'Selection too large to mark (max 500 lines)'
        return
    endif

    let l:bn  = s:EnsureBufStore()
    let l:key = 'sel_' . string(l:positions)

    if has_key(g:marked_store[l:bn], l:key)
        call remove(g:marked_store[l:bn], l:key)
        echo "Unmarked selection"
    else
        let g:marked_store[l:bn][l:key] = {'group': 'MarkedLine', 'pos': l:positions}
        echo "Marked selection"
    endif

    call s:ApplyMarksForCurrentBuffer()
endfunction

function! ClearAllMarks() abort
    let l:bn = bufnr('%')
    if has_key(g:marked_store, l:bn)
        let g:marked_store[l:bn] = {}
    endif
    call s:ApplyMarksForCurrentBuffer()
    echo "All marks cleared (this buffer)"
endfunction

nnoremap <silent> mh :call ToggleMarkWord()<CR>
vnoremap <silent> mh :<C-u>call ToggleMarkSelection()<CR>
nnoremap <silent> ml :call ClearAllMarks()<CR>

function! s:VimrcManualHighlights() abort
    silent! highlight default VMHeader  guifg=#61AFEF ctermfg=75  gui=bold
    silent! highlight default VMSubHead guifg=#98c379 ctermfg=114 gui=bold
    silent! highlight default VMKey     guifg=#e5c07b ctermfg=180 gui=bold
    silent! highlight default VMDim     guifg=#5c6370 ctermfg=59  gui=italic
endfunction
call s:VimrcManualHighlights()

augroup VimrcManualColors
    autocmd!
    autocmd ColorScheme * call s:VimrcManualHighlights()
augroup END

function! s:VimrcManualSyntax() abort
    silent! syntax clear
    syntax match VMHeader  /^═\+$/
    syntax match VMHeader  /^▶.*/
    syntax match VMSubHead /^  •.*/ contains=VMKey
    syntax match VMKey     /`[^`]\+`/
    syntax match VMDim     /^\s*$/
endfunction

function! s:VimrcManualContent() abort
    let l:L = []
    call add(l:L, '═══════════════════════════════════════════════════════════════════')
    call add(l:L, '  VIMRC MANUAL — haozxje custom GVim config   (F1 / q to close)')
    call add(l:L, '  Version 7.54  ·  2026-11-19')
    call add(l:L, '═══════════════════════════════════════════════════════════════════')
    call add(l:L, '')

    call add(l:L, '▶ STATUSLINE')
    call add(l:L, '  • Bố cục: `~/.vimrc` bên trái, `[CL<current>:TL<total>]` bên phải')
    call add(l:L, '     CL = dòng hiện tại, TL = tổng số dòng của buffer')
    call add(l:L, '  • Thứ tự BỐN khối, SÁT nhau không dấu cách:')
    call add(l:L, '     `[CL12:TL431][4sp][systemverilog][V7.54]`')
    call add(l:L, '  • Khối 2 `[<indent>]` — dò từ NỘI DUNG buffer:')
    call add(l:L, '     `[4sp]` = thụt 4 cột bằng dấu cách, `[8tb]` = thụt bằng TAB,')
    call add(l:L, '     `[mix]` = trộn cả hai (mỗi loại >= 10% số dòng có thụt).')
    call add(l:L, '     Khuôn: `<cỡ><tb|sp>`')
    call add(l:L, '  • Khối 3 `[<filetype>]` — filetype/syntax của buffer')
    call add(l:L, '     Buffer RỖNG (chưa có nội dung) hiện `[none]`, kể cả khi')
    call add(l:L, '     filetype chỉ là `log` do autocmd đặt mặc định.')
    call add(l:L, '  • Khối 4 `[Vx]` — VERSION của chính file .vimrc này, đọc từ')
    call add(l:L, '     header (`Version  : X.Y`) lúc khởi động -> bump header là')
    call add(l:L, '     statusline tự đổi, không phải sửa thêm chỗ nào.')
    call add(l:L, '     (`g:haoz_vimrc_version`; không đọc được file -> `[V?]`)')
    call add(l:L, '  • Màu chữ vị trí bám theo màu path (highlight link StatusLinePos)')
    call add(l:L, '  • Nền statusline đổi theo mode: xanh đậm (Normal), cam (Insert),')
    call add(l:L, '     xanh lá (Replace) — tự động qua DynamicStatusLine')
    call add(l:L, '')

    call add(l:L, '▶ TAB LABEL & WINDOW TITLE')
    call add(l:L, '  • Cả hai luôn hiện tên FILE THẬT, kể cả khi focus đang ở panel')
    call add(l:L, '     WinList/NERDTree — không còn hiện "__WindowList__"')
    call add(l:L, '  • Tab label: `GuiTabLabel()` → tên file + [M] + [RO]')
    call add(l:L, '  • Window title: `GuiTitle()` qua `titlestring`, dạng')
    call add(l:L, '     `<thư mục> — <file> [M] [RO] (tab/tổng) — GVIM`')
    call add(l:L, '  • Cả hai dùng chung `s:IsPanelBuf()` để bỏ qua buffer panel')
    call add(l:L, '')

    call add(l:L, '▶ COMMENT SYSTEM')
    call add(l:L, '  • `cc`        Toggle comment on line (Normal) / range (Visual)')
    call add(l:L, '  • `hh`        Toggle trailing haozxje tag at end of line')
    call add(l:L, '  • `ch`        Toggle leading haozxje tag at start of code')
    call add(l:L, '     Tag luôn kèm timestamp: `[haozxje-YYYYMMDD-HHMM] <lý do>`')
    call add(l:L, '     (leader auto-detected per filetype: // # % " ; >)')
    call add(l:L, '')

    call add(l:L, '▶ SENTENCE INSERT  (GVim: dd / dm)')
    call add(l:L, '  • `dd`  Chèn NGAY câu đầu tiên của `g:haoz_sentences`')
    call add(l:L, '  • `dm`  Menu chọn câu (↑↓ hoặc click chuột, Enter = chèn,')
    call add(l:L, '     Esc = huỷ); nơi không có popup_menu thì dùng inputlist')
    call add(l:L, '  • Câu được chèn thành DÒNG MỚI NGAY DƯỚI dòng con trỏ, con trỏ')
    call add(l:L, '     nhảy xuống dòng vừa chèn; dòng trước/sau KHÔNG bị sửa ký tự')
    call add(l:L, '     nào (chỉ dịch số dòng); `u` = undo 1 bước.')
    call add(l:L, '  • Dòng mới LẤY ĐÚNG LỀ của dòng đang đứng (space/tab như file) ->')
    call add(l:L, '     câu thẳng hàng với code xung quanh; con trỏ đặt ở ký tự đầu câu.')
    call add(l:L, '  • Hàm: `HaozInsertSentenceLine()`, `HaozSentenceMenu()`,')
    call add(l:L, '     `HaozSentenceMenuPick()`; phím map trong `.gvimrc` (ở đó `d`')
    call add(l:L, '     đã disable nên dd/dm không giành mất lệnh nào).')
    call add(l:L, '  • Sửa danh sách câu: trực tiếp trong `g:haoz_sentences`, hoặc')
    call add(l:L, '     `:SentenceAdd <câu>` (trong phiên) / `:SentenceList` (xem).')
    call add(l:L, '  • Chèn bằng `append()` rồi đưa con trỏ xuống dòng mới — KHÔNG')
    call add(l:L, '     dùng `:put =` vì `:execute` hiểu dấu `"` trong câu là COMMENT')
    call add(l:L, '     -> lệnh bị cắt, lỗi `E115: Missing quote`, không chèn được.')
    call add(l:L, '  • Sau khi chèn tự `zv` (mở fold đang che dòng mới) + `redraw` +')
    call add(l:L, '     echo số dòng, để không bị hiểu nhầm là "không chèn được".')
    call add(l:L, '')

    call add(l:L, '▶ AUTO-SAVE & AUTO-FEATURES')
    call add(l:L, '  • Buffer auto-saves (if writable): TextChanged HOÃN 800ms,')
    call add(l:L, '     InsertLeave + VimLeavePre ghi NGAY (`g:autosave_delay`)')
    call add(l:L, '  • Unset filetype auto-defaults to "log" on read')
    call add(l:L, '  • `*.md` mang ft `md`, KHÔNG gọi `md#setup()` (7 phím leader')
    call add(l:L, '     `\= \- \l \x \t \z \p` của plugin đã bỏ; chỉ giữ fold + lệnh)')
    call add(l:L, '     → plugin `hughbien/md-vim`; bản riêng của haozxje CHỈ 2 file:')
    call add(l:L, '     `~/.vim/syntax/md.vim` + `~/.vim/ftplugin/md.vim`')
    call add(l:L, '     (repo KHÔNG có autoload/ — md#setup nằm ngay trong ftplugin).')
    call add(l:L, '     Ngôn ngữ trong fence: `g:md_fenced_languages` (sv, v, c, …)')
    call add(l:L, '     Bản riêng: chữ thường TRẮNG; **đậm**/*nghiêng* đổi sang REGION')
    call add(l:L, '     nên tô được cả khi xuống dòng; dòng thụt 4 space VẪN có syntax')
    call add(l:L, '     (tắt: `let g:md_indent_is_code = 0`); mục list chia 3 cấp màu')
    call add(l:L, '     theo độ thụt (0-3 / 4-7 / >=8 space). `code` chứa `/`')
    call add(l:L, '     (đường dẫn) = XANH BIỂN; dấu ``` mở/đóng fence = CAM')
    call add(l:L, '     (không nền).  NỀN XÁM `g:md_fence_bg` có cạnh TRÁI = lề NHỎ')
    call add(l:L, '     NHẤT của khối (các dòng THẲNG CỘT) và chạy tới HẾT DÒNG;')
    call add(l:L, '     cạnh phải cũng thẳng hàng nên thành hình chữ nhật.  Mặc định')
    call add(l:L, '     `#363636` = đúng màu `highlight CursorLine` trong vimrc.')
    call add(l:L, '     Cạnh phải thẳng hàng nhờ formatter đệm space cuối dòng trong')
    call add(l:L, '     fence (`let g:md_fence_pad = 0` để tắt; `g:md_fence_bg =')
    call add(l:L, '     ''NONE''` để tắt hẳn nền).  Chữ có màu riêng vẫn giữ màu.')
    call add(l:L, '     Nền do ftplugin/md.vim vẽ bằng matchaddpos (`s:FenceBgApply`),')
    call add(l:L, '     KHÔNG bằng syntax: `syn keyword` đứng đầu dòng luôn thắng syn')
    call add(l:L, '     match/region nên tô nền bằng syntax thì dòng mở đầu bằng')
    call add(l:L, '     bit/if/constraint/end bị mất nền.')
    call add(l:L, '     BẢNG markdown cũng được tô nền y như khối ``` (`g:md_table_bg')
    call add(l:L, '     = 0` để tắt); dòng phân cách `| --- |` màu XANH BIỂN giống')
    call add(l:L, '     path (mdTableHead).')
    call add(l:L, '     Phím: CHỈ `za` (toggle fold hiện tại) + `zo` (toggle tất cả)')
    call add(l:L, '     TỰ FORMAT NGAY KHI MỞ FILE (1 lần, xong đặt nomodified')
    call add(l:L, '     nên không hiện [M]) + mỗi lần ghi file + khi rời Insert,')
    call add(l:L, '     và FORMAT LẠI khi file bị ghi thêm từ NGOÀI (autoread')
    call add(l:L, '     nạp lại buffer -> s:MdOnReload, cũng nomodified):')
    call add(l:L, '     căn bảng, bỏ')
    call add(l:L, '     space cuối dòng, tiêu đề `#   X  ##` -> `# X`, `* `/`+ ` ->')
    call add(l:L, '     `- `, đánh số lại ordered list theo từng cấp, chèn/gộp dòng')
    call add(l:L, '     trống trước header/bảng/list/fence (bỏ qua ``` … ``` và')
    call add(l:L, '     front-matter --- … ---). Rời Insert chỉ căn bảng đang đứng.')
    call add(l:L, '     `:MdFormat` = format toàn bộ, `:MdFormatTable` = chỉ bảng,')
    call add(l:L, '     `:MdAutoFormat` = bật/tắt cho buffer này, `let g:md_autoformat')
    call add(l:L, '     = 0` = tắt toàn cục, `let g:md_trim_trailing_space = 0` =')
    call add(l:L, '     giữ space cuối dòng. `indentexpr` giữ lề mục con; `<Tab>`')
    call add(l:L, '     (sw=4) để lùi thêm 1 cấp. Bảng viết thiếu dòng phân cách')
    call add(l:L, '     `| --- |` sẽ được TỰ CHÈN (`let g:md_table_guess = 0` tắt);')
    call add(l:L, '     bảng thiếu `|` đầu dòng vẫn căn được; độ rộng cột tính theo')
    call add(l:L, '     số ô màn hình nên tiếng Việt có dấu không bị lệch cột.')
    call add(l:L, '     BẢNG VIẾT TAY (cột căn bằng space, chỉ dòng `| --- |` có `|`):')
    call add(l:L, '     số cột lấy theo ĐA SỐ các hàng, mỗi hàng tách theo `|` hoặc theo')
    call add(l:L, '     cụm 2+ space -> tự chuyển thành bảng `| … | … |` chuẩn.  Hàng')
    call add(l:L, '     không tách được đúng số cột thì GIỮ NGUYÊN VĂN, không bị phá.')
    call add(l:L, '  • THEO LINK NỘI BỘ: đặt con trỏ lên `[text](#anchor)` (bảng')
    call add(l:L, '     Contents) rồi `<C-]>` hoặc DOUBLE-CLICK -> nhảy tới tiêu đề')
    call add(l:L, '     có slug khớp (GitHub-style, giữ dấu tiếng Việt; không khớp')
    call add(l:L, '     chính xác thì so lần 2 sau khi bỏ dấu cả hai phía; vẫn không')
    call add(l:L, '     khớp thì so TIỀN TỐ, và anchor `%xx` được giải mã). Tiêu đề')
    call add(l:L, '     thụt lề bao nhiêu cũng được. Link không nằm dưới con trỏ mà')
    call add(l:L, '     dòng chỉ có 1 link thì vẫn nhảy.  Nhảy xong TỰ VỀ NORMAL')
    call add(l:L, '     (double-click không để lại Visual mode).')
    call add(l:L, '     Lệnh: `:MdLink`.  (`:MdSyn` = soi nhóm syntax/màu dưới con trỏ)')
    call add(l:L, '     (FOLD của .md xem mục ▶ FOLDING)')
    call add(l:L, '  • `autoread` + CursorHold auto :checktime (detect external changes)')
    call add(l:L, '  • SWAP FILE: vẫn bật (lưới an toàn cho auto-save), nhưng dồn về')
    call add(l:L, '     `~/.vim/swp/` — không rải *.swp trong cây source')
    call add(l:L, '  • `shortmess+=A`: gặp file đã có swap thì KHÔNG hỏi')
    call add(l:L, '     "[O]pen Read-Only / (E)dit anyway ..."), vào thẳng EDIT')
    call add(l:L, '  • Cursor position restored on reopening a file')
    call add(l:L, '  • Auto-comment continuation disabled (fo-=c,r,o)')
    call add(l:L, '')

    call add(l:L, '▶ PERFORMANCE (các chỗ đã tối ưu)')
    call add(l:L, '  • AUTO-SAVE: TextChanged chỉ HẸN ghi sau 800ms')
    call add(l:L, '     (`let g:autosave_delay = 1500`); InsertLeave/VimLeavePre ghi')
    call add(l:L, '     ngay -> không còn 1 lần ghi đĩa cho MỖI phím sửa')
    call add(l:L, '  • WINLIST: mọi event đều đi qua `WinListRefreshSoon()` — gộp')
    call add(l:L, '     nhiều event liền nhau thành 1 lần dựng (40ms) + 1 lần dựng bù')
    call add(l:L, '     (60ms); panel ẩn thì KHÔNG dựng nội dung; `syntax match` của')
    call add(l:L, '     panel chỉ đặt 1 lần/buffer; bề ngang panel + đường dẫn rút')
    call add(l:L, '     gọn được cache theo lần dựng')
    call add(l:L, '  • STATUSLINE `[Nsp]`: đang Insert thì quét tối đa 1 lần/giây')
    call add(l:L, '     (trước: quét 400 dòng cho mỗi phím); rời Insert quét lại ngay')
    call add(l:L, '  • Snapshot layout cho Ctrl-Shift-T vẫn chạy, tự chặn 1 lần/200ms')
    call add(l:L, '  • Đo startup: `gvim --startuptime /tmp/st.log` rồi xem /tmp/st.log')
    call add(l:L, '')

    call add(l:L, '▶ FOLDING  (mặc định + phím, riêng cho từng loại buffer)')
    call add(l:L, '  • `.md`: `foldmethod=expr` + `foldexpr=HaozMdFoldLevel()` — cấp')
    call add(l:L, '     fold = số space đầu dòng / 4 + 1 (BƯỚC CỐ ĐỊNH 4 SPACE), nên')
    call add(l:L, '     KHÔNG phụ thuộc `shiftwidth` (sleuth đổi sw -> indent-fold gộp')
    call add(l:L, '     cả file thành 1 fold).  Cấp: cột 0 = 1 (`#`,`##`), 4 space = 2')
    call add(l:L, '     (`###`), 8 space = 3 (thân bài), 12 = 4 …')
    call add(l:L, '     Mở file: **`foldlevel=2`** -> thấy `#`/`##`/`###`, GẬP thân bài.')
    call add(l:L, '     (gập cả `###` -> 1; mở hết -> 5.)')
    call add(l:L, '  • `.sv/.v/.svh/.svt/.svti`: `foldmethod=indent`, `foldlevel=3`.')
    call add(l:L, '     `foldlevel` chỉ đặt ở lần mở buffer ĐẦU (b:haoz_fold_init) nên')
    call add(l:L, '     buffer reload không làm fold tự gập.')
    call add(l:L, '  • Phím: `za` = toggle fold hiện tại (Vim gốc) | `zo` = toggle')
    call add(l:L, '     TẤT CẢ fold | `zA` = toggle fold hiện tại + toàn bộ node con')
    call add(l:L, '     (chỉ .sv — `HaozFoldToggleRecursive`)')
    call add(l:L, '  • `zo` toggle giữa MỞ HẾT <-> GẬP VỀ `b:haoz_fold_home`')
    call add(l:L, '     (= 2 cho .md, 3 cho .sv)')
    call add(l:L, '  • Mọi mapping đều `<buffer>`; `zc`/`zO`/`zC`/`zM`/`zR` vẫn là')
    call add(l:L, '     lệnh gốc của Vim.')
    call add(l:L, '')

    call add(l:L, '▶ CLIPBOARD / EDITING')
    call add(l:L, '  • `Ctrl-C` / `Ctrl-V` / `Ctrl-X`  Copy/Paste/Cut via system clipboard "+')
    call add(l:L, '  • `Ctrl-Z`   Undo (Normal/Insert/Visual)')
    call add(l:L, '  • `Ctrl-U`   Toggle case of word (Normal) / selection (Visual)')
    call add(l:L, '  • `Ctrl-A`   Select whole buffer')
    call add(l:L, '  • `Ctrl-D`   Select word under cursor + set search')
    call add(l:L, '  • `Ctrl-F`   Search word under cursor / visual selection')
    call add(l:L, '  • `V`        Enter BLOCKWISE visual (remapped from linewise)')
    call add(l:L, '  • `x` / `Del` / `o` disabled in Normal mode (no accidental')
    call add(l:L, '     char delete / stray new line; thay bằng `dd` `S-Del` `cc` `O`)')
    call add(l:L, '  • TRONG GVIM, `.gvimrc` (version 1.0, nạp SAU file này) disable')
    call add(l:L, '     THÊM: `a h j k l s c v d x p o` (Normal) và `p d` (Visual)')
    call add(l:L, '     -> điều hướng bằng phím mũi tên/chuột.  `vim` trong terminal')
    call add(l:L, '     KHÔNG nạp .gvimrc nên các phím đó vẫn dùng bình thường.')
    call add(l:L, '  • `S-Del`    Delete current line (dd)')
    call add(l:L, '  • `S-l`      Clear search highlight (:nohlsearch)')
    call add(l:L, '')

    call add(l:L, '▶ NAVIGATION')
    call add(l:L, '  • `Ctrl-Left/Right`      Word jump (Normal/Visual/Insert)')
    call add(l:L, '  • `Ctrl-Shift-Left/Right` Extend selection by word')
    call add(l:L, '  • `Shift-Arrow/Home/End`  GUI-style text selection')
    call add(l:L, '  • `Home`                 Jump to first non-blank char (^)')
    call add(l:L, '  • `n` / `N`               Next/prev search match + re-center (zz)')
    call add(l:L, '  • `1..9,0`                Jump directly to tab N (0 = tab 10)')
    call add(l:L, '  • `Ctrl-Up` / `Ctrl-Down` Prev/Next tab')
    call add(l:L, '  • `Alt-Left` / `Alt-Right` Cycle real editing splits')
    call add(l:L, '     (auto-skips WinList/NERDTree panel windows)')
    call add(l:L, '')

    call add(l:L, '▶ SPLIT / WINDOW MANAGEMENT')
    call add(l:L, '  • `Ctrl-\`     Vertical split + focus new window')
    call add(l:L, '  • `Enter Enter` (double-tap) Temporarily maximize current split')
    call add(l:L, '     width (others collapse to 1 col); Enter again restores layout')
    call add(l:L, '  • `Ctrl-Enter` Force-expand current window immediately')
    call add(l:L, '  • `Ctrl-W`     Close window — đẩy vào stack: file + TAB (Tab-ID) +')
    call add(l:L, '     vị trí cửa sổ trong tab + bề rộng của nó')
    call add(l:L, '  • `Ctrl-Shift-T` Mỗi lần bấm khôi phục ĐÚNG MỘT thứ, giống')
    call add(l:L, '     restore tab của browser: ưu tiên TAB vừa đóng (đúng vị trí,')
    call add(l:L, '     đúng các cửa sổ con: hướng chia + bề rộng/chiều cao + cửa sổ')
    call add(l:L, '     active); hết tab thì đến CỬA SỔ vừa đóng bằng Ctrl-W (stack,')
    call add(l:L, '     max 20) — về ĐÚNG TAB cũ và ĐÚNG VỊ TRÍ (cửa sổ nội dung thứ')
    call add(l:L, '     N), đúng bề rộng.  Tab chứa cửa sổ đó đã đóng hẳn thì DỰNG')
    call add(l:L, '     LẠI TAB đó ở vị trí cũ, chỉ với cửa sổ đang khôi phục; các')
    call add(l:L, '     cửa sổ khác của tab đó (nếu có) đến ở những lần bấm sau,')
    call add(l:L, '     vào đúng tab đó nhờ g:last_restored_tab.')
    call add(l:L, '  • Đóng 1 split rồi mở split khác ĐÚNG CHỖ ĐÓ rồi đóng: entry của')
    call add(l:L, '     split mới GHI ĐÈ split cũ (cùng tabidx + cùng ord), nên chỉ')
    call add(l:L, '     restore đúng 1 lần cho vị trí đó, không dồn thành 2 lần bấm.')
    call add(l:L, '  • Hết ngăn xếp: chỉ báo "không còn gì để khôi phục", không đổi')
    call add(l:L, '     layout/buffer hiện tại (khôi phục rỗng).')
    call add(l:L, '     WinList KHÔNG tính vào phần khôi phục: bản chụp chỉ giữ')
    call add(l:L, '     cửa sổ nội dung; panel tự mở lại như ở mọi tab khác.')
    call add(l:L, '     Vị trí/cửa sổ active lấy ANCHOR từ nội dung WinList (dấu `>`,')
    call add(l:L, '     tức g:winlist_last_active theo BUFFER NUMBER) chứ không dựa')
    call add(l:L, '     vào tabpagewinnr — vì khi chuyển qua lại giữa các tab, hoặc')
    call add(l:L, '     khi focus đang ở panel, index đó trỏ sai cửa sổ. Khi dựng')
    call add(l:L, '     lại thì mở theo ĐƯỜNG DẪN, không theo buffer number.')
    call add(l:L, '  • Nếu tab mới không tạo được, hoặc không mở được file nào, thì')
    call add(l:L, '     báo lỗi và GIỮ tab vừa đóng trong stack để bấm lại; file nào')
    call add(l:L, '  • Chẩn đoán: `:ClosedInfo` in 2 ngăn xếp (tab/file) + Tab-ID')
    call add(l:L, '     các tab đang mở + restore_log (lịch sử push/pop từng lần)')
    call add(l:L, '     Mỗi lần Ctrl-Shift-T cũng tự báo nó đã')
    call add(l:L, '     khôi phục cái gì, ở tab nào, vị trí nào, rộng bao nhiêu')
    call add(l:L, '     không mở được cũng được nêu tên. Đặt g:tab_restore_debug=1')
    call add(l:L, '     để in snapshot (index/dir/active/danh sách file) khi restore.')
    call add(l:L, '')

    call add(l:L, '▶ SIDE PANEL — WinList (always on) + NERDTree (on demand)')
    call add(l:L, '  • WinList         LUÔN hiển thị ở mọi tab (cột trái, full height)')
    call add(l:L, '     Panel WRAP (`wrap linebreak`): tên test/file dài thì xuống')
    call add(l:L, '     dòng, không bị cắt cụt ở mép panel.  Dòng active được đệm')
    call add(l:L, '     space tới textw-1 nên nền xanh phủ kín hàng mà không tràn.')
    call add(l:L, '  • `wl`            Bật/tắt WinList (KHÔNG ảnh hưởng NERDTree)')
    call add(l:L, '  • `Ctrl-B`        Bật/tắt NERDTree. NERDTree mở ra ở NỬA DƯỚI')
    call add(l:L, '     của cột trái (WinList giữ nửa trên). WinList KHÔNG bị ảnh')
    call add(l:L, '     hưởng; con trỏ nhảy vào NERDTree, tắt thì trả về cửa sổ code.')
    call add(l:L, '  • `<leader>W`   Fix/sync WinList panel width')
    call add(l:L, '  • `<leader>wa`  Open panel in ALL tabs')
    call add(l:L, '  • `<leader>wh`  Fix panel heights (50/50 split when NERDTree is up)')
    call add(l:L, '  • Inside panel: `Enter` / double-click jumps to entry, `q` closes,')
    call add(l:L, '     `r` refreshes')
    call add(l:L, '  • NERDTree Enter/double-click opens file as a NEW right split')
    call add(l:L, '     (panel stays open, stable Tab-ID survives tab drag-reorder)')
    call add(l:L, '  • NERDTree `T` mở file ở TAB MỚI nhưng đặt ở VỊ TRÍ CUỐI thanh')
    call add(l:L, '     tab (focus vẫn ở tab đang đứng, như hành vi gốc của T)')
    call add(l:L, '  • NERDTree dùng phím mặc định: `o` mở/thu node, `O` mở đệ quy,')
    call add(l:L, '     `x`/`X` đóng, `P` về root (không remap gì thêm)')
    call add(l:L, '  • Commands: `:WinList` `:WinListClose` `:WinListFix`')
    call add(l:L, '     `:WinListRefresh` `:WinListAllTabs` `:WinListFixH`')
    call add(l:L, '')

    call add(l:L, '▶ NETRW QUICK BROWSE')
    call add(l:L, '  • `Ctrl-O`  Mở netrw (`:Explore`) ngay trong cửa sổ hiện tại —')
    call add(l:L, '     KHÔNG ẩn panel, KHÔNG phóng to, layout tab giữ nguyên')
    call add(l:L, '  • `Ctrl-O` lần 2 (khi đang trong netrw) Quay lại file vừa xem:')
    call add(l:L, '     đúng buffer cũ -> mở lại theo path nếu buffer bị xoá -> cuối')
    call add(l:L, '     cùng là alternate buffer. Không còn gì để quay lại thì báo lỗi.')
    call add(l:L, '  • Chọn file -> file mở ra thay chỗ netrw (browse_split = 0),')
    call add(l:L, '     panel vẫn nguyên; không có layout nào phải dựng lại')
    call add(l:L, '  • `:E` giống `:e` — mở file theo đường dẫn (`:E <path>`, `:E!`')
    call add(l:L, '     như `:e!`). Explorer là `:Explore`, KHÔNG phải `:E`')
    call add(l:L, '')

    call add(l:L, '▶ QUICK REPLACE / DELETE (whole buffer, literal text)')
    call add(l:L, '  • `:R <old> --- <new>`  Replace ALL literal occurrences of <old>')
    call add(l:L, '     with <new> (case-sensitive, symbol/space-safe). New text gets')
    call add(l:L, '     search-highlighted. Clear via `S-l`.')
    call add(l:L, '  • `:D <text>`           Delete ALL literal occurrences of <text>.')
    call add(l:L, '     Affected FULL LINES get search-highlighted. Clear via `S-l`.')
    call add(l:L, '')

    call add(l:L, '▶ MARK / BOOKMARK HIGHLIGHT (per-buffer, persistent)')
    call add(l:L, '  • `mh`  (Normal) Toggle highlight mark on word under cursor')
    call add(l:L, '  • `mh`  (Visual) Toggle highlight mark on selection')
    call add(l:L, '  • `ml`  Clear all marks in current buffer')
    call add(l:L, '     CHỈ 2 phím này; `m` một mình trả lại lệnh đặt mark gốc của')
    call add(l:L, '     Vim (`ma`, `mb`, …).')
    call add(l:L, '     Marks persist across buffer switches, cleaned up on BufWipeout')
    call add(l:L, '     Selection tối đa 500 dòng; mark lưu theo (dòng,cột) nên khi sửa')
    call add(l:L, '     file, vị trí không còn hợp lệ sẽ tự bị bỏ (không còn lỗi ở')
    call add(l:L, '     BufEnter).  `timeoutlen=300` (BASIC SETTINGS) để `mh`/`ml`')
    call add(l:L, '     phản hồi nhanh.')
    call add(l:L, '')

    call add(l:L, '▶ DIFF MODE')
    call add(l:L, '  • `dn` / `db`  Next / previous diff change (]c / [c)')
    call add(l:L, '  • `df`         diff-put (dp) — push current change across')
    call add(l:L, '  • All diff windows auto-unfold on VimEnter')
    call add(l:L, '')

    call add(l:L, '▶ SESSION — lưu / khôi phục phiên làm việc (tab + split)')
    call add(l:L, '  • `<F3>`  Hỏi tên rồi lưu: `Enter` = tên mặc định')
    call add(l:L, '     (session-<ngày giờ>.json), gõ tên = session-<tên>-<ngày')
    call add(l:L, '     giờ>.json, `Ctrl-C` = huỷ. Tên hiện trong ngoặc [] ở picker.')
    call add(l:L, '  • Thoát GVim (nút X hay `:q`) KHÔNG hỏi và KHÔNG tự lưu gì —')
    call add(l:L, '     việc lưu là do anh bấm F3')
    call add(l:L, '  • `:SaveSession [tên]`  Lưu tay, có thể kèm tên')
    call add(l:L, '  • Session lưu trong `~/.gvim_sessions/session-YYYYmmdd-HHMMSS.json`')
    call add(l:L, '     gồm mọi tab + mọi split: đúng thứ tự, hướng chia, bề rộng,')
    call add(l:L, '     chiều cao, cửa sổ active. Mỗi cửa sổ lưu FULL PATH của file')
    call add(l:L, '     (kèm `name` để hiển thị) — WinList không nằm trong bản lưu')
    call add(l:L, '  • `<F2>`  TOGGLE danh sách session NGAY TRONG CỬA SỔ HIỆN TẠI')
    call add(l:L, '     (không mở tab mới — thao tác này hay dùng khi vừa mở GVim')
    call add(l:L, '     trống). Bấm F2 lần nữa để đóng. Tên session = ngày giờ lưu,')
    call add(l:L, '     kèm danh sách tab/split; `Enter`/double-click khôi phục,')
    call add(l:L, '     `q` đóng, `r` đọc lại. Chữ trong picker là TIẾNG ANH.')
    call add(l:L, '     KHÔNG map Ctrl-Shift-O: với chữ cái, Vim bỏ qua Shift khi đi')
    call add(l:L, '     cùng Ctrl nên <C-S-o> chính là <C-o> (sẽ đè phím Ctrl-O')
    call add(l:L, '     explorer). Giữ tối đa 20 session.')
    call add(l:L, '')

    call add(l:L, '▶ MISC / FUNCTION KEYS')
    call add(l:L, '  • `F1`   Toggle this manual (you are here)')
    call add(l:L, '  • `F2`   Toggle the session picker (see SESSION section above)')
    call add(l:L, '  • `F3`   Save session (asks for a name; Enter = default)')
    call add(l:L, '  • `F5`   Reload current file (:edit!)')
    call add(l:L, '  • `F10`  Toggle GVim menu bar + toolbar')
    call add(l:L, '  • `F11`  Toggle window maximize (wmctrl, Linux/X11)')
    call add(l:L, '  • `F12`  Copy full file path to clipboard')
    call add(l:L, '  • `Alt-Z` Toggle line wrap — MẶC ĐỊNH WRAP BẬT cho mọi file')
    call add(l:L, '     (`set wrap` + `linebreak` + `breakindent`, dòng nối có `↪`;')
    call add(l:L, '     panel WinList / session picker / Vimrc Manual luôn nowrap;')
    call add(l:L, '     riêng *.md mở ra là NOWRAP — ftplugin/md.vim đặt setlocal)')
    call add(l:L, '')
    call add(l:L, '═══════════════════════════════════════════════════════════════════')
    return l:L
endfunction

function! ToggleVimrcManual() abort
    let l:bufname = '__VimrcManual__'
    let l:winnr   = bufwinnr(l:bufname)

    if l:winnr != -1
        execute l:winnr . 'wincmd c'
        return
    endif

    let l:height = max([10, &lines / 2])
    execute 'topleft ' . l:height . 'split ' . l:bufname

    setlocal buftype=nofile bufhidden=hide noswapfile nobuflisted
    setlocal nowrap number norelativenumber
    setlocal winfixheight signcolumn=no
    setlocal filetype=vimrcmanual
    setlocal modifiable

    silent! %delete _
    call setline(1, s:VimrcManualContent())
    call s:VimrcManualSyntax()

    setlocal nomodifiable nomodified
    setlocal statusline=\ 【Vimrc\ Manual】\ Press\ F1\ or\ q\ to\ close

    nnoremap <silent> <buffer> q  :call ToggleVimrcManual()<CR>
    nnoremap <silent> <buffer> <F1> :call ToggleVimrcManual()<CR>
endfunction

nnoremap <silent> <F1> :call ToggleVimrcManual()<CR>
