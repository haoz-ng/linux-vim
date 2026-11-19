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

  let l:rawTable = map(
    \ getline(l:top, l:bot),
    \ "split(substitute(substitute(" .
          \ "v:val, '^\\s\\+', '', ''), '\\s\\+$', '', ''), '|', 1)")
  if len(l:rawTable) == 0 || len(l:rawTable[0]) == 0
    return 0
  endif

  " Cắt/thêm đúng 1 space hai bên mỗi ô; dòng phân cách thu về ' -- ' để phần
  " tính độ rộng bên dưới tự kéo dài lại.
  " Bỏ ô rỗng ở đầu/cuối để hàng viết thiếu '|' đầu (kiểu 'Nội dung | text')
  " và hàng có đủ ('| Nội dung | text |') ra cùng số cột; khi ghi sẽ thêm lại.
  let l:table = []
  for l:rawRow in l:rawTable
    let l:cells = copy(l:rawRow)
    if !empty(l:cells) && l:cells[0] !~# '\S'
      call remove(l:cells, 0)
    endif
    if !empty(l:cells) && l:cells[-1] !~# '\S'
      call remove(l:cells, -1)
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
    call add(l:table, l:row)
  endfor

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
  while l:i <= l:bot
    if getline(l:i) =~ "^\\s*+[+-]*$"
      call setline(l:i, l:indent . l:border)
    elseif !empty(l:table)
      call setline(l:i, l:indent . substitute(
        \ "|" . join(remove(l:table, 0), "|") . "|",
        \ "| |", "|", "g"))
    endif
    let l:i = l:i + 1
  endwhile
  return 1
endfunction

" Vùng trong ``` … ``` (không được coi là bảng, không được format)
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
  if l:start > 0
    call add(l:ranges, [l:start, line('$')])
  endif
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
function! s:TableBlockAt(lnum) abort
  if a:lnum < 1 || a:lnum > line('$') || getline(a:lnum) !~# '|'
    return []
  endif
  let l:top = a:lnum
  while l:top > 1 && getline(l:top - 1) =~# '|'
        \ && getline(l:top - 1) !~# '^\s*$'
        \ && getline(l:top - 1) !~# '^\s*```'
        \ && getline(l:top - 1) !~# '^#\{1,6}\%(\s\|$\)'
    let l:top = l:top - 1
  endwhile
  let l:bot = a:lnum
  while l:bot < line('$') && getline(l:bot + 1) =~# '|'
        \ && getline(l:bot + 1) !~# '^\s*$'
        \ && getline(l:bot + 1) !~# '^\s*```'
        \ && getline(l:bot + 1) !~# '^#\{1,6}\%(\s\|$\)'
    let l:bot = l:bot + 1
  endwhile
  for l:i in range(l:top, l:bot)
    if s:IsTableDelim(getline(l:i))
      return [l:top, l:bot]
    endif
  endfor
  if get(g:, 'md_table_guess', 1) && l:bot - l:top >= 2
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
  let l:tables = s:FormatAllTables()
  let l:old = getline(1, '$')
  let l:new = copy(l:old)
  let l:mask = s:FenceMask(l:new)
  call s:FmtTrailing(l:new, l:mask)
  call s:FmtHeaders(l:new, l:mask)
  call s:FmtBullets(l:new, l:mask)
  call s:FmtOrdered(l:new, l:mask)
  let l:new = s:FmtSpacing(l:new)
  if l:new != l:old
    let l:newcur = s:MapCursor(l:old, l:new, l:cur)
    call s:ReplaceLines(l:old, l:new)
    let l:view.lnum = max([1, min([l:newcur, line('$')])])
    let l:view.col = l:col
    let l:view.topline = max([1, l:view.topline + l:newcur - l:cur])
  endif
  call winrestview(l:view)
  return l:tables
endfunction

" Format TOÀN BỘ nội dung: :MdFormat
function! MdFormatAll()
  let l:n = s:FormatBuffer()
  echo 'md: đã format toàn bộ nội dung (' . l:n . ' bảng)'
endfunction

" Chỉ format bảng: :MdFormatTable
function! MdFormatTables()
  let l:n = s:FormatAllTables()
  echo 'md: đã format ' . l:n . ' bảng'
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

" Tự format:
"   • BufWritePre  -> format TOÀN BỘ nội dung (mỗi lần :w, kể cả auto-save)
"   • InsertLeave  -> chỉ căn bảng đang đứng (không xếp lại văn bản khi đang gõ)
" Tắt toàn bộ:  let g:md_autoformat = 0   |  tắt cho buffer này:  :MdAutoFormat
let s:augroup = 'md_autoformat_' . bufnr('')
execute 'augroup ' . s:augroup
  autocmd!
  autocmd BufWritePre <buffer> if <SID>AutoFormatOn() | silent! call <SID>FormatBuffer() | endif
  autocmd InsertLeave  <buffer> if <SID>AutoFormatOn() && getline('.') =~# '|' | silent! call <SID>FormatTableAt(line('.')) | endif
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
