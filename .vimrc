" ╔══════════════════════════════════════════════════════════════════════════╗
" ║  Author   : haoz.ng                                                      ║
" ║  Version  : 6.47                                                         ║
" ║  Modified : 2026-06-09                                                   ║
" ║  Desc     : Personal GVIM configuration — themes, keymaps, WinList,      ║
" ║             NERDTree integration, diff, folding, auto-save & more.       ║
" ╚══════════════════════════════════════════════════════════════════════════╝


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                         GVIM AUTO FULLSCREEN                             │
" └──────────────────────────────────────────────────────────────────────────┘
if has('gui_running')
    autocmd GUIEnter * silent! call system("wmctrl -ir " . v:windowid . " -b add,maximized_vert,maximized_horz")
endif

if has('gui_running')
    map <silent> <F11> :silent! call system("wmctrl -ir " . v:windowid . " -b toggle,maximized_vert,maximized_horz")<CR>
endif


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                           BASIC SETTINGS                                 │
" └──────────────────────────────────────────────────────────────────────────┘
set hlsearch
set encoding=utf-8
set fileencoding=utf-8
set termencoding=utf-8
set guifont=Monospace\ Regular\ 11
set ignorecase
set smartcase
set autoread
set number
set mouse=a
set showtabline=2
set guitablabel=%t%M
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set nowrap
set linebreak
set breakindent
set showbreak=↪\ 
set laststatus=2
set cursorcolumn
set cursorline
set foldlevel=99
set lazyredraw
set updatetime=1000

au CursorHold,CursorHoldI * silent! checktime


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                          THEME AND COLORS                                │
" └──────────────────────────────────────────────────────────────────────────┘
syntax enable
syntax on
set background=dark
colorscheme haoz

highlight Normal      ctermbg=black guibg=#000000
highlight LineNr      ctermbg=black guibg=#000000
highlight NonText     ctermbg=black guibg=#000000
highlight EndOfBuffer ctermbg=black guibg=#000000
highlight SignColumn  ctermbg=black guibg=#000000
highlight FoldColumn  ctermbg=black guibg=#000000

highlight CursorLine   guibg=#001933
highlight CursorColumn guibg=#001933
highlight CursorLineNr guifg=#00ffff guibg=#001933
highlight Cursor       guifg=blue

highlight Folded     ctermfg=White ctermbg=DarkBlue guifg=#ffffff guibg=#003366
highlight Search     ctermfg=blue  ctermbg=grey     guifg=#0000ff guibg=#888888
highlight VertSplit  guifg=#00ffff guibg=#191E2A
highlight SpecialKey ctermbg=17    guibg=#001933    guifg=#00ffff
highlight TabLineSel ctermfg=159   ctermbg=0


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                         NETRW ( :E ) STYLING                            │
" └──────────────────────────────────────────────────────────────────────────┘

" ── Netrw behavior ────────────────────────────────────────────────────────
let g:netrw_liststyle    = 1
let g:netrw_banner       = 1
let g:netrw_browse_split = 0
let g:netrw_sizestyle    = "H"

" ── Netrw highlight function ──────────────────────────────────────────────
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


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                           CURSOR SHAPE                                   │
" └──────────────────────────────────────────────────────────────────────────┘
if has('gui_running')
    set guicursor=n-v-c:ver25-blinkon0,i:ver25-blinkon500-blinkoff500,r:hor20-blinkon500-blinkoff500
else
    let &t_SI = "\e[6 q"
    let &t_EI = "\e[2 q"
endif


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                            STATUS LINE                                   │
" └──────────────────────────────────────────────────────────────────────────┘
set statusline=%t
set statusline+=%#LineNr#
set statusline+=%=
set statusline+=%#CursorColumn#
set statusline+=\[%l/%L]
set statusline+=\[%{&shiftwidth}\%{&expandtab?'spaces':'tabs'}]

highlight StatusLine   guifg=#00ffff guibg=#001933
highlight StatusLineNC guifg=#888888 guibg=#001933

function! StatusLineColorMonitor()
    let m = mode()
    if m ==# 'i'
        silent! highlight StatusLine guifg=#00ffff guibg=#661900
    elseif m ==# 'R'
        silent! highlight StatusLine guifg=#00ffff guibg=#006619
    else
        silent! highlight StatusLine guifg=#00ffff guibg=#001933
    endif
endfunction

let g:statusline_timer = 0

function! StatuslineStartTimer()
    if g:statusline_timer == 0
        let g:statusline_timer = timer_start(1000, {-> silent! StatusLineColorMonitor()}, {'repeat': -1})
    endif
endfunction

function! StatuslineStopTimer()
    if g:statusline_timer != 0
        silent! call timer_stop(g:statusline_timer)
        let g:statusline_timer = 0
    endif
endfunction

augroup DynamicStatusLine
    autocmd!
    autocmd VimEnter,FocusGained * silent! call StatuslineStartTimer()
    autocmd FocusLost,QuitPre    * silent! call StatuslineStopTimer()
