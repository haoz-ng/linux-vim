" ╔══════════════════════════════════════════════════════════════════════════╗
" ║  FILE NÀY COPY VÀO:  ~/.vim/syntax/md.vim                                ║
" ║  (tên file trên Windows là syntax.md.vim để biết chỗ đặt; khi copy phải  ║
" ║   đổi tên thành md.vim)                                                  ║
" ║                                                                          ║
" ║  Gốc: hughbien/md-vim — syntax/md.vim (BSD License, Hugh Bien).          ║
" ║  Bản của bạn haozxje, sửa so với gốc:                                    ║
" ║   • CHỮ THƯỜNG MÀU TRẮNG: mdPreCode (gồm cả dòng thụt 4 space và khối    ║
" ║     ``` … ```), mdBlockquote, mdBold, mdItalic, text trong list.         ║
" ║     Gốc link các nhóm này sang PreProc/Number/Function nên chữ bị tím/   ║
" ║     xanh — đó là lý do "text không trắng".                               ║
" ║   • **đậm** / *nghiêng* / ~~gạch~~ đổi từ 'syn match' sang REGION nên    ║
" ║     tô được cả khi nội dung XUỐNG DÒNG (gốc chỉ match trong 1 hàng).     ║
" ║   • Dòng thụt 4 space: mdPreCode thêm 'contains=' nên vẫn giữ chữ        ║
" ║     trắng mà vẫn có đậm/nghiêng/`code`/link (gốc nuốt cả dòng -> mất     ║
" ║     hết syntax phía sau 4 space).  Tắt: let g:md_indent_is_code = 0      ║
" ║   • Mục list chia 3 CẤP theo độ thụt lề (0-3 / 4-7 / >=8 space) để       ║
" ║     nhìn thấy mục con.                                                   ║
" ║   • Màu còn lại lấy đúng palette haoz (không link sang nhóm colorscheme, ║
" ║     để đổi colorscheme không làm lệch màu markdown).                     ║
" ║   • Giữ NGUYÊN phần include syntax theo ngôn ngữ trong fence             ║
" ║     (g:md_fenced_languages) — nhờ nó ```systemverilog mới có màu SV.     ║
" ║   • Thêm autocmd ColorScheme để gắn lại màu sau khi đổi colorscheme.     ║
" ╚══════════════════════════════════════════════════════════════════════════╝

" Language: Markdown
" Maintainer: Hugh Bien (http://hughbien.com) — bản gốc
" Maintainer (bản này): haozxje

if exists("b:current_syntax")
  finish
endif
syntax clear

if !exists("main_syntax")
  let main_syntax = "md"
endif

