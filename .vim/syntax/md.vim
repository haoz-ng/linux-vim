" ╔══════════════════════════════════════════════════════════════════════════╗
" ║  FILE NÀY COPY VÀO:  ~/.vim/syntax/md.vim                                ║
" ║  (tên file trên Windows là syntax.md.vim để biết chỗ đặt; khi copy phải  ║
" ║   đổi tên thành md.vim)                                                  ║
" ║                                                                          ║
" ║  Gốc: hughbien/md-vim — syntax/md.vim (BSD License, Hugh Bien).          ║
" ║  Bản của bạn haozxje, sửa so với gốc:                                    ║
" ║   • CHỮ THƯỜNG MÀU TRẮNG: mdPreCode (khối ``` … ```), mdBlockquote,      ║
" ║     mdBold, mdItalic, text trong list.  Gốc link các nhóm này sang       ║
" ║     PreProc/Number/Function nên chữ bị tím/xanh.                         ║
" ║   • **đậm** / *nghiêng* / ~~gạch~~ là REGION nên tô được cả khi nội      ║
" ║     dung XUỐNG DÒNG; bên trong **đậm** vẫn hiện đúng `code`/link.        ║
" ║   • TIÊU ĐỀ cho phép THỤT ĐẦU DÒNG BAO NHIÊU CŨNG ĐƯỢC (vd "    ###"),   ║
" ║     vẫn đúng cấp H1..H6; đường kẻ ===/---/*** cũng cho phép thụt lề.     ║
" ║   • `code` thường màu XANH LÁ; `code` có chứa dấu / (đường dẫn) màu      ║
" ║     XANH BIỂN.  Dấu ``` mở/đóng fence màu CAM, bắt đầu đúng từ dấu `.    ║
" ║   • NỀN XÁM của khối ``` … ``` KHÔNG do file này vẽ — ftplugin/md.vim vẽ ║
" ║     bằng matchaddpos (nhóm mdFenceBg, g:md_fence_bg + g:md_fence_pad),   ║
" ║     vì 'syn keyword' đứng đầu dòng luôn thắng 'syn match/region'.  Cạnh  ║
" ║     trái = lề NHỎ NHẤT của khối (các dòng thẳng cột).  Dòng ``` vẫn CAM, ║
" ║     không nền (matchgroup=mdFence).                                      ║
" ║   • HIỆU NĂNG: 'syn sync minlines=120' — giới hạn số dòng Vim quét ngược ║
" ║     khi vẽ lại (không có thì cuộn file dài rất lag).                     ║
" ║   • Dòng thụt 4 space MẶC ĐỊNH KHÔNG phải code block (kiểu ghi chú dùng  ║
" ║     4 space cho cấu trúc).  Bật lại: let g:md_indent_is_code = 1         ║
" ║     (khi đó dòng thụt 4 space ra chữ TRẮNG như code).                    ║
" ║   • Mục list chia 3 CẤP theo độ thụt lề (0-3 / 4-7 / >=8 space).         ║
" ║   • Màu còn lại lấy đúng palette haoz (không link sang nhóm colorscheme, ║
" ║     để đổi colorscheme không làm lệch màu markdown).                     ║
" ║   • Giữ NGUYÊN phần include syntax theo ngôn ngữ trong fence             ║
" ║     (g:md_fenced_languages) — nhờ nó ```systemverilog mới có màu SV.     ║
" ║   • Thêm autocmd ColorScheme để gắn lại màu sau khi đổi colorscheme.     ║
" ╚══════════════════════════════════════════════════════════════════════════╝

" Language: Markdown
" Maintainer: Hugh Bien (http://hughbien.com) — bản gốc
" Maintainer (bản này): haozxje

" Guard: chỉ bỏ qua khi CHÍNH FILE NÀY đã nạp cho buffer (b:md_syntax_loaded).
" Dùng 'b:current_syntax' không thôi là nguy hiểm: một 'syn include' khác (vd
" yaml.vim) có thể đặt b:current_syntax = 'yaml' và như vậy file md bị chặn
" nạp -> KHÔNG quy tắc nào được định nghĩa (tiêu đề mất màu hoàn toàn).
if get(b:, 'md_syntax_loaded', 0) && exists('b:current_syntax') && b:current_syntax ==# 'md'
  finish