augroup END


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                           COMMENT SYSTEM                                 │
" └──────────────────────────────────────────────────────────────────────────┘
autocmd FileType c,cpp,java,scala                   let b:comment_leader = '\/\/'
autocmd FileType sh,csh,ruby,python,tcsh            let b:comment_leader = '#'
autocmd FileType conf,fstab                         let b:comment_leader = '#'
autocmd FileType tex                                let b:comment_leader = '%'
autocmd FileType mail                               let b:comment_leader = '>'
autocmd FileType vim                                let b:comment_leader = '"'
autocmd FileType nasm                               let b:comment_leader = ';'
autocmd BufReadPre,FileReadPre *.v,*.sv,*.svh,*.svt let b:comment_leader = '\/\/'
autocmd BufReadPre,FileReadPre *.csh,*.txt          let b:comment_leader = '#'

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


" ┌──────────────────────────────────────────────────────────────────────────┐
" │               TOGGLE 'haoz' AT END OF LINE  ( hh )                      │
" └──────────────────────────────────────────────────────────────────────────┘
function! ToggleCommentSyntaxHaoz()
    let l:comment = exists('b:comment_leader') ? b:comment_leader : '//'
    let l:comment = substitute(l:comment, '\\/\\/', '//', 'g')
    let l:pattern = '\s*' . escape(l:comment, '/\.*$^~[]') . '\s* haoz\s*$'
    let l:current_line = getline('.')
    if l:current_line =~ l:pattern
        silent! call setline('.', substitute(l:current_line, l:pattern, '', ''))
    else
        silent! call setline('.', l:current_line . ' ' . l:comment . ' haoz')
    endif
endfunction

nnoremap <silent> hh :call ToggleCommentSyntaxHaoz()<CR>
vnoremap <silent> hh :call ToggleCommentSyntaxHaoz()<CR>


" ┌──────────────────────────────────────────────────────────────────────────┐
" │             TOGGLE 'haoz' AT BEGINNING OF LINE  ( ch )                  │
" └──────────────────────────────────────────────────────────────────────────┘
function! ToggleHaozCommentAtBeginning()
    let cl = exists('b:comment_leader') ? b:comment_leader : '//'
    let cl = substitute(cl, '\\/\\/', '//', 'g')
    let line = getline('.')
    let indent = matchstr(line, '^\s*')
    let content = substitute(line, '^\s*', '', '')
    let pattern = '^' . escape(cl, '/\.*$^~[]') . '\s*haoz\s\+'
    if content =~ pattern
        let new_content = substitute(content, pattern, '', '')
        silent! call setline('.', indent . new_content)
    else
        if content != ''
            silent! call setline('.', indent . cl . ' haoz ' . content)
        endif
    endif
endfunction

function! ToggleHaozCommentRangeAtBeginning(start, end)
    let cl = exists('b:comment_leader') ? b:comment_leader : '//'
    let cl = substitute(cl, '\\/\\/', '//', 'g')
    let all_have_haoz = 1
    let pattern = '^\s*' . escape(cl, '/\.*$^~[]') . '\s*haoz\s\+'
    for lnum in range(a:start, a:end)
        let line = getline(lnum)
        let content = substitute(line, '^\s*', '', '')
        if content != '' && content !~ '^' . escape(cl, '/\.*$^~[]') . '\s*haoz\s\+'
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
                let new_content = substitute(content, '^' . escape(cl, '/\.*$^~[]') . '\s*haoz\s\+', '', '')
                silent! call setline(lnum, indent . new_content)
            else
                if content !~ '^' . escape(cl, '/\.*$^~[]') . '\s*haoz\s\+'
                    silent! call setline(lnum, indent . cl . ' haoz ' . content)
                endif
            endif
        endif
    endfor
endfunction

nnoremap <silent> ch :call ToggleHaozCommentAtBeginning()<CR>
vnoremap <silent> ch :<C-u>call ToggleHaozCommentRangeAtBeginning(line("'<"), line("'>"))<CR>


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                             AUTO SAVE                                    │
" └──────────────────────────────────────────────────────────────────────────┘
augroup autosave
    autocmd!
    autocmd BufRead * if &filetype == "" | setlocal ft=log | endif
    autocmd TextChanged,InsertLeave * if &readonly == 0 && &modified | silent write | endif
augroup END


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                          BASIC KEYBINDINGS                               │
" └──────────────────────────────────────────────────────────────────────────┘
noremap <C-n> :tabnew<CR>
noremap <C-\> :vs<CR><C-w>w
noremap <C-o> :E<CR>

nnoremap <F5>  :edit!<CR>
nnoremap <F12> :let @+ = expand('%:p') <bar> echo "Copied full path: " . expand('%:p')<CR>

nnoremap <C-a> ggVG
nnoremap <S-l> :nohlsearch<CR>
nnoremap <C-l> V
inoremap <C-l> <Esc>V


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                          COPY / PASTE / CUT                              │
" └──────────────────────────────────────────────────────────────────────────┘
vnoremap <C-c> "+y
nnoremap <C-c> "+yy
nnoremap <C-v> "+p
inoremap <C-v> <C-r>+
vnoremap <C-V> "+p
cnoremap <C-v> <C-r>+
vnoremap <C-x> "+d
nnoremap <C-x> "+dd


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                       VISUAL MODE AND SELECTION                          │
" └──────────────────────────────────────────────────────────────────────────┘
nnoremap V <C-v>

