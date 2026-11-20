" ╔══════════════════════════════════════════════════════════════════════════╗
" ║  FILE NÀY COPY VÀO:  ~/.vim/ftplugin/md.vim                              ║
" ║  (tên file trên Windows là ftplugin.md.vim để biết chỗ đặt; khi copy     ║
" ║   phải đổi tên thành md.vim)                                             ║
" ║                                                                          ║
" ║  Gốc: hughbien/md-vim — ftplugin/md.vim (BSD License, Hugh Bien).        ║
" ║  Giữ nguyên chức năng; md#setup(leader) nằm ngay trong file này nên      ║
" ║  KHÔNG cần autoload/.                                                    ║
" ║  Phím sau khi gọi md#setup("\") (leader của vimrc là '\'):               ║
" ║    \=  h1     \-  h2     \l  đánh số lại ordered list                    ║
" ║    \x  task   \t  format bảng   \z  fold theo header   \p  preview       ║
" ║                                                                          ║
" ║  Bản của bạn haozxje, sửa so với gốc:                                    ║
" ║   • SỬA LỖI gốc: MdFixTable dò biên bảng bằng pattern "^\\s*\\|" —       ║
" ║     trong Vim '\\|' là phép HOẶC nên pattern khớp MỌI dòng, vòng lặp     ║
" ║     chạy vô hạn.  Đổi thành '^\\s*|' (literal, nháy đơn).                ║
" ║   • Thêm TỰ ĐỘNG FORMAT khi ghi file + khi rời Insert trong bảng.        ║
" ║     Tắt:  :let g:md_autoformat = 0   hoặc  :MdAutoFormat                 ║
" ║     Format ngay:  :MdFormat (toàn bộ nội dung)                           ║
" ║                   :MdFormatTable (chỉ căn bảng)                          ║
" ║   • FORMAT TOÀN BỘ NỘI DUNG (mỗi lần ghi file): bảng, bỏ space cuối      ║
" ║     dòng, tiêu đề '#   X  ##' -> '# X', '* '/'+ ' -> '- ', đánh số lại   ║
" ║     ordered list theo từng cấp, chèn/gộp dòng trống trước header / bảng  ║
" ║     / list / fence.  Bỏ qua ``` … ``` và front-matter --- … ---.         ║
" ║   • Tắt riêng việc bỏ space cuối dòng: let g:md_trim_trailing_space = 0  ║
" ║   • Tắt riêng cho 1 buffer: :MdAutoFormat  (đặt b:md_autoformat)         ║
" ║   • BẢNG: độ rộng cột tính bằng strdisplaywidth -> tiếng Việt có dấu     ║
" ║     không bị lệch cột; nhận cả bảng thiếu '|' ở đầu dòng; bảng thiếu     ║
" ║     dòng phân cách '| --- |' sẽ được TỰ CHÈN (tắt: g:md_table_guess=0).  ║
" ║   • Ordered list: chỉ reset bộ đếm khi khối THẬT SỰ kết thúc (gặp dòng   ║
" ║     trống / tiêu đề / fence / đường kẻ), nên một dòng gõ sai kiểu '7/'   ║
" ║     nằm giữa '6.' và '8.' không làm '8.' bị đánh lại thành 1.            ║
" ║   • Thêm THỤT LỀ MỤC CON: 'indentexpr' giữ lề dòng trước, nên Enter      ║
" ║     trên mục con giữ đúng cấp; <Tab> (expandtab, sw=4) lùi 1 cấp.        ║
" ║     Bảng và tiêu đề luôn về lề 0.                                        ║
" ║   • 'formatoptions+=n' để gq biết đánh số lại ordered list.              ║
" ║   • NỀN XÁM của khối ``` … ``` do FILE NÀY vẽ bằng matchaddpos           ║
" ║     (s:FenceBgApply, nhóm mdFenceBg): cạnh TRÁI = lề NHỎ NHẤT của khối   ║
" ║     nên các dòng THẲNG CỘT; chạy tới HẾT DÒNG.  Không dùng syntax vì     ║
" ║     'syn keyword' đứng đầu dòng luôn thắng syn match/region.             ║
" ║     Màu: g:md_fence_bg (#363636 hoặc NONE).  BẢNG markdown cũng được     ║
" ║     tô nền y như vậy (s:TableRanges; tắt: let g:md_table_bg = 0).        ║
" ║   • ĐỆM SPACE CUỐI DÒNG trong fence (s:FmtFencePad): mọi dòng NỘI DUNG   ║
" ║     của một khối ``` được đệm cho bằng độ rộng hiển thị lớn nhất của     ║
" ║     khối -> cạnh phải nền thẳng hàng.  Dòng trống và dòng ``` không đệm. ║
" ║     Tắt:  let g:md_fence_pad = 0                                         ║
" ║  Lưu ý: \z mới đặt 'foldmethod=expr' cho buffer .md (không tự bật).      ║
" ╚══════════════════════════════════════════════════════════════════════════╝

function! MdMakeH1()
  echo ""
  call MdMakeHeader("=")
endfunction

function! MdMakeH2()
  echo ""
  call MdMakeHeader("-")
endfunction

function! MdMakeHeader(character)
  let line = substitute(getline("."), "\\s\\+$", "", "")
  let nextline = getline(line(".") + 1)
  let border = substitute(line, ".", a:character, "g")
  call setline(".", line)
  if nextline =~ "^" . a:character . "\\+\\s*$"
    call setline(line(".") + 1, border)
  else
    call append(".", border)
  endif
endfunction

function! MdFixOrderedList()
  echo ""
  let ltop = line(".")
  while getline(ltop) =~ "^\\s*[0-9]\\+\\." ||
      \ (getline(ltop) =~ "^\\s" && getline(ltop) !~ "^\\s*$")
    let ltop = ltop - 1
  endwhile

  let lbot = line(".")
  while getline(lbot) =~ "^\\s*[0-9]\\+\\." ||
      \ (getline(lbot) =~ "^\\s" && getline(lbot) !~ "^\\s*$")
    let lbot = lbot + 1
  endwhile

  let ltop = ltop + 1
  let lbot = lbot - 1
  if ltop > lbot
    return
  endif

  let i = 1
  let row = ltop
  while row <= lbot
    let line = getline(row)
    if line =~ "^\\s*[0-9]\\+\\."
      call setline(row, substitute(line, "[0-9]\\+", i, ""))
      let i = i + 1
    endif
    let row = row + 1
  endwhile
endfunction

" ══════════════════════════════════════════════════════════════════════════
"  ĐỊNH DẠNG BẢNG — phần thân của MdFixTable gốc, tách ra thành
"  s:FormatTable(top, bot) để dùng lại cho cả bảng đang đứng (MdFixTable) và
"  cho chế độ tự format toàn buffer.
" ══════════════════════════════════════════════════════════════════════════
" Ô PHÂN CÁCH của bảng? ('---', ':--', '--:', ':--:')
function! s:IsTableDelimCell(cell) abort
  return a:cell =~# '^\s*[-:]\{2,}\s*$'
endfunction

" Số cột của hàng a:lnum (đếm ô sau khi bỏ ô rỗng đầu/cuối)
function! s:TableColumns(lnum) abort
  let l:cells = split(substitute(substitute(getline(a:lnum),
        \ '^\s\+', '', ''), '\s\+$', '', ''), '|', 1)
  if !empty(l:cells) && l:cells[0] !~# '\S'
    call remove(l:cells, 0)
  endif
  if !empty(l:cells) && l:cells[-1] !~# '\S'
    call remove(l:cells, -1)
  endif
  return len(l:cells)
