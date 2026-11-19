" ╔══════════════════════════════════════════════════════════════════════════╗
" ║  Author   : haoz.ng                                                      ║
" ║  Version  : 1.1                                                          ║
" ║  Modified : 2026-11-19                                                   ║
" ║  Desc     : Phần RIÊNG của GVim, nạp SAU .vimrc (nên thắng mọi mapping   ║
" ║             trùng trong .vimrc).  Nội dung: disable các phím Normal /    ║
" ║             Visual dễ bấm nhầm (a h j k l s c v p d x o <Del>) để một    ║
" ║             lần gõ lệch không xoá mất chữ hoặc tạo dòng rác.             ║
" ║                                                                          ║
" ║  Điều hướng thay thế : phím mũi tên, chuột, hoặc <C-Left/Right>…         ║
" ║  Xoá / sửa           : <S-Del> (xoá dòng = dd), cc (toggle comment)      ║
" ║  Mở dòng mới         : O (phía trên) / :call append(line('.'), '')       ║
" ║  Chèn câu mẫu        : dd (chèn ngay câu đầu tiên) / dm (menu chọn câu)  ║
" ║  Xem đầy đủ phím     : F1 trong GVim (manual nằm trong .vimrc)           ║
" ║                                                                          ║
" ║  Lưu ý: file này CHỈ có hiệu lực với GVim (gvim).  Chạy vim trong        ║
" ║  terminal thì KHÔNG nạp file này — các phím dưới đây vẫn hoạt động       ║
" ║  bình thường (trừ x / <Del> / o đã bị disable sẵn trong .vimrc).         ║
" ╚══════════════════════════════════════════════════════════════════════════╝

" ── Phím di chuyển / thao tác bị disable ở Normal mode ────────────────────
nnoremap a <Nop>
nnoremap h <Nop>
nnoremap j <Nop>
nnoremap k <Nop>
nnoremap l <Nop>
nnoremap s <Nop>
nnoremap c <Nop>
nnoremap v <Nop>
nnoremap d <Nop>

" ── Xoá / dán: disable cả Visual mode (dễ mất đoạn text khi bấm nhầm) ─────
nnoremap x     <Nop>
nnoremap p     <Nop>
vnoremap p     <Nop>
vnoremap d     <Nop>
nnoremap <Del> <Nop>

" ── Tạo dòng mới: disable ở Normal mode (xem cách thay thế ở header) ──────
nnoremap o <Nop>

" ── CHÈN CÂU MẪU (hàm nằm trong .vimrc) ──────────────────────────────────
" Ở GVim 'd' đã bị disable nên dd/dm KHÔNG giành mất lệnh nào của Vim.
"   dd  chèn NGAY câu đầu tiên của g:haoz_sentences vào DÒNG MỚI dưới con trỏ
"   dm  hiện menu chọn câu (↑↓ hoặc click chuột, Enter = chèn, Esc = huỷ)
" Sau khi chèn, con trỏ nằm ở dòng vừa chèn; 'u' = undo 1 bước.
" <S-Del> vẫn xoá dòng: mapping đó dùng 'nnoremap' nên 'dd' trong RHS chạy
" đúng lệnh gốc của Vim, không bị 2 mapping dưới đây bắt.
nnoremap <silent> dd :call HaozInsertSentenceLine(get(g:haoz_sentences, 0, ''))<CR>
nnoremap <silent> dm :call HaozSentenceMenu()<CR>

" (dòng dưới là ghi chú cũ, giữ lại để tham khảo)
" nnoremap i a