nnoremap <C-d> :let @/='\<'.expand('<cword>').'\>'<CR>viw
inoremap <C-d> <Esc>viw

nnoremap <C-f> :let @/ = '\<'.expand('<cword>').'\>'<CR>:set hlsearch<CR>
vnoremap <C-f> "zy:let @/ = escape(@z, '/\')<CR>:set hlsearch<CR>


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                        SHIFT ARROW SELECTION                             │
" └──────────────────────────────────────────────────────────────────────────┘
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


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                      CTRL ARROW WORD NAVIGATION                          │
" └──────────────────────────────────────────────────────────────────────────┘
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


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                       TAB NAVIGATION (CTRL UP/DOWN)                      │
" └──────────────────────────────────────────────────────────────────────────┘
nnoremap <C-Up>   :tabprevious<CR>
nnoremap <C-Down> :tabnext<CR>


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                  SPLIT WINDOW NAVIGATION (ALT LEFT/RIGHT)                │
" └──────────────────────────────────────────────────────────────────────────┘
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


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                     NUMBER KEY TAB JUMP  (1–9, 0=10)                     │
" └──────────────────────────────────────────────────────────────────────────┘
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


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                          HOME KEY BEHAVIOR                               │
" └──────────────────────────────────────────────────────────────────────────┘
inoremap <Home> <C-o>^
nnoremap <Home> ^


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                       TAB / SHIFT-TAB INDENTATION                        │
" └──────────────────────────────────────────────────────────────────────────┘
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

nnoremap <silent> <Tab>   :call NormalModeTab()<CR>
nnoremap <silent> <S-Tab> :call NormalModeShiftTab()<CR>
vnoremap <silent> <Tab>   :<C-u>call VisualModeTab()<CR>gv
vnoremap <silent> <S-Tab> :<C-u>call VisualModeShiftTab()<CR>gv


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                                UNDO                                      │
" └──────────────────────────────────────────────────────────────────────────┘
nnoremap <C-z> u
inoremap <C-z> <C-o>u
vnoremap <C-z> <Esc>u


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                            DELETE LINE                                   │
" └──────────────────────────────────────────────────────────────────────────┘
nnoremap <S-Del> dd


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                            TOGGLE CASE                                   │
" └──────────────────────────────────────────────────────────────────────────┘
function! ToggleCase()
    if mode() ==# 'v' || mode() ==# 'V' || mode() ==# "\<C-v>"
        normal! g~
    else
        normal! g~iw
    endif
endfunction

vnoremap <C-U> :<C-u>call ToggleCase()<CR>
nnoremap <C-U> :<C-u>call ToggleCase()<CR>


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                         SEARCH NAVIGATION                                │
" └──────────────────────────────────────────────────────────────────────────┘
nnoremap n nzz
nnoremap N Nzz


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                          TOGGLE LINE WRAP                                │
" └──────────────────────────────────────────────────────────────────────────┘
nnoremap <M-z> :set wrap!<CR>


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                        DISABLE PROBLEMATIC KEYS                          │
" └──────────────────────────────────────────────────────────────────────────┘
nnoremap x     <Nop>
nnoremap <Del> <Nop>


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                              FOLDING                                     │
" └──────────────────────────────────────────────────────────────────────────┘
augroup filtype_verilog
    autocmd!
    autocmd FileType Verilog,verilog_systemverilog  setlocal foldmethod=indent
    autocmd BufNewFile,BufRead *.v,*.sv,*.svh,*.svt setlocal foldmethod=indent
augroup END
runtime macros/matchit.vim


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                            INDENT LINE                                   │
" └──────────────────────────────────────────────────────────────────────────┘
let g:indentLine_color_gui = '#0055aa'
let g:indentLine_char      = '┆'


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                           VIM BOOKMARK                                   │
" └──────────────────────────────────────────────────────────────────────────┘
let g:bookmark_highlight_lines = 1
highlight BookmarkLine ctermbg=17 guibg=#001933
highlight BookmarkSign ctermbg=17 guibg=#001933 guifg=#00ffff
let g:bookmark_sign   = '=='
let g:bookmark_center = 1


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                          GVIM GUI SETTINGS                               │
" └──────────────────────────────────────────────────────────────────────────┘
if has('gui_running')
    set guioptions-=mT
endif

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


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                             DIFF MODE                                    │
" └──────────────────────────────────────────────────────────────────────────┘
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


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                           MISCELLANEOUS                                  │
" └──────────────────────────────────────────────────────────────────────────┘
if has("autocmd")
    au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
endif

autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                    COMBINED PANEL (WinList + NERDTree)                   │
" │                    WinList on TOP — NERDTree on BOTTOM                   │
" └──────────────────────────────────────────────────────────────────────────┘

" ── Panel dimensions ──────────────────────────────────────────────────────
let g:winlist_min_width    = 15
let g:winlist_max_width    = 75
let g:winlist_padding      = 2
let g:winlist_width        = 75

