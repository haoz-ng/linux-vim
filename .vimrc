" ============================================
" GVIM AUTO FULLSCREEN
" ============================================
if has('gui_running')
    " Set GVim window to maximize
    autocmd GUIEnter * call system("wmctrl -ir " . v:windowid . " -b add,maximized_vert,maximized_horz")
endif

" Toggle fullscreen with F11
if has('gui_running')
    map <silent> <F11> :call system("wmctrl -ir " . v:windowid . " -b toggle,maximized_vert,maximized_horz")<CR>
endif

" ============================================
" BASIC SETTINGS
" ============================================
set hlsearch                    " Highlight search results
set encoding=utf-8
set fileencoding=utf-8
set termencoding=utf-8
set guifont=Monospace\ Regular\ 11
set ignorecase                  " Case insensitive search
set smartcase                   " Case sensitive when uppercase present
set autoread                    " Auto reload file when changed externally
set number                      " Show line numbers
set mouse=a                     " Enable mouse
set showtabline=2               " Always show tab line
set guitablabel=%t%M            " Tab label format
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set nowrap
set linebreak
set breakindent
set showbreak=↪\ 
set laststatus=2                " Always show status line
set cursorcolumn
set cursorline
set foldlevel=99

" Auto reload file on focus
au CursorHold,CursorHoldI * silent! checktime

" ============================================
" THEME AND COLORS
" ============================================
syntax enable
syntax on
set background=dark
colorscheme haoz

" Background colors
highlight Normal      ctermbg=black guibg=#000000
highlight LineNr      ctermbg=black guibg=#000000
highlight NonText     ctermbg=black guibg=#000000
highlight EndOfBuffer ctermbg=black guibg=#000000
highlight SignColumn  ctermbg=black guibg=#000000
highlight FoldColumn  ctermbg=black guibg=#000000

" Cursor colors
highlight CursorLine guibg=#001933
highlight CursorColumn guibg=#001933
highlight CursorLineNr guifg=#00ffff guibg=#001933
highlight Cursor guifg=blue

" Other colors
highlight Folded ctermfg=White ctermbg=DarkBlue guifg=#ffffff guibg=#003366
highlight Search ctermfg=blue ctermbg=grey guifg=#0000ff guibg=#888888
highlight VertSplit guifg=#00ffff guibg=#191E2A
highlight SpecialKey ctermbg=17 guibg=#001933 guifg=#00ffff
highlight TabLineSel ctermfg=159 ctermbg=0

" ============================================
" CURSOR SHAPE
" ============================================
if has('gui_running')
    set guicursor=n-v-c:ver25-blinkon0,i:ver25-blinkon500-blinkoff500,r:hor20-blinkon500-blinkoff500
else
    let &t_SI = "\e[6 q"    " Insert mode: steady bar
    let &t_EI = "\e[2 q"    " Normal mode: steady block
endif

" ============================================
" STATUS LINE
" ============================================
set statusline=%F                                                   " Full file path
set statusline+=%#LineNr#
set statusline+=%=
set statusline+=%#CursorColumn#
set statusline+=%y                                                  " File type
set statusline+=\[%l/%L]                                            " Current/Total lines
set statusline+=\[%{&shiftwidth}\%{&expandtab?'spaces':'tabs'}]    " Tab size

highlight StatusLine guifg=#00ffff guibg=#001933
highlight StatusLineNC guifg=#888888 guibg=#001933

function! StatusLineColorMonitor()
  let m = mode()
  if m ==# 'i'
    highlight StatusLine guifg=#00ffff guibg=#661900
  elseif m ==# 'R'
    highlight StatusLine guifg=#00ffff guibg=#006619
  else
    highlight StatusLine guifg=#00ffff guibg=#001933
  endif
endfunction

let g:statusline_timer = 0

function! StatuslineStartTimer()
  if g:statusline_timer == 0
    let g:statusline_timer = timer_start(500, {-> StatusLineColorMonitor()}, {'repeat': -1})
  endif
endfunction

