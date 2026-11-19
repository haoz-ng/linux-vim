" ╔══════════════════════════════════════════════════════════════════════════╗
" ║  Author   : haozxje                                                      ║
" ║  Version  : 7.42                                                         ║
" ║  Modified : 2026-11-19                                                   ║
" ║  Desc     : Personal GVIM configuration — themes, keymaps, WinList       ║
" ║             (always-on) + on-demand NERDTree, statusline with            ║
" ║             [CL:TL], panel-aware tab label & window title, diff,         ║
" ║             folding, auto-save, quick replace/delete, mark highlight.    ║
" ╚══════════════════════════════════════════════════════════════════════════╝


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                         GVIM AUTO FULLSCREEN                             │
" │ Description: Automatically maximizes the GVim window (vertical +         │
" │ horizontal) on startup via wmctrl, and binds F11 to manually toggle      │
" │ maximize/restore. Linux/X11 only (uses wmctrl).                          │
" └──────────────────────────────────────────────────────────────────────────┘
if has('gui_running')
    autocmd GUIEnter * silent! call system("wmctrl -ir " . v:windowid . " -b add,maximized_vert,maximized_horz")
endif

if has('gui_running')
    map <silent> <F11> :silent! call system("wmctrl -ir " . v:windowid . " -b toggle,maximized_vert,maximized_horz")<CR>
endif


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                           BASIC SETTINGS                                 │
" │ Description: Core editor behavior — UTF-8 encoding, search               │
" │ (highlight + smartcase), auto-reload changed files, line numbers,        │
" │ mouse support, tab labels, 4-space soft tabs, cursorline/column,         │
" │ WRAP MẶC ĐỊNH BẬT (Alt-Z để tắt), fold defaults, and performance         │
" │ tuning (lazyredraw, updatetime).                                         │
" └──────────────────────────────────────────────────────────────────────────┘
set hlsearch
set encoding=utf-8
set fileencoding=utf-8
set termencoding=utf-8
set guifont=Consolas\ Regular\ 9
set ignorecase
set smartcase
set autoread
" ── Swap file ───────────────────────────────────────────────────────────────
" GIỮ swap file (KHÔNG dùng 'noswapfile'): nó là lưới an toàn cho auto-save /
" autoread — khi buffer không ghi được (file [RO], đĩa đầy, process khác giữ
" file) thì swap là thứ duy nhất còn giữ thay đổi.
"
" Bỏ hộp thoại ATTENTION khi file đã có swap (đúng ca "chính tôi đang dùng
" file nên nó có swap"):
"   Swap file "...swp" already exists!
"   [O]pen Read-Only, (E)dit anyway, (R)ecover, (D)elete it, (Q)uit, (A)bort
" Cờ 'A' trong 'shortmess' = không hỏi, Vim coi như chọn (E)dit anyway và mở
" luôn để SỬA (không thành read-only).
set shortmess+=A

" Dồn swap về ~/.vim/swp để *.swp không rải trong cây source (/rsc/...).
" Hai dấu '//' = Vim dùng cả đường dẫn đầy đủ khi đặt tên .swp, tránh trùng
" tên giữa hai file cùng tên ở hai thư mục khác nhau.  /tmp// là chỗ dự phòng.
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
" MẶC ĐỊNH WRAP: mọi file mở ra đều xuống dòng cho vừa bề ngang cửa sổ.
" Đổi qua lại bằng <M-z> (xem BASIC KEYBINDINGS).  linebreak: chỉ ngắt ở
" khoảng trắng; breakindent + showbreak: dòng bị wrap được thụt đúng lề và
" có ký tự ↪ ở đầu để biết là dòng nối.
" Panel: WinList đặt riêng `wrap linebreak` (tên test dài thì xuống dòng);
" session picker và Vimrc Manual đặt `nowrap` (mỗi mục 1 dòng cho gọn).
set wrap
set linebreak
set breakindent
" (dùng let thay vì 'set showbreak=↪\ ' để dấu cách cuối không bị mất khi
"  file bị trim/trailing-space-strip)
let &showbreak = '↪ '
set laststatus=2
set cursorcolumn
set cursorline
set foldlevel=99
set lazyredraw
" timeoutlen ngắn: 'mh' và 'ml' là mapping có tiền tố chung 'm' nên Vim phải
" chờ một chút để biết bạn gõ 'mh' hay 'ml'.  300ms đủ nhanh mà vẫn phân biệt
" được (cũng làm các phím có tiền tố như '\' phản hồi nhanh hơn).
set timeoutlen=300
set updatetime=1000

" Builds the tab label text: filename + [M] (modified) + [RO] (readonly)
" Bỏ qua các cửa sổ panel (WinList / NERDTree / netrw): nếu cửa sổ đang
" focus là panel thì vẫn lấy tên file thật đang mở trong tab, không hiện
" "__WindowList__".  Ưu tiên cửa sổ đang focus nếu nó là cửa sổ nội dung.
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

    " Nếu cửa sổ focus là panel, tìm cửa sổ nội dung đầu tiên trong tab
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

" Auto-detect external file changes when cursor idles (works with autoread)
au CursorHold,CursorHoldI * silent! checktime


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                          THEME AND COLORS                                │
" │ Description: Loads the custom 'haoz' dark colorscheme and overrides      │
" │ core highlight groups (Normal, LineNr, CursorLine/Column, Cursor,        │
" │ Visual, Folded, Search, VertSplit, SpecialKey, TabLineSel) to enforce    │
" │ the black background / cyan accent visual identity.                      │
" └──────────────────────────────────────────────────────────────────────────┘
" Use GUI (true-color) highlights in terminal Vim so colors match GVim
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

" ── Markdown: 2 file riêng (dựa trên hughbien/md-vim, BSD) ──────────────────
" Cài bằng cách copy ĐÚNG 2 file (repo gốc không có autoload/ — md#setup()
" nằm ngay trong ftplugin/md.vim):
"   syntax.md.vim   ->  ~/.vim/syntax/md.vim     (bản riêng: chữ thường TRẮNG,
"                       heading/link/code theo palette haoz, đậm/nghiêng là
"                       REGION nên xuống dòng vẫn tô, dòng thụt 4 space vẫn
"                       có syntax, mục list 3 cấp màu theo độ thụt lề)
"   ftplugin.md.vim ->  ~/.vim/ftplugin/md.vim   (bản riêng: sửa lỗi dò biên
"                       bảng của MdFixTable + TỰ FORMAT TOÀN BỘ NỘI DUNG khi
"                       ghi file + indentexpr cho mục con)
" Bảng: cột tính theo strdisplaywidth (tiếng Việt có dấu không lệch cột),
" nhận cả bảng thiếu '|' ở đầu dòng, và TỰ CHÈN dòng phân cách '| --- |'
" nếu bảng viết thiếu (tắt: let g:md_table_guess = 0).
" FOLD của file .md: nằm ở mục FOLDING, dùng 2 hàm NGAY TRONG VIMRC này
" (HaozMdFoldLevel/HaozMdFoldText) -> không phụ thuộc ftplugin/md.vim, và
" không ảnh hưởng fold của Verilog (mỗi filetype setlocal riêng).
" Mặc định khi mở file .md: ĐÓNG HẾT fold (setlocal foldlevel=0) — khác
" foldlevel=99 chung của vimrc.  CHỈ 2 phím, chỉ trong buffer .md:
"   za = toggle fold HIỆN TẠI (lệnh gốc của Vim)
"   zo = toggle TẤT CẢ fold (đang đóng -> mở hết; đang mở hết -> đóng hết)
" Tùy chọn ở vimrc (đặt TRƯỚC khi mở file .md):
"   let g:md_indent_is_code = 0       " 4 space đầu dòng KHÔNG phải code block
"   let g:md_autoformat = 0           " tắt tự format khi ghi file
"   let g:md_trim_trailing_space = 0  " giữ space/tab cuối dòng
"   let g:md_table_guess = 0          " không tự chèn dòng phân cách bảng
" Lệnh trong buffer .md:  :MdFormat  (toàn bộ nội dung)
"                         :MdFormatTable  (chỉ căn bảng)
"                         :MdAutoFormat  (bật/tắt cho buffer đang mở)
" 'au ... setlocal ft=md' là BẮT BUỘC (không có ftdetect/ trong 2 file này).
" setlocal thay vì 'set ft=md': 'set' ghi cả giá trị GLOBAL, làm buffer mới
" không tên cũng bị nhận là md.
filetype plugin on
au BufNewFile,BufRead *.md setlocal ft=md
" KHÔNG gọi md#setup(): hàm đó chỉ tạo 7 mapping leader của plugin (\= \- \l
" \x \t \z \p) — theo yêu cầu, buffer .md chỉ giữ phím fold (za/zo, xem mục
" FOLDING) và các lệnh :MdFormat/:MdFormatTable/:MdAutoFormat bên dưới.
" (conceallevel của plugin được đặt bằng autocmd riêng ở cuối khối này.)

" Ngôn ngữ được tô màu bên trong khối ``` … ``` (plugin tự include syntax).
" Dạng 'ext=ngôn-ngữ' cho fence ghi tắt, ví dụ ```sv.
let g:md_fenced_languages = [
      \ 'systemverilog', 'sv=systemverilog',
      \ 'verilog',       'v=verilog',
      \ 'c', 'cpp', 'python', 'sh', 'tcl', 'make', 'json', 'yaml', 'vim',
      \ ]

" Phím của buffer .md: CHỈ 2 phím fold (za / zo — xem mục FOLDING).
" 7 mapping leader của plugin (\= \- \l \x \t \z \p) đã bỏ theo yêu cầu;
" việc format bảng/list giờ do chế độ tự format đảm nhiệm.
"
" Các lệnh (không cần phím):
"   :MdFormat      format MỌI bảng trong buffer ngay
"   :MdAutoFormat  bật/tắt tự format (mặc định BẬT: format bảng mỗi lần ghi
"                  file và mỗi lần rời Insert khi con trỏ đang trong bảng)

" conceal của plugin cần 'conceallevel' > 0.  Vimrc này chỉ đặt option đó cho
" panel WinList và session picker, nên buffer .md phải đặt riêng; concealcursor
" =nc: ẩn dấu khi ở Normal/Command, hiện lại khi Insert.
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


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                       NETRW ( :Explore ) STYLING                         │
" │ Description: Configures netrw's built-in file explorer (tree-style       │
" │ listing, horizontal size hints) and applies a custom cyan/dark syntax    │
" │ highlight palette (directories, links, executables, hidden files,        │
" │ marks, banner, etc.) re-applied on every colorscheme change.             │
" └──────────────────────────────────────────────────────────────────────────┘
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


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                           CURSOR SHAPE                                   │
" │ Description: Sets distinct cursor shapes per mode in GUI (vertical bar   │
" │ for normal/visual/cmdline, blinking bar for insert, blinking underline   │
" │ for replace). Falls back to terminal escape codes (t_SI/t_EI) for        │
" │ console Vim to switch cursor shape between insert/normal mode.           │
" └──────────────────────────────────────────────────────────────────────────┘
if has('gui_running')
    set guicursor=n-v-c:ver25-blinkon0,i:ver25-blinkon500-blinkoff500,r:hor20-blinkon500-blinkoff500
else
    let &t_SI = "\e[6 q"
    let &t_EI = "\e[2 q"
endif


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                            STATUS LINE                                   │
" │ Description: Custom statusline showing filename (left) and padding       │
" │ (right), plus cursor position as [CL current:TL total] on the right.     │
" │ Dynamically recolors the StatusLine highlight group based on current     │
" │ mode: cyan/dark-blue (Normal), cyan/orange (Insert), cyan/green          │
" │ (Replace) — updated automatically via InsertEnter/Change/Leave.          │
" │ StatusLinePos is linked to StatusLine so the position text always        │
" │ matches the path colour.                                                 │
" └──────────────────────────────────────────────────────────────────────────┘
" Bố cục:  ~/.vimrc            [CL81:TL1793][4sp][md][V7.42]
"   %F   = đường dẫn đầy đủ              (trái, đã có sẵn)
"   %=   = đệm, đẩy phần sau sang phải
"   %l   = dòng hiện tại  (CL = current line)
"   %L   = tổng số dòng   (TL = total lines)
"   %{StatusIndent()}   = indent của buffer, đặt SAU [CL:TL]
"   %{StatusFiletype()} = filetype/syntax của buffer
"   [V…]  = VERSION của chính file .vimrc này, đặt CUỐI
" Thứ tự: [CL:TL][indent][syntax][Vx] — đứng SÁT nhau, không dấu cách.

" ── Version của vimrc (dùng cho statusline) ─────────────────────────────────
" Lấy TỪ CHÍNH header của file này (dòng `Version  : X.Y`) nên mỗi lần bump
" Version chỉ phải sửa header, statusline tự đổi theo.  Đọc tối đa 20 dòng
" đầu của file đang được source (fallback: $MYVIMRC).
let g:haoz_vimrc_version = 'V?'         " dự phòng nếu không đọc được header
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

" ── Indent thật của buffer, hiện NGAY SAU [CL:TL] ───────────────────────────
" Định dạng: <cỡ><tb|sp>  — vd  [4sp]  [8tb]  [mix]
" Không chỉ đọc option mà DÒ NỘI DUNG (N dòng đầu):
"   • đếm số dòng thụt bằng TAB và số dòng thụt bằng DẤU CÁCH
"   • bên nào nhiều hơn thì lấy bên đó; cả hai đều >= 10% -> [mix]
"   • cỡ bước: dấu cách -> gcd các mức thụt gặp được (thường ra 4);
"     tab -> &tabstop; không dò được gì -> theo option của buffer
" Kết quả CACHE theo b:changedtick, nên statusline không quét lại mỗi lần vẽ
" (nếu quét mỗi lần thì file lớn sẽ chậm thấy rõ).
function! s:DetectIndent() abort
    " 400 dòng đầu là quá đủ để biết file thụt bằng tab hay dấu cách; quét ít
    " lại thì mỗi lần gõ (changedtick đổi -> cache mất) không bị khựng.
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
            " gcd của các mức thụt bằng dấu cách
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
        " không có dòng nào thụt -> theo option
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

" Wrapper có cache cho statusline (%{...} gọi hàm này rất thường xuyên).
" PERFORMANCE: khi đang gõ, b:changedtick đổi sau MỖI phím, nên cache theo
" tick không cứu được — bản cũ vẫn quét tới 400 dòng cho mỗi phím để vẽ lại
" statusline.  Trong Insert/Replace giờ chỉ tính lại tối đa 1 lần/giây; rời
" Insert (Enter/ESC) là mode khác nên lần vẽ sau quét lại ngay.
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