endfunction

" ── Tách ô của một hàng ────────────────────────────────────────────────────
" Bảng chuẩn: mọi hàng đều có '|'.  Bảng VIẾT TAY (kiểu ghi chú của bạn
" haozxje): cột căn bằng SPACE, chỉ dòng phân cách mới có '|' — vì vậy phải
" có đường tách dự phòng theo cụm 2+ space.
function! s:PipeCells(line) abort
  let l:l = substitute(substitute(a:line, '^\s\+', '', ''), '\s\+$', '', '')
  let l:c = split(l:l, '|', 1)
  if !empty(l:c) && l:c[0] !~# '\S'
    call remove(l:c, 0)
  endif
  if !empty(l:c) && l:c[-1] !~# '\S'
    call remove(l:c, -1)
  endif
  return l:c
endfunction

function! s:SpaceCells(line) abort
  let l:l = substitute(substitute(a:line, '^\s\+', '', ''), '\s\+$', '', '')
  return split(substitute(l:l, '|', ' ', 'g'), '\%(\s\{2,}\|\t\)')
endfunction

" Số ô "tự nhiên" của hàng: ưu tiên tách theo '|' nếu được >= 2 ô.
function! s:CountCells(line) abort
  let l:n = len(s:PipeCells(a:line))
  if l:n >= 2
    return l:n
  endif
  return len(s:SpaceCells(a:line))
endfunction

" Tách hàng thành ĐÚNG a:ncols ô, hoặc [] nếu không tách được (chỗ gọi sẽ
" GIỮ NGUYÊN dòng đó, không phá nội dung).
function! s:SplitCells(line, ncols) abort
  if substitute(a:line, '\s', '', 'g') ==# ''
    return []
  endif
  let l:c = s:PipeCells(a:line)
  if len(l:c) == a:ncols
    return l:c
  endif
  let l:c2 = s:SpaceCells(a:line)
  if len(l:c2) == a:ncols
    return l:c2
  endif
  return []
endfunction

" Số cột của cả bảng: BẦU CHỌN theo đa số các hàng (dòng phân cách bị bỏ qua
" khi bầu).  Nhờ vậy bảng viết tay có dòng phân cách SAI số cột vẫn được sửa
" đúng theo phần lớn các hàng còn lại.
function! s:MajorityCols(lines) abort
  let l:votes = {}
  for l:l in a:lines
    if s:IsTableDelim(l:l)
      continue
    endif
    let l:n = s:CountCells(l:l)
    if l:n >= 2
      let l:votes[l:n] = get(l:votes, l:n, 0) + 1
    endif
  endfor
  let l:best = 0
  let l:bestv = 0
  for [l:k, l:v] in items(l:votes)
    if l:v > l:bestv
      let l:bestv = l:v
      let l:best = str2nr(l:k)
    endif
  endfor
  return l:best
endfunction