function! StatuslineStopTimer()
  if g:statusline_timer != 0
    call timer_stop(g:statusline_timer)
    let g:statusline_timer = 0
  endif
endfunction

augroup DynamicStatusLine
  autocmd!
  autocmd VimEnter,FocusGained * call StatuslineStartTimer()
  autocmd FocusLost,QuitPre * call StatuslineStopTimer()
augroup END

" ============================================
" COMMENT SYSTEM
" ============================================

" Filetype-specific comment leader
autocmd FileType c,cpp,java,scala             let b:comment_leader = '\/\/'
autocmd FileType sh,csh,ruby,python,tcsh      let b:comment_leader = '#'
autocmd FileType conf,fstab                   let b:comment_leader = '#'
autocmd FileType tex                          let b:comment_leader = '%'
autocmd FileType mail                         let b:comment_leader = '>'
autocmd FileType vim                          let b:comment_leader = '"'
autocmd FileType nasm                         let b:comment_leader = ';'
autocmd BufReadPre,FileReadPre *.v,*.sv,*.svh let b:comment_leader = '\/\/'
autocmd BufReadPre,FileReadPre *.csh,*.txt    let b:comment_leader = '#'

function! CommentLine()
    let line = getline('.')
    if line =~ '\S'
        call setline('.', substitute(line, '^\(\s*\)\(.*\)', '\1' . b:comment_leader . ' \2', ''))
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
            call setline(lnum, substitute(line, '^\(\s*\)\(.*\)', '\1' . b:comment_leader . ' \2', ''))
        endif
    endfor
endfunction

function! UncommentRange(start, end)
    for lnum in range(a:start, a:end)
        let line = getline(lnum)
        if line =~? '^\s*' . b:comment_leader
            call setline(lnum, substitute(line, '^\(\s*\)' . b:comment_leader . ' \?', '\1', ''))
        endif
    endfor
endfunction

function! ToggleCommentLine()
    let cl = exists('b:comment_leader') ? b:comment_leader : '//'
    let line = getline('.')
    if line =~ '^\s*' . cl
        call UncommentLine()
    else
        call CommentLine()
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
        call UncommentRange(a:start, a:end)
    else
        call CommentRange(a:start, a:end)
    endif
endfunction

nnoremap <silent> cc :call ToggleCommentLine()<CR>
vnoremap <silent> cc :<C-u>call ToggleCommentRange(line("'<"), line("'>"))<CR>

" ============================================
" TOGGLE 'haoz' AT END OF LINE (hh)
" ============================================

function! ToggleCommentSyntaxHaoz()
    let l:comment = exists('b:comment_leader') ? b:comment_leader : '//'
    let l:comment = substitute(l:comment, '\\/\\/', '//', 'g')
    
    let l:pattern = '\s*' . escape(l:comment, '/\.*$^~[]') . '\s* haoz\s*$'
    let l:current_line = getline('.')
    
    if l:current_line =~ l:pattern
        call setline('.', substitute(l:current_line, l:pattern, '', ''))
    else
        call setline('.', l:current_line . ' ' . l:comment . ' haoz')
    endif
endfunction

nnoremap <silent> hh :call ToggleCommentSyntaxHaoz()<CR>
vnoremap <silent> hh :call ToggleCommentSyntaxHaoz()<CR>

" ============================================
" TOGGLE 'haoz' AT BEGINNING OF LINE (ch)
" ============================================

function! ToggleHaozCommentAtBeginning()
    let cl = exists('b:comment_leader') ? b:comment_leader : '//'
    let cl = substitute(cl, '\\/\\/', '//', 'g')
    
    let line = getline('.')
    let indent = matchstr(line, '^\s*')
    let content = substitute(line, '^\s*', '', '')
    
    let pattern = '^' . escape(cl, '/\.*$^~[]') . '\s*haoz\s\+'
    
    if content =~ pattern
        let new_content = substitute(content, pattern, '', '')
        call setline('.', indent . new_content)
    else
        if content != ''
            call setline('.', indent . cl . ' haoz ' . content)
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
                call setline(lnum, indent . new_content)
            else
                if content !~ '^' . escape(cl, '/\.*$^~[]') . '\s*haoz\s\+'
                    call setline(lnum, indent . cl . ' haoz ' . content)
                endif
            endif
        endif
    endfor