" Filetype/syntax hiện trên statusline, sau [CL:TL].
" Lưu ý: '%{...}' chỉ gọi được hàm PUBLIC (không phải s:), giống GuiTitle().
" - Buffer RỖNG (chưa có nội dung) thì hiện [none], kể cả khi filetype chỉ là
"   'log' do autocmd đặt mặc định cho file không rõ loại (augroup autosave).
" - filetype rỗng thì lấy tên syntax đang nạp, không có nữa thì 'none'.
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
" Màu vị trí bám theo StatusLine (giống hệt màu path, kể cả khi đổi
" màu nền theo mode Insert/Replace nhờ DynamicStatusLine).
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


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                           COMMENT SYSTEM                                 │
" │ Description: Filetype-aware line-comment toggling. Detects the correct   │
" │ comment leader (//, #, %, ", ;, >) per filetype/extension and provides   │
" │ CommentLine/UncommentLine/Range helpers. Bound to  cc  in Normal mode    │
" │ (single line) and Visual mode (range) to toggle comment on/off.          │
" └──────────────────────────────────────────────────────────────────────────┘
autocmd FileType c,cpp,java,scala                           let b:comment_leader = '\/\/'
autocmd FileType sh,csh,ruby,python,tcsh                    let b:comment_leader = '#'
autocmd FileType conf,fstab                                 let b:comment_leader = '#'
autocmd FileType tex                                        let b:comment_leader = '%'
autocmd FileType mail                                       let b:comment_leader = '>'
autocmd FileType vim                                        let b:comment_leader = '"'
autocmd FileType nasm                                       let b:comment_leader = ';'
autocmd BufReadPre,FileReadPre *.v,*.sv,*.svh,*.svt         let b:comment_leader = '\/\/'
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


" ┌──────────────────────────────────────────────────────────────────────────┐
" │               TOGGLE 'haozxje' AT END OF LINE  ( hh )                    │
" │ Description: Appends/removes a trailing "<comment_leader>                │
" │ [haozxje-YYYYMMDD-HHMM]" tag at the end of the current line — quick      │
" │ authorship/attention tag toggle. Works in Normal and Visual mode via  hh.│
" └──────────────────────────────────────────────────────────────────────────┘

" ── Timestamp cho mọi tag haozxje: ──────────────────────────────────────────
" Định dạng YYYYMMDD-HHMM, tương đương `date "+%Y%m%d-%H%M"` của shell.
" VD:  [haozxje-20261118-1136] lý do ngắn gọn
function! HaozTimestamp() abort
    return strftime('%Y%m%d-%H%M')
endfunction

" ── Tên tag comment ─────────────────────────────────────────────────────────
" Đổi tên tag chỉ cần sửa 2 biến dưới đây — mọi chỗ chèn tag và mọi pattern
" nhận diện đều lấy từ chúng.
" s:haoz_tag_legacy: các tên CŨ vẫn được nhận diện khi TẮT comment, để những
" dòng đã ghi trước khi đổi tên (vd "// haoz: ...") vẫn toggle off được.
let s:haoz_tag        = 'haozxje'
let s:haoz_tag_legacy = ['haoz']

" Chuỗi tag dùng để CHÈN: "[haozxje-YYYYMMDD-HHMM] " (có 1 space ở cuối
" để gõ tiếp lý do).  Gom vào một hàm để mọi chỗ chèn đều ra cùng format.
function! s:HaozTagText() abort
    return '[' . s:haoz_tag . '-' . HaozTimestamp() . '] '
endfunction

" Pattern (ordinary magic) khớp tag NGAY SAU comment leader, gồm 2 dạng:
"   dạng MỚI : [haozxje-YYYYMMDD-HHMM]        (dạng đang dùng)
"   dạng CŨ  : haozxje:  /  haoz:  /  haoz: [YYYYMMDD-HHMM]
" Các dạng cũ vẫn được nhận để những dòng đã ghi trước đây còn tắt/bỏ được.
" Trả về pattern dùng lại được cho cả =~ , !~ và substitute(), nên không phải
" viết pattern hai lần ở mỗi hàm.
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
    " Khớp tag + timestamp + phần lý do phía sau tới hết dòng: tag nằm cuối
    " dòng nên mọi thứ sau nó đều thuộc comment -> tắt là xoá sạch.
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


" ┌──────────────────────────────────────────────────────────────────────────┐
" │             TOGGLE 'haozxje' AT BEGINNING OF LINE  ( ch )                │
" │ Description: Inserts/removes a leading "<comment_leader>                 │
" │ [haozxje-YYYYMMDD-HHMM]" marker right after the indentation, before      │
" │ actual code/text. Supports single-line ( ch  Normal mode) and            │
" │ multi-line range toggling (Visual mode).                                 │
" └──────────────────────────────────────────────────────────────────────────┘
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


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                       CHÈN CÂU MẪU (dd / dm — GVim)                      │
" │ Description: dd = chèn NGAY câu đầu tiên; dm = hiện menu chọn câu rồi    │
" │ Enter để chèn.  Câu được chèn thành DÒNG MỚI NGAY DƯỚI dòng con trỏ và   │
" │ con trỏ nhảy xuống dòng vừa chèn; các dòng khác không bị sửa ký tự nào.  │
" │ Phím dd/dm nằm trong .gvimrc (ở đó 'd' đã bị disable nên không đụng gì;  │
" │ <S-Del> vẫn xoá dòng vì mapping đó dùng 'noremap').                      │
" └──────────────────────────────────────────────────────────────────────────┘
" Danh sách câu mẫu: sửa trực tiếp ở đây, hoặc :SentenceAdd <câu> trong phiên
" làm việc.  dd luôn chèn câu ĐẦU TIÊN (g:haoz_sentences[0]).
let g:haoz_sentences = get(g:, 'haoz_sentences', [
    \ '$display("[haozxje][%t][%6d][x] - ", $realtime, `__LINE__ );',
    \ ])

" Chèn a:text thành dòng MỚI ngay dưới dòng con trỏ, con trỏ xuống dòng đó.
" Dòng mới LẤY ĐÚNG LỀ của dòng đang đứng (space/tab như file), nên câu chèn
" vào thẳng hàng với code xung quanh.
"
" VÌ SAO KHÔNG dùng ':put =string(text)':  ':execute' chạy chuỗi đó như một
" DÒNG LỆNH Ex, mà dấu '"' trong câu (vd  $display("...  ) bị Vim hiểu là
" BẮT ĐẦU COMMENT -> lệnh bị cắt ngay tại đó, biểu thức thành thiếu dấu đóng:
"     Insert failed: Vim(put):E115: Missing quote: '$display(
" Đó chính là lỗi với câu $display(...) có ngoặc kép.
" => Dùng append(): hàm Vimscript, không qua parser của Ex, nên mọi ký tự
"    " | ` \ % đều an toàn; sau đó tự đưa con trỏ xuống dòng vừa chèn.
" append() không đụng thanh ghi nào (không phá yank/paste); 1 lần 'u' là xoá
" lại đúng dòng vừa chèn.
function! HaozInsertSentenceLine(text) abort
    if a:text ==# ''
        echo 'Sentence is empty - nothing inserted'
        return
    endif
    if !&modifiable || &readonly
        echo 'Buffer is not writable (readonly / nomodifiable)'
        return
    endif
    " Lề của DÒNG HIỆN TẠI: chép nguyên phần thụt đầu dòng (space/tab y như
    " file đang dùng) rồi ghép vào đầu câu, để dòng chèn vào thẳng hàng với
    " code xung quanh.  Câu trong g:haoz_sentences không cần chứa lề.
    let l:indent = matchstr(getline('.'), '^\s*')
    let l:text   = l:indent . substitute(a:text, '^\s\+', '', '')
    try
        call append(line('.'), l:text)
    catch
        echo 'Insert failed: ' . v:exception
        return
    endtry
    " Con trỏ xuống dòng vừa chèn, đặt ở ký tự đầu tiên của câu (sau lề).
    call cursor(line('.') + 1, strlen(l:indent) + 1)
    " 'zv': mở vừa đủ fold để lộ dòng con trỏ — .sv mở với foldlevel=3, .md
    " với 0, nên dòng mới có thể nằm trong fold đang đóng.
    silent! normal! zv
    " lazyredraw đang bật -> phải redraw thì dòng mới hiện ra ngay.
    silent! redraw
    echo 'Sentence inserted (line ' . line('.') . ', press u to undo)'
endfunction

" Menu chọn câu: GVim dùng popup_menu (↑↓ hoặc click chuột, Enter = chèn,
" Esc = huỷ); nơi không có popup_menu thì dùng inputlist (gõ số).
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

" idx = 1..N (popup_menu/inputlist đều đếm từ 1), -1 = huỷ.
function! HaozSentenceMenuPick(idx) abort
    if a:idx < 1 || a:idx > len(g:haoz_sentences)
        return
    endif
    call HaozInsertSentenceLine(g:haoz_sentences[a:idx - 1])
endfunction

" Thêm câu trong phiên làm việc hiện tại (muốn giữ lâu dài thì sửa list trên):
command! -nargs=+ SentenceAdd  call add(g:haoz_sentences, <q-args>)
command! -nargs=0 SentenceList echo join(map(copy(g:haoz_sentences),
    \ 'v:key + 1 . ". " . v:val'), "\n")
" :SentenceShow  -> in ra dạng ESCAPE (string()) của từng câu: thấy rõ từng
" space, từng dấu ` " \ nên kiểm tra "đúng từng ký tự" được ngay trong Vim.
command! -nargs=0 SentenceShow echo join(map(copy(g:haoz_sentences),
    \ 'v:key + 1 . ". " . string(v:val)'), "\n")


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                             AUTO SAVE                                    │
" │ Description: Automatically saves the buffer whenever text changes or     │
" │ insert mode is left (if the buffer is modifiable). Also defaults an      │
" │ unset filetype to 'log' on read — useful for arbitrary/extension-less    │
" │ log files.                                                               │
" └──────────────────────────────────────────────────────────────────────────┘
" ── PERFORMANCE ─────────────────────────────────────────────────────────────
" Bản cũ: `autocmd TextChanged,InsertLeave * if &modified | silent write`.
" TextChanged bắn ra sau MỖI lệnh sửa ở Normal mode (x, dd, p, J, u, …), nên
" mỗi phím = 1 lần ghi đĩa thật + ghi swap + BufWritePost + WinList dựng lại.
" Trên NFS (/nobackup) mỗi lần ghi mất vài ms -> gõ phím thấy khựng.
" Bản mới: hoãn ghi 800ms (gộp nhiều lần sửa thành 1 lần ghi), vẫn ghi NGAY
" khi rời Insert và khi thoát Vim nên không mất dữ liệu.
" Đổi độ trễ: let g:autosave_delay = 1500
augroup autosave
    autocmd!
    autocmd BufRead      * if &filetype == "" | setlocal ft=log | endif
    autocmd TextChanged  * call s:AutoSaveSchedule()
    " Ghi NGAY ở các mốc an toàn: rời Insert, rời buffer (chuyển file/tab/split
    " — để buffer vừa sửa không bị bỏ lại chưa ghi), mất focus cửa sổ GVim, và
    " thoát Vim.  Nhờ vậy việc hoãn 800ms ở TextChanged không thể mất dữ liệu.
    autocmd InsertLeave  * call s:AutoSaveNow()
    autocmd BufLeave     * call s:AutoSaveNow()
    autocmd FocusLost    * call s:AutoSaveNow()
    autocmd VimLeavePre  * call s:AutoSaveNow()
augroup END

let s:autosave_timer = -1

" Chỉ ghi buffer thật sự ghi được: có tên, buftype rỗng, đang sửa, không RO.
" (Bản cũ gọi 'write' cả trên buffer [No Name]/nofile -> E32 bị silent! nuốt,
" nhưng vẫn tốn một lần gọi :write.)
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
    " Đang gõ dở (Insert/Replace) thì để InsertLeave lo, không hẹn ghi.
    if mode() =~# '^[iR]'
        return
    endif
    if s:autosave_timer != -1
        call timer_stop(s:autosave_timer)
    endif
    let s:autosave_timer = timer_start(get(g:, 'autosave_delay', 800),
        \ {-> s:AutoSaveNow()})
endfunction


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                          BASIC KEYBINDINGS                               │
" │ Description: Miscellaneous general-purpose keymaps — new tab (Ctrl-N),   │
" │ vertical split + focus (Ctrl-\), reload file (F5), copy full path        │
" │ (F12), select-all (Ctrl-A), clear search highlight (Shift-L), and        │
" │ Ctrl-L remapped to start Visual mode (Normal/Insert).                    │
" └──────────────────────────────────────────────────────────────────────────┘
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


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                          COPY / PASTE / CUT                              │
" │ Description: System-clipboard ("+  register) bindings for standard       │
" │ Ctrl-C / Ctrl-V / Ctrl-X behavior across Normal, Visual, Insert, and     │
" │ Command-line modes — mimics conventional OS clipboard shortcuts.         │
" └──────────────────────────────────────────────────────────────────────────┘
" Without +clipboard, bridge to the system clipboard via an external tool
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