let NERDTreeShowHidden     = 1
let g:NERDTreeWinPos       = "left"
let g:NERDTreeWinSize      = 75

let g:panel_nerdtree_lines = 20
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


" ══════════════════════════════════════════════════════════════════════════
"  TAB ID SYSTEM — stable IDs that survive drag-reorder
" ══════════════════════════════════════════════════════════════════════════

" Assign a unique ID to a single tab (call with tab number)
function! WinListEnsureTabID(...) abort
    let l:t = a:0 > 0 ? a:1 : tabpagenr()
    if gettabvar(l:t, 'winlist_tab_id', '') ==# ''
        call settabvar(l:t, 'winlist_tab_id',
            \ printf('tab_%d_%s', l:t, reltimestr(reltime())))
    endif
endfunction

" Get the stable ID of a tab (default: current tab)
function! WinListGetTabID(...) abort
    let l:t = a:0 > 0 ? a:1 : tabpagenr()
    return gettabvar(l:t, 'winlist_tab_id', '')
endfunction

" Find the CURRENT real tab number by its stable ID
function! WinListFindTabByID(tid) abort
    for l:t in range(1, tabpagenr('$'))
        if gettabvar(l:t, 'winlist_tab_id', '') ==# a:tid
            return l:t
        endif
    endfor
    return -1
endfunction

" Assign IDs to ALL existing tabs at startup
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


" ══════════════════════════════════════════════════════════════════════════
"  HELPER FUNCTIONS
" ══════════════════════════════════════════════════════════════════════════

" ── Single global WinList buffer name (no per-tab number) ─────────────────
function! WinListBufName(...) abort
    return '__WindowList__'
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

function! WinListIsOpen() abort
    return bufwinnr(WinListBufName()) != -1
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


" ══════════════════════════════════════════════════════════════════════════
"  AUTO-CLOSE TAB WHEN ONLY PANEL REMAINS
" ══════════════════════════════════════════════════════════════════════════

function! WinListCheckAutoCloseTab() abort
    if g:winlist_opening      | return | endif
    if g:winlist_file_opening | return | endif
    if g:panel_opening        | return | endif

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


" ══════════════════════════════════════════════════════════════════════════
"  WIDTH MANAGEMENT
" ══════════════════════════════════════════════════════════════════════════

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
            execute 'vertical resize ' . g:winlist_width
            execute 'noautocmd ' . l:cur . 'wincmd w'
            return
        endif
    endfor
endfunction

function! WinListFixWidth() abort
    if !WinListIsOpen() | return | endif
    let l:wnr = bufwinnr(WinListBufName())
    if winwidth(l:wnr) == g:winlist_width | return | endif

    let l:cur = winnr()
    silent! call WinListLockSplitWidths()
    execute 'noautocmd ' . l:wnr . 'wincmd w'
    execute 'vertical resize ' . g:winlist_width
    execute 'noautocmd ' . l:cur . 'wincmd w'
    silent! call WinListUnlockSplitWidths()
    silent! call SyncNERDTreeWidth()
endfunction


" ══════════════════════════════════════════════════════════════════════════
"  WINLIST CONTENT  — header embeds §<tab_id> for stable jump after reorder
" ══════════════════════════════════════════════════════════════════════════