endfunction

nnoremap <silent> ch :call ToggleHaozCommentAtBeginning()<CR>
vnoremap <silent> ch :<C-u>call ToggleHaozCommentRangeAtBeginning(line("'<"), line("'>"))<CR>

" ============================================
" AUTO SAVE
" ============================================
augroup autosave
    autocmd!
    autocmd BufRead * if &filetype == "" | setlocal ft=log | endif
    autocmd TextChanged,InsertLeave * if &readonly == 0 && &modified | silent write | endif
augroup END

" ============================================
" BASIC KEYBINDINGS
" ============================================

" Tab management
noremap <C-n> :tabnew<CR>
noremap <C-w> :q<CR>
noremap <C-\> :vs<CR><C-w>w
noremap <C-o> :E<CR>:edit!<CR>

" File operations
nnoremap <F5> :edit!<CR>
nnoremap <F12> :let @+ = expand('%:p') <bar> echo "Copied full path: " . expand('%:p')<CR>

" Select all
nnoremap <C-a> ggVG

" Clear highlight
nnoremap <S-l> :nohlsearch<CR>

" Select current line
nnoremap <C-l> V
inoremap <C-l> <Esc>V

" ============================================
" COPY/PASTE/CUT (Clipboard Integration)
" ============================================

" Copy
vnoremap <C-c> "+y
nnoremap <C-c> "+yy

" Paste
nnoremap <C-v> "+p
inoremap <C-v> <C-r>+
vnoremap <C-V> "+p
cnoremap <C-v> <C-r>+

" Cut
vnoremap <C-x> "+d
nnoremap <C-x> "+dd

" ============================================
" VISUAL MODE AND SELECTION
" ============================================

" Use V for block visual mode (since Shift+V is for line selection)
nnoremap V <C-v>

" Select current word with Ctrl+D
nnoremap <C-d> :let @/='\<'.expand('<cword>').'\>'<CR>viw
inoremap <C-d> <Esc>viw

" Highlight word under cursor with Ctrl+F
nnoremap <C-f> :let @/ = '\<'.expand('<cword>').'\>'<CR>:set hlsearch<CR>
vnoremap <C-f> "zy:let @/ = escape(@z, '/\')<CR>:set hlsearch<CR>

" ============================================
" SHIFT ARROW SELECTION (FIXED)
" ============================================

" Insert mode
inoremap <S-Left>   <Left><C-o>v
inoremap <S-Right>  <C-o>v
inoremap <S-Up>     <Left><C-o>v<Up><Right>
inoremap <S-Down>   <C-o>v<Down><Left>
inoremap <S-Home>   <C-o>v<Home>
inoremap <S-End>    <C-o>v<End>
imap     <C-S-Left> <S-Left><C-Left>
imap     <C-S-Right> <S-Right><C-Right>

" Visual mode - Keep selection
vnoremap <S-Left>  <Left>
vnoremap <S-Right> <Right>
vnoremap <S-Up>    <Up>
vnoremap <S-Down>  <Down>
vnoremap <S-Home>  <Home>
vnoremap <S-End>   <End>

" Normal mode - Start selection
nnoremap <S-Left>  v<Left>
nnoremap <S-Right> v<Right>
nnoremap <S-Up>    v<Up>
nnoremap <S-Down>  v<Down>
nnoremap <S-Home>  v<Home>
nnoremap <S-End>   v<End>

" ============================================
" CTRL ARROW WORD NAVIGATION (FIXED)
" ============================================

" Normal mode
nnoremap <C-Right> w
nnoremap <C-Left>  b

" Visual mode - Extend selection
vnoremap <C-Right> e
vnoremap <C-Left>  b