" ── Inline ─────────────────────────────────────────────────────────────────
syn match mdCode           "`[^`]\+`"
syn match mdFootnote       "\[\^[^\]]*\]"
syn match mdHtmlAttr       "\s[^>"]\+" contained
syn match mdHtmlString     "\"[^"]\+\"" contained
syn match mdHtmlTag        "<[!/]\?[^>]\+>" contains=mdHtmlAttr,mdHtmlString
syn match mdHtmlComment    "<!--.*-->"
syn match mdUrl            "<[a-zA-Z]\+://[^>]\+>"
syn match mdUrl            "</[^>/]\+[/_-][^>]*>"
syn match mdUrl            "<#[^>]*>"
syn match mdLinkUrl        "([^)]\+)" contained
syn match mdLink           "\[[^]]*\]([^)]\+)" contains=mdLinkUrl
syn match mdImg            "!\[[^]]*\]([^)]\+)" contains=mdLinkUrl
syn match mdHeaderId       /{#[^}]\+}/ contained

" ── ĐẬM / NGHIÊNG / GẠCH: REGION (tô được nhiều hàng) ──────────────────────
" Khác gốc: gốc dùng 'syn match "\*\*[^\*]\+\*\*"' -> chỉ tô khi mở và đóng
" nằm CÙNG một hàng.  Ở đây dùng 'syn region' nên **đậm** kéo dài qua nhiều
" hàng vẫn tô hết (markdown cho phép xuống dòng bên trong **…**).
" Hai điều kiện để không nhận nhầm:
"   • ngay SAU dấu mở phải là ký tự không-space, không phải chính dấu đó
"     (\%(\S\)\@= là lookahead) -> dấu '-' / '*' của MỤC LIST, vốn luôn có
"     space phía sau, không bị nhận là đậm/nghiêng;
"   • ngay TRƯỚC dấu đóng cũng phải là ký tự không-space.
" Thêm 'end=^\s*$': nếu thiếu dấu đóng thì vùng dừng ở DÒNG TRỐNG, không
" "nuốt" phần còn lại của file.
syn region mdBold   start="\*\*\%(\S\)\@="    end="\%(\S\)\@<=\*\*\|^\s*\n"    keepend
syn region mdBold   start="__\%(\S\)\@="      end="\%(\S\)\@<=__\|^\s*\n"      keepend
syn region mdItalic start="\*\%([^ \t*]\)\@=" end="\%([^ \t*]\)\@<=\*\|^\s*\n" keepend
syn region mdItalic start="_\%([^ \t_]\)\@="  end="\%([^ \t_]\)\@<=_\|^\s*\n"  keepend
syn region mdStrike start="\~\~\%(\S\)\@="    end="\%(\S\)\@<=\~\~\|^\s*\n"    keepend

syn match mdHeader         /^.\+\n=\+\s*$/ contains=mdHeaderId,mdCode,mdItalic,mdBold,mdStrike,mdLink,mdUrl,mdImg
syn match mdHeader2        /^.\+\n-\+\s*$/ contains=mdHeaderId,mdCode,mdItalic,mdBold,mdStrike,mdLink,mdUrl,mdImg
syn match mdHeader         "^\#.*" contains=mdHeaderId,mdCode,mdItalic,mdBold,mdStrike,mdLink,mdUrl,mdImg
syn match mdHeader2        "^\##.*" contains=mdHeaderId,mdCode,mdItalic,mdBold,mdStrike,mdLink,mdUrl,mdImg
syn match mdHeader3        "^\###.*" contains=mdHeaderId,mdCode,mdItalic,mdBold,mdStrike,mdLink,mdUrl,mdImg
syn match mdHeader4        "^\####.*" contains=mdHeaderId,mdCode,mdItalic,mdBold,mdStrike,mdLink,mdUrl,mdImg
syn match mdHeader5        "^\#####.*" contains=mdHeaderId,mdCode,mdItalic,mdBold,mdStrike,mdLink,mdUrl,mdImg
syn match mdHeader6        "^\######.*" contains=mdHeaderId,mdCode,mdItalic,mdBold,mdStrike,mdLink,mdUrl,mdImg
syn match mdTask           "\s*\[ \]"
syn match mdTaskDone       "\s*\[x\].*$"

" ── MỤC LIST: 3 CẤP theo độ thụt lề ────────────────────────────────────────
" Cấp 1: 0-3 space | Cấp 2: 4-7 space (mục con) | Cấp 3: >=8 space (mục cháu).
" Nhóm "cấp 1" giữ tên cũ (mdListItem) để không phá các 'contains=' khác.
" Thứ tự khai báo quan trọng: cùng bắt đầu ở cột 1 thì nhóm khai báo SAU
" thắng, nên cấp 2/3 phải nằm sau cấp 1.
syn match mdListItem       "^\s*\(+\|-\|*\)\s"
syn match mdListItem2      "^\s\{4,7}[+*-]\ze\s"
syn match mdListItem3      "^\s\{8,}[+*-]\ze\s"
syn match mdNumListItem    "^\s*[0-9]\+\.\s"
syn match mdNumListItem2   "^\s\{4,7}[0-9]\+\.\ze\s"
syn match mdNumListItem3   "^\s\{8,}[0-9]\+\.\ze\s"

syn match mdTableBorder    "^\s*|" contained
syn match mdTableBorder    "\s|" contained
syn match mdTableBorder    "\s|\s*$" contained
syn match mdTableRow       "^\s*|.*|\s*$" contains=mdTableBorder,mdCode,mdItalic,mdBold,mdStrike,mdLink,mdUrl,mdImg
syn match mdTableHead      "^\s*|[-: |]*|\s*$"
syn match mdSeparator      "^===\+\s*$"
syn match mdSeparator      "^---\+\s*$"
syn match mdSeparator      "^\*\*\*\+\s*$"
" Blockquote: phải 'contains=' thì **đậm**/*nghiêng*/link bên trong mới có màu
" (gốc không có -> cả hàng '> …' chỉ một màu).
syn match mdBlockquote     "^\s*>.*" contains=mdCode,mdItalic,mdBold,mdStrike,mdLink,mdUrl,mdImg,mdTask,mdTaskDone

" ── Dòng thụt 4 space = code block trong markdown ──────────────────────────
" NHƯNG nếu mdPreCode phủ cả dòng mà không có 'contains=' (bản gốc) thì mọi
" thứ trong dòng đó mất màu -> đây chính là hiện tượng "syntax chỉ tác dụng
" khi dòng KHÔNG có space đầu dòng".  Cách sửa: giữ mdPreCode (ra chữ TRẮNG)
" + cho nó contains các nhóm inline.  Muốn coi 4 space là văn thường hoàn
" toàn: let g:md_indent_is_code = 0  (đặt trong vimrc).
if get(g:, 'md_indent_is_code', 1)
  syn match mdPreCode "^    .*" contains=mdCode,mdItalic,mdBold,mdStrike,mdLink,mdLinkUrl,mdUrl,mdImg,mdTask,mdTaskDone,mdTableRow,mdTableHead,mdSeparator,mdListItem,mdListItem2,mdListItem3,mdNumListItem,mdNumListItem2,mdNumListItem3
endif
syn region mdPreCode       start="^\s*````*.*$" end="^\s*````*\ze\s*$" keepend
syn region mdPreCode       start=/\%^+++\s*$/ end=/^+++\s*$/ keepend

" fenced implementation copied from https://github.com/tpope/vim-markdown
if !exists("g:md_fenced_languages")
  let g:md_fenced_languages = []
endif
let s:done_include = {}
for s:type in map(copy(g:md_fenced_languages),'matchstr(v:val,"[^=]*$")')
  if has_key(s:done_include, matchstr(s:type,'[^.]*'))
    continue
  endif
  if s:type =~ '\.'
    let b:{matchstr(s:type,'[^.]*')}_subtype = matchstr(s:type,'\.\zs.*')
  endif
  exe 'syn include @markdownHighlight'.substitute(s:type,'\.','','g').' syntax/'.matchstr(s:type,'[^.]*').'.vim'
  unlet! b:current_syntax
  let s:done_include[matchstr(s:type,'[^.]*')] = 1
endfor
unlet! s:type
unlet! s:done_include

if main_syntax ==# "md"
  let s:concealends = ""
  let s:done_include = {}
  for s:type in g:md_fenced_languages
    if has_key(s:done_include, matchstr(s:type,'[^.]*'))
      continue
    endif
    exe 'syn region markdownHighlight'.substitute(matchstr(s:type,'[^=]*$'),'\..*','','').' matchgroup=mdPreCode start="^\s*````*\s*\%({.\{-}\.\)\='.matchstr(s:type,'[^=]*').'}\=\S\@!.*$" end="^\s*````*\ze\s*$" keepend contains=@markdownHighlight'.substitute(matchstr(s:type,'[^=]*$'),'\.','','g') . s:concealends
    let s:done_include[matchstr(s:type,'[^.]*')] = 1
  endfor
  unlet! s:type
  unlet! s:done_include
endif

" ══════════════════════════════════════════════════════════════════════════
"  MÀU — palette haoz + chữ thường TRẮNG
" ══════════════════════════════════════════════════════════════════════════
function! s:MdColors() abort
  let l:white   = '#ffffff'
  let l:red     = '#e06c75'
  let l:green   = '#98c379'
  let l:yellow  = '#e5c07b'
  let l:blue    = '#61afef'
  let l:magenta = '#c678dd'
  let l:cyan    = '#56b6c2'
  let l:dim     = '#5c6370'
  let l:purple  = '#bf65cf'

  " ── CHỮ THƯỜNG: TRẮNG ───────────────────────────────────────────────────
  " mdPreCode là nhóm quan trọng nhất: nó phủ dòng thụt 4 space VÀ khối
  " ``` … ``` -> nếu link sang PreProc thì gần như cả file thành màu tím.
  execute 'highlight mdPreCode     guifg=' . l:white . ' guibg=NONE gui=NONE'
  execute 'highlight mdBlockquote  guifg=' . l:white . ' guibg=NONE gui=italic'
  execute 'highlight mdBold        guifg=' . l:white . ' guibg=NONE gui=bold'
  execute 'highlight mdItalic      guifg=' . l:white . ' guibg=NONE gui=italic'
  execute 'highlight mdStrike      guifg=' . l:dim   . ' guibg=NONE gui=strikethrough'

  " ── Tiêu đề ─────────────────────────────────────────────────────────────
  execute 'highlight mdHeader      guifg=' . l:blue . ' guibg=NONE gui=bold,underline'
  execute 'highlight mdHeader2     guifg=' . l:blue . ' guibg=NONE gui=bold'
  execute 'highlight mdHeader3     guifg=' . l:cyan . ' guibg=NONE gui=bold'
  execute 'highlight mdHeader4     guifg=' . l:cyan . ' guibg=NONE gui=bold'
  execute 'highlight mdHeader5     guifg=' . l:dim  . ' guibg=NONE gui=bold'
  execute 'highlight mdHeader6     guifg=' . l:dim  . ' guibg=NONE gui=bold'
  execute 'highlight mdHeaderId    guifg=' . l:yellow . ' guibg=NONE gui=NONE'

  " ── Code / link ─────────────────────────────────────────────────────────
  execute 'highlight mdCode        guifg=' . l:green . ' guibg=NONE gui=NONE'
  execute 'highlight mdLink        guifg=' . l:blue  . ' guibg=NONE gui=NONE'
  execute 'highlight mdLinkUrl     guifg=' . l:cyan  . ' guibg=NONE gui=underline'
  execute 'highlight mdUrl         guifg=' . l:cyan  . ' guibg=NONE gui=underline'
  execute 'highlight mdImg         guifg=' . l:blue  . ' guibg=NONE gui=NONE'
  execute 'highlight mdFootnote    guifg=' . l:purple . ' guibg=NONE gui=bold'

  " ── Danh sách / bảng / phân cách ────────────────────────────────────────
  " Chỉ DẤU đầu dòng được tô, chữ phía sau là Normal (trắng).
  " Màu dấu đổi theo CẤP: 1 đỏ, 2 vàng, 3 xanh cyan -> thấy ngay mục con.
  execute 'highlight mdListItem     guifg=' . l:red    . ' guibg=NONE gui=bold'
  execute 'highlight mdListItem2    guifg=' . l:yellow . ' guibg=NONE gui=bold'
  execute 'highlight mdListItem3    guifg=' . l:cyan   . ' guibg=NONE gui=bold'
  execute 'highlight mdNumListItem  guifg=' . l:red    . ' guibg=NONE gui=bold'
  execute 'highlight mdNumListItem2 guifg=' . l:yellow . ' guibg=NONE gui=bold'
  execute 'highlight mdNumListItem3 guifg=' . l:cyan   . ' guibg=NONE gui=bold'
  execute 'highlight mdTask        guifg=' . l:green . ' guibg=NONE gui=bold'
  execute 'highlight mdTaskDone    guifg=' . l:dim   . ' guibg=NONE gui=italic'
  execute 'highlight mdTableHead   guifg=' . l:yellow . ' guibg=NONE gui=bold'
  execute 'highlight mdTableBorder guifg=' . l:dim   . ' guibg=NONE gui=NONE'
  execute 'highlight mdSeparator   guifg=' . l:magenta . ' guibg=NONE gui=bold'

  " ── HTML lẫn trong markdown ─────────────────────────────────────────────
  execute 'highlight mdHtmlTag     guifg=' . l:blue  . ' guibg=NONE gui=NONE'
  execute 'highlight mdHtmlAttr    guifg=' . l:yellow . ' guibg=NONE gui=NONE'
  execute 'highlight mdHtmlString  guifg=' . l:green . ' guibg=NONE gui=NONE'
  execute 'highlight mdHtmlComment guifg=' . l:dim   . ' guibg=NONE gui=italic'
endfunction

call s:MdColors()

" ':colorscheme' chạy 'hi clear' -> các nhóm trên bị xoá; gắn lại.
" Dùng autocmd GLOBAL (không <buffer>) vì highlight group là global, và như
" vậy mỗi lần một buffer .md được nạp chỉ thay thế đúng 1 entry, không xoá
" mất entry của buffer khác.
augroup md_colors
  autocmd!
  autocmd ColorScheme * call s:MdColors()
augroup END

let b:current_syntax = "md"
if main_syntax ==# "md"
  unlet main_syntax
endif

" Front-Matter YAML
unlet b:current_syntax
syn include @mdYaml syntax/yaml.vim
syn region mdFrontYaml start=/\%^---\s*$/ end=/^---\s*$/ keepend contains=@mdYaml