function! WinListShortPath(fullpath) abort
    if a:fullpath ==# '' | return '[No Name]' | endif
    let l:parts = split(a:fullpath, '/')
    if len(l:parts) > 5
        let l:parts = l:parts[-5:]
        return '…/' . join(l:parts, '/')
    else
        return (a:fullpath[0] ==# '/' ? '/' : '') . join(l:parts, '/')
    endif
endfunction

function! WinListBuildAllTabLines() abort
    let l:cur_tab = tabpagenr()
    let l:lines   = []

    for l:t in range(1, tabpagenr('$'))
        " ── Ensure stable tab ID exists ───────────────────────────────────
        call WinListEnsureTabID(l:t)
        let l:tid = gettabvar(l:t, 'winlist_tab_id', string(l:t))

        " ── Header: visible part + §<tid> suffix (concealed in display) ───
        " Format:  === Tab N ===§<tid>
        call add(l:lines, printf('=== Tab %d ===§%s', l:t, l:tid))

        let l:wins_in_tab = tabpagebuflist(l:t)
        let l:active_win  = get(g:winlist_last_active, l:t, 1)
        let l:raw_idx     = 0
        let l:display_idx = 0          " ← reset per tab (bug fix)

        for l:bn in l:wins_in_tab
            let l:raw_idx += 1
            if WinListIsWinList(l:bn) || WinListIsNERDTree(l:bn)
                continue
            endif
            let l:display_idx += 1

            let l:fullpath = bufname(l:bn)
            let l:fname    = l:fullpath ==# '' ? '[No Name]'
                           \ : fnamemodify(l:fullpath, ':t')
            let l:mod      = getbufvar(l:bn, '&modified') ? ' [+]' : ''
            let l:prefix   = (l:t == l:cur_tab
                           \ && l:raw_idx == l:active_win) ? '> ' : '  '

            call add(l:lines,
                \ printf('%s%d: %s%s', l:prefix, l:display_idx, l:fname, l:mod))

            if l:fullpath !=# ''
                let l:abspath = fnamemodify(l:fullpath, ':p')
                let l:dirpath = fnamemodify(l:abspath, ':h')
                call add(l:lines, '     ' . WinListShortPath(l:dirpath))
            else
                call add(l:lines, '     -')
            endif
        endfor
    endfor

    return l:lines
endfunction


" ══════════════════════════════════════════════════════════════════════════
"  HIGHLIGHTS & SYNTAX
" ══════════════════════════════════════════════════════════════════════════

function! WinListSetupHighlight() abort
    silent! highlight default WinListHeader     guifg=#61AFEF ctermfg=75  gui=bold
    silent! highlight default WinListHeaderID   guifg=bg      ctermfg=0   gui=NONE
    silent! highlight default WinListNumber     guifg=#E5C07B ctermfg=180 gui=bold
    silent! highlight default WinListActive     guifg=#00FFFF ctermfg=114 gui=bold
    silent! highlight default WinListActiveMark guifg=#E06C75 ctermfg=204 gui=bold
    silent! highlight default WinListModified   guifg=#E06C75 ctermfg=204 gui=bold
    silent! highlight default WinListSpecial    guifg=#5C6370 ctermfg=59  gui=italic
    silent! highlight default WinListPath       guifg=#7a8a9a ctermfg=66
endfunction
silent! call WinListSetupHighlight()

augroup WinListHighlight
    autocmd!
    autocmd ColorScheme * silent! call WinListSetupHighlight()
    augroup WinListBufSettings
        autocmd!
        autocmd FileType winlist setlocal wrap nonumber norelativenumber
                               \ cursorline buftype=nofile noswapfile nobuflisted
                               \ winfixwidth winfixheight signcolumn=no
                               \ statusline=\ 
    augroup END
augroup END

function! WinListApplySyntax() abort
    silent! syntax clear

    " ── Header: show '=== Tab N ===' brightly; CONCEAL the §<tid> suffix ──
    syntax match WinListHeader   /^=== Tab \d\+ ===/
    syntax match WinListHeaderID /§[^ ]*$/           conceal
    setlocal conceallevel=2 concealcursor=nvic

    syntax match WinListActive     /^>.*$/
        \ contains=WinListActiveMark,WinListNumber,WinListModified,
        \           WinListSpecial,WinListPath
    syntax match WinListActiveMark /^>/              contained
    syntax match WinListNumber     /\d\+:/           contained
    syntax match WinListNumber     /^\s\+\d\+:/
    syntax match WinListModified   /\[+\]/
    syntax match WinListSpecial    /\[[^\]+]\+\]/
    syntax match WinListPath       /^\s\+[…\/].*/
endfunction


" ══════════════════════════════════════════════════════════════════════════
"  WINLIST REFRESH
" ══════════════════════════════════════════════════════════════════════════

function! WinListRefresh() abort
    if g:winlist_opening | return | endif
    if g:panel_opening   | return | endif
    if !WinListIsOpen()  | return | endif

    let l:wl_winnr = bufwinnr(WinListBufName())
    let l:cur_win  = winnr()

    if l:cur_win != l:wl_winnr
        \ && !WinListIsSpecial()
        \ && !WinListIsNERDTree(winbufnr(l:cur_win))
        let g:winlist_last_active[tabpagenr()] = l:cur_win
    endif

    let l:lines = WinListBuildAllTabLines()

    execute 'noautocmd ' . l:wl_winnr . 'wincmd w'
    setlocal modifiable
    silent! %delete _
    silent! call setline(1, l:lines)
    setlocal nomodifiable nomodified
    setlocal statusline=\ 
    silent! call WinListApplySyntax()

    silent! call WinListLockSplitWidths()
    if winwidth(winnr()) != g:winlist_width
        execute 'vertical resize ' . g:winlist_width
    endif
    silent! call WinListUnlockSplitWidths()

    execute 'noautocmd ' . l:cur_win . 'wincmd w'
    silent! call WinListFixWidth()
endfunction

" ── Simplified refresh: builds all-tab content, writes to current-tab panel
function! WinListRefreshAllTabs() abort
    if g:winlist_opening | return | endif
    if g:panel_opening   | return | endif

    let l:save_lz = &lazyredraw
    set lazyredraw

    let l:cur_tab = tabpagenr()
    let l:cur_win = winnr()

    if !WinListIsSpecial() && !WinListIsNERDTree()
        let g:winlist_last_active[l:cur_tab] = l:cur_win
    endif

    " Build content covering ALL tabs
    let l:lines = WinListBuildAllTabLines()

    " Write into the WinList window on the current tab only
    let l:wl_buf = WinListBufName()
    let l:wl_wnr = bufwinnr(l:wl_buf)

    if l:wl_wnr != -1
        let l:restore_win = winnr()
        execute 'noautocmd ' . l:wl_wnr . 'wincmd w'

        setlocal modifiable
        silent! %delete _
        silent! call setline(1, l:lines)
        setlocal nomodifiable nomodified
        setlocal statusline=\ 
        silent! call WinListApplySyntax()

        silent! call WinListLockSplitWidths()
        if winwidth(winnr()) != g:winlist_width
            execute 'vertical resize ' . g:winlist_width
        endif
        silent! call WinListUnlockSplitWidths()

        execute 'noautocmd ' . l:restore_win . 'wincmd w'
    endif

    let &lazyredraw = l:save_lz