" Visual mode - Start word selection
nnoremap <C-S-Right> vew
nnoremap <C-S-Left>  vb

" Visual mode - Extend word selection
vnoremap <C-S-Right> e
vnoremap <C-S-Left>  b

" Insert mode
inoremap <C-Right> <C-o>w
inoremap <C-Left>  <C-o>b

" ============================================
" HOME KEY BEHAVIOR
" ============================================
inoremap <Home> <C-o>^
nnoremap <Home> ^

" ============================================
" TAB/SHIFT-TAB INDENTATION
" ============================================

function! NormalModeTab()
    let sw = &shiftwidth
    let line = getline('.')
    let col = col('.') - 1
    let lead = matchstr(line, '^\s*')
    let leadlen = strlen(lead)

    if col <= leadlen
        let next = ((col / sw) + 1) * sw
        let newline = repeat(' ', next) . substitute(line, '^\s*', '', '')
        call setline('.', newline)
        call cursor(line('.'), next + 1)
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
        call setline('.', newline)
        call cursor(line('.'), col - n + 1 > 0 ? col - n + 1 : 1)
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
        call setline(i, newline)
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
        call setline(i, newline)
    endfor
endfunction

nnoremap <silent> <Tab>   :call NormalModeTab()<CR>
nnoremap <silent> <S-Tab> :call NormalModeShiftTab()<CR>
vnoremap <silent> <Tab>   :<C-u>call VisualModeTab()<CR>gv
vnoremap <silent> <S-Tab> :<C-u>call VisualModeShiftTab()<CR>gv

" ============================================
" UNDO (Ctrl+Z)
" ============================================
nnoremap <C-z> u
inoremap <C-z> <C-o>u
vnoremap <C-z> <Esc>u

" ============================================
" DELETE LINE (Shift+Delete)
" ============================================
nnoremap <S-Del> dd

" ============================================
" TOGGLE CASE (Ctrl+U)
" ============================================
function! ToggleCase()
    if mode() ==# 'v' || mode() ==# 'V' || mode() ==# "\<C-v>"
        normal! g~
    else
        normal! g~iw
    endif
endfunction

vnoremap <C-U> :<C-u>call ToggleCase()<CR>
nnoremap <C-U> :<C-u>call ToggleCase()<CR>

" ============================================
" SEARCH NAVIGATION
" ============================================
nnoremap n nzz
nnoremap N Nzz

" ============================================
" TOGGLE LINE WRAP (Alt+Z)
" ============================================
nnoremap <M-z> :set wrap!<CR>

" ============================================
" DISABLE PROBLEMATIC KEYS
" ============================================
nnoremap x <Nop>
nnoremap <Del> <Nop>

" ============================================
" FOLDING
" ============================================
augroup filtype_verilog
    autocmd!
    autocmd FileType Verilog,verilog_systemverilog setlocal foldmethod=indent
    autocmd BufNewFile,BufRead *.v,*.sv,*.svh setlocal foldmethod=indent
augroup END
runtime macros/matchit.vim

" ============================================
" NERDTREE
" ============================================

let NERDTreeShowHidden=1
let g:NERDTreeWinPos = "left"
let g:NERDTreeWinSize = 50

" Exit Vim if NERDTree is the only window
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | call feedkeys(":quit\<CR>:\<BS>") | endif

" Smart toggle
noremap <silent> <C-b> :call SmartNERDTreeToggle()<CR>

function! SmartNERDTreeToggle()
    if g:NERDTree.IsOpen()
        :NERDTreeClose
    else
        if @% == ""
            :NERDTreeCWD
        elseif filereadable(expand('%'))
            :NERDTreeFind
        else
            execute ':NERDTree ' . expand('%:p:h')
        endif
    endif
endfunction

" Open files in background tabs
autocmd VimEnter * call NERDTreeAddKeyMap({
      \ 'key': '<2-LeftMouse>',
      \ 'scope': 'FileNode',
      \ 'callback': 'OpenSmart',
      \ 'override': 1 })