endif
syntax clear

if !exists("main_syntax")
  let main_syntax = "md"
endif

" ── Inline ─────────────────────────────────────────────────────────────────
syn match mdCode           "`[^`]\+`"
" PATH nội tuyến: `...` có dấu '/' (vd `/nobackup/RLE1396/...`, `~/x`, `a/b`)
" -> tô XANH BIỂN, tách khỏi `code` thường (vẫn xanh lá).  Khai báo SAU mdCode
" nên thắng ở cùng vị trí bắt đầu.
syn match mdCodePath       "`[^`]*/[^`]*`"
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
" 'contains=' để **đậm** vẫn hiện đúng `code`/link/[*nghiêng*] BÊN TRONG.
syn region mdBold   start="\*\*\%(\S\)\@="    end="\%(\S\)\@<=\*\*\|^\s*\n"    keepend contains=mdCode,mdCodePath,mdItalic,mdLink,mdUrl,mdImg,mdStrike
syn region mdBold   start="__\%(\S\)\@="      end="\%(\S\)\@<=__\|^\s*\n"      keepend contains=mdCode,mdCodePath,mdItalic,mdLink,mdUrl,mdImg,mdStrike
syn region mdItalic start="\*\%([^ \t*]\)\@=" end="\%([^ \t*]\)\@<=\*\|^\s*\n" keepend contains=mdCode,mdCodePath,mdLink,mdUrl,mdImg
syn region mdItalic start="_\%([^ \t_]\)\@="  end="\%([^ \t_]\)\@<=_\|^\s*\n"  keepend contains=mdCode,mdCodePath,mdLink,mdUrl,mdImg
syn region mdStrike start="\~\~\%(\S\)\@="    end="\%(\S\)\@<=\~\~\|^\s*\n"    keepend contains=mdCode,mdCodePath,mdLink,mdUrl,mdImg

" TIÊU ĐỀ: cho phép THỤT ĐẦU DÒNG **KHÔNG GIỚI HẠN** (`^\s*`).
" Kiểu ghi chú của bạn haozxje thụt 4 space MỖI CẤP, cộng dồn:
"     '#'  -> cột 0    (0 space)
"     '##' -> 4 space
"     '###'-> 8 space      <-- bản trước chỉ cho 0..7 nên '###' KHÔNG khớp
"     '####'-> 12 space
" (Đã gặp đúng lỗi này: :MdSyn cho indent()=8 và syn= rỗng.)
" DÙNG DẤU /…/ (không dùng chuỗi nháy kép) để khỏi phải escape: bản trước
" viết "…\\#…" -> Vim coi '\#' là atom KHÔNG hợp lệ -> 6 lệnh 'syn match'
" đều bị bỏ, tiêu đề mất màu hoàn toàn.
" Nhóm khai báo SAU thắng khi cùng bắt đầu ở cột 1 -> giữ thứ tự H1 → H6.
syn match mdHeader         /^.\+\n=\+\s*$/ contains=mdHeaderId,mdCode,mdCodePath,mdItalic,mdBold,mdStrike,mdLink,mdUrl,mdImg
syn match mdHeader2        /^.\+\n-\+\s*$/ contains=mdHeaderId,mdCode,mdCodePath,mdItalic,mdBold,mdStrike,mdLink,mdUrl,mdImg
syn match mdHeader         /^\s*#\s.*/    contains=mdHeaderId,mdCode,mdCodePath,mdItalic,mdBold,mdStrike,mdLink,mdUrl,mdImg
syn match mdHeader2        /^\s*##\s.*/   contains=mdHeaderId,mdCode,mdCodePath,mdItalic,mdBold,mdStrike,mdLink,mdUrl,mdImg
syn match mdHeader3        /^\s*###\s.*/  contains=mdHeaderId,mdCode,mdCodePath,mdItalic,mdBold,mdStrike,mdLink,mdUrl,mdImg
syn match mdHeader4        /^\s*####\s.*/ contains=mdHeaderId,mdCode,mdCodePath,mdItalic,mdBold,mdStrike,mdLink,mdUrl,mdImg
syn match mdHeader5        /^\s*#####\s.*/ contains=mdHeaderId,mdCode,mdCodePath,mdItalic,mdBold,mdStrike,mdLink,mdUrl,mdImg
syn match mdHeader6        /^\s*######\s.*/ contains=mdHeaderId,mdCode,mdCodePath,mdItalic,mdBold,mdStrike,mdLink,mdUrl,mdImg
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
syn match mdTableRow       "^\s*|.*|\s*$" contains=mdTableBorder,mdCode,mdCodePath,mdItalic,mdBold,mdStrike,mdLink,mdUrl,mdImg
syn match mdTableHead      "^\s*|[-: |]*|\s*$"
" (dùng /…/ cho khỏi phải escape 2 lần như các dòng trên)
syn match mdSeparator      /^\s*===\+\s*$/
syn match mdSeparator      /^\s*---\+\s*$/
syn match mdSeparator      /^\s*\*\*\*\+\s*$/
" Blockquote: phải 'contains=' thì **đậm**/*nghiêng*/link bên trong mới có màu
" (gốc không có -> cả hàng '> …' chỉ một màu).
syn match mdBlockquote     "^\s*>.*" contains=mdCode,mdCodePath,mdItalic,mdBold,mdStrike,mdLink,mdUrl,mdImg,mdTask,mdTaskDone