endfunction


" ══════════════════════════════════════════════════════════════════════════
"  COMBINED PANEL — Open / Close / Toggle
" ══════════════════════════════════════════════════════════════════════════

function! CombinedPanelOpen() abort
    if g:panel_opening   | return | endif
    if g:winlist_opening | return | endif

    let l:tabnr   = tabpagenr()
    let l:bufname = WinListBufName()

    if WinListIsOpen() && NERDTreeIsOpen()
        silent! call WinListRefreshAllTabs()
        silent! call SyncNERDTreeWidth()
        return
    endif

    let l:safe = WinListFindNormalWin()
    if l:safe == -1
        call timer_start(100, {-> CombinedPanelOpen()})
        return
    endif

    let g:panel_opening   = 1
    let g:winlist_opening = 1
    let l:cur      = winnr()
    let l:cur_file = expand('%:p')

    try
        execute 'noautocmd ' . l:safe . 'wincmd w'

        if filereadable(l:cur_file)
            execute 'NERDTree ' . fnameescape(fnamemodify(l:cur_file, ':h'))
        else
            execute 'NERDTree ' . fnameescape(getcwd())
        endif

        let g:panel_nerdtree_open = 1

        execute 'vertical resize ' . g:winlist_width
        setlocal winfixwidth

        execute 'noautocmd leftabove ' . g:panel_nerdtree_lines . 'split ' . l:bufname

        setlocal winfixwidth winfixheight
        setlocal buftype=nofile bufhidden=hide
        setlocal noswapfile nobuflisted
        setlocal nowrap nonumber norelativenumber
        setlocal cursorline filetype=winlist signcolumn=no
        setlocal statusline=\ 

        " ── Buffer-local mappings ──────────────────────────────────────────
        nnoremap <silent> <nowait> <buffer> <CR>          :call WinListJump()<CR>
        nnoremap <silent> <nowait> <buffer> <LeftMouse>   <LeftMouse>
        nnoremap <silent> <nowait> <buffer> <2-LeftMouse> :call WinListMouseJump()<CR>
        nnoremap <silent> <nowait> <buffer> q             :call CombinedPanelClose()<CR>
        nnoremap <silent> <nowait> <buffer> r             :call WinListRefreshAllTabs()<CR>

        let g:winlist_tab_open[l:tabnr] = 1

        execute 'vertical resize ' . g:winlist_width

        for l:i in range(1, winnr('$'))
            if WinListIsNERDTree(winbufnr(l:i))
                execute 'noautocmd ' . l:i . 'wincmd w'
                setlocal winfixwidth
                execute 'vertical resize ' . g:winlist_width
                break
            endif
        endfor

        let l:wl_wnr    = bufwinnr(l:bufname)
        let l:return_nr = l:cur + 2
        let l:return_nr = min([l:return_nr, winnr('$')])

        while l:return_nr <= winnr('$')
            if !WinListIsSpecial(winbufnr(l:return_nr)) && !WinListIsNERDTree(winbufnr(l:return_nr))
                break
            endif
            let l:return_nr += 1
        endwhile

        if l:return_nr <= winnr('$')
            execute 'noautocmd ' . l:return_nr . 'wincmd w'
        else
            let l:fb = WinListFindNormalWin()
            if l:fb != -1
                execute 'noautocmd ' . l:fb . 'wincmd w'
            endif
        endif

    finally
        let g:panel_opening   = 0
        let g:winlist_opening = 0
    endtry

    silent! call WinListRefreshAllTabs()
endfunction


function! CombinedPanelClose() abort
    if WinListIsOpen()
        let l:wl_wnr = bufwinnr(WinListBufName())
        execute 'noautocmd ' . l:wl_wnr . 'wincmd c'
        let g:winlist_tab_open[tabpagenr()] = 0
    endif

    if NERDTreeIsOpen()
        silent! NERDTreeClose
        let g:panel_nerdtree_open = 0
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


" ══════════════════════════════════════════════════════════════════════════
"  NERDTREE — open file as RIGHT SPLIT, keep panel open
" ══════════════════════════════════════════════════════════════════════════

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
    silent! call WinListFixWidth()
endfunction

function! s:ClearFileOpening() abort
    let g:winlist_file_opening = 0
endfunction


" ══════════════════════════════════════════════════════════════════════════
"  WINLIST JUMP — uses stable Tab ID to survive drag-reorder
" ══════════════════════════════════════════════════════════════════════════

function! WinListMouseJump() abort
    let l:lnum = 0

    if exists('*getmousepos')
        let l:mpos = getmousepos()
        if l:mpos.winid == win_getid()
            let l:lnum = l:mpos.line
            silent! call cursor(l:lnum, l:mpos.column)
        endif
    elseif v:mouse_lnum > 0
        let l:lnum = v:mouse_lnum
        silent! call cursor(l:lnum, v:mouse_col)
    else
        let l:lnum = line('.')
    endif

    if l:lnum > 0 && getline(l:lnum) =~# '^[> ]*\d\+:'
        silent! call WinListJump()
    endif