function! s:FormatTable(top, bot) abort
  let l:top = a:top
  let l:bot = a:bot
  if l:bot - l:top < 1
    return 0
  endif

  " Bảng viết tay thiếu dòng phân cách: markdown sẽ KHÔNG render thành bảng.
  " Nếu đang bật g:md_table_guess (mặc định 1) thì chèn '| --- | --- |' ngay
  " sau hàng đầu.  Tắt: let g:md_table_guess = 0
  let l:has_delim = 0
  for l:i in range(l:top, l:bot)
    if s:IsTableDelim(getline(l:i))
      let l:has_delim = 1
      break
    endif
  endfor
  if !l:has_delim
    if !get(g:, 'md_table_guess', 1)
      return 0
    endif
    let l:ncols = s:TableColumns(l:top)
    if l:ncols < 2
      return 0
    endif
    call append(l:top, '|' . repeat(' --- |', l:ncols))
    let l:bot = l:bot + 1
  endif

  " Số cột: BẦU CHỌN theo đa số các hàng (xem s:MajorityCols) — bảng viết tay
  " hay có dòng phân cách sai số cột.  Không bầu được thì lấy theo dòng phân
  " cách, cuối cùng là theo hàng đầu.
  let l:lines = getline(l:top, l:bot)
  let l:ncols = s:MajorityCols(l:lines)
  if l:ncols < 2
    let l:ncols = s:TableColumns(l:top)
  endif
  if l:ncols < 2
    return 0
  endif

  " Tách từng dòng thành ô.  Dòng không tách được đúng ncols -> kind 'keep':
  " GIỮ NGUYÊN VĂN (không phá nội dung), chỉ những dòng tách được mới bị vẽ
  " lại thành | ô | ô |.
  let l:kind  = []        " 'grid' | 'row' | 'keep'
  let l:rowno = []        " chỉ số trong l:table khi kind == 'row'
  let l:table = []
  for l:src in l:lines
    if l:src =~ "^\\s*+[+-]*$"
      call add(l:kind, 'grid')
      call add(l:rowno, -1)
      continue
    endif
    let l:cells = s:SplitCells(l:src, l:ncols)
    if empty(l:cells)
      call add(l:kind, 'keep')
      call add(l:rowno, -1)
      continue
    endif
    let l:row = []
    for l:cell in l:cells
      let l:c = l:cell
      if s:IsTableDelimCell(l:c) " ô phân cách?
        let l:c = substitute(l:c, "--\\*", "--", "")
      endif
      let l:c = substitute(l:c, "^\\s*", " ", "")
      let l:c = substitute(l:c, "\\s*$", " ", "")
      call add(l:row, l:c)
    endfor
    call add(l:kind, 'row')
    call add(l:rowno, len(l:table))
    call add(l:table, l:row)
  endfor
  if empty(l:table)
    return 0
  endif

  " Độ rộng mỗi cột = ô dài nhất, tính theo SỐ CỘT MÀN HÌNH (strdisplaywidth)
  " chứ KHÔNG phải strlen: tiếng Việt có dấu là 2 byte nhưng rộng 1 ô, dùng
  " strlen thì các dấu | trong bảng lệch nhau.
  let l:maxlength = map(copy(l:table[0]), "strdisplaywidth(v:val)")
  for l:row in l:table
    for l:i in range(len(l:row))
      if l:i >= len(l:maxlength)
        call add(l:maxlength, 0)
      endif
      if strdisplaywidth(l:row[l:i]) > l:maxlength[l:i]
        let l:maxlength[l:i] = strdisplaywidth(l:row[l:i])
      endif
    endfor
  endfor

  " Cột có dòng phân cách phải đủ rộng cho tối thiểu 3 dấu '-' (| --- |),
  " nếu không bảng sinh ra sẽ không phải bảng markdown hợp lệ.
  " Ô có ':' (:- : : ---: :---:) cần thêm chỗ cho dấu ':' -> nới rộng hơn.
  for l:i in range(len(l:maxlength))
    for l:row in l:table
      if l:i < len(l:row) && s:IsTableDelimCell(l:row[l:i])
        let l:need = 5                                   " ' --- '
        if l:row[l:i] =~# '^\s*:' || l:row[l:i] =~# ':\s*$'
          let l:need = 6                                 " ':--- ' hoặc ' ---:'
        endif
        if l:row[l:i] =~# '^\s*:' && l:row[l:i] =~# ':\s*$'
          let l:need = 7                                 " ':---:'
        endif
        if l:maxlength[l:i] < l:need
          let l:maxlength[l:i] = l:need
        endif
      endif
    endfor
  endfor

  " Bù space/gạch cho ô ngắn; thêm ô trống nếu hàng thiếu cột
  for l:ri in range(len(l:table))
    let l:row = l:table[l:ri]
    for l:i in range(len(l:maxlength))
      if l:i >= len(l:row)
        call add(l:row, "")
      endif

      " Ô PHÂN CÁCH: dựng lại đúng độ rộng cột, giữ ':' ở đúng đầu/cuối và
      " luôn >= 3 dấu '-' (nguồn hay viết ':-', '-:' chỉ 1 dấu).
      if s:IsTableDelimCell(l:row[l:i])
        let l:openc = (l:row[l:i] =~# '^\s*:') ? ':' : ''
        let l:closec = (l:row[l:i] =~# ':\s*$') ? ':' : ''
        let l:dashes = l:maxlength[l:i] - 2 - strlen(l:openc) - strlen(l:closec)
        if l:dashes < 3
          let l:dashes = 3
        endif
        let l:row[l:i] = ' ' . l:openc . repeat('-', l:dashes) . l:closec . ' '
        continue
      endif

      if strdisplaywidth(l:row[l:i]) < l:maxlength[l:i]
        let l:spaces = l:maxlength[l:i] - strdisplaywidth(l:row[l:i])
        " căn theo ô phân cách gần nhất (trên trước, dưới sau)
        let l:align = "left"
        let l:d = l:ri
        if l:d + 1 < len(l:table)
          let l:d = l:d + 1 " xét cả hàng dưới (trường hợp hàng tiêu đề)
        endif
        while l:d >= 0
          if l:i < len(l:table[l:d])
            let l:delCell = l:table[l:d][l:i]
            if s:IsTableDelimCell(l:delCell)
              if l:delCell =~# '^\s*:' && l:delCell =~# ':\s*$'
                let l:align = "center"
                break
              elseif l:delCell =~# ':\s*$'
                let l:align = "right"
                break
              endif
            endif
          endif
          let l:d = l:d - 1
        endwhile
        if l:align == "left"
          let l:row[l:i] = l:row[l:i] . repeat(" ", l:spaces)
        elseif l:align == "right"
          let l:row[l:i] = repeat(" ", l:spaces) . l:row[l:i]
        else
          let l:leftSpace = repeat(" ", float2nr(floor(l:spaces/2.0)))
          let l:rightSpace = repeat(" ", float2nr(ceil(l:spaces/2.0)))
          let l:row[l:i] = l:leftSpace . l:row[l:i] . l:rightSpace
        endif
      endif
    endfor
  endfor

  " Sinh lại: dòng '+' thành viền lưới, còn lại thành | ô | ô |
  " Giữ nguyên lề của bảng (bảng nằm trong mục list thụt lề thì không bị kéo
  " về lề 0).
  let l:indent = matchstr(getline(l:top), '^\s*')
  let l:border = substitute(
    \ "+" . join(map(copy(l:maxlength), "repeat('-', v:val)"), "+") . "+",
    \ "++", "+", "g")
  let l:i = l:top
  let l:k = 0
  while l:i <= l:bot
    let l:kk = get(l:kind, l:k, 'keep')
    if l:kk ==# 'grid'
      call setline(l:i, l:indent . l:border)
    elseif l:kk ==# 'row'
      let l:rn = get(l:rowno, l:k, -1)
      if l:rn >= 0 && l:rn < len(l:table) && !empty(l:table[l:rn])
        call setline(l:i, l:indent . "|" . join(l:table[l:rn], "|") . "|")
      endif
    endif
    " 'keep' -> giữ nguyên văn dòng đó
    let l:i = l:i + 1
    let l:k = l:k + 1
  endwhile
  return 1
endfunction

" Vùng trong ``` … ``` (không được coi là bảng, không được format)
" Fence KHÔNG ĐÓNG (số dòng ``` lẻ) thì BỎ QUA — không kéo dài tới cuối file.
" Nếu không, chỉ cần một dòng ``` thiếu là toàn bộ phần sau bị coi là code:
" bảng không được format, và bên syntax thì mọi dòng ra màu code (tiêu đề
" mất màu) -> đúng kiểu lỗi "syntax ### sai + table sai".
function! s:FenceRanges() abort
  let l:ranges = []
  let l:start = 0
  let l:n = 1
  while l:n <= line('$')
    if getline(l:n) =~# '^\s*```'
      if l:start == 0
        let l:start = l:n
      else
        call add(l:ranges, [l:start, l:n])
        let l:start = 0
      endif
    endif
    let l:n = l:n + 1
  endwhile
  " KHÔNG thêm [l:start, line('$')] khi fence không đóng.
  return l:ranges
endfunction

function! s:InFence(lnum, ranges) abort
  for l:r in a:ranges
    if a:lnum >= l:r[0] && a:lnum <= l:r[1]
      return 1
    endif
  endfor
  return 0
endfunction

" ══════════════════════════════════════════════════════════════════════════
"  CHẨN ĐOÁN: :MdFenceInfo  và  :MdTableInfo
"  Đặt con trỏ trong bảng rồi gõ các lệnh này để xem formatter nghĩ gì.
" ══════════════════════════════════════════════════════════════════════════
function! s:FenceInfo() abort
  let l:opens = 0
  let l:n = 1
  let l:odd_at = 0
  while l:n <= line('$')
    if getline(l:n) =~# '^\s*```'
      let l:opens += 1
      if l:opens % 2 == 1
        let l:odd_at = l:n
      endif
    endif
    let l:n = l:n + 1
  endwhile
  echo 'fence pairs: ' . string(s:FenceRanges())
  if l:opens % 2 == 1
    echo printf('!! UNCLOSED FENCE tại dòng %d: tổng %d dòng ``` (số LẺ).', l:odd_at, l:opens)
    echo '   -> syntax coi mọi thứ SAU dòng đó là code (tiêu đề mất màu).'
    echo '   -> formatter (bản mới) bỏ qua cặp lẻ này, nhưng bạn nên đóng fence.'
  else
    echo printf('OK: %d dòng ``` (chẵn) — mọi fence đều đóng.', l:opens)
  endif
endfunction
command! -buffer MdFenceInfo call s:FenceInfo()

function! s:TableInfo() abort
  let l:l = line('.')
  let l:r = s:TableBlockAt(l)
  if empty(l:r)
    echo printf('dòng %d: KHÔNG phải bảng (delim=%d, in_fence=%d)',
          \ l:l, s:IsTableDelim(getline(l:l)),
          \ s:InFence(l, s:FenceRanges()))
    return
  endif
  let l:lines = getline(l:r[0], l:r[1])
  let l:ncols = s:MajorityCols(l:lines)
  echo printf('block %d-%d | in_fence=%d | ncols(majority)=%d',
        \ l:r[0], l:r[1], s:InFence(l:r[0], s:FenceRanges()), l:ncols)
  for l:x in l:lines
    echo printf('   pipe=%-2d space=%-2d split=%-2d | %s',
          \ len(s:PipeCells(l:x)), len(s:SpaceCells(l:x)),
          \ len(s:SplitCells(l:x, l:ncols)), strpart(l:x, 0, 60))
  endfor
endfunction
command! -buffer MdTableInfo call s:TableInfo()

" Dòng PHÂN CÁCH của bảng: chỉ gồm | - : và space, có ít nhất 2 dấu '-', và
" phải có ít nhất một '|'.  Đây là dấu hiệu chắc chắn nhất để biết "đây là
" bảng", kể cả bảng viết THIẾU '|' ở đầu dòng (kiểu 'Nội dung | text') —
" bản trước dò bằng '^\\s*|' nên bỏ sót loại bảng đó.
function! s:IsTableDelim(line) abort
  return a:line =~# '^\s*|\?[-: |]\+$' && a:line =~# '|' && a:line =~# '-\{2,}'
endfunction

" Trả [top, bot] của KHỐI có '|' quanh dòng a:lnum, hoặc [] nếu khối đó không
" đủ điều kiện là bảng.
"   • có dòng phân cách (| --- |) -> chắc chắn là bảng;
"   • không có dòng phân cách -> chỉ nhận khi khối ≥3 dòng (bảng viết tay
"     thiếu dòng phân cách); s:FormatTable sẽ tự chèn dòng phân cách.
" Dòng có thể là một HÀNG của bảng? (không trống, không fence, không tiêu đề,
" không phải mục list) — dùng để mở rộng khối cho bảng VIẾT TAY (cột căn bằng
" space nên nhiều hàng không có '|').
function! s:IsRowLike(line) abort
  return a:line !~# '^\s*$'
      \ && a:line !~# '^\s*```'
      \ && a:line !~# '^#\{1,6}\%(\s\|$\)'
      \ && a:line !~# '^\s*[-*+]\s'
      \ && a:line !~# '^\s*\d\+[.)]\s'
endfunction

" Trả [top, bot] của bảng quanh dòng a:lnum, hoặc [] nếu không phải bảng.
" Có 2 kiểu bảng:
"   • CHUẨN: mọi hàng đều có '|' (kèm dòng phân cách '| --- |').
"   • VIẾT TAY (kiểu ghi chú của bạn haozxje): cột căn bằng SPACE, chỉ dòng
"     phân cách là có '|'.  Nhận kiểu này bằng cách: thấy dòng phân cách thì
"     mở rộng khối lên 1 dòng (hàng tiêu đề, có thể không có '|') và xuống
"     qua các dòng liền nhau còn "giống hàng bảng".
function! s:TableBlockAt(lnum) abort
  if a:lnum < 1 || a:lnum > line('$')
    return []
  endif

  " dò dòng phân cách ở chính nó / dòng trên / dòng dưới (tối đa 1 dòng)
  let l:delim = 0
  for l:c in [a:lnum, a:lnum - 1, a:lnum + 1]
    if l:c >= 1 && l:c <= line('$') && s:IsTableDelim(getline(l:c))
      let l:delim = l:c
      break
    endif
  endfor

  if l:delim > 0
    " ── CÓ dòng phân cách: khối = [hàng tiêu đề] + phân cách + các hàng dưới
    let l:top = l:delim
    if l:delim > 1 && s:IsRowLike(getline(l:delim - 1))
      let l:top = l:delim - 1
    endif
    let l:bot = l:delim
    while l:bot < line('$')
      let l:nx = getline(l:bot + 1)
      if !s:IsRowLike(l:nx) || s:IsTableDelim(l:nx)
        break
      endif
      let l:bot = l:bot + 1
    endwhile
    if l:bot - l:top >= 1
      return [l:top, l:bot]
    endif
    return []
  endif

  " ── KHÔNG có dòng phân cách: giữ hành vi cũ (bảng toàn '|', ≥3 dòng)
  if !get(g:, 'md_table_guess', 1) || getline(a:lnum) !~# '|'
    return []
  endif
  let l:top = a:lnum
  while l:top > 1 && getline(l:top - 1) =~# '|' && s:IsRowLike(getline(l:top - 1))
    let l:top = l:top - 1
  endwhile
  let l:bot = a:lnum
  while l:bot < line('$') && getline(l:bot + 1) =~# '|' && s:IsRowLike(getline(l:bot + 1))
    let l:bot = l:bot + 1
  endwhile
  if l:bot - l:top >= 2
    " Đoạn văn có lẫn '|' cũng thoả 3 dòng, nên chỉ nhận khi SỐ '|' mỗi dòng
    " gần bằng nhau (chênh ≤ 1) — đặc trưng của bảng.
    let l:pmin = 99
    let l:pmax = 0
    for l:i in range(l:top, l:bot)
      let l:pc = strlen(substitute(getline(l:i), '[^|]', '', 'g'))
      if l:pc < l:pmin | let l:pmin = l:pc | endif
      if l:pc > l:pmax | let l:pmax = l:pc | endif
    endfor
    if l:pmin >= 1 && l:pmax - l:pmin <= 1
      return [l:top, l:bot]
    endif
  endif
  return []
endfunction

" Format bảng chứa dòng a:lnum.  Trả 1 nếu có format.
function! s:FormatTableAt(lnum) abort
  if !&modifiable
    return 0
  endif
  if s:InFence(a:lnum, s:FenceRanges())
    return 0
  endif
  let l:r = s:TableBlockAt(a:lnum)
  if empty(l:r)
    " Bảng viết tay (cột căn bằng space): con trỏ có thể đứng cách dòng phân
    " cách vài hàng mà hàng đó lại không có '|'.  Dò dòng phân cách trong
    " ±10 dòng quanh con trỏ, rồi lấy khối theo dòng đó.
    let l:from = max([1, a:lnum - 10])
    let l:to   = min([line('$'), a:lnum + 10])
    for l:d in range(l:from, l:to)
      if s:IsTableDelim(getline(l:d))
        let l:r = s:TableBlockAt(l:d)
        break
      endif
    endfor
  endif
  if empty(l:r)
    return 0
  endif
  return s:FormatTable(l:r[0], l:r[1])
endfunction

" Format MỌI bảng trong buffer, giữ nguyên vị trí con trỏ / cửa sổ.
function! s:FormatAllTables() abort
  if !&modifiable
    return 0
  endif
  let l:fences = s:FenceRanges()
  let l:view = winsaveview()
  let l:count = 0
  let l:n = 1
  while l:n <= line('$')
    " chỉ bắt đầu từ dòng ĐẦU của một khối có '|'
    if getline(l:n) =~# '|' && !s:InFence(l:n, l:fences)
          \ && (l:n == 1 || getline(l:n - 1) !~# '|')
      let l:r = s:TableBlockAt(l:n)
      if !empty(l:r)
        let l:count += s:FormatTable(l:r[0], l:r[1])
        let l:n = l:r[1] + 1
        continue
      endif
    endif
    let l:n = l:n + 1
  endwhile
  call winrestview(l:view)
  return l:count
endfunction

" Lệnh gốc \t -> vẫn tên MdFixTable để không phá md#setup()
function! MdFixTable()
  echo ""
  call s:FormatTableAt(line('.'))
endfunction

" ══════════════════════════════════════════════════════════════════════════
"  FORMAT TOÀN BỘ NỘI DUNG
"  Bảng đã được căn ở phần trên; phần này xử lý phần còn lại của file:
"   • bỏ space/tab thừa cuối dòng            (tắt: g:md_trim_trailing_space=0)
"   • tiêu đề: '#   X  ##' -> '# X'
"   • dấu mục list: '* ' / '+ ' -> '- ', đúng 1 space sau dấu
"   • ordered list: đánh số lại 1,2,3… theo TỪNG CẤP thụt lề
"   • dòng trống: chèn trước header / bảng / khối list / fence, gộp nhiều
"     dòng trống thành 1, bỏ dòng trống ở cuối file
"  MỌI rule đều bỏ qua vùng ``` … ``` và front-matter YAML (--- … ---).
" ══════════════════════════════════════════════════════════════════════════
function! s:FrontMatterEnd(lines) abort
  if empty(a:lines) || a:lines[0] !~# '^---\s*$'
    return 0
  endif
  let l:i = 1
  while l:i < len(a:lines)
    if a:lines[l:i] =~# '^---\s*$'
      return l:i
    endif
    let l:i = l:i + 1
  endwhile
  return 0
endfunction

" 0 = dòng thường, 1 = dòng phải bỏ qua (front-matter hoặc trong fence,
" kể cả dòng ``` và dòng --- bao ngoài)
function! s:FenceMask(lines) abort
  let l:fm_end = s:FrontMatterEnd(a:lines)
  let l:mask = []
  let l:in_fence = 0
  let l:i = 0
  for l:l in a:lines
    if l:i <= l:fm_end
      call add(l:mask, 1)
    elseif l:l =~# '^\s*```'
      call add(l:mask, 1)
      let l:in_fence = !l:in_fence
    else
      call add(l:mask, l:in_fence)
    endif
    let l:i = l:i + 1
  endfor
  return l:mask
endfunction

function! s:FmtTrailing(lines, mask) abort
  if !get(g:, 'md_trim_trailing_space', 1)
    return
  endif
  for l:i in range(len(a:lines))
    if a:mask[l:i]
      continue
    endif
    let a:lines[l:i] = substitute(a:lines[l:i], '[ \t]\+$', '', '')
  endfor
endfunction

" ── Nền khối ``` cho "BẰNG NHAU" (hình chữ nhật) ───────────────────────────
" Vim KHÔNG tô được nền quá cuối dòng, nên muốn nền của các dòng trong fence
" thành một hình chữ nhật thì phải có space THẬT ở cuối dòng ngắn.  Hàm này
" đệm space cuối dòng cho mọi dòng NỘI DUNG của từng khối ``` cho bằng độ
" rộng hiển thị LỚN NHẤT của khối đó (bỏ đệm cũ trước rồi tính lại, nên chạy
" bao nhiêu lần cũng ra một kết quả).
"   • Dòng TRỐNG trong fence: không đệm (giữ nguyên).
"   • Dòng ``` mở/đóng: không đệm.
"   • Tắt:  let g:md_fence_pad = 0
"   • Không thích trailing space trong file: tắt luôn cả nền
"     (let g:md_fence_bg = 'NONE') thì nền chỉ phủ tới ký tự cuối mỗi dòng.
function! s:FmtFencePad(lines) abort
  if !get(g:, 'md_fence_pad', 1)
    return
  endif
  let l:ranges = []
  let l:open = 0
  let l:i = 0
  for l:l in a:lines
    if l:l =~# '^\s*```'
      if l:open == 0
        let l:open = l:i + 1
      else
        call add(l:ranges, [l:open, l:i + 1])
        let l:open = 0
      endif
    endif
    let l:i = l:i + 1
  endfor
  for l:r in l:ranges
    if l:r[1] - l:r[0] < 2
      continue
    endif
    " 1) bỏ đệm cũ + đo độ rộng lớn nhất
    let l:maxw = 0
    for l:n in range(l:r[0] + 1, l:r[1] - 1)
      let l:line = substitute(a:lines[l:n - 1], '[ \t]\+$', '', '')
      let a:lines[l:n - 1] = l:line
      let l:w = strdisplaywidth(l:line)
      if l:w > l:maxw
        let l:maxw = l:w
      endif
    endfor
    " 2) đệm lại cho bằng nhau (dòng TRỐNG: không đệm, giữ file sạch)
    for l:n in range(l:r[0] + 1, l:r[1] - 1)
      let l:line = a:lines[l:n - 1]
      if l:line =~# '^\s*$'
        continue
      endif
      let l:pad = l:maxw - strdisplaywidth(l:line)
      if l:pad > 0
        let a:lines[l:n - 1] = l:line . repeat(' ', l:pad)
      endif
    endfor
  endfor
endfunction

" '#   Title  ##' -> '# Title'
function! s:FmtHeaders(lines, mask) abort
  for l:i in range(len(a:lines))
    if a:mask[l:i]
      continue
    endif
    let l:l = a:lines[l:i]
    if l:l !~# '^#\{1,6}\%(\s\|$\)'
      continue
    endif
    let l:l = substitute(l:l, '^\(#\{1,6}\)\s*', '\1 ', '')
    let l:l = substitute(l:l, '\s\+#\+$', '', '')
    let a:lines[l:i] = substitute(l:l, '\s\+$', '', '')
  endfor
endfunction

" ── NỀN XÁM của khối ``` … ``` (window-local matchaddpos) ──────────────────
" VÌ SAO KHÔNG DÙNG SYNTAX: luật :syn-priority của Vim — 'syn keyword' LUÔN
" thắng 'syn match'/'syn region' — nên dòng nào mở đầu bằng từ khoá (bit, if,
" constraint, end, uvm_info…) thì nhóm nền không bao giờ khớp ⇒ nền bị so le,
" có dòng có dòng không.  matchaddpos() vẽ ĐÈ lên syntax, không dính luật đó,
" và nhóm mdFenceBg CHỈ đặt guibg nên MÀU CHỮ của syntax giữ nguyên.
"   • Cạnh TRÁI = lề NHỎ NHẤT trong khối -> các dòng THẲNG CỘT với nhau.
"   • Cạnh PHẢI = hết dòng, thẳng hàng nhờ s:FmtFencePad đệm space cuối dòng.
"   • Dòng ``` (mở/đóng) và dòng trống: không tô.
"   • Tắt:  let g:md_fence_bg = 'NONE'    Đổi màu:  let g:md_fence_bg = '#xxxxxx'
let s:fence_bg_group = 'mdFenceBg'
let s:fence_bg_timer = -1
let s:fence_bg_buf   = -1

function! s:FenceBgClear() abort
  if exists('w:md_fbg_ids')
    for l:id in w:md_fbg_ids
      silent! call matchdelete(l:id)
    endfor
  endif
  let w:md_fbg_ids = []
  " Xoá cả "chữ ký" -> lần vào lại buffer chắc chắn vẽ lại (tránh trạng thái
  " kẹt: chữ ký còn nhưng match đã bị xoá).
  let w:md_fbg_sig = ''
endfunction

" Dải các BẢNG trong buffer: mỗi phần tử là [top, bot] (đã gồm hàng tiêu đề).
" Dùng lại s:IsTableDelim/s:TableBlockAt nên nhận cả bảng viết tay.
function! s:TableRanges() abort
  let l:out = []
  let l:n = 1
  let l:last = 0
  while l:n <= line('$')
    if l:n > l:last && s:IsTableDelim(getline(l:n))
      let l:r = s:TableBlockAt(l:n)
      if !empty(l:r) && l:r[1] > l:last
        call add(l:out, l:r)
        let l:last = l:r[1]
        let l:n = l:r[1]
      endif
    endif
    let l:n = l:n + 1
  endwhile
  return l:out
endfunction

" Dải NỘI DUNG của các khối ``` (bỏ dòng ``` mở/đóng).
function! s:FenceContentRanges() abort
  let l:out = []
  for l:r in s:FenceRanges()
    if l:r[1] - l:r[0] >= 2
      call add(l:out, [l:r[0] + 1, l:r[1] - 1])
    endif
  endfor
  return l:out
endfunction

" Thêm position [lnum, col, len] cho từng dải: cạnh trái = lề NHỎ NHẤT của dải
" (các dòng thẳng cột), cạnh phải = hết dòng.
function! s:BgAddRanges(pos, ranges) abort
  for l:r in a:ranges
    let l:left = -1
    for l:n in range(l:r[0], l:r[1])
      let l:st = match(getline(l:n), '\S')
      if l:st < 0
        continue
      endif
      if l:left < 0 || l:st < l:left
        let l:left = l:st
      endif
    endfor
    if l:left < 0
      continue
    endif
    for l:n in range(l:r[0], l:r[1])
      let l:len = strlen(getline(l:n)) - l:left
      if l:len > 0
        call add(a:pos, [l:n, l:left + 1, l:len])
      endif
    endfor
  endfor
endfunction

function! s:FenceBgApply() abort
  " matchaddpos() tác động lên CỬA SỔ hiện tại -> chỉ chạy khi buffer này đang
  " hiển thị trong cửa sổ đó.
  if winbufnr(0) != bufnr('%')
    return
  endif
  if !exists('w:md_fbg_ids')
    let w:md_fbg_ids = []
  endif
  let l:bg = get(g:, 'md_fence_bg', '#363636')
  if type(l:bg) == type('') && l:bg ==# 'NONE'
    call s:FenceBgClear()
    let w:md_fbg_sig = ''
    return
  endif
  silent! execute 'highlight ' . s:fence_bg_group . ' guifg=NONE guibg=' . l:bg . ' gui=NONE'
  " Tính position cho MỌI khối trước, rồi so với lần vẽ trước: nếu y hệt thì
  " KHÔNG xoá/thêm lại (mỗi lần matchdelete/matchaddpos đều làm Vim redraw cả
  " cửa sổ -> đây là nguồn lag chính khi gõ phím).
  let l:pos = []
  " Khối ``` … ```
  call s:BgAddRanges(l:pos, s:FenceContentRanges())
  " BẢNG markdown: cùng concept với khối ``` (tắt: let g:md_table_bg = 0)
  if get(g:, 'md_table_bg', 1)
    call s:BgAddRanges(l:pos, s:TableRanges())
  endif
  let l:sig = string(l:pos)
  if exists('w:md_fbg_sig') && w:md_fbg_sig ==# l:sig && !empty(w:md_fbg_ids)
    return
  endif
  call s:FenceBgClear()
  let w:md_fbg_sig = l:sig
  " matchaddpos() chỉ nhận tối đa 8 position mỗi lần -> chẻ nhỏ (E5030).
  let l:i = 0
  while l:i < len(l:pos)
    let l:last = (l:i + 7 < len(l:pos)) ? l:i + 7 : len(l:pos) - 1
    let l:id = 0
    silent! let l:id = matchaddpos(s:fence_bg_group, l:pos[l:i : l:last], 1)
    if l:id > 0
      call add(w:md_fbg_ids, l:id)
    endif
    let l:i = l:last + 1
  endwhile
  " lazyredraw đang bật (vimrc) -> phải redraw thì nền mới hiện NGAY, không
  " phải đợi lần vẽ kế tiếp (đúng lỗi 'mở file nền hiện chậm').
  silent! redraw
endfunction

function! s:FenceBgTick(timer) abort
  let s:fence_bg_timer = -1
  if bufnr('%') == s:fence_bg_buf
    call s:FenceBgApply()
    " ':redraw' gọi trong autocmd (BufWinEnter/BufReadPost) có thể bị bỏ qua;
    " trong TIMER thì luôn có tác dụng.  Không có dòng này, nền chỉ hiện khi
    " có redraw khác xảy ra (ví dụ vào/ra Insert) — đúng lỗi bạn vừa báo.
    silent! redraw
  endif
endfunction

" Gõ phím: dồn lại rồi mới vẽ (đỡ lag).  Trong Insert dồn lâu hơn vì mỗi lần
" vẽ lại là một lần redraw cả cửa sổ.
function! s:FenceBgSchedule(...) abort
  let l:delay = (a:0 && a:1 > 0) ? a:1 : 150
  if s:fence_bg_timer != -1
    call timer_stop(s:fence_bg_timer)
  endif
  let s:fence_bg_buf = bufnr('%')
  let s:fence_bg_timer = timer_start(l:delay, function('s:FenceBgTick'))
endfunction

let s:fbg_aug = 'md_fence_bg_' . bufnr('')
execute 'augroup ' . s:fbg_aug
  autocmd!
  autocmd BufEnter,BufWinEnter,WinEnter,BufReadPost <buffer> call <SID>FenceBgApply()
  autocmd CursorHold,VimEnter         <buffer> call <SID>FenceBgSchedule(10)
  autocmd TextChanged                 <buffer> call <SID>FenceBgSchedule(150)
  autocmd TextChangedI                <buffer> call <SID>FenceBgSchedule(600)
  autocmd InsertLeave,BufWritePost    <buffer> call <SID>FenceBgApply()
  autocmd ColorScheme                 <buffer> call <SID>FenceBgApply()
  autocmd BufLeave                    <buffer> call <SID>FenceBgClear()
augroup END
unlet s:fbg_aug
" Vẽ ngay khi nạp ftplugin + hẹn 10ms sau (lúc đó buffer chắc chắn đã nằm
" trong cửa sổ) -> mở file là thấy nền liền.
call s:FenceBgApply()
call s:FenceBgSchedule(10)

" '* ' / '+ ' -> '- ' và đúng 1 space sau dấu
function! s:FmtBullets(lines, mask) abort
  for l:i in range(len(a:lines))
    if a:mask[l:i]
      continue
    endif
    if a:lines[l:i] =~# '^\s*[-*+]\s\+'
      let a:lines[l:i] = substitute(a:lines[l:i], '^\(\s*\)[-*+]\s\+', '\1- ', '')
    endif
  endfor
endfunction

" Đánh số lại ordered list, mỗi cấp thụt lề đếm riêng từ 1
function! s:FmtOrdered(lines, mask) abort
  let l:stack = []
  let l:blank = 1
  for l:i in range(len(a:lines))
    if a:mask[l:i]
      let l:blank = 0
      continue
    endif
    let l:l = a:lines[l:i]
    if l:l =~# '^\s*$'
      let l:blank = 1
      continue
    endif
    let l:m = matchlist(l:l, '^\(\s*\)\(\d\+\)\([.)]\)\s\+')
    if empty(l:m)
      " Reset bộ đếm CHỈ khi khối thật sự kết thúc: gặp tiêu đề / fence /
      " đường kẻ ngang, hoặc một dòng mới SAU dòng trống.  Nhờ vậy một dòng
      " gõ sai kiểu '7/ ...' nằm giữa '6.' và '8.' không làm '8.' bị đánh
      " lại thành 1.
      if l:blank || l:l =~# '^#\{1,6}\%(\s\|$\)' || l:l =~# '^\s*```'
            \ || l:l =~# '^\s*\%(---\+\|\*\*\*\+\|___\+\)\s*$'
        let l:stack = []
      endif
      let l:blank = 0
      continue
    endif
    let l:blank = 0
    let l:ind = strlen(substitute(l:m[1], "\t", '    ', 'g'))
    let l:idx = -1
    for l:k in range(len(l:stack))
      if l:stack[l:k][0] == l:ind
        let l:idx = l:k
        break
      endif
    endfor
    if l:idx < 0
      while !empty(l:stack) && l:stack[-1][0] > l:ind
        call remove(l:stack, -1)
      endwhile
      call add(l:stack, [l:ind, 0])
      let l:idx = len(l:stack) - 1
    else
      while len(l:stack) - 1 > l:idx
        call remove(l:stack, -1)
      endwhile
    endif
    let l:stack[l:idx][1] = l:stack[l:idx][1] + 1
    let a:lines[l:i] = substitute(l:l, '^\(\s*\)\d\+\([.)]\)',
          \ '\1' . l:stack[l:idx][1] . '\2', '')
  endfor
endfunction

" Dòng trống: chèn trước khối, gộp nhiều dòng trống thành 1
function! s:FmtSpacing(lines) abort
  let l:fm_end = s:FrontMatterEnd(a:lines)
  let l:out = []
  let l:in_fence = 0
  for l:idx in range(len(a:lines))
    let l:l = a:lines[l:idx]
    if l:idx <= l:fm_end
      call add(l:out, l:l)
      continue
    endif
    if l:l =~# '^\s*```'
      if !l:in_fence && !empty(l:out) && l:out[-1] !~# '^\s*$'
        call add(l:out, '')
      endif
      call add(l:out, l:l)
      let l:in_fence = !l:in_fence
      continue
    endif
    if l:in_fence
      call add(l:out, l:l)
      continue
    endif
    if l:l =~# '^\s*$'
      if !empty(l:out) && l:out[-1] !~# '^\s*$'
        call add(l:out, '')
      endif
      continue
    endif
    if !empty(l:out) && l:out[-1] !~# '^\s*$'
      let l:prev = l:out[-1]
      let l:need = 0
      if l:l =~# '^#\{1,6}\%(\s\|$\)'
        let l:need = 1
      elseif l:l =~# '^\s*|'
        let l:need = (l:prev !~# '^\s*|')
      elseif l:l =~# '^\s*>'
        let l:need = (l:prev !~# '^\s*>')
      elseif l:l =~# '^\s*\%([-*+]\|\d\+[.)]\)\s'
        let l:need = (l:prev !~# '^\s*\%([-*+]\|\d\+[.)]\)\s'
              \ && l:prev !~# '^\s\+\S'
              \ && l:prev !~# '^#\{1,6}\%(\s\|$\)')
      elseif l:prev =~# '^\s*|'
        let l:need = 1
      elseif l:prev =~# '^\s*>'
        let l:need = 1
      endif
      if l:need
        call add(l:out, '')
      endif
    endif
    call add(l:out, l:l)
  endfor
  while !empty(l:out) && l:out[-1] =~# '^\s*$'
    call remove(l:out, -1)
  endwhile
  return l:out
endfunction

" Ghi danh sách dòng mới vào buffer, chỉ sửa từ dòng đầu tiên khác nhau
function! s:ReplaceLines(old, new) abort
  let l:new = a:new
  if empty(l:new)
    let l:new = ['']
  endif
  let l:n = min([len(a:old), len(l:new)])
  let l:p = 0
  while l:p < l:n && a:old[l:p] ==# l:new[l:p]
    let l:p = l:p + 1
  endwhile
  if l:p < len(l:new)
    call setline(l:p + 1, l:new[l:p:])
  endif
  if len(l:new) < len(a:old)
    silent! call deletebufline(bufnr('%'), len(l:new) + 1, '$')
  endif
endfunction

" Vị trí mới của con trỏ: file chỉ bị chèn/xoá DÒNG TRỐNG, phần nội dung đổi
" theo kiểu 1-1, nên so khớp 2 con trỏ là đủ.
function! s:MapCursor(old, new, cur) abort
  let l:oi = 0
  let l:ni = 0
  while l:oi < a:cur - 1 && l:oi < len(a:old) && l:ni < len(a:new)
    if a:old[l:oi] ==# a:new[l:ni]
      let l:oi = l:oi + 1
      let l:ni = l:ni + 1
    elseif a:old[l:oi] =~# '^\s*$'
      let l:oi = l:oi + 1
    elseif a:new[l:ni] =~# '^\s*$'
      let l:ni = l:ni + 1
    else
      let l:oi = l:oi + 1
      let l:ni = l:ni + 1
    endif
  endwhile
  return l:ni + 1
endfunction

" Chạy toàn bộ: bảng trước, rồi các rule nội dung
function! s:FormatBuffer() abort
  if !&modifiable
    return 0
  endif
  let l:view = winsaveview()
  let l:cur = line('.')
  let l:col = col('.')

  " GHI LẠI trạng thái fold TRƯỚC khi format: format có thể chèn/xoá dòng,
  " khi đó Vim tính lại fold theo indent và MẤT các fold người dùng đã mở tay
  " -> trông như "tự nhiên bị fold/gập".  Sau khi format sẽ trả lại.
  let l:fold_lvl = &l:foldlevel
  let l:fold_closed = []
  if &l:foldenable
    let l:n = 1
    while l:n <= line('$')
      if foldclosed(l:n) == l:n
        call add(l:fold_closed, l:n)
      endif
      let l:n = l:n + 1
    endwhile
  endif

  let l:tables = s:FormatAllTables()
  let l:old = getline(1, '$')
  let l:new = copy(l:old)
  let l:mask = s:FenceMask(l:new)
  call s:FmtTrailing(l:new, l:mask)
  call s:FmtHeaders(l:new, l:mask)
  call s:FmtBullets(l:new, l:mask)
  call s:FmtOrdered(l:new, l:mask)
  let l:new = s:FmtSpacing(l:new)
  " CUỐI CÙNG: đệm space cuối dòng trong fence để nền khối ``` thành hình
  " chữ nhật (xem s:FmtFencePad; tắt bằng let g:md_fence_pad = 0).
  call s:FmtFencePad(l:new)
  if l:new != l:old
    let l:newcur = s:MapCursor(l:old, l:new, l:cur)
    call s:ReplaceLines(l:old, l:new)
    let l:view.lnum = max([1, min([l:newcur, line('$')])])
    let l:view.col = l:col
    let l:view.topline = max([1, l:view.topline + l:newcur - l:cur])

    " Trả lại foldlevel + các fold đang đóng (dịch số dòng theo diff).
    silent! let &l:foldlevel = l:fold_lvl
    for l:old_lnum in l:fold_closed
      let l:new_lnum = s:MapCursor(l:old, l:new, l:old_lnum)
      if l:new_lnum < 1 || l:new_lnum > line('$')
        continue
      endif
      call cursor(l:new_lnum, 1)
      silent! normal! zc
    endfor
  endif
  call winrestview(l:view)
  " Format vừa đệm/đổi số dòng -> vẽ lại NỀN khối ``` (s:FenceBgApply).
  call s:FenceBgSchedule()
  return l:tables
endfunction

" Format TOÀN BỘ nội dung: :MdFormat
function! MdFormatAll()
  let l:n = s:FormatBuffer()
  echo 'md: formatted whole buffer (' . l:n . ' tables)'
endfunction

" :MdFormatTable — theo yêu cầu: format TOÀN BỘ nội dung (bảng + tiêu đề +
" list + dòng trống + trailing space), kể cả phần vừa append vào buffer.
" (Trước đây chỉ căn bảng; giữ tên lệnh để khỏi phải nhớ lệnh mới.)
function! MdFormatTables()
  let l:n = s:FormatBuffer()
  echo 'md: formatted whole buffer (' . l:n . ' tables)'
endfunction

function! s:AutoFormatOn() abort
  return get(b:, 'md_autoformat', get(g:, 'md_autoformat', 1))
endfunction

function! MdAutoFormatToggle() abort
  let b:md_autoformat = !s:AutoFormatOn()
  echo 'md autoformat (buffer này) = ' . b:md_autoformat
endfunction

command! -buffer MdFormat      call MdFormatAll()
command! -buffer MdFormatTable call MdFormatTables()
command! -buffer MdAutoFormat  call MdAutoFormatToggle()

" Tự format — TOÀN BỘ nội dung (bảng + tiêu đề + list + dòng trống + trailing
" space + đệm space cuối dòng trong fence) ở 2 mốc, GIỐNG NHAU:
"   • BufWritePre  -> mỗi lần ghi file (kể cả auto-save)
"   • InsertLeave  -> khi rời Insert (buffer có sửa) — phần văn bản/bảng bạn
"                     vừa append cũng được căn ngay, không cần :w
" KHÔNG format lúc mở file: làm vậy buffer bị đánh dấu 'modified' ngay khi mở.
" File cũ chưa có space đệm: gõ :MdFormat một lần (hoặc chỉ cần :w).
" Tắt toàn bộ:  let g:md_autoformat = 0   |  tắt cho buffer này:  :MdAutoFormat
let s:augroup = 'md_autoformat_' . bufnr('')
execute 'augroup ' . s:augroup
  autocmd!
  autocmd BufWritePre <buffer> if <SID>AutoFormatOn() | silent! call <SID>FormatBuffer() | endif
  " Buffer RẤT DÀI: bỏ format ở InsertLeave cho đỡ lag (vẫn format khi ghi
  " file).  Ngưỡng: let g:md_autoformat_maxlines = 4000
  autocmd InsertLeave  <buffer> if <SID>AutoFormatOn() && &modified && line('$') <= get(g:, 'md_autoformat_maxlines', 4000) | silent! call <SID>FormatBuffer() | endif
augroup END
unlet s:augroup

" ══════════════════════════════════════════════════════════════════════════
"  THỤT LỀ MỤC CON
"  'indentexpr' của buffer: Enter giữ đúng lề dòng trước -> mục con giữ cấp;
"  muốn xuống 1 cấp thì <Tab> (vimrc: expandtab + shiftwidth=4 -> thêm 4
"  space).  Tiêu đề, bảng, và dòng sau dòng trống thì về lề 0.
" ══════════════════════════════════════════════════════════════════════════
" (hàm GLOBAL, không dùng s:, để 'indentexpr' không phụ thuộc <SID> của file)
function! MdIndent(lnum) abort
  if a:lnum <= 1
    return 0
  endif
  let l:prev = getline(a:lnum - 1)
  " dòng trước trống / tiêu đề / bảng -> không thụt
  if l:prev =~# '^\s*$' || l:prev =~# '^\s*#' || l:prev =~# '^\s*|'
    return 0
  endif
  let l:ind = indent(a:lnum - 1)
  " dòng hiện tại đã có nội dung (đang sửa) -> giữ nguyên
  if getline(a:lnum) =~# '\S'
    return indent(a:lnum)
  endif
  return l:ind
endfunction

setlocal indentexpr=MdIndent(v:lnum)
setlocal formatoptions+=n

function! MdToggleTask()
  echo ""
  let row = line(".")
  let line = getline(row)
  if line =~ "\\[ \\]"
    call setline(row, substitute(line, "\\[ \\]", "[x]", ""))
  elseif line =~ "\\[x\\]"
    call setline(row, substitute(line, "\\[x\\]", "[ ]", ""))
  endif
endfunction

function! MdFoldLevel(lnum)
  let line = getline(a:lnum)
  let nextline = getline(a:lnum + 1)
  if a:lnum == 1 && (line =~ "^---\s*$" || line =~ "^+++\s*$")
    return '>1'
  elseif nextline =~ "^=\\+\\s*$"
    return '>1'
  elseif nextline =~ "^-\\+\\s*$"
    if getline(1) =~ "^---\s*$" " is this frontmatter yaml ending?
      let i = a:lnum - 1
      while i > 1
        if getline(i) =~ "^---\s*$"
          return '>2'
        endif
        let i = i - 1
      endwhile
    endif
    return '1' " this is frontmatter yaml ending line
  elseif line =~ "^#"
    return '>' . strlen(matchstr(line, "^#*"))
  else
    let i = a:lnum
    while i > 0
      let line = getline(i)
      let nextline = getline(i + 1)
      if i == 1 && (line =~ "^---\s*$" || line =~ "^+++\s*$")
        return '1'
      elseif nextline =~ "^=\\+\\s*$"
        return '1'
      elseif nextline =~ "^-\\+\\s*$"
        if getline(1) =~ "^---\s*$" " is this frontmatter yaml ending?
          let prev = i - 1
          while prev > 1
            if getline(prev) =~ "^---\s*$"
              return '2'
            endif
            let prev = prev - 1
          endwhile
        endif
        return '1'
      elseif line =~ "^#"
        return strlen(matchstr(line, "^#*"))
      endif
      let i = i - 1
    endwhile
    return '0'
  endif
endfunction

function! MdFoldText()
  let line = getline(v:foldstart)
  let nextline = getline(v:foldstart + 1)
  if line !~ "^#"
    if nextline =~ "^="
      return ("# " . line)
    elseif nextline =~ "^-"
      return ("## " . line)
    endif
  endif
  return line
endfunction

" '\z': đặt foldmethod/foldexpr cho buffer rồi ĐÓNG HẾT fold.
" Ưu tiên hàm fold của vimrc (HaozMdFoldLevel/HaozMdFoldText) để không ghi đè
" cấu hình fold mà vimrc đã đặt; nếu vimrc không có (dùng plugin trần) thì
" dùng bản MdFoldLevel/MdFoldText của file này.  Tất cả đều 'setlocal'.
function! MdFold()
  echo ""
  if exists('*HaozMdFoldLevel')
    setlocal foldmethod=expr
    setlocal foldexpr=HaozMdFoldLevel(v:lnum)
    if exists('*HaozMdFoldText')
      setlocal foldtext=HaozMdFoldText()
    endif
  else
    setlocal foldmethod=expr
    setlocal foldexpr=MdFoldLevel(v:lnum)
    setlocal foldtext=MdFoldText()
  endif
  setlocal foldenable
  setlocal foldlevel=0
endfunction

function! md#setup(leader)
  exe "nmap <buffer> " . a:leader . "= :call MdMakeH1()<CR>"
  exe "nmap <buffer> " . a:leader . "- :call MdMakeH2()<CR>"
  exe "nmap <buffer> " . a:leader . "l :call MdFixOrderedList()<CR>"
  exe "nmap <buffer> " . a:leader . "x :call MdToggleTask()<CR>"
  exe "nmap <buffer> " . a:leader . "t :call MdFixTable()<CR>"
  exe "nmap <buffer> " . a:leader . "z :call MdFold()<CR>"
  exe "nmap <buffer> " . a:leader . "p :!mark %<CR><CR>"
endfunction