" ── Dòng thụt 4 space: MẶC ĐỊNH KHÔNG phải code block ─────────────────────
" Kiểu ghi chú của bạn haozxje dùng thụt 4 space cho CẤU TRÚC (tiêu đề cấp
" con, mục list, đoạn văn) chứ không dùng để viết code block (code viết trong
" ``` … ```).  Vì vậy mặc định TẮT quy tắc "thụt 4 space = code", để tiêu đề
" thụt đầu dòng vẫn lên màu tiêu đề, **đậm**/*nghiêng*/`code` vẫn tô bình
" thường.  Muốn BẬT lại (coi 4 space là code, chữ trắng):
"     let g:md_indent_is_code = 1
if get(g:, 'md_indent_is_code', 0)
  syn match mdPreCode "^    .*" contains=mdCode,mdCodePath,mdItalic,mdBold,mdStrike,mdLink,mdLinkUrl,mdUrl,mdImg,mdTask,mdTaskDone,mdTableRow,mdTableHead,mdSeparator,mdListItem,mdListItem2,mdListItem3,mdNumListItem,mdNumListItem2,mdNumListItem3
endif
" HIỆU NĂNG: khi vẽ lại, Vim phải quét NGƯỢC để biết đang nằm trong khối ```
" nào.  Với syntax nhiều 'syn region' mà không khai báo 'syn sync', mỗi lần
" cuộn/nhảy trang Vim quét lại từ rất xa -> lag trên file dài.  Giới hạn 120
" dòng (fence thực tế ngắn hơn nhiều).
syn sync minlines=120
syn sync maxlines=360

" ── FENCE ``` ──────────────────────────────────────────────────────────────
" Dấu ``` + tên ngôn ngữ trên dòng đó -> CAM (matchgroup=mdFence), KHÔNG nền.
" NỀN XÁM của khối KHÔNG làm bằng syntax nữa — xem ftplugin/md.vim
" (s:FenceBgApply dùng matchaddpos).  LÝ DO: 'syn keyword' đứng đầu dòng LUÔN
" thắng 'syn match'/'syn region' (luật :syn-priority), nên mọi dòng mở đầu
" bằng từ khoá (bit, if, constraint, end…) bị MẤT nền; chỉ dòng mở đầu bằng
" ký hiệu mới có nền -> nền so le đúng như đã thấy.
" Ở đây syntax chỉ lo MÀU CHỮ: chữ thường trắng, còn fence có ghi ngôn ngữ
" thì cluster của ngôn ngữ đó tô (contains=), màu chữ hoàn toàn không đổi.
syn region mdPreCode       matchgroup=mdFence start=/^\s*\zs````*.*$/ end=/^\s*\zs````*$/ keepend
syn region mdPreCode       matchgroup=mdFence start=/\%^+++\s*$/ end=/^+++\s*$/ keepend

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
    " Region tên 'mdPreCode' (không phải 'markdownHighlightXXX' như gốc);
    " contains = cluster của CHÍNH ngôn ngữ ghi trên dòng ``` — chỉ lo MÀU CHỮ.
    exe 'syn region mdPreCode matchgroup=mdFence start=/^\s*\zs````*\s*\%({.\{-}\.\)\='.matchstr(s:type,'[^=]*').'}\=\S\@!/ end=/^\s*\zs````*$/ keepend contains=@markdownHighlight'.substitute(matchstr(s:type,'[^=]*$'),'\.','','g').s:concealends
    let s:done_include[matchstr(s:type,'[^.]*')] = 1
  endfor
  unlet! s:type
  unlet! s:done_include