endfunction

function! WinListJump() abort
    let l:line = getline('.')
    let l:m    = matchlist(l:line, '^[> ]*\(\d\+\):')
    if empty(l:m) | return | endif
    let l:display_idx = str2nr(l:m[1])

    " ── Scan upward for nearest header; extract the stable §<tid> suffix ──
    let l:header_tid = ''
    for l:lnum in range(1, line('.'))
        " Header format: === Tab N ===§<tid>
        let l:hdr = matchlist(getline(l:lnum), '^=== Tab \d\+ ===§\(.\+\)$')
        if !empty(l:hdr)
            let l:header_tid = l:hdr[1]
        endif
    endfor

    " ── Resolve stable ID → current real tab number ───────────────────────
    let l:real_tab = -1
    if l:header_tid !=# ''
        let l:real_tab = WinListFindTabByID(l:header_tid)
    endif

    if l:real_tab == -1
        echo "WinList: tab no longer exists."
        return
    endif

    " Switch to the correct tab (resolves drag-reorder correctly)
    if l:real_tab != tabpagenr()
        execute 'tabnext ' . l:real_tab
    endif

    " ── Find the Nth normal window in that tab ────────────────────────────
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


" ══════════════════════════════════════════════════════════════════════════
"  WINLIST OPEN / CLOSE / TOGGLE (backward-compat wrappers)
" ══════════════════════════════════════════════════════════════════════════

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


" ══════════════════════════════════════════════════════════════════════════
"  TAB LIFECYCLE HANDLERS
" ══════════════════════════════════════════════════════════════════════════

function! WinListOnTabLeave() abort
    let g:winlist_tab_open[tabpagenr()] = WinListIsOpen() ? 1 : 0
endfunction

function! WinListOnTabEnter() abort
    let l:tabnr = tabpagenr()
    if get(g:winlist_tab_open, l:tabnr, 0) == 1
        call timer_start(20, {-> s:RestorePanel(l:tabnr)})
    endif
endfunction

function! s:RestorePanel(tabnr) abort
    if tabpagenr() != a:tabnr | return | endif
    if !WinListIsOpen()
        silent! call CombinedPanelOpen()
    else
        silent! call WinListRefreshAllTabs()
    endif
endfunction

function! WinListOnTabNew() abort
    let l:tabnr = tabpagenr()
    let g:winlist_tab_open[l:tabnr] = 0
endfunction


" ══════════════════════════════════════════════════════════════════════════
"  AUTOCMDS
" ══════════════════════════════════════════════════════════════════════════

augroup WinListAuto
    autocmd!

    autocmd BufWritePost * if !g:winlist_opening && !g:panel_opening | silent! call WinListRefreshAllTabs() | endif
    autocmd BufReadPost  * if !g:winlist_opening && !g:panel_opening | silent! call WinListRefreshAllTabs() | endif
    autocmd BufAdd       * if !g:winlist_opening && !g:panel_opening | silent! call WinListRefreshAllTabs() | endif
    autocmd BufDelete    * if !g:winlist_opening && !g:panel_opening | silent! call WinListRefreshAllTabs() | endif
    autocmd BufWipeout   * if !g:winlist_opening && !g:panel_opening | silent! call WinListRefreshAllTabs() | endif

    autocmd WinEnter * silent! call WinListCheckAutoCloseTab()
    autocmd WinEnter * if !g:winlist_opening && !g:panel_opening | silent! call WinListRefreshAllTabs() | endif
    autocmd BufEnter * if !g:winlist_opening && !g:panel_opening | silent! call WinListRefreshAllTabs() | endif

    autocmd VimResized * silent! call WinListFixWidth()
    autocmd WinLeave   * silent! call WinListFixWidth()

    autocmd TabLeave * silent! call WinListOnTabLeave()
    autocmd TabEnter * silent! call WinListOnTabEnter()
    autocmd TabNew   * silent! call WinListOnTabNew()

augroup END


" ══════════════════════════════════════════════════════════════════════════
"  KEYMAPS + COMMANDS
" ══════════════════════════════════════════════════════════════════════════

noremap <silent> <C-b> :call CombinedPanelToggle()<CR>

nnoremap <silent> <leader>w  :call WinListToggle()<CR>
nnoremap <silent> <leader>W  :call WinListFixWidth()<CR>
nnoremap <silent> <leader>wa :call WinListOpenInAllTabs()<CR>

command! WinList        call WinListOpen()
command! WinListClose   call WinListClose()
command! WinListFix     call WinListFixWidth()
command! WinListRefresh call WinListRefreshAllTabs()
command! WinListAllTabs call WinListOpenInAllTabs()


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                    DOUBLE-ENTER SPLIT EXPAND / RESTORE                   │
" └──────────────────────────────────────────────────────────────────────────┘
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

    if len(l:normal_wins) <= 1
        return
    endif

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
        execute 'vertical resize ' . g:winlist_width
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