" Send the unnamed register (just yanked/deleted) to the system clipboard
function! ClipPush() abort
    let l:tools = s:ClipTools()
    if !empty(l:tools)
        silent call system(l:tools[0] . ' >/dev/null 2>&1', @")
    endif
endfunction

" Load the system clipboard into the unnamed register; returns '' for <C-r>=
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

" Terminal Vim: avoid auto-indent staircase when pasting via the terminal
if !has('gui_running')
    set pastetoggle=<F2>
endif


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                       VISUAL MODE AND SELECTION                          │
" │ Description: Remaps  V  to enter blockwise-visual (Ctrl-V default)       │
" │ instead of linewise-visual. Ctrl-D selects/searches the word under       │
" │ cursor (Normal/Insert); Ctrl-F sets the search register to the word      │
" │ under cursor or the visually selected text and enables highlighting.     │
" └──────────────────────────────────────────────────────────────────────────┘
nnoremap V <C-v>

nnoremap <C-d> :let @/='\<'.expand('<cword>').'\>'<CR>viw
inoremap <C-d> <Esc>viw

nnoremap <C-f> :let @/ = '\<'.expand('<cword>').'\>'<CR>:set hlsearch<CR>
vnoremap <C-f> "zy:let @/ = escape(@z, '/\')<CR>:set hlsearch<CR>


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                        SHIFT ARROW SELECTION                             │
" │ Description: Standard "Shift+Arrow" text selection behavior familiar     │
" │ from GUI editors — extends/starts a Visual selection in Insert,          │
" │ Visual, and Normal mode using Shift+Arrow/Home/End. Ctrl-Shift-Arrow     │
" │ extends selection by word (Insert mode).                                 │
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
" │ Description: Ctrl+Left/Right jumps by word (Normal/Visual/Insert);       │
" │ Ctrl+Shift+Left/Right extends selection by word.                         │
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
" │ Description: Ctrl+Up / Ctrl+Down switch to previous/next tab.            │
" └──────────────────────────────────────────────────────────────────────────┘
nnoremap <C-Up>   :tabprevious<CR>
nnoremap <C-Down> :tabnext<CR>


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                  SPLIT WINDOW NAVIGATION (ALT LEFT/RIGHT)                │
" │ Description: Alt+Left / Alt+Right cycle focus between real (non-panel)   │
" │ editing splits horizontally, automatically skipping over the WinList     │
" │ and NERDTree panel windows and wrapping around at the edges.             │
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
" │ Description: Pressing a number key (1-9, 0 for tab 10) in Normal mode    │
" │ jumps directly to that tab index, if it exists.                          │
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
" │ Description: Home key jumps to first non-blank character (^) instead     │
" │ of column 0, in both Normal and Insert mode.                             │
" └──────────────────────────────────────────────────────────────────────────┘
inoremap <Home> <C-o>^
nnoremap <Home> ^


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                       TAB / SHIFT-TAB INDENTATION                        │
" │ Description: Custom indent-aware Tab/Shift-Tab handling. In Normal       │
" │ mode (currently commented-out bindings), Tab increases indent to the     │
" │ next multiple of shiftwidth (or inserts a literal tab if past            │
" │ leading whitespace); Shift-Tab dedents. In Visual mode, Tab/Shift-Tab    │
" │ indent/dedent the whole selection by shiftwidth (active bindings).       │
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

" nnoremap <silent> <Tab>   :call NormalModeTab()<CR>
" nnoremap <silent> <S-Tab> :call NormalModeShiftTab()<CR>
vnoremap <silent> <Tab>   :<C-u>call VisualModeTab()<CR>gv
vnoremap <silent> <S-Tab> :<C-u>call VisualModeShiftTab()<CR>gv


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                                UNDO                                      │
" │ Description: Ctrl-Z triggers undo from Normal, Insert, and Visual mode.  │
" └──────────────────────────────────────────────────────────────────────────┘
nnoremap <C-z> u
inoremap <C-z> <C-o>u
vnoremap <C-z> <Esc>u


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                            DELETE LINE                                   │
" │ Description: Shift-Delete deletes the current line (like  dd ).          │
" └──────────────────────────────────────────────────────────────────────────┘
nnoremap <S-Del> dd


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                            TOGGLE CASE                                   │
" │ Description: Ctrl-U toggles case of the word under cursor (Normal) or    │
" │ the selected text (Visual), using  g~ .                                  │
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
" │ Description: n / N (next/prev search match) additionally re-center       │
" │ the view (zz) after jumping.                                             │
" └──────────────────────────────────────────────────────────────────────────┘
nnoremap n nzz
nnoremap N Nzz


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                          TOGGLE LINE WRAP                                │
" │ Description: Alt-Z toggles soft line-wrap.  MẶC ĐỊNH = WRAP BẬT cho mọi  │
" │ buffer file (xem BASIC SETTINGS); panel WinList/picker luôn nowrap.      │
" └──────────────────────────────────────────────────────────────────────────┘
nnoremap <M-z> :set wrap!<CR>


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                        DISABLE PROBLEMATIC KEYS                          │
" │ Description: Disables  x  (char delete), <Del>, and  o  (open new line   │
" │ below) in Normal mode to prevent accidental deletions / stray lines.     │
" │ Dùng thay thế: xoá dòng `S-Del`, mở dòng mới `O` (phía trên) hoặc        │
" │ `:call append(line('.'), '')` (phía dưới).                               │
" │ Insert/Visual mode KHÔNG bị ảnh hưởng.                                   │
" └──────────────────────────────────────────────────────────────────────────┘
nnoremap x     <Nop>
nnoremap <Del> <Nop>
nnoremap o     <Nop>


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                              FOLDING                                     │
" │ Description: indent-fold for Verilog/SystemVerilog (*.v, *.sv, *.svt)    │
" │ with foldlevel=3 (đọc được tổng quan), header-fold for Markdown (*.md)   │
" │ with foldlevel=0 (đóng hết); phím fold RIÊNG cho từng loại buffer; và    │
" │ loads matchit.vim for % (matching pairs) navigation.                     │
" └──────────────────────────────────────────────────────────────────────────┘
" Phím fold, tất cả đều là mapping <buffer> (chỉ buffer đang mở) và lệnh gốc
" của Vim KHÔNG bị đổi ở nơi khác:
"   za   toggle fold HIỆN TẠI                        (có sẵn của Vim)
"   zo   toggle TẤT CẢ fold của file                 (map, mọi buffer có fold)
"   zA   toggle fold hiện tại + TOÀN BỘ node con     (map, chỉ file .sv)
augroup filtype_verilog
    autocmd!
    autocmd FileType Verilog,verilog_systemverilog call HaozSvFoldSetup()
    autocmd BufNewFile,BufRead *.v,*.sv,*.svh,*.svt call HaozSvFoldSetup()
    autocmd FileType md call HaozMdFoldSetup()
augroup END

" Fold cho buffer Verilog/SystemVerilog: Vim tự fold theo độ THỤT LỀ.
" foldlevel=3 -> các khối lồng tới cấp 3 vẫn mở, sâu hơn mới đóng, nên mở
" file ra là đọc được tổng quan cấu trúc.
function! HaozSvFoldSetup() abort
    setlocal foldmethod=indent
    setlocal foldenable
    setlocal foldlevel=3
    " Mức "đã fold tất cả" của file .sv = 3 (vẫn thấy 3 cấp đầu để đọc tổng
    " quan).  'zo' đóng về đúng mức này, không đóng xuống 0.
    let b:haoz_fold_home = 3
    nnoremap <buffer> <silent> zo :<C-U>call HaozFoldToggleAll()<CR>
    nnoremap <buffer> <silent> zA :<C-U>call HaozFoldToggleRecursive()<CR>
endfunction

" Đặt fold + phím fold CHỈ cho buffer markdown (buffer-local mapping nên
" không ảnh hưởng .sv/.v hay buffer khác).
function! HaozMdFoldSetup() abort
    setlocal foldmethod=expr
    setlocal foldexpr=HaozMdFoldLevel(v:lnum)
    setlocal foldtext=HaozMdFoldText()
    setlocal foldenable
    setlocal foldlevel=0            " mặc định: ĐÓNG tất cả khi mở file
    let b:haoz_fold_home = 0        " md: 'zo' đóng về 0 = đóng hết
    nnoremap <buffer> <silent> zo :<C-U>call HaozFoldToggleAll()<CR>
endfunction
" (za của buffer .md là lệnh gốc của Vim — không map.)

" Fold cho markdown: 'foldmethod=expr' gọi hàm này cho TỪNG dòng và hỏi
" "dòng này thuộc fold cấp mấy":
"   '>N' = mở fold cấp N tại dòng này (dòng tiêu đề cấp N)
"   '='  = cùng cấp với dòng phía trên -> dòng thân nằm trong fold của tiêu
"          đề gần nhất phía trên
" Nhận: front-matter '--- … ---' ở đầu file, tiêu đề ATX ('#', '##', …) và
" setext (dòng dưới là '===' hoặc '---').  Đường kẻ ngang đứng một mình
" ('===', '---', '***', '___' ở mục "Separators") KHÔNG bị coi là tiêu đề.
function! HaozMdFoldLevel(lnum) abort
    let l:line = getline(a:lnum)

    " 1) front-matter YAML ở đầu file -> cả khối là MỘT fold cấp 1
    "    (chỉ xét 200 dòng đầu cho rẻ; front-matter luôn nằm ở đầu file)
    if a:lnum <= 202 && getline(1) =~# '^---\s*$'
        let l:end = 0
        let l:i = 2
        while l:i <= line('$') && l:i <= 200
            if getline(l:i) =~# '^---\s*$'
                let l:end = l:i
                break
            endif
            let l:i = l:i + 1
        endwhile
        if l:end > 0
            if a:lnum == 1
                return '>1'
            elseif a:lnum <= l:end
                return '1'
            elseif a:lnum == l:end + 1
                return '0'  " dòng ngay sau front-matter: đóng fold
            endif
        endif
    endif

    " 2) đường kẻ ngang (cũng là gạch dưới của setext) -> không mở fold
    if l:line =~# '^\%(=\+\|-\+\|\*\*\*\+\|___\+\)\s*$'
        return '='
    endif

    " 3) tiêu đề ATX: số dấu # = cấp fold
    if l:line =~# '^#\{1,6}\s'
        return '>' . strlen(matchstr(l:line, '^#*'))
    endif

    " 4) tiêu đề setext: dòng kế tiếp là '===' (h1) hoặc '---' (h2)
    let l:next = getline(a:lnum + 1)
    if l:next =~# '^=\+\s*$'
        return '>1'
    elseif l:next =~# '^-\+\s*$' && l:line =~# '^\S' && l:line !~# '^[|#>]'
        return '>2'
    endif
    return '='
endfunction

" Chữ hiện trên dòng fold đang đóng: bỏ dấu # cho gọn, kèm số dòng.
function! HaozMdFoldText() abort
    let l:line = getline(v:foldstart)
    if l:line =~# '^---\s*$'
        let l:title = '[front-matter]'      " khối --- … --- ở đầu file
    else
        let l:title = substitute(l:line, '^#\+\s*', '', '')
        if empty(l:title)
            let l:title = l:line
        endif
    endif
    return '▸ ' . l:title . '  ⋯ ' . (v:foldend - v:foldstart + 1) . ' dòng '
endfunction

" 'zA' = TOGGLE ĐỆ QUY: fold dưới con trỏ + TOÀN BỘ node con.
" Vim có zo (mở 1 cấp), zO (mở hết cả cây con), zC (đóng hết cả cây con) —
" nhưng không có toggle đệ quy.  Ở đây:
"   • fold đang đóng (hoặc còn node con đang đóng) -> MỞ hết  (zO)
"   • fold đang mở hết                              -> ĐÓNG hết (zC)
" Muốn biết "còn node con nào đóng không" thì phải biết PHẠM VI fold hiện tại,
" mà Vim chỉ cho biết phạm vi khi fold đang ĐÓNG (foldclosed/foldclosedend) —
" nên: ghi lại các fold đang đóng, đóng thử fold hiện tại để lấy phạm vi, rồi
" quyết định mở lại hay giữ đóng.
function! HaozFoldToggleRecursive() abort
    if foldlevel('.') == 0
        return          " dòng này không nằm trong fold nào
    endif
    if foldclosed('.') != -1
        normal! zO      " đang đóng -> mở hết cả cây con
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
            normal! zO  " bên trong còn node đóng -> người dùng muốn mở hết
            return
        endif
    endfor
    " trước đó mở hết -> giữ đóng (zc vừa đóng cả cây con)
endfunction

" 'zo' = TOGGLE TẤT CẢ fold của file (map cho buffer .md và .sv).
" Vim gốc chỉ có một chiều: zR = mở hết, zM = đóng hết.
" Ở đây hai trạng thái là "mở hết" <-> "gập về mức home" (b:haoz_fold_home,
" đặt trong HaozSvFoldSetup / HaozMdFoldSetup):
"   • .sv  -> 3 : gập tới cấp 3, vẫn thấy 3 cấp đầu để đọc tổng quan
"                 (không gập xuống 0)
"   • .md  -> 0 : gập hết
" Chiều toggle: đang ở mức home mà còn fold đóng (hoặc mới mở file) -> MỞ hết;
" còn lại -> GẬP về mức home.  (za vẫn là toggle 1 fold của Vim.)
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
        normal! zR                      " đang là trạng thái "đã gập" -> mở hết
    else
        let &l:foldlevel = l:home       " đang mở -> gập về đúng mức home
    endif
endfunction

runtime macros/matchit.vim

" ── Markdown: bỏ highlight lỗi của syntax mặc định ──────────────────────────
" Vim tô đỏ (markdownError) các dòng markdown mà bộ syntax coi là sai —
" ví dụ khối code không có ngôn ngữ, đường dẫn Windows, bảng thiếu cột.
" Không phải lỗi thật nên tắt hẳn nhóm highlight đó.
" Lưu ý: phải dùng 'hi! link ... NONE' (không phải 'highlight clear') để
" giữ nguyên các nhóm markdown khác; và chạy sau khi syntax đã nạp nên
" đặt trong FileType (và lặp lại ở Syntax nếu filetype đổi muộn).
augroup markdown_fix
    autocmd!
    " 'markdown' (mặc định Vim) VÀ 'md' (*.md, đặt ở BASIC SETTINGS)
    autocmd FileType markdown,md hi! link markdownError NONE
augroup END


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                            INDENT LINE                                   │
" │ Description: Configuration for the indentLine plugin — sets guide        │
" │ character (┆) and its color to match the dark/cyan theme.                │
" └──────────────────────────────────────────────────────────────────────────┘
let g:indentLine_color_gui = '#0055aa'
let g:indentLine_char      = '┆'


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                           VIM BOOKMARK                                   │
" │ Description: Configuration for the vim-bookmark plugin — highlights      │
" │ bookmarked lines/signs in the theme's dark-blue/cyan palette, sets       │
" │ bookmark sign glyph ("==") and enables auto-centering on jump.           │
" └──────────────────────────────────────────────────────────────────────────┘
let g:bookmark_highlight_lines = 1
highlight BookmarkLine ctermbg=17 guibg=#001933
highlight BookmarkSign ctermbg=17 guibg=#001933 guifg=#00ffff
let g:bookmark_sign   = '=='
let g:bookmark_center = 1


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                          GVIM GUI SETTINGS                               │
" │ Description: Hides GUI menu bar and toolbar by default. F10 toggles      │
" │ menu+toolbar visibility on/off manually. Also builds the window title    │
" │ from the CURRENT CONTENT window — focusing the WinList/NERDTree panel    │
" │ no longer changes the title to "__WindowList__".                         │
" └──────────────────────────────────────────────────────────────────────────┘
if has('gui_running')
    set guioptions-=mT
endif

" Title = tên file thật của cửa sổ nội dung đang hoạt động.
" Mặc định Vim dùng tên buffer của cửa sổ đang focus, nên khi focus vào
" panel WinList thì title thành "__WindowList__" — đây là lỗi đã sửa.
set title
set titleold=
" %{...} trong titlestring chỉ gọi được hàm public (không phải s:).
function! GuiTitle() abort
    " tabs: số tab đang mở, để giữ thông tin như title mặc định của Vim
    let l:ntabs = tabpagenr('$')

    " tìm cửa sổ nội dung: ưu tiên cửa sổ focus nếu nó không phải panel
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

    " tab hiện tại / tổng số tab — giống kiểu title mặc định
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


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                             DIFF MODE                                    │
" │ Description: Custom diff highlight colors (add/change/delete/text) for   │
" │ both dark and light backgrounds, re-applied on colorscheme change.       │
" │ In diff mode: dn/db jump next/prev change, df ("diff-fix") applies       │
" │ :diffput (dp) to push the change across. Also auto-unfolds all diff      │
" │ windows on startup so changes are immediately visible.                   │
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
" │ Description: Restores cursor to last-known position when reopening a     │
" │ file, and disables auto-comment continuation (formatoptions c/r/o) so    │
" │ new lines don't inherit comment leaders automatically.                   │
" └──────────────────────────────────────────────────────────────────────────┘
if has("autocmd")
    au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
endif

autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                 SIDE PANEL (WinList always-on + NERDTree)                │
" │ Description: Global state/config for the side panel.  WinList is a       │
" │ persistent left-hand column listing every tab/window — it is ALWAYS on   │
" │ and stays consistent across all tabs.  NERDTree is on-demand only:       │
" │ Ctrl-B toggles it, and when open it takes the bottom half of the same    │
" │ column (WinList top / NERDTree bottom, 50/50).  Ctrl-O hides both while  │
" │ netrw is open.  Includes width/height constants + state flags.           │
" └──────────────────────────────────────────────────────────────────────────┘

" ── Panel dimensions ────────────────────────────────────────────────────────
" Width cố định 50 cột; min 15, max 50.  Dùng hàm s:PanelWidth() bên dưới
" để mọi chỗ resize đều bị kẹp trong [min,max] — trước đây min/max khai
" báo nhưng KHÔNG chỗ nào đọc, nên panel có thể bị nới rộng tuỳ ý.
let g:winlist_min_width    = 15
let g:winlist_max_width    = 50
let g:winlist_padding      = 2
let g:winlist_width        = 50

let NERDTreeShowHidden     = 1
let g:NERDTreeWinPos       = "left"
let g:NERDTreeWinSize      = 50

" WinList luôn hiển thị ở mọi tab; NERDTree chỉ bật/tắt bằng Ctrl-B
let g:winlist_always       = 1

" Trạng thái netrw của Ctrl-O.  Ctrl-O không ẩn panel / không resize gì cả,
" nên KHÔNG cần nhớ layout để dựng lại — chỉ cần các biến dưới đây.
" g:netrw_expanding      : 1 trong lúc đang xem netrw -> tạm tắt auto-close tab
"                          và các lần refresh/dựng lại panel.
" g:netrw_explore_active : 1 = phiên Ctrl-O đang mở (để SmartCtrlORestore()
"                          bỏ qua những lần rời netrw không do Ctrl-O tạo ra).
" g:netrw_back_buf/path  : buffer (và đường dẫn dự phòng) đã xem NGAY TRƯỚC khi
"                          mở netrw — Ctrl-O lần 2 sẽ quay lại đúng chỗ này.
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
" (g:netrw_expanding / g:netrw_explore_active khai báo ở trên, cùng cụm với
"  trạng thái Ctrl-O)


" ── Helper: compute half-screen height for WinList panel ────────────────────
function! WinListHalfHeight() abort
    let l:total = &lines - 2
    return max([5, l:total / 2])
endfunction


" ════════════════════════════════════════════════════════════════════════════
"  TAB ID SYSTEM — stable IDs that survive drag-reorder
"  Description: Assigns each tab a unique, stable string ID (independent
"  of its numeric position) so WinList jump-targets remain valid even
"  after tabs are reordered/dragged.
" ════════════════════════════════════════════════════════════════════════════

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


" ════════════════════════════════════════════════════════════════════════════
"  HELPER FUNCTIONS
"  Description: Buffer/window classification helpers used throughout the
"  panel system — detect if a buffer/window is the WinList panel,
"  NERDTree, or any "special" (non-editable) window, and locate the
"  nearest normal editing window.
" ════════════════════════════════════════════════════════════════════════════

function! WinListBufName(...) abort
    return '__WindowList__'
endfunction

" Width thực tế của panel, đã kẹp trong [g:winlist_min_width, g:winlist_max_width].
" Không bao giờ vượt quá nửa màn hình: panel rộng hơn nửa thì cửa sổ soạn
" thảo còn < 50% và không đọc được code.
function! s:PanelWidth() abort
    let l:w = g:winlist_width
    let l:w = max([l:w, g:winlist_min_width])
    let l:w = min([l:w, g:winlist_max_width])
    let l:w = min([l:w, max([g:winlist_min_width, &columns / 2])])
    return l:w
endfunction

" Trả về BUFFER NUMBER của cửa sổ NỘI DUNG đang hoạt động trong tab hiện
" tại.  Dùng bufnr chứ không dùng winnr: winnr thay đổi khi tách/đóng
" split hoặc khi panel chen vào, còn bufnr thì ổn định — đây chính là
" nguồn gốc bug marker '>' chỉ sai dòng trước đây.
" - Focus đang ở cửa sổ nội dung  -> bufnr của nó
" - Focus đang ở panel           -> bufnr đã nhớ trong g:winlist_last_active
" - Không có gì hợp lệ           -> -1
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

" Như WinListFindNormalWin(), nhưng CHẤP NHẬN netrw làm cửa sổ tựa.
" netrw có buftype=nofile nên bị WinListIsSpecial() coi là special — nếu
" dùng FindNormalWin() ở đây sẽ trả -1 và code gọi enew, đè mất netrw.
function! WinListFindAnchorWin() abort
    " ưu tiên cửa sổ soạn thảo thật
    let l:w = WinListFindNormalWin()
    if l:w != -1 | return l:w | endif
    " không có -> lấy cửa sổ netrw nếu đang mở
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

" Panel có hiển thị ở BẤT KỲ tab nào không.  Buffer WinList là MỘT buffer dùng
" chung cho mọi tab, nên chỉ cần nó hiện ở đâu đó là nội dung phải đúng; còn
" nếu không hiện ở đâu thì không cần dựng lại nội dung (đây là phần đắt nhất).
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


" ════════════════════════════════════════════════════════════════════════════
"  AUTO-CLOSE TAB WHEN ONLY PANEL REMAINS
"  Description: If a tab's only remaining windows are the WinList/NERDTree
"  panel (no real file buffer left), automatically closes that tab (or
"  quits Vim if it's the last tab) after a short debounce delay.
" ════════════════════════════════════════════════════════════════════════════

" Tab này có chứa buffer session picker không?  Picker là buffer nofile nên bị
" tính là "không phải cửa sổ thật" -> nếu không loại trừ, tab picker vừa mở
" sẽ bị auto-close đóng lại sau ~200ms.
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
    " Đang xem netrw bằng Ctrl-O: panel bị ẩn và buffer netrw là nofile nên
    " "số cửa sổ thật" có thể bằng 0 — không được đóng tab lúc này.
    if get(g:, 'netrw_expanding', 0) | return | endif
    " Tab đang hiện session picker: coi như có nội dung
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
    " tab đang hiện session picker (buffer nofile) -> coi như có nội dung
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


" ════════════════════════════════════════════════════════════════════════════
"  WIDTH MANAGEMENT  (panel-open time + manual only)
"  Description: Locks/unlocks winfixwidth on real editing splits so panel
"  open/resize operations don't disturb user split widths. Provides
"  manual-only width sync (WinListFixWidth) and NERDTree width sync
"  (SyncNERDTreeWidth) — never triggered automatically during normal edits.
" ════════════════════════════════════════════════════════════════════════════

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

" ── Manual-only: <leader>W or :WinListFix ───────────────────────────────────
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

" ── Manual-only: <leader>wh or :WinListFixH ─────────────────────────────────
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


" ════════════════════════════════════════════════════════════════════════════
"  WINLIST CONTENT
"  Description: Builds the textual content of the WinList panel buffer —
"  one section per tab (with split count + active marker), listing each
"  editable window's filename, modified flag, and shortened directory path.
" ════════════════════════════════════════════════════════════════════════════

" Rút gọn đường dẫn thư mục để hiện dưới mỗi entry.  PERFORMANCE: kết quả
" được cache theo đường dẫn — panel được dựng lại rất nhiều lần nhưng cùng
" một thư mục thì luôn ra cùng một chuỗi, nên không cần split/join lại.
" Cache tự xoá khi vượt 500 mục (đường dẫn đổi liên tục thì cũng không phình).
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

" Bề ngang text thực tế của buffer WinList (đã trừ cột number), dùng để đệm
" space cho dòng entry đang active nhằm phủ kín cả hàng bằng guibg.
" Không có cửa sổ WinList (đang dựng panel) -> lấy theo bề rộng cấu hình.
function! s:WinListTextWidth() abort
    let l:wnr = bufwinnr(WinListBufName())
    if l:wnr == -1
        return max([10, s:PanelWidth() - 1])
    endif
    let l:w = winwidth(l:wnr)
    " Cột number chiếm 'numberwidth' cột + 1 dấu cách phân cách.  Lưu ý: với
    " buffer winlist, augroup WinListBufSettings đặt 'nonumber' (FileType
    " winlist bắn ra sau 'setlocal number' trong s:SetupWinListWindow), nên
    " thực tế cột này KHÔNG tồn tại — chỉ trừ khi 'number' thật sự đang bật.
    " Đệm dư 1-2 cột là vô hại (nowrap nên phần thừa bị cắt), đệm thiếu thì
    " thanh nền bị hụt so với mép panel.
    if getwinvar(l:wnr, '&number')
        let l:w -= str2nr(getwinvar(l:wnr, '&numberwidth')) + 1
    endif
    return max([10, l:w])
endfunction

function! WinListBuildAllTabLines() abort
    let l:cur_tab = tabpagenr()
    let l:lines   = []
    " Tính bề ngang panel MỘT lần cho cả lần dựng (bản cũ gọi lại cho từng
    " dòng active -> mỗi lần là bufwinnr + winwidth + getwinvar).
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

        " Xác định cửa sổ đang hoạt động bằng BUFFER NUMBER, không dùng index.
        " Bug cũ: code so sánh raw_idx (vị trí trong tabpagebuflist) với
        " g:winlist_last_active (vốn là winnr). Hai đại lượng khác hệ quy
        " chiếu, nên khi thứ tự buffer trong tab khác thứ tự cửa sổ (rất hay
        " xảy ra sau khi tách/mở nhiều split) marker '>' chỉ sai dòng.
        if l:t == l:cur_tab
            let l:active_buf = s:CurrentContentBuf()
        else
            " tab khác: dùng buffer đã nhớ (g:winlist_last_active lưu BUFFER
            " NUMBER, xem WinListRefreshAllTabs)
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

            " Đệm space cho hết bề ngang panel CHỈ ở dòng entry đang active.
            " Lý do: guibg của syntax chỉ tô phần có ký tự, nên nếu không đệm
            " thì thanh nền xanh chỉ dài bằng tên file, không phủ hết hàng.
            " Buffer WinList đặt 'nowrap' nên phần đệm dư không bao giờ xuống
            " dòng.  Buffer là nofile và được dựng lại mỗi lần refresh
            " (WinListRefresh/RefreshAllTabs) nên đệm luôn khớp bề ngang mới.
            if l:prefix ==# '> '
                " Đệm tới textw-1 (không phải textw): panel đang 'wrap', đệm
                " đúng bằng bề ngang sẽ bị đẩy 1 space sang dòng thứ hai.
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

    " Chụp layout mọi tab (và phát hiện tab vừa đóng) ngay tại đây: hàm này
    " vốn đã đi qua toàn bộ tab/cửa sổ nên không tốn thêm vòng lặp đáng kể.
    silent! call s:SnapshotAllTabLayouts()

    return l:lines
endfunction


" ════════════════════════════════════════════════════════════════════════════
"  WINLIST STATUSLINE
"  Description: Renders a mini tab-indicator statusline inside the WinList
"  panel window itself — shows all tab numbers, highlighting the active
"  one, plus a "current/total" counter on the right.
" ════════════════════════════════════════════════════════════════════════════

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


" ════════════════════════════════════════════════════════════════════════════
"  HIGHLIGHTS & SYNTAX
"  Description: Highlight groups and syntax rules for the WinList buffer —
"  colors headers, split counts, active-tab marker, entry numbers, active
"  entry, modified flag, path text, plus the mini-statusline groups.
"  Also sets WinList buffer-local options (nofile, nowrap off, etc.).
" ════════════════════════════════════════════════════════════════════════════

function! WinListSetupHighlight() abort
    silent! highlight default WinListHeader     guifg=#61AFEF ctermfg=75  gui=bold
    silent! highlight default WinListHeaderID   guifg=bg      ctermfg=0   gui=NONE
    silent! highlight default WinListHeaderNum  guifg=#98c379 ctermfg=114 gui=bold
    silent! highlight default WinListSplitCnt   guifg=#e5c07b ctermfg=180 gui=bold
    silent! highlight default WinListActivTab   guifg=#e06c75 ctermfg=204 gui=bold
    silent! highlight default WinListNumber     guifg=#98c379 ctermfg=114 gui=bold
    " Dòng entry đang hoạt động (có marker '>') trong WinList: chữ TRẮNG trên
    " nền xanh đậm #003366 — đúng bằng màu nền của nhóm Search, nên trông
    " giống một match đang được search-highlight thay vì chữ cyan như trước.
    " Ba nhóm ActiveNum/ActiveMod/ActiveMark là bản "contained" của
    " Number/Modified/Mark: chúng PHẢI khai báo lại guibg, vì trong Vim một
    " syntax item contained không thừa hưởng thuộc tính của nhóm bao ngoài —
    " thiếu guibg thì chữ số / [+] / '>' sẽ bị khoét lỗ đen giữa thanh xanh.
    " Bốn nhóm dưới đây cố ý KHÔNG dùng 'default': ':highlight default' không
    " ghi đè nhóm đã tồn tại, nên sau khi 'hi clear' (đổi colorscheme) hay
    " khi source lại vimrc giữa chừng, màu mới sẽ không được áp — đúng lỗi
    " đã gặp: chữ vẫn cyan cũ, chỉ các nhóm mới sinh ra mới có nền xanh.
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
        " Panel WinList WRAP: tên test/file dài thì xuống dòng, KHÔNG bị cắt cụt
        " ở mép panel.  linebreak: chỉ ngắt ở khoảng trắng cho dễ đọc.
        " (Dòng entry đang active được đệm space tới textw-1 chứ không phải
        "  đúng textw, nên phần đệm không bao giờ đẩy sang dòng thứ hai.)
        autocmd FileType winlist setlocal wrap linebreak
                               \ nonumber norelativenumber nolist
                               \ cursorline buftype=nofile noswapfile nobuflisted
                               \ winfixwidth winfixheight signcolumn=no
    augroup END
augroup END

function! WinListApplySyntax() abort
    " PERFORMANCE: các 'syntax match' dưới đây KHÔNG phụ thuộc nội dung nên
    " chỉ cần đặt MỘT lần cho buffer panel.  Bản cũ chạy 'syntax clear' + 13
    " lệnh ':syntax' ở mọi lần refresh (mỗi lần chuyển cửa sổ/ghi file), và
    " 'syntax clear' còn ép tô lại toàn bộ cửa sổ panel.
    " Điều kiện 'exists(b:current_syntax)' để nếu ai đó 'syntax clear' (đổi
    " colorscheme, :syntax on…) thì ta đặt lại.
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

    " Dòng entry đang hoạt động: nền xanh đậm phủ cả dòng, chữ trắng.
    " Chỉ contains các nhóm riêng của dòng active (đều đã có guibg cùng màu),
    " KHÔNG dùng WinListNumber/Modified/Path nữa vì các nhóm đó không có nền
    " và chỉ dùng cho những dòng không active.
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

    " Đánh dấu đã đặt xong (xem chú thích ở đầu hàm).
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


" ════════════════════════════════════════════════════════════════════════════
"  WINLIST REFRESH  — content only, NO resize
"  Description: Rebuilds and rewrites the WinList buffer content without
"  touching window sizes. WinListRefresh updates just the current window's
"  view; WinListRefreshAllTabs rebuilds fully across all tabs (used by
"  most autocmds) while remembering the "last active" real window per tab.
" ════════════════════════════════════════════════════════════════════════════

function! WinListRefresh() abort
    if g:winlist_opening | return | endif
    if g:panel_opening   | return | endif
    if !WinListIsOpen()  | return | endif

    let l:wl_winnr = bufwinnr(WinListBufName())
    let l:cur_win  = winnr()

    " LƯU BUFFER NUMBER (không phải winnr): winnr đổi khi tách/đóng split
    " hoặc khi panel chiếm chỗ, còn bufnr thì ổn định.
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

    " Chụp layout MỌI tab cho tính năng khôi phục tab — việc này phải chạy kể
    " cả khi panel đang ẩn (chính nó đã tự chặn 1 lần/200ms nên rất rẻ).
    silent! call s:SnapshotAllTabLayouts()

    " Panel không hiển thị ở đâu cả -> bỏ qua phần ĐẮT NHẤT (dựng danh sách
    " mọi tab/buffer + xoá và ghi lại cả buffer panel).
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


" ════════════════════════════════════════════════════════════════════════════
"  GỘP NHIỀU EVENT THÀNH MỘT LẦN DỰNG PANEL      (performance)
"  Một thao tác của người dùng bắn ra nhiều event liền nhau: chuyển cửa sổ =
"  WinEnter + BufEnter; mở file = BufReadPost + BufEnter + WinEnter; ghi file
"  = BufWritePost (+ BufAdd khi tạo buffer mới)…  Bản cũ gọi
"  WinListRefreshAllTabs() NGAY cho từng event -> 2-4 lần quét toàn bộ tab và
"  ghi lại cả buffer panel cho MỘT thao tác.
"  WinListRefreshSoon() thay vào đó:
"    • cập nhật anchor (một phép gán) NGAY -> Ctrl-Shift-T vẫn đúng vị trí;
"    • dựng panel ngay nếu lần trước đã cách > 40ms;
"    • nếu vừa dựng xong thì hẹn MỘT lần dựng bù sau 60ms, để event cuối
"      cùng vẫn được phản ánh (không bị mất trạng thái);
"    • lần dựng bù chỉ chạy khi đang ở Normal mode (không đổi cửa sổ khi
"      đang Insert / command-line).
" ════════════════════════════════════════════════════════════════════════════
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
    " Đổi cửa sổ khi đang gõ / đang ở command-line sẽ làm nháy màn hình và có
    " thể cắt ngang thao tác -> hẹn lại.
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


" ════════════════════════════════════════════════════════════════════════════
"  SIDE PANEL — Open / Close / Toggle
"  Description: Core open/close/toggle logic. CombinedPanelOpen() opens
"  WinList alone (full height, left column) — NERDTree is NOT opened.
"  NERDTreePanelToggle() (Ctrl-B) opens NERDTree on demand; if WinList is
"  already up, WinList takes the top half and NERDTree the bottom half of
"  the same column. Panel-local keymaps (double-click/Enter to jump, q to
"  close, r to refresh) are applied by s:SetupWinListWindow(). Focus is
"  always restored to the previously active editing window afterwards.
" ════════════════════════════════════════════════════════════════════════════

" ── Áp option + keymap cho cửa sổ WinList (dùng chung mọi nơi mở panel) ─────
function! s:SetupWinListWindow() abort
    setlocal winfixwidth
    setlocal buftype=nofile bufhidden=hide
    setlocal noswapfile nobuflisted
    " wrap: tên dài xuống dòng thay vì bị cắt ở mép panel (xem thêm
    " WinListBufSettings — FileType winlist cũng đặt wrap linebreak).
    setlocal wrap linebreak number norelativenumber
    setlocal cursorline filetype=winlist signcolumn=no
    setlocal statusline=%!WinListStatusLine()

    nnoremap <silent> <nowait> <buffer> <LeftMouse>   <LeftMouse>
    nnoremap <silent> <nowait> <buffer> <2-LeftMouse> :call WinListMouseJump()<CR>
    nnoremap <silent> <nowait> <buffer> <CR>          :call WinListJump()<CR>
    nnoremap <silent> <nowait> <buffer> q             :call CombinedPanelClose()<CR>
    nnoremap <silent> <nowait> <buffer> r             :call WinListRefreshAllTabs()<CR>
endfunction


" Mở WinList (full height, cột trái). KHÔNG mở NERDTree nữa.
function! CombinedPanelOpen() abort
    if g:panel_opening   | return | endif
    if g:winlist_opening | return | endif

    " đang mở rồi -> chỉ refresh + chỉnh lại bề rộng
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

        " trả focus về cửa sổ nội dung (chấp nhận cả netrw)
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


" Mở NERDTree theo yêu cầu. Nếu WinList đang mở -> WinList nửa trên,
" NERDTree nửa dưới, cùng cột trái.
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
        " 1) NERDTree tạo cột trái trước (nó luôn mở sang trái)
        if !NERDTreeIsOpen()
            let l:cwd = filereadable(expand('%:p'))
                \ ? fnamemodify(expand('%:p'), ':h')
                \ : getcwd()
            execute 'NERDTree ' . fnameescape(l:cwd)
            execute 'vertical resize ' . s:PanelWidth()
            setlocal winfixwidth
        endif

        " 2) tìm cửa sổ NERDTree vừa tạo
        let l:nt = -1
        for l:i in range(1, winnr('$'))
            if WinListIsNERDTree(winbufnr(l:i))
                let l:nt = l:i
                break
            endif
        endfor

        " 3) chèn WinList vào NỬA TRÊN của cột đó
        if l:nt != -1 && !WinListIsOpen()
            let l:half = WinListHalfHeight()

            execute 'noautocmd ' . l:nt . 'wincmd w'
            execute 'aboveleft ' . l:half . 'split ' . WinListBufName()
            call s:SetupWinListWindow()
            execute 'vertical resize ' . s:PanelWidth()

            " cân lại NERDTree cho đúng nửa dưới
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


" Ctrl-B: bật/tắt NERDTree. WinList không bị ảnh hưởng.
" Khi BẬT: con trỏ nhảy thẳng vào cửa sổ NERDTree vừa mở.
" Khi TẮT: con trỏ trả về cửa sổ soạn thảo gần nhất.
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


" Đóng WinList (NERDTree giữ nguyên — nó có công tắc riêng là Ctrl-B)
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


" Toggle WinList. Không đụng tới NERDTree.
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

" Đặt con trỏ vào cửa sổ NERDTree ngay sau khi bật nó bằng Ctrl-B.
" Phải chạy qua timer: PanelOpenWithNERDTree() kết thúc bằng việc trả focus
" về cửa sổ soạn thảo, nên nếu focus ngay lập tức thì sẽ bị kéo ngược lại.
" Dùng winnr của NERDTree tại thời điểm timer chạy (layout đã ổn định),
" không dùng winnr tính trước đó.
function! s:FocusNERDTreeWindow() abort
    for l:i in range(1, winnr('$'))
        if WinListIsNERDTree(winbufnr(l:i))
            execute l:i . 'wincmd w'
            return
        endif
    endfor
endfunction


" ════════════════════════════════════════════════════════════════════════════
"  NERDTREE — open file as RIGHT SPLIT, keep panel open
"  Description: Overrides NERDTree's default Enter/double-click file-open
"  behavior so files always open in a new rightmost vertical split (or as
"  a fresh split if no editing window exists yet), instead of replacing
"  the NERDTree window — panel stays open and in sync afterward.
" ════════════════════════════════════════════════════════════════════════════

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
" T (shift-t) mặc định của NERDTree mở file trong tab mới NGAY SAU tab hiện tại;
" ở đây đổi thành: tab mới nhưng đặt ở VỊ TRÍ CUỐI thanh tab, và vẫn giữ focus
" ở tab đang đứng (giống hành vi "silent" gốc của T).
" Đăng ký cho CẢ 3 scope vì mỗi bản NERDTree gắn 'T' vào scope khác nhau; nếu
" chỉ đăng ký FileNode thì bản dùng 'Node'/'DirNode' vẫn chạy mapping gốc và
" tab sẽ nằm ngay cạnh tab hiện tại (đúng lỗi đã gặp).
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

    " ':tabnew' chèn tab mới NGAY SAU tab hiện tại, nên muốn nó ở cuối thì
    " trước hết đứng ở tab cuối đã.  Cách này chắc chắn hơn ':tabmove' và
    " không phụ thuộc việc tính lại số hiệu tab.
    if tabpagenr() != l:ntabs
        silent! execute 'tabnext ' . l:ntabs
    endif

    silent! execute 'tabnew ' . fnameescape(l:path)
    if tabpagenr('$') != l:ntabs + 1
        " không tạo được tab (vd E37: buffer đang sửa mà không ghi được)
        echo 'T: cannot open a new tab for ' . fnamemodify(l:path, ':t')
        silent! execute 'tabnext ' . l:cur
        return
    endif

    " về lại tab ban đầu như T gốc (tab mới vẫn tự có WinList riêng)
    if tabpagenr() != l:cur && l:cur <= tabpagenr('$')
        silent! execute 'tabnext ' . l:cur
    endif

    silent! call WinListRefreshAllTabs()

    " thông báo ngắn để biết override CÓ chạy (không thấy dòng này = NERDTree
    " vẫn dùng mapping gốc)
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


" ════════════════════════════════════════════════════════════════════════════
"  WINLIST MOUSE JUMP
"  Description: Handles double-click inside the WinList panel — resolves
"  the exact clicked line/column via getmousepos() and jumps to the
"  corresponding entry if the line matches a file entry pattern.
" ════════════════════════════════════════════════════════════════════════════

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


" ════════════════════════════════════════════════════════════════════════════
"  WINLIST JUMP — uses stable Tab ID to survive drag-reorder
"  Description: Given the cursor's current line in the WinList buffer,
"  parses the entry number and the concealed Tab ID from its section
"  header, resolves it to the real (possibly reordered) tab number, and
"  focuses the corresponding editing window.
" ════════════════════════════════════════════════════════════════════════════

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


" ════════════════════════════════════════════════════════════════════════════
"  WINLIST OPEN / CLOSE / TOGGLE (backward-compat wrappers)
"  Description: Thin wrapper functions preserving the original
"  WinListOpen/Close/Toggle API names, delegating to the CombinedPanel*
"  functions. WinListOpenInAllTabs opens the panel across every tab.
" ════════════════════════════════════════════════════════════════════════════

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


" ════════════════════════════════════════════════════════════════════════════
"  TAB LIFECYCLE HANDLERS
"  Description: Tracks, per tab, whether the panel was open before
"  leaving it, and automatically re-opens/refreshes it upon re-entering
"  that tab (with a small timer delay to let Vim settle window layout).
" ════════════════════════════════════════════════════════════════════════════

function! WinListOnTabLeave() abort
    let g:winlist_tab_open[tabpagenr()] = WinListIsOpen() ? 1 : 0
endfunction

function! WinListOnTabEnter() abort
    " WinList luôn có mặt ở mọi tab, trừ khi đang trong netrw (Ctrl-O)
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


" ════════════════════════════════════════════════════════════════════════════
"  AUTOCMDS  — content refresh only, editing splits never auto-resized
"  Description: Wires up all events (buffer write/read/add/delete/wipeout,
"  window/buffer enter, tab enter/leave/new) that keep the WinList panel
"  content in sync, without ever forcibly resizing the user's own splits.
" ════════════════════════════════════════════════════════════════════════════

augroup WinListAuto
    autocmd!
    " Tất cả cùng gọi WinListRefreshSoon(): nó gộp các event bắn liền nhau
    " thành MỘT lần dựng lại panel (xem chú thích ở WinListRefreshSoon).
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

    " Đổi bề ngang cửa sổ (hoặc resize panel bằng <leader>W / Ctrl-w +) thì
    " phần đệm space của dòng active phải được tính lại, nếu không thanh nền
    " xanh sẽ hụt (hẹp lại) hoặc dư (rộng ra) so với bề ngang panel.
    autocmd VimResized * silent! call WinListRefreshSoon()
augroup END


" ── Mở WinList ngay khi khởi động (VimEnter không bắn TabEnter) ─────────────
augroup WinListStartup
    autocmd!
    autocmd VimEnter * call timer_start(60, {-> s:StartupWinList()})
augroup END

function! s:StartupWinList() abort
    if !get(g:, 'winlist_always', 1) | return | endif
    if get(g:, 'netrw_expanding', 0)  | return | endif
    if WinListIsOpen()                | return | endif

    " Khởi động với một thư mục (gvim . / gvim /path/dir) hoặc không có
    " argument: Vim mở [No Name] trống.  Nếu có thư mục làm việc thì mở
    " netrw để hiện cây thư mục, thay vì để buffer trống.
    if &buftype ==# '' && expand('%') ==# ''
        let l:dir = argc() > 0 ? fnamemodify(argv(0), ':p') : getcwd()
        if isdirectory(l:dir)
            silent! execute 'edit ' . fnameescape(l:dir)
        endif
    endif

    " Không bao giờ enew ở đây: netrw dùng buftype=nofile nên bị coi là
    " special, enew sẽ đè mất netrw.  CombinedPanelOpen() tự tìm cửa sổ
    " tựa qua WinListFindAnchorWin() (chấp nhận cả netrw).
    silent! call CombinedPanelOpen()
endfunction


" ════════════════════════════════════════════════════════════════════════════
"  KEYMAPS + COMMANDS
"  Description: User-facing entry points for the panel system.
"    wl          → toggle WinList (bật/tắt cột WindowList)
"    Ctrl-B      → toggle NERDTree ONLY (không đụng WinList)
"    <leader>W   → fix/sync WinList width
"    <leader>wa  → open panel in ALL tabs
"    <leader>wh  → fix 50/50 panel heights (khi NERDTree đang mở)
"  Ex commands (:WinList, :WinListClose, :WinListFix, etc.) mirror these.
" ════════════════════════════════════════════════════════════════════════════

" wl — bật/tắt WinList. Dùng nnoremap để KHÔNG ảnh hưởng Visual mode
" (Visual  w  phải giữ nguyên nghĩa "chọn word tiếp theo").
nnoremap <silent> wl :call WinListToggle()<CR>

" Ctrl-B chỉ bật/tắt NERDTree. WinList luôn hiển thị.
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


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                    DOUBLE-ENTER SPLIT EXPAND / RESTORE                   │
" │ Description: Pressing Enter twice quickly in a vertical split            │
" │ temporarily maximizes the current split's width (minimizing others to    │
" │ 1 column) — pressing Enter again restores original layout. Ctrl-Enter    │
" │ force-expands the current window immediately (collapsing any active      │
" │ expand first). Panel (WinList/NERDTree) widths are protected throughout. │
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


" ┌──────────────────────────────────────────────────────────────────────────┐
" │        CTRL+O — mở netrw / quay lại file vừa xem (toggle 2 chiều)        │
" │ Description: Ctrl-O bật/tắt netrw NGAY TRONG cửa sổ hiện tại — KHÔNG ẩn  │
" │ panel, KHÔNG phóng to, layout của tab giữ nguyên như bình thường.        │
" │  • Lần 1 (đang xem file): nhớ buffer hiện tại rồi mở explorer bằng tên   │
" │    đầy đủ ':Explore' — ':E' đã được định nghĩa lại thành ':e' (mở file   │
" │    theo đường dẫn) nên không dùng được cho explorer nữa).                │
" │  • Lần 2 (đang trong netrw): quay lại đúng buffer/file vừa xem; nếu      │
" │    buffer đó đã bị xoá thì mở lại theo đường dẫn, cuối cùng fallback     │
" │    sang alternate buffer.                                                │
" │ Chọn file trong netrw -> file mở ra thay chỗ netrw (browse_split = 0),   │
" │ panel vẫn nguyên chỗ cũ.  Không có layout nào phải dựng lại, nên khi     │
" │ rời netrw chỉ cần hạ cờ.                                                 │
" └──────────────────────────────────────────────────────────────────────────┘

" Có cửa sổ netrw nào đang mở không — dùng để phát hiện cờ cũ còn sót lại
" (netrw bị đóng bằng :bd nên autocmd BufLeave không bắt được).
function! s:HasNetrwWindow() abort
    for l:i in range(1, winnr('$'))
        if getbufvar(winbufnr(l:i), '&filetype') ==# 'netrw'
            return 1
        endif
    endfor
    return 0
endfunction

" Buffer đang hiển thị có phải netrw không (dùng filetype, giống các autocmd
" BufLeave/BufWinLeave bên dưới).
function! s:IsNetrwBuffer() abort
    return &filetype ==# 'netrw' || bufname('%') =~# '^netrw'
endfunction

" Quay lại buffer đã xem trước khi mở netrw.  Ba mức dự phòng, theo thứ tự:
"   1. buffer number đã nhớ (còn tồn tại)
"   2. đường dẫn đã nhớ (buffer bị :bwipeout nhưng file còn trên đĩa)
"   3. alternate buffer  -> cho trường hợp netrw mở bằng tay, không qua Ctrl-O
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
    " Đang trong netrw -> Ctrl-O lần 2 = quay lại file vừa xem.  Việc chuyển
    " buffer sẽ bắn BufLeave(netrw) -> SmartCtrlORestore() hạ cờ giúp mình.
    if s:IsNetrwBuffer()
        silent! call s:NetrwBack()
        return
    endif

    " Tên đầy đủ ':Explore' (netrw).  Không dùng ':E': trong gvim ':E' đã
    " được bind cho Ctrl-O và hành xử như ':e' (mở file), nên ':Explore' là
    " cách gọi chắc chắn đúng explorer, không phụ thuộc alias/abbrev.
    if !exists(':Explore')
        echo ':Explore (netrw) not available - cannot open explorer.'
        return
    endif

    if get(g:, 'netrw_explore_active', 0) && !s:HasNetrwWindow()
        let g:netrw_explore_active = 0
        let g:netrw_expanding      = 0
    endif

    " Nhớ chỗ đang xem để Ctrl-O lần 2 quay lại: buffer number là chính, đường
    " dẫn chỉ là phương án dự phòng khi buffer bị xoá.
    let g:netrw_back_buf  = bufnr('%')
    let g:netrw_back_path = expand('%:p')

    " Cờ này KHÔNG dùng để dựng lại layout (không có gì bị thay đổi), chỉ để:
    " (1) tạm tắt auto-close tab trong lúc buffer duy nhất của tab là netrw —
    " netrw có buftype=nofile nên bị tính là "không phải cửa sổ thật",
    " (2) các hàm panel khỏi refresh/dựng lại giữa chừng.
    let g:netrw_expanding      = 1
    let g:netrw_explore_active = 1

    silent! execute 'Explore'
endfunction

function! SmartCtrlORestore() abort
    " Rời netrw = đã chọn xong file, đã bấm Ctrl-O quay lại, hoặc thoát
    " explorer.  Chỉ hạ cờ; layout và panel không bị đụng tới nên không phải
    " dựng lại gì.  g:netrw_back_buf/path được GIỮ LẠI để lần Ctrl-O sau còn
    " dùng (nó luôn được ghi đè khi mở netrw).
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


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                  ':E' = ':e'  (mở file), KHÔNG phải explorer             │
" │ Description: netrw định nghĩa ':E' là ':Explore' trong plugin của nó,    │
" │ và plugin được nạp SAU vimrc — nên phải ghi đè ở VimEnter mới thắng.     │
" │ Kết quả: ':E <path>' mở file y như ':e <path>'; ':E' (không tham số)     │
" │ nạp lại file hiện tại.  Explorer vẫn còn nguyên: ':Explore' và Ctrl-O    │
" │ (SmartCtrlO gọi thẳng ':Explore' nên không bị ảnh hưởng).                │
" └──────────────────────────────────────────────────────────────────────────┘
function! s:DefineEAsEdit() abort
    " delcommand trước để không bị E174 khi định nghĩa lại
    silent! delcommand E
    " -nargs=?  : ':E' không tham số = ':e' (nạp lại file hiện tại)
    " -bang     : cho ':E!' hoạt động như ':e!'
    " -complete=file : Tab completion giống ':e'
    command! -nargs=? -bang -complete=file E edit<bang> <args>
endfunction

augroup ForceEAsEdit
    autocmd!
    autocmd VimEnter * call s:DefineEAsEdit()
augroup END

" Gọi ngay 1 lần nữa: lúc khởi động lệnh này bị netrw (nạp sau vimrc) ghi đè
" và được VimEnter sửa lại; nhưng khi ':so ~/.vimrc' giữa chừng thì VimEnter
" không bắn nữa, nên phải áp luôn tại đây.
silent! call s:DefineEAsEdit()


" ┌──────────────────────────────────────────────────────────────────────────┐
" │              REOPEN LAST CLOSED  (CTRL+SHIFT+T)                          │
" │ Description: Tracks a stack (max 20) of recently closed real file        │
" │ buffers. Ctrl-W closes the current window while pushing onto the stack   │
" │ not only its file path but ALSO which tab it belonged to (stable         │
" │ Tab-ID), its ordinal among the tab's content windows, and its width.     │
" │ Ctrl-Shift-T then reopens it in that very tab, at that very position,    │
" │ with the same width — not as a stray split in the current tab.           │
" │ Tab vừa đóng được ưu tiên khôi phục trước (xem mục TAB RESTORE bên       │
" │ dưới, chạy cùng phím Ctrl-Shift-T).                                      │
" └──────────────────────────────────────────────────────────────────────────┘
if !exists('g:closed_file_stack')
    let g:closed_file_stack = []
endif

let g:closed_file_stack_max = 20

" Đường dẫn của 1 entry trong ngăn xếp (chấp nhận cả entry dict kiểu mới lẫn
" string của bản cũ, phòng khi ngăn xếp được tạo từ trước khi source lại).
function! s:ClosedEntryPath(e) abort
    return type(a:e) == type({}) ? get(a:e, 'path', '') : a:e
endfunction

" Thứ tự (1-based) của cửa sổ đang hiển thị buffer {bn} trong tab hiện tại,
" chỉ đếm cửa sổ NỘI DUNG (bỏ panel) — đúng thứ tự WinList đang liệt kê.
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

" Số hiệu cửa sổ (winnr) của cửa sổ NỘI DUNG thứ n; 0 nếu không có.
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

" Ghi lại cửa sổ sắp đóng: file + TAB nào (Tab-ID ổn định) + vị trí thứ mấy
" trong tab + bề rộng, để ReopenLastClosedFile() dựng lại ĐÚNG CHỖ.
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

    " Bỏ entry cũ khi:
    "   1. cùng ĐƯỜNG DẪN (đóng lại chính file đó ở chỗ khác), hoặc
    "   2. cùng SLOT (cùng tabidx + cùng ord) — ca "đóng split B rồi mở split C
    "      thay đúng chỗ đó rồi đóng C": vị trí đó chỉ còn đúng MỘT cửa sổ, nên
    "      entry của C GHI ĐÈ entry của B thay vì giữ cả hai (giữ cả hai thì
    "      bấm Ctrl-Shift-T 2 lần sẽ dựng lại 3 split, không đúng thực tế).
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

" Mở lại cửa sổ vừa đóng Ở ĐÚNG TAB VÀ ĐÚNG VỊ TRÍ của nó:
"   1. tab cũ còn sống (so theo Tab-ID, không phụ thuộc thứ tự tab) -> tabnext
"   2. dựng split đúng thứ tự: ord = 1 -> chèn vào trái cửa sổ nội dung đầu;
"      ord = N -> chèn ngay sau cửa sổ nội dung thứ N-1
"   3. trả lại bề rộng cũ
" Không tìm được tab cũ (tab đã bị đóng hẳn) thì mới mở trong tab hiện tại —
" trường hợp đó tab-restore (Ctrl-Shift-T) đã có nhánh riêng lo cả tab.
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

    " 1) về đúng tab cũ; tab đã bị đóng hẳn thì DỰNG LẠI TAB đó (không mở
    "    file lạc vào tab đang đứng) — đây là trường hợp đóng cả file lẫn tab.
    let l:tab = l:tabid ==# '' ? -1 : WinListFindTabByID(l:tabid)

    " Lần bấm TRƯỚC đã dựng lại đúng tab chứa cửa sổ này?  Tab dựng lại mang
    " Tab-ID mới nên tìm theo ID ở trên thất bại — dùng ký ức theo VỊ TRÍ.
    " Chỉ dùng một lần rồi xoá, tránh lần khôi phục sau nhảy nhầm tab.
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

            " Khôi phục MỘT thứ mỗi lần bấm (giống restore tab của browser):
            " ở đây chỉ mở đúng file này trong tab mới.  Các cửa sổ khác của
            " tab đó (nếu người dùng đóng nhiều split trước khi tab biến mất)
            " sẽ được khôi phục ở những lần bấm TIẾP THEO, nhờ
            " g:last_restored_tab bên dưới chỉ đúng tab này.
            let g:last_restored_tab = {'tabnr': tabpagenr(), 'index': l:tabidx}

            " WinList của tab mới
            silent! call CombinedPanelOpen()

            " về đúng vị trí tab cũ
            let l:target = max([0, min([l:tabidx - 1, tabpagenr('$') - 1])])
            silent! execute 'tabmove ' . l:target

            " trả bề rộng cũ cho cửa sổ vừa mở
            if l:width > 0 && winwidth(0) != l:width
                silent! execute 'vertical resize ' . l:width
            endif

            silent! call WinListRefreshAllTabs()
            echo printf('Ctrl-Shift-T: rebuilding tab %d with %s',
                \ tabpagenr(), fnamemodify(l:path, ':t'))
            return 1
        endif
        " không tạo được tab mới -> rơi xuống nhánh mở trong tab hiện tại
    elseif l:tab != -1 && l:tab != tabpagenr()
        silent! execute 'tabnext ' . l:tab
    endif

    " 2) dựng lại split đúng vị trí
    let l:n_wins = 0
    for l:i in range(1, winnr('$'))
        if !WinListIsSpecial(winbufnr(l:i)) && !WinListIsNERDTree(winbufnr(l:i))
            let l:n_wins += 1
        endif
    endfor

    " cửa sổ làm mốc: đứng ngay trước vị trí cũ; vị trí cũ vượt quá số cửa sổ
    " hiện có thì lấy cửa sổ cuối (coi như thêm vào cuối)
    let l:anchor = s:ContentWinNr(max([1, l:ord - 1]))
    if l:anchor == 0
        let l:anchor = s:ContentWinNr(l:n_wins)
    endif

    if l:anchor == 0
        " tab không còn cửa sổ nội dung nào -> mở ngay trong cửa sổ hiện tại
        silent! execute 'edit ' . fnameescape(l:path)
    else
        execute 'noautocmd ' . l:anchor . 'wincmd w'
        if l:ord <= 1
            " vị trí cũ là cửa sổ đầu -> chèn sang TRÁI cửa sổ nội dung đầu
            silent! execute 'leftabove vsplit ' . fnameescape(l:path)
        else
            " chèn ngay SAU cửa sổ thứ ord-1 -> thành cửa sổ thứ ord
            silent! execute 'rightbelow vsplit ' . fnameescape(l:path)
        endif
    endif

    " 3) trả lại bề rộng cũ (chỉ khi cửa sổ mới thật sự hẹp/rộng khác đi)
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


" ════════════════════════════════════════════════════════════════════════════
"  TAB RESTORE — Ctrl-Shift-T mở lại TAB vừa đóng, ĐÚNG vị trí cũ
"  Description: mỗi lần WinList refresh, layout của TẤT CẢ tab được chụp lại
"  (danh sách cửa sổ con + buffer + bề rộng/chiều cao + cửa sổ đang active).
"  Tab nào biến mất khỏi danh sách tab thì bản chụp của nó được đẩy vào
"  g:closed_tab_stack.  Ctrl-Shift-T lấy mục đầu, tạo lại tab với đúng các
"  cửa sổ con đó rồi ':tabmove' về đúng vị trí tab cũ, và GIỮ LẠI Tab-ID cũ
"  cho tab vừa dựng (settabvar) — nhờ vậy các entry còn trong
"  closed_file_stack của tab đó vẫn tìm lại được chính tab này.
"  Không có tab nào đã đóng thì Ctrl-Shift-T mở lại CỬA SỔ vừa đóng bằng
"  Ctrl-W: đúng tab (theo Tab-ID), đúng vị trí thứ N, đúng bề rộng.  Nếu tab
"  chứa cửa sổ đó cũng đã bị đóng hẳn (đóng file rồi đóng luôn tab) thì nó
"  DỰNG LẠI TAB đó ở vị trí cũ chứ không thả file vào tab đang đứng.
"  Không cần TabClosed (Vim cũ không có) — việc phát hiện tab đã đóng dựa
"  trên so sánh Tab-ID ổn định (g:winlist_tab_id) với danh sách tab hiện có.
" ════════════════════════════════════════════════════════════════════════════

if !exists('g:closed_tab_stack')
    let g:closed_tab_stack = []
endif
if !exists('g:tab_layout_cache')
    let g:tab_layout_cache = {}
endif

let g:closed_tab_stack_max = 10

" Mốc thời gian của lần chụp layout gần nhất — dùng để chặn tần suất (xem
" s:SnapshotAllTabLayouts).
let g:tab_snapshot_last = reltime()

" ── restore_log: nhật ký push/pop của cơ chế khôi phục ──────────────────────
" Ghi lại MỌI quyết định (đẩy tab, đẩy cửa sổ, pop, có gộp file vào tab hay
" không) kèm giờ.  Chỉ để chẩn đoán: :ClosedInfo in 40 dòng gần nhất, nhờ vậy
" biết chính xác lần bấm Ctrl-Shift-T đã thấy dữ liệu gì.
if !exists('g:restore_log')
    let g:restore_log = []
endif

" Tab vừa được Ctrl-Shift-T dựng lại: {'tabnr': N, 'index': vị trí tab cũ}.
" Dùng cho lần bấm TIẾP THEO: nếu cửa sổ cần khôi phục thuộc tab vừa dựng đó
" (so theo vị trí) thì đưa nó vào đúng tab ấy — không phụ thuộc Tab-ID, vì
" tab dựng lại mang ID mới nên WinListFindTabByID() không tìm ra.
if !exists('g:last_restored_tab')
    let g:last_restored_tab = {}
endif

function! s:RestoreLog(msg) abort
    call add(g:restore_log, strftime('%H:%M:%S') . '  ' . a:msg)
    while len(g:restore_log) > 40
        call remove(g:restore_log, 0)
    endwhile
endfunction

" ── :ClosedInfo — in nội dung 2 ngăn xếp khôi phục ──────────────────────────
" Dùng để chẩn đoán khi Ctrl-Shift-T khôi phục sai chỗ: xem nó sẽ lấy entry
" nào, entry đó mang tab/tabidx/ord gì, và trong ngăn xếp có entry cũ sót
" lại từ lần thử trước hay không.
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

" Thu các winid của node 'leaf' theo đúng thứ tự layout.
function! s:CollectLayoutLeaves(node, out) abort
    if a:node[0] ==# 'leaf'
        call add(a:out, a:node[1])
        return
    endif
    for l:child in a:node[1:]
        call s:CollectLayoutLeaves(l:child, a:out)
    endfor
endfunction

" Bỏ panel (WinList/NERDTree/cửa sổ special) khỏi cây layout, và gộp node chỉ
" còn 1 con vào con đó.  Nhờ vậy hướng chia của tab được suy ra từ phần NỘI
" DUNG, không bị cột panel bên trái làm sai: ví dụ
"   ['row', leaf(WinList), ['col', A, B]]  ->  ['col', A, B]  -> chia NGANG
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

" Chụp layout của 1 tab.  Trả {} nếu không lấy được / tab không còn cửa sổ
" nội dung nào (tab chỉ có panel thì không có gì để dựng lại).
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
            " Bỏ panel: WinList luôn tự mở lại ở mọi tab, NERDTree do Ctrl-B
            if WinListIsWinList(l:bn) || WinListIsNERDTree(l:bn) | continue | endif
            if WinListIsSpecial(l:bn) | continue | endif
            " Ghi đường dẫn TUYỆT ĐỐI: buffer number có thể bị dùng lại / đổi
            " nội dung khi chuyển qua lại giữa các tab, còn đường dẫn thì
            " không.  Buffer không tên ([No Name]) thì để rỗng.
            let l:name  = bufname(l:bn)
            let l:apath = l:name ==# '' ? '' : fnamemodify(l:name, ':p')
            call add(l:wins, {
                \ 'nr':   l:bn,
                \ 'path': l:apath,                     " FULL PATH (tuyệt đối)
                \ 'name': l:name ==# '' ? '[No Name]' : fnamemodify(l:name, ':t'),
                \ 'w':    winwidth(l:wid),
                \ 'h':    winheight(l:wid),
                \ })
        endfor

        " ── Fallback ──────────────────────────────────────────────────────
        " winlayout()/winbufnr(winid) không dùng được (Vim cũ, hoặc trả về
        " rỗng) -> lấy danh sách buffer của tab bằng tabpagebuflist().  Khi đó
        " không biết bề rộng/chiều cao từng cửa sổ (để 0, lúc dựng lại
        " s:ApplySnapshotSizes sẽ bỏ qua) và hướng chia lấy mặc định.
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

        " Hướng chia lấy từ node gốc SAU KHI bỏ panel: 'row' = các cửa sổ nằm
        " NGANG nhau (split dọc), 'col' = xếp CHỒNG (split ngang).  Mặc định
        " 'row' vì vimrc này dùng split dọc là chính.
        let l:dir = 'row'
        let l:pruned = empty(l:root) ? [] : s:PruneLayout(l:root)
        if type(l:pruned) == type([]) && !empty(l:pruned)
            if l:pruned[0] ==# 'col'
                let l:dir = 'col'
            endif
        endif

        " ── ANCHOR = nội dung WinList ──────────────────────────────────────
        " Không dùng tabpagewinnr()/tabpagebuflist() để đoán cửa sổ đang active:
        " khi chuyển qua lại giữa các gvim tab, hoặc khi focus đang nằm ở panel,
        " index đó trỏ sai cửa sổ (buffer "đổi chỗ").  WinList đã giải quyết
        " đúng chuyện này bằng BUFFER NUMBER, lưu ở g:winlist_last_active[tab]
        " và cũng chính là dấu '>' trong panel — nên lấy lại từ đó:
        "   • tab hiện tại : s:CurrentContentBuf()  (tự fallback về buffer đã nhớ)
        "   • tab khác     : g:winlist_last_active[tab]  (do WinListRefresh ghi)
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

" Đẩy bản chụp của tab vừa đóng vào ngăn xếp (bỏ trùng, giới hạn số lượng).
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

" Chụp layout mọi tab + phát hiện tab vừa đóng.  Được gọi ở cuối
" WinListBuildAllTabLines() nên chạy theo mọi lần panel refresh.
function! s:SnapshotAllTabLayouts() abort
    " Hàm này được gọi từ MỌI lần WinList refresh (BufEnter/WinEnter/TabEnter...)
    " nên rất hay chạy; mỗi lần lại quét mọi tab.  Chặn còn tối đa 1 lần/200ms —
    " dò "tab vừa đóng" không cần nhanh hơn thế, mà mở nhiều file liên tiếp thì
    " đỡ hẳn chi phí.
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

    " Tid có trong cache mà không còn tab tương ứng -> tab đó vừa bị đóng.
    for l:tid in keys(g:tab_layout_cache)
        if !has_key(l:live, l:tid)
            call s:PushClosedTab(remove(g:tab_layout_cache, l:tid))
        endif
    endfor
endfunction

" Mở buffer của 1 cửa sổ trong snapshot.  Trả 1 nếu cửa sổ này ĐÃ HIỂN THỊ
" đúng buffer/file cần khôi phục, 0 nếu thất bại (vd E37 vì buffer đang sửa
" mà không ghi được) — nhờ vậy chỗ gọi báo được lỗi thay vì im lặng.
" Ưu tiên ĐƯỜNG DẪN: buffer number có thể đã bị dùng lại cho file khác trong
" lúc chuyển qua lại giữa các tab.  ':edit <path>' tự dùng lại buffer đã nạp
" sẵn cùng đường dẫn nên không tạo buffer trùng.
function! s:OpenSnapshotBuf(w) abort
    let l:nr   = get(a:w, 'nr', -1)
    let l:path = get(a:w, 'path', '')
    " Session lưu FULL PATH; phòng khi file session cũ/bị sửa tay chỉ ghi
    " đường dẫn tương đối thì quy về tuyệt đối trước khi mở.
    if l:path !=# '' && l:path !~# '^\%(/\|\a:[/\\]\)'
        let l:path = fnamemodify(l:path, ':p')
    endif
    if l:path !=# '' && filereadable(l:path)
        silent! execute 'edit ' . fnameescape(l:path)
        " xác nhận cửa sổ hiện tại thật sự đang hiển thị file đó
        if fnamemodify(bufname('%'), ':p') ==# l:path
            return 1
        endif
        " thử lại một lần: buffer đang giữ chỗ có thể bị sửa mà chưa ghi
        silent! execute 'edit! ' . fnameescape(l:path)
        return fnamemodify(bufname('%'), ':p') ==# l:path ? 1 : 0
    endif
    " buffer không tên ([No Name]) -> dùng số buffer, kiểm tra lại cho chắc
    if l:nr > 0 && bufexists(l:nr) && bufname(l:nr) ==# ''
        silent! execute 'buffer ' . l:nr
        return bufnr('%') == l:nr ? 1 : 0
    endif
    return 0
endfunction

" Trả về winid của cửa sổ NỘI DUNG thứ n (1-based, bỏ qua panel
" WinList/NERDTree).  Dùng winid chứ không dùng winnr vì có panel chen vào
" thì số thứ tự cửa sổ không còn khớp với thứ tự cửa sổ con của tab cũ.
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

" Focus cửa sổ NỘI DUNG thứ n (1-based, bỏ qua panel WinList/NERDTree).
function! s:FocusNormalWin(n) abort
    if a:n <= 0 | return | endif
    let l:wid = s:NormalWinId(a:n)
    if l:wid != 0
        silent! call win_gotoid(l:wid)
    endif
endfunction

" Trả lại bề rộng (split dọc) / chiều cao (split ngang) đã ghi cho từng cửa
" sổ con.  Chạy SAU khi WinList được dựng lại, vì lúc panel chen vào Vim sẽ
" lấy bớt bề ngang của cửa sổ đầu tiên.
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

    " Chỉ POP khi đã khôi phục xong — hỏng giữa chừng thì giữ lại để thử lại,
    " tránh mất luôn tab vừa đóng.
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

        " Tab mới PHẢI được tạo thật.  Nếu không (vd bị autocmd/timer khác
        " chặn), dừng ngay — trước đây lỗi này bị silent! nuốt mất nên các
        " bước sau chạy nhầm vào tab đang mở, đẩy file sang tab khác.
        if tabpagenr('$') != l:n_before + 1
            echo 'Ctrl-Shift-T: could not create a new tab - state kept.'
            return 0
        endif
        let l:newtab = tabpagenr()

        " Nhớ tab vừa dựng để lần bấm TIẾP THEO đưa cửa sổ file đã đóng vào
        " đúng tab này (xem ReopenLastClosedFile).  Không phụ thuộc Tab-ID.
        let g:last_restored_tab = {'tabnr': l:newtab, 'index': l:snap.index}

        " Giữ nguyên Tab-ID CŨ cho tab vừa dựng lại.  Nhờ vậy nếu trước đó
        " trong closed_file_stack còn entry của một cửa sổ thuộc tab này
        " (file bị đóng TRƯỚC khi cả tab bị đóng), lần Ctrl-Shift-T sau
        " WinListFindTabByID() vẫn tìm ra đúng tab này để mở lại đúng chỗ,
        " thay vì tạo thêm một tab mới.
        if get(l:snap, 'tid', '') !=# ''
            silent! call settabvar(l:newtab, 'winlist_tab_id', l:snap.tid)
        endif

        " 1) dựng lại từng cửa sổ con, giữ đúng hướng chia của tab cũ
        let l:i = 0
        for l:w in l:snap.wins
            " bảo đảm vẫn đang ở đúng tab mới trước mỗi bước
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

        " Không mở được cửa sổ nào -> dọn tab vừa tạo, giữ snapshot để thử lại
        if len(l:missing) == len(l:snap.wins)
            if tabpagenr('$') > 1
                silent! close
            endif
            echo 'Ctrl-Shift-T: could not open any file of the closed tab - kept in stack.'
            return 0
        endif

        " 2) về đúng vị trí tab cũ (':tabmove' đếm từ 0).  Kẹp lại trong
        "    khoảng hợp lệ phòng khi vị trí cũ lớn hơn số tab hiện có.
        let l:target = l:snap.index - 1
        let l:target = max([0, min([l:target, tabpagenr('$') - 1])])
        silent! execute 'tabmove ' . l:target
    finally
        let g:panel_opening = 0
    endtry

    " 3) Mở lại WinList — KHÔNG nằm trong snapshot và không được dựng từ
    "    snapshot: bản chụp chỉ giữ cửa sổ NỘI DUNG (s:PruneLayout bỏ panel),
    "    bề rộng panel luôn lấy theo s:PanelWidth() hiện tại, nên tab khôi
    "    phục không mang theo bề rộng panel cũ.  Phải mở panel TRƯỚC khi
    "    resize: khi panel chen vào, Vim lấy bớt bề ngang của cửa sổ bên cạnh.
    silent! call CombinedPanelOpen()
    silent! call s:ApplySnapshotSizes(l:snap)

    " 4) focus đúng cửa sổ đang active như lúc trước khi đóng tab
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

    " khôi phục xong mới bỏ snapshot khỏi ngăn xếp
    call remove(g:closed_tab_stack, 0)
    return 1
endfunction

" Ctrl-Shift-T: ưu tiên khôi phục TAB vừa đóng; nếu không có tab nào đã đóng
" thì quay về hành vi cũ là mở lại FILE vừa đóng bằng Ctrl-W.
function! ReopenLastClosed() abort
    " Hết cả hai ngăn xếp -> chỉ báo info, KHÔNG đụng vào layout/buffer hiện
    " tại (khôi phục rỗng).
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


" ════════════════════════════════════════════════════════════════════════════
"  SESSION SAVE / RESTORE
"  Description: lưu toàn bộ phiên (mọi tab + mọi split, đúng thứ tự, đúng
"  hướng chia, đúng bề rộng, đúng cửa sổ active) ra file JSON trong
"  ~/.gvim_sessions/session-YYYYmmdd-HHMMSS.json.
"   • Khi thoát GVim mà có NHIỀU tab hoặc có SPLIT: hiện hộp thoại 2 nút
"     "Save-exit" / "Exit" (confirm() của GVim).  Save-exit -> ghi file rồi
"     thoát; Exit -> thoát không lưu; Esc -> thoát, không lưu.
"   • `:SaveSession` lưu tay bất cứ lúc nào.
"   • `<F2>` = TOGGLE danh sách session NGAY TRONG CỬA SỔ HIỆN TẠI (không mở
"     tab mới — đây là thao tác hay dùng khi vừa mở một GVim trống): tên
"     session = ngày giờ lưu, kèm danh sách tab/split của từng session; Enter
"     (hoặc double click) để khôi phục, q đóng, r đọc lại thư mục.  Bấm F2
"     lần nữa (dù con trỏ đang ở cửa sổ khác) cũng đóng picker.
"     Toàn bộ chữ trong picker là TIẾNG ANH.
"     Vì sao không dùng Ctrl-Shift-O: trong Vim, với CHỮ CÁI thì Shift bị bỏ
"     qua khi đi cùng Ctrl -> <C-S-o> chính là <C-o>, map nó sẽ ghi đè phím
"     Ctrl-O (explorer) của SmartCtrlO().
"  Kỹ thuật dựng lại tab dùng chung với TAB RESTORE ở trên
"  (s:OpenSnapshotBuf / s:ApplySnapshotSizes): panel WinList không nằm trong
"  bản lưu, mỗi tab luôn tự mở lại panel như bình thường.
" ════════════════════════════════════════════════════════════════════════════

let g:session_max         = 20
let g:session_picker_buf  = '__SessionPicker__'

function! s:SessionsDir() abort
    let l:dir = expand('~/.gvim_sessions')
    if !isdirectory(l:dir)
        silent! call mkdir(l:dir, 'p')
    endif
    return l:dir
endfunction

" Danh sách file session, MỚI NHẤT TRƯỚC.
" Sắp theo THỜI GIAN SỬA FILE (getftime) chứ không theo tên: khi người dùng
" đặt tên session, tên file thành session-<tên>-<timestamp>.json nên sort
" theo tên sẽ nhóm lộn xộn.
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

" Giữ tối đa g:session_max file, xoá các file cũ nhất.
function! s:PruneSessions() abort
    let l:files = s:SessionFiles()
    if len(l:files) <= g:session_max | return | endif
    for l:f in l:files[g:session_max :]
        silent! call delete(l:f)
    endfor
endfunction

" Chụp toàn bộ phiên hiện tại thành dict {saved, tabs:[{wins,dir,active}]}.
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

" Lưu session.  {label} là tuỳ chọn: rỗng -> tên mặc định
" session-YYYYmmdd-HHMMSS.json; có tên -> session-<tên>-YYYYmmdd-HHMMSS.json
" (tên được làm sạch ký tự lạ để không hỏng tên file).
function! s:SaveSession(...) abort
    let l:label = a:0 > 0 ? substitute(a:1, '[^0-9A-Za-z._-]', '-', 'g') : ''
    let l:label = substitute(l:label, '^-\+\|-\+$', '', 'g')

    let l:data = s:SessionSnapshot()
    if empty(l:data.tabs)
        " Kèm vài số liệu để biết vì sao: winlayout có sẵn không, đang có mấy
        " tab, buffer của tab hiện tại là gì.
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

" <F3>: echo hỏi tên rồi lưu.
"   • Enter (không gõ gì)  -> lưu với tên mặc định session-<ngày giờ>.json
"   • gõ tên               -> lưu thành session-<tên>-<ngày giờ>.json
"   • Ctrl-C               -> huỷ (input() bị ngắt nên hàm abort, không lưu)
function! s:AskNameAndSave() abort
    let l:label = input('Session name (Enter = default, Ctrl-C = cancel): ')
    " input() để lại nguyên dòng prompt (kể cả tên vừa gõ) trên command line;
    " xoá đi rồi mới in "Session saved: ..." để thông báo đứng riêng một dòng.
    echo ''
    silent! redraw
    call s:SaveSession(l:label)
endfunction

" Dựng lại 1 tab từ snapshot {wins, dir, active} rồi đưa về vị trí index.
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

" Khôi phục toàn bộ session (đúng thứ tự tab/split đã lưu).
function! s:RestoreSession(sess) abort
    if type(a:sess) != type({}) | return 0 | endif
    let l:tabs = get(a:sess, 'tabs', [])
    if empty(l:tabs)
        echo 'Session: the file has no tab.'
        return 0
    endif

    " tab đang đứng trước khi khôi phục: nếu chỉ là scratch ([No Name] /
    " picker / netrw) thì dọn sau khi dựng xong, để không để lại tab rác
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

" ── Chọn session (<F2> / :SessionPicker) ────────────────────────────────────
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
        " '§path' ở cuối dòng bị conceal; dùng để biết dòng thuộc session nào
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
                " ưu tiên 'name' đã lưu; file session cũ thì lấy tên từ path
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

" Đóng picker: trả lại buffer đã hiển thị trước đó trong cửa sổ này.
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

" Mở danh sách session NGAY TRONG CỬA SỔ HIỆN TẠI (không mở tab mới) — đây
" là thao tác hay dùng khi vừa mở một GVim trống, nên chiếm luôn cửa sổ đó.
function! SessionPicker() abort
    " TOGGLE: picker đang hiện ở bất kỳ cửa sổ nào -> đóng (trả lại buffer cũ);
    " chưa mở -> mở trong cửa sổ hiện tại.
    if bufwinnr(g:session_picker_buf) != -1
        call s:SessionPickerClose()
        return
    endif

    let l:prev = bufnr('%')
    silent! execute 'keepalt edit ' . fnameescape(g:session_picker_buf)
    if bufname('%') !=# g:session_picker_buf
        " :edit thất bại (vd buffer hiện tại đang sửa mà không ghi được)
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

" Restore the session on the cursor line (header line or one of its Tab lines).
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

" Hai phím của tính năng session (trong GVim F2/F3 chưa dùng — pastetoggle bên
" dưới chỉ đặt cho Vim trong terminal):
"   <F2> = TOGGLE session picker (chọn session để restore)
"   <F3> = hỏi TÊN rồi lưu: Enter = tên mặc định (session-<ngày giờ>.json),
"          gõ tên = session-<tên>-<ngày giờ>.json, Ctrl-C = huỷ
" TUYỆT ĐỐI không map <C-S-o>: trong Vim, với CHỮ CÁI phần Shift bị bỏ qua khi
" đi cùng Ctrl, nên <C-S-o> chính là <C-o> — map nó sẽ GHI ĐÈ mapping <C-o>
" của SmartCtrlO() (explorer), và Ctrl-O sẽ mở nhầm session picker.
if has('gui_running')
    nnoremap <silent> <F2> :call SessionPicker()<CR>
    inoremap <silent> <F2> <Esc>:call SessionPicker()<CR>
    nnoremap <silent> <F3> :call <SID>AskNameAndSave()<CR>
    inoremap <silent> <F3> <Esc>:call <SID>AskNameAndSave()<CR>
endif
command! -nargs=? SaveSession call <SID>SaveSession(<q-args>)
command! SessionPicker call SessionPicker()

" KHÔNG có autocmd VimLeavePre: đóng bằng X hay :q đều im lặng, không hỏi,
" không tự lưu.  Việc lưu là do người dùng bấm <F3>.


" ┌──────────────────────────────────────────────────────────────────────────┐
" │               QUICK REPLACE  :R <old> --- <new>                          │
" │ Description: Replaces ALL literal (regex-safe, symbol/space-agnostic)    │
" │ occurrences of <old> with <new> across the whole buffer, case-sensitive. │
" │ Delimiter is the LAST "---" found in the argument string, so both        │
" │ <old> and <new> may freely contain spaces, punctuation, or code syntax   │
" │ (brackets, arrows, dots, etc.) without breaking the pattern. After a     │
" │ successful replace, the NEW text is search-highlighted (clear via        │
" │ <S-l> / :nohlsearch). Reports the number of occurrences replaced.        │
" └──────────────────────────────────────────────────────────────────────────┘
function! QuickReplace(args) abort
    " ── Find the LAST '---' delimiter ──────────────────────────────────────
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

    " ── Build a fully literal (\V) search pattern ─────────────────────────
    " Only '\' and '/' need escaping under \V — everything else
    " (. * $ ^ [ ] ( ) { } + ? | < > ~ - etc.) is treated as plain text.
    let l:escaped_old = escape(l:old, '\/')
    let l:pattern      = '\V\C' . l:escaped_old

    " ── Escape only what matters on the *replacement* side of :substitute ─
    let l:escaped_new = escape(l:new, '\/&~')

    " ── Count literal occurrences first (plain string search, no regex) ───
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


" ┌──────────────────────────────────────────────────────────────────────────┐
" │                    QUICK DELETE  :D <text>                               │
" │ Description: Deletes ALL literal (regex-safe, symbol/space-agnostic)     │
" │ occurrences of <text> across the whole buffer, case-sensitive. <text>    │
" │ may contain spaces, punctuation, or code syntax — works for single       │
" │ words or full multi-word phrases, matching the same \V-literal engine    │
" │ as :R. After a successful delete, every FULL LINE that had a match is    │
" │ highlighted (since the deleted text itself no longer exists to           │
" │ highlight), built via ordinary-magic \%Nl line-number atoms — clear via  │
" │ <S-l> / :nohlsearch, identical to :R's behavior. Reports the number of   │
" │ occurrences deleted.                                                     │
" └──────────────────────────────────────────────────────────────────────────┘
function! QuickDelete(args) abort
    let l:target = trim(a:args)

    if l:target ==# ''
        echo "Usage: :D <word(s)/text to delete>"
        echo "  e.g. :D haoz"
        echo "  e.g. :D foo.bar[0]"
        echo "  e.g. :D assign a = b;"
        return
    endif

    " ── Build a fully literal (\V) search pattern ─────────────────────────
    let l:escaped = escape(l:target, '\/')
    let l:pattern = '\V\C' . l:escaped

    " ── Find occurrences + collect affected line numbers ──────────────────
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

    " ── Highlight affected full lines (ordinary magic mode, correct \%Nl) ─
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


" ┌──────────────────────────────────────────────────────────────────────────┐
" │              WORD / SELECTION HIGHLIGHT BOOKMARK  ( m  /  ml )           │
" │   Marks are bound to BUFFER content — they never leak into netrw/        │
" │   WinList/other buffers reused in the same window, and never fire        │
" │   automatically outside of an explicit  m  /  ml  keypress.              │
" │ Description: Persistent per-buffer text-highlight bookmarks (a manual    │
" │ "sticky highlight" separate from search-highlight). Press  m  on a       │
" │ word (Normal) or a selection (Visual) to toggle a highlight mark at      │
" │ that exact position; marks persist across buffer switches (redrawn via   │
" │ matchaddpos on BufEnter) and are cleaned up automatically when a         │
" │ buffer is wiped out. Press  ml  to clear all marks in the current        │
" │ buffer.                                                                  │
" └──────────────────────────────────────────────────────────────────────────┘

function! s:MarkedHighlights() abort
    silent! highlight default MarkedWord guibg=#7a333d guifg=NONE gui=NONE ctermbg=95 ctermfg=NONE
    silent! highlight default MarkedLine guibg=#7a333d guifg=NONE gui=NONE ctermbg=95 ctermfg=NONE
endfunction
call s:MarkedHighlights()

augroup MarkedHighlightColors
    autocmd!
    autocmd ColorScheme * call s:MarkedHighlights()
augroup END

" g:marked_store : { bufnr : { key : {'group': <hl>, 'pos': [[l,c,len], ...]} } }
if !exists('g:marked_store')
    let g:marked_store = {}
endif

" ── Guard: only allow marking on real, normal file buffers ──────────────────
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

" Clear the visual matches (only) in the CURRENT window — storage untouched
function! s:ClearWindowMatches() abort
    if exists('w:marked_ids')
        for l:id in w:marked_ids
            silent! call matchdelete(l:id)
        endfor
    endif
    let w:marked_ids = []
endfunction

" Vim cho tối đa 8 position trong MỘT matchaddpos() (quá 8 -> lỗi E5030
" "Too many positions").  Selection dài hơn 8 dòng phải chẻ thành nhiều match.
let s:maxpos = 8

" (Re)draw matches for whatever buffer is now loaded in this window.
" LƯU Ý (bug đã sửa): mark lưu theo (dòng, cột), nên sau khi sửa/xoá dòng thì
" vị trí cũ có thể vượt quá số dòng hiện có -> matchaddpos() ném lỗi ở MỌI
" lần BufEnter (vì hàm này chạy mỗi lần vào buffer), làm 'm' trông như lỗi.
" Giờ: lọc lại vị trí, bỏ entry không còn hợp lệ, chẻ ≤ 8 position/match, và
" bọc matchaddpos trong silent!.
function! s:ApplyMarksForCurrentBuffer() abort
    call s:ClearWindowMatches()
    let l:bn = bufnr('%')
    if !has_key(g:marked_store, l:bn) | return | endif

    let l:last = line('$')
    for [l:key, l:entry] in items(g:marked_store[l:bn])
        " chỉ giữ vị trí còn nằm trong buffer và có độ dài > 0
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

" Free memory when a buffer is wiped out
augroup MarkedBufWipe
    autocmd!
    autocmd BufWipeout * if has_key(g:marked_store, str2nr(expand('<abuf>')))
                       \ |   call remove(g:marked_store, str2nr(expand('<abuf>')))
                       \ | endif
augroup END

" ── Find exact (line, col, len) of the word instance under the cursor ───────
function! s:GetWordAtCursorPos() abort
    let l:cword = expand('<cword>')
    if l:cword ==# '' | return [] | endif

    let l:line     = getline('.')
    " escape phải có cả '\' (iskeyword của .sv có thể chứa '$', '.', … nên cword
    " có thể là '$display' -> thiếu escape là pattern hỏng, matchstrpos ném lỗi)
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

" ── Toggle highlight on the exact word occurrence under cursor ──────────────
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

" ── Build exact [line, col, len] list for the current visual selection ──────
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

" ── Toggle highlight on the exact visual selection ──────────────────────────
function! ToggleMarkSelection() abort
    if !s:MarkGuardOK() | return | endif

    let l:positions = s:GetVisualSelectionPositions()
    if empty(l:positions) | return | endif
    " Chặn selection quá lớn: mỗi lần BufEnter phải dựng lại toàn bộ match, và
    " 1 selection cả nghìn dòng sẽ làm chậm thấy rõ.
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

" ── Clear all marks for the CURRENT buffer only ─────────────────────────────
function! ClearAllMarks() abort
    let l:bn = bufnr('%')
    if has_key(g:marked_store, l:bn)
        let g:marked_store[l:bn] = {}
    endif
    call s:ApplyMarksForCurrentBuffer()
    echo "All marks cleared (this buffer)"
endfunction

" CHỈ 2 phím (theo yêu cầu):
"   mh = toggle mark (Normal: từ dưới con trỏ / Visual: cả vùng chọn)
"   ml = clear all mark của buffer hiện tại
" 'm' một mình KHÔNG còn map -> trả lại cho Vim lệnh đặt mark gốc (ma, mb, …).
nnoremap <silent> mh :call ToggleMarkWord()<CR>
vnoremap <silent> mh :<C-u>call ToggleMarkSelection()<CR>
nnoremap <silent> ml :call ClearAllMarks()<CR>

" ┌──────────────────────────────────────────────────────────────────────────┐
" │                    F1 — VIMRC MANUAL (TOP SPLIT TOGGLE)                  │
" │ Description: F1 toggles a top-half horizontal split showing a built-in   │
" │ cheat-sheet documenting this vimrc's keybindings and auto-features.      │
" │ Read-only scratch buffer; press F1 or q inside it to close.              │
" └──────────────────────────────────────────────────────────────────────────┘

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
    call add(l:L, '  Version 7.42  ·  2026-11-19')
    call add(l:L, '═══════════════════════════════════════════════════════════════════')
    call add(l:L, '')

    call add(l:L, '▶ STATUSLINE')
    call add(l:L, '  • Bố cục: `~/.vimrc` bên trái, `[CL<current>:TL<total>]` bên phải')
    call add(l:L, '     CL = dòng hiện tại, TL = tổng số dòng của buffer')
    call add(l:L, '  • Thứ tự BỐN khối, SÁT nhau không dấu cách:')
    call add(l:L, '     `[CL12:TL431][4sp][systemverilog][V7.42]`')
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
    call add(l:L, '     theo độ thụt (0-3 / 4-7 / >=8 space).')
    call add(l:L, '     Phím: CHỈ `za` (toggle fold hiện tại) + `zo` (toggle tất cả)')
    call add(l:L, '     TỰ FORMAT TOÀN BỘ NỘI DUNG mỗi lần ghi file: căn bảng, bỏ')
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
    call add(l:L, '  • `.md`  `foldmethod=expr` theo TIÊU ĐỀ (hàm `HaozMdFoldLevel`/')
    call add(l:L, '     `HaozMdFoldText` nằm NGAY trong .vimrc, không phụ thuộc')
    call add(l:L, '     ftplugin); mở file = ĐÓNG HẾT (`foldlevel=0`).')
    call add(l:L, '  • `.sv/.v/.svt`  `foldmethod=indent`; mở file = `foldlevel=3`')
    call add(l:L, '     (khối lồng tới cấp 3 vẫn mở -> đọc được tổng quan).')
    call add(l:L, '  • Phím: `za` = toggle fold hiện tại (Vim gốc) | `zo` = toggle')
    call add(l:L, '     TẤT CẢ fold | `zA` = toggle fold hiện tại + toàn bộ node con')
    call add(l:L, '     (chỉ .sv — `HaozFoldToggleRecursive`)')
    call add(l:L, '  • `zo` toggle giữa MỞ HẾT <-> GẬP VỀ mức "home" của buffer:')
    call add(l:L, '     `.sv` -> 3 (không gập xuống 0), `.md` -> 0 (`b:haoz_fold_home`)')
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
    call add(l:L, '     panel WinList / session picker / Vimrc Manual luôn nowrap)')
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