autocmd VimEnter * call NERDTreeAddKeyMap({
      \ 'key': '<CR>',
      \ 'scope': 'FileNode',
      \ 'callback': 'OpenSmart',
      \ 'override': 1 })

function! OpenSmart(node)
  let l:path = a:node.path.str()

  let l:bufs = tabpagebuflist()
  let l:other = 0
  for b in l:bufs
    if buflisted(b)
      if exists('t:NERDTreeBufName') && bufname(b) ==# t:NERDTreeBufName
        continue
      endif
      let l:other += 1
    endif
  endfor

  if l:other == 0
    execute 'edit ' . fnameescape(l:path)
  else
    execute 'silent tabedit ' . fnameescape(l:path)
    execute 'tabprevious'
  endif
endfunction

" ============================================
" INDENT LINE
" ============================================
let g:indentLine_color_gui = '#0055aa'
let g:indentLine_char = '┆'

" ============================================
" VIM BOOKMARK
" ============================================
let g:bookmark_highlight_lines = 1
highlight BookmarkLine ctermbg=17 guibg=#001933
highlight BookmarkSign ctermbg=17 guibg=#001933 guifg=#00ffff
let g:bookmark_sign = '=='
let g:bookmark_center = 1

" ============================================
" GVIM GUI SETTINGS
" ============================================

" Hide menu bar and tool bar by default
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
    autocmd GUIEnter * call ToggleGvimMenuToolbar()
augroup END

" ============================================
" DIFF MODE (vimdiff/gvimdiff)
" ============================================

" Custom diff colors
augroup diffcolors
  autocmd!
  autocmd ColorScheme * call s:DiffHighlights()
augroup END

function! s:DiffHighlights()
  if &background ==# 'dark'
    highlight DiffAdd      guibg=#29762e guifg=NONE gui=NONE
    highlight DiffChange   guibg=#304e75 guifg=NONE gui=NONE
    highlight DiffDelete   guibg=#772e2e guifg=NONE gui=NONE
    highlight DiffText     guibg=#aa3a3a guifg=NONE gui=NONE
    highlight DiffRemoved  guibg=#772e2e guifg=NONE gui=NONE
    highlight DiffFile     guibg=#304e75 guifg=NONE gui=NONE
    highlight DiffNewFile  guibg=#29762e guifg=NONE gui=NONE
  else
    highlight DiffAdd      guibg=#cce8cc guifg=NONE gui=NONE
    highlight DiffChange   guibg=#cce0fa guifg=NONE gui=NONE
    highlight DiffDelete   guibg=#facccc guifg=NONE gui=NONE
    highlight DiffText     guibg=#ffbaba guifg=NONE gui=NONE
    highlight DiffRemoved  guibg=#facccc guifg=NONE gui=NONE
    highlight DiffFile     guibg=#cce0fa guifg=NONE gui=NONE
    highlight DiffNewFile  guibg=#cce8cc guifg=NONE gui=NONE
  endif
endfunction

autocmd VimEnter * call s:DiffHighlights()

" Diff mode keybindings
if &diff
  nnoremap dn ]c     " Jump to next change
  nnoremap db [c     " Jump to previous change
  nnoremap df dp     " Put change
endif

" Quick replace in diff mode
autocmd FilterReadPre * if &diff | nnoremap <buffer> df dp | endif
autocmd VimEnter * if &diff | nnoremap <buffer> df dp | endif

" Disable folds in diff mode
function! UnfoldAllDiffWindows()
    let curr_win = win_getid()
    for i in range(1, winnr('$'))
        execute i . 'wincmd w'
        if &diff
            setlocal nofoldenable foldmethod=manual
            silent! normal! zR
        endif
    endfor
    call win_gotoid(curr_win)
endfunction

augroup Difffoldfix
    autocmd!
    autocmd VimEnter * call UnfoldAllDiffWindows()
augroup END

" ============================================
" MISCELLANEOUS
" ============================================

" Reopen at last position
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
endif

" Turn off auto comment after commented line
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