" ┌──────────────────────────────────────────────────────────────────────────┐
" │           CTRL+O — Open netrw expanded, restore on leave                 │
" └──────────────────────────────────────────────────────────────────────────┘
let g:netrw_pre_expand_layout = {}

function! SmartCtrlO() abort
    let g:netrw_pre_expand_layout = {}
    for l:i in range(1, winnr('$'))
        let l:bn = winbufnr(l:i)
        if !WinListIsSpecial(l:bn) && !WinListIsNERDTree(l:bn)
            let g:netrw_pre_expand_layout[l:i] = winwidth(l:i)
        endif
    endfor

    let l:wl_wnr = bufwinnr(WinListBufName())
    if l:wl_wnr != -1
        call setwinvar(l:wl_wnr, '&winfixwidth', 1)
    endif
    for l:i in range(1, winnr('$'))
        if WinListIsNERDTree(winbufnr(l:i))
            call setwinvar(l:i, '&winfixwidth', 1)
        endif
    endfor

    let l:normal_wins = []
    for l:i in range(1, winnr('$'))
        let l:bn = winbufnr(l:i)
        if !WinListIsSpecial(l:bn) && !WinListIsNERDTree(l:bn)
            call add(l:normal_wins, l:i)
        endif
    endfor

    let l:cur = winnr()

    if len(l:normal_wins) >= 2
        let l:avail = &columns
        if l:wl_wnr != -1
            let l:avail -= winwidth(l:wl_wnr) + 1
        endif
        for l:i in range(1, winnr('$'))
            if WinListIsNERDTree(winbufnr(l:i))
                let l:avail -= winwidth(l:i) + 1
            endif
        endfor

        let l:min_w  = 1
        let l:main_w = l:avail - (len(l:normal_wins) - 1) * (l:min_w + 1)
        if l:main_w < 1 | let l:main_w = 1 | endif

        for l:i in l:normal_wins
            call setwinvar(l:i, '&winfixwidth', 0)
            execute l:i . 'wincmd w'
            if l:i == l:cur
                execute 'vertical resize ' . l:main_w
            else
                execute 'vertical resize ' . l:min_w
            endif
        endfor
        execute l:cur . 'wincmd w'
    endif

    execute 'E'
endfunction


function! SmartCtrlORestore() abort
    if empty(g:netrw_pre_expand_layout) | return | endif

    for l:i in range(1, winnr('$'))
        let l:bn = winbufnr(l:i)
        if !WinListIsSpecial(l:bn) && !WinListIsNERDTree(l:bn)
            call setwinvar(l:i, '&winfixwidth', 0)
        endif
    endfor

    let l:cur = winnr()
    execute 'wincmd ='

    let l:wl_wnr = bufwinnr(WinListBufName())
    if l:wl_wnr != -1
        silent! call WinListFixWidth()
    endif

    let g:netrw_pre_expand_layout = {}
endfunction


augroup NetrwExpandRestore
    autocmd!
    autocmd BufLeave    * if &filetype ==# 'netrw' | call SmartCtrlORestore() | endif
    autocmd BufWinLeave * if &filetype ==# 'netrw' | call SmartCtrlORestore() | endif
augroup END

noremap <silent> <C-o> :call SmartCtrlO()<CR>


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                     REOPEN LAST CLOSED FILE (CTRL+SHIFT+T)              │
" └──────────────────────────────────────────────────────────────────────────┘
if !exists('g:closed_file_stack')
    let g:closed_file_stack = []
endif

let g:closed_file_stack_max = 20

function! ClosedFileStackPush() abort
    let l:name = expand('%:p')
    let l:bt   = &buftype

    if l:name ==# ''                    | return | endif
    if l:bt   !=# ''                    | return | endif
    if l:name =~# 'NERD_tree'           | return | endif
    if l:name =~# '__WindowList__'      | return | endif
    if !filereadable(l:name)            | return | endif

    call filter(g:closed_file_stack, 'v:val !=# l:name')
    call insert(g:closed_file_stack, l:name, 0)

    if len(g:closed_file_stack) > g:closed_file_stack_max
        let g:closed_file_stack = g:closed_file_stack[:g:closed_file_stack_max - 1]
    endif
endfunction

function! ReopenLastClosedFile() abort
    if empty(g:closed_file_stack)
        echo "No recently closed files."
        return
    endif

    let l:path = remove(g:closed_file_stack, 0)

    if !filereadable(l:path)
        echo "File no longer readable: " . l:path
        return
    endif

    let l:cur_win = winnr()
    wincmd l

    if winnr() == l:cur_win
        execute 'rightbelow vsplit ' . fnameescape(l:path)
    else
        execute 'edit ' . fnameescape(l:path)
    endif
endfunction

function! SmartClose() abort
    silent! call ClosedFileStackPush()
    quit
endfunction

noremap <silent> <C-w> :call SmartClose()<CR>

nnoremap <silent> <C-S-t> :call ReopenLastClosedFile()<CR>
inoremap <silent> <C-S-t> <Esc>:call ReopenLastClosedFile()<CR>