endif

" Nền khối ``` do CHÍNH region mdPreCode phủ (xem khối FENCE ở trên).  KHÔNG
" dùng 'syn match' riêng cho nền nữa: match chỉ phủ được từ ký tự đầu đến ký
" tự cuối của dòng -> nền bị so le, còn region phủ từ CỘT 1 tới HẾT DÒNG.

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
  let l:orange  = '#d19a66'   " cam (One Dark) — dùng cho DẤU FENCE ```
  let l:grid    = '#8a8f98'   " xám SÁNG cho dấu | của bảng (nền bảng là #363636)

  " ── Dấu FENCE ``` ───────────────────────────────────────────────────────
  " mdFence   = dòng mở/đóng (kể cả tên ngôn ngữ) -> CAM, KHÔNG nền.
  " mdPreCode = chữ bên trong fence -> trắng, KHÔNG nền.
  " (NỀN XÁM của khối do ftplugin/md.vim vẽ bằng matchaddpos — nhóm mdFenceBg;
  "  không dùng syntax vì 'syn keyword' đứng đầu dòng luôn thắng syn match.)
  execute 'highlight mdFence       guifg=' . l:orange . ' guibg=NONE gui=bold'

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
  " mdCode     = `code` nội tuyến nói chung                      -> XANH LÁ
  " mdCodePath = `code` mà bên trong có dấu / (đường dẫn file)   -> XANH BIỂN
  " Hai pattern cùng bắt đầu ở cột ` nhưng mdCodePath khai báo sau nên thắng
  " khi có /; chuỗi thường vẫn xanh lá.  Muốn đổi: sửa l:green / l:blue.
  execute 'highlight mdCode        guifg=' . l:green . ' guibg=NONE gui=NONE'
  execute 'highlight mdCodePath    guifg=' . l:blue  . ' guibg=NONE gui=NONE'
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
  " Dòng phân cách bảng '| --- |' -> cùng màu với PATH (`code` chứa '/') theo
  " yêu cầu (trước là vàng #e5c07b).
  execute 'highlight mdTableHead   guifg=' . l:blue . ' guibg=NONE gui=bold'
  execute 'highlight mdTableBorder guifg=' . l:grid  . ' guibg=NONE gui=NONE'
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

" Front-Matter YAML: CHỈ TÔ MỘT MÀU, KHÔNG 'syn include syntax/yaml.vim'.
"
" VÌ SAO (bug thật đã gặp): 'syn include' nạp yaml.vim, mà file runtime
" 'syntax/yaml.vim' đặt b:current_syntax = 'yaml' (và bản của Vim còn chạy
" 'syntax clear' bên trong).  Kết quả:
"   • b:current_syntax thành 'yaml' (thấy rõ trong :MdSyn);
"   • các quy tắc md ĐÃ ĐỊNH NGHĨA TRƯỚC ĐÓ bị xoá sạch / lần nạp sau bị
"     chặn bởi 'if exists("b:current_syntax") | finish' ở đầu file;
"   • hậu quả: tiêu đề '#' / '###' KHÔNG có nhóm syntax nào (syn= rỗng),
"     toàn bộ chữ ra trắng.
" => Bỏ include; chỉ khoanh vùng front-matter và cho nó cùng màu với mdPreCode.
syn region mdFrontYaml start=/\%^---\s*$/ end=/^---\s*$/ keepend
silent! highlight def link mdFrontYaml mdPreCode

let b:current_syntax   = "md"
let b:md_syntax_loaded = 1     " dấu "file này đã nạp cho buffer" (xem guard ở đầu)
if main_syntax ==# "md"
  unlet main_syntax
endif
