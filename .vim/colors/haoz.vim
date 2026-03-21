" Clear existing highlights
highlight clear
if exists("syntax_on")
  syntax reset
endif

" Set colorscheme name
let g:colors_name = "haoz"

" Set background (light or dark)
set background=dark

" ===== Color Palette =====
" Define your colors using hex codes
let s:black         = "#1e1e1e"
let s:red           = "#e06c75"
let s:green         = "#98c379"
let s:yellow        = "#e5c07b"
let s:blue          = "#61afef"
let s:magenta       = "#c678dd"
let s:cyan          = "#56b6c2"
let s:white         = "#abb2bf"
let s:bright_black  = "#5c6370"
let s:bg            = "#282c34"
let s:fg            = "#abb2bf"

" Basic syntax
" highlight GroupName guifg=<foreground> guibg=<background> gui=<style> ctermfg=<num> ctermbg=<num> cterm=<style>

" ===== Default Editor Settings =====
highlight Normal        guifg=#abb2bf guibg=#282c34 ctermfg=145 ctermbg=235
highlight Cursor        guifg=#282c34 guibg=#abb2bf ctermfg=235 ctermbg=145
highlight CursorLine    guibg=#2c323c ctermbg=236 cterm=none
highlight LineNr        guifg=#5c6370 guibg=#282c34 ctermfg=240 ctermbg=235
highlight CursorLineNr  guifg=#abb2bf guibg=#2c323c ctermfg=145 ctermbg=236

" ===== Default Syntax Highlighting =====
highlight Comment       guifg=#5c6370 gui=italic ctermfg=240 cterm=italic
highlight String        guifg=#98c379 ctermfg=114
highlight Number        guifg=#e5c07b ctermfg=180
highlight Boolean       guifg=#e5c07b ctermfg=180
highlight Function      guifg=#61afef ctermfg=75
highlight Keyword       guifg=#c678dd ctermfg=176
highlight Conditional   guifg=#c678dd ctermfg=176
highlight Repeat        guifg=#c678dd ctermfg=176
highlight Operator      guifg=#56b6c2 ctermfg=73
highlight Type          guifg=#e5c07b ctermfg=180
highlight StorageClass  guifg=#e5c07b ctermfg=180
highlight Identifier    guifg=#e06c75 ctermfg=204
highlight Constant      guifg=#e5c07b ctermfg=180
highlight PreProc       guifg=#c678dd ctermfg=176
highlight Special       guifg=#61afef ctermfg=75

" ===== Default UI Elements =====
highlight StatusLine    guifg=#abb2bf guibg=#2c323c ctermfg=145 ctermbg=236
highlight StatusLineNC  guifg=#5c6370 guibg=#2c323c ctermfg=240 ctermbg=236
highlight VertSplit     guifg=#2c323c guibg=#2c323c ctermfg=236 ctermbg=236
highlight Visual        guibg=#3e4452 ctermbg=238
highlight Search        guifg=#282c34 guibg=#e5c07b ctermfg=235 ctermbg=180
highlight IncSearch     guifg=#282c34 guibg=#61afef ctermfg=235 ctermbg=75

" Use Helper Function for Cleaner Code
function! s:hi(group, fg, bg, style)
  execute "highlight " . a:group . " guifg=" . a:fg . " guibg=" . a:bg . " gui=" . a:style
endfunction

" " ============================================
" " GENERAL TEXT GROUPS
" " ============================================

" Normal        " Normal text - default foreground and background colors
" NonText       " Characters that don't exist in the text (e.g., ~ lines beyond end of buffer, @ for wrapped lines)
" SpecialKey    " Special keys in listings (e.g., ^I for tab, $ for end of line when 'list' is set)
" Whitespace    " Visible whitespace characters when 'list' is enabled (spaces, tabs)
" Conceal       " Concealed text (placeholder characters for concealed text)
" EndOfBuffer   " Filler lines (~) after the end of the buffer

" " ============================================
" " SYNTAX HIGHLIGHTING GROUPS
" " ============================================

" Comment       " Any comment in the code
" Constant      " Any constant value (generic parent group)
" String        " String literals: "hello", 'world'
" Character     " Character constants: 'a', '\n'
" Number        " Numeric constants: 123, 0xFF
" Boolean       " Boolean constants: true, false
" Float         " Floating point constants: 3.14, 1.5e-10

" Identifier    " Variable names, identifiers
" Function      " Function names, method names

" Statement     " Any programming language statement (generic parent group)
" Conditional   " Conditional statements: if, then, else, endif, switch, case
" Repeat        " Loop statements: for, do, while, until, loop
" Label         " Case labels, goto labels: case, default
" Operator      " Operators: sizeof, +, -, *, /, %, =, ==, <, >, &&, ||
" Keyword       " Any other keyword not covered above: return, break, continue
" Exception     " Exception handling: try, catch, throw, finally, raise

" PreProc       " Generic preprocessor (parent group)
" Include       " Preprocessor #include directives
" Define        " Preprocessor #define directives
" Macro         " Macro names (same as Define)
" PreCondit     " Preprocessor conditionals: #if, #else, #endif, #ifdef

" Type          " Data type declarations (int, long, char, etc.)
" StorageClass  " Storage class specifiers: static, register, volatile, extern, const
" Structure     " Structure/union/enum keywords: struct, union, enum, class
" Typedef       " Typedef keyword

" Special       " Any special symbol or character (parent group)
" SpecialChar   " Special character within a constant (e.g., \n, \t, escape sequences)
" Tag           " You can use CTRL-] on this (e.g., HTML tags, help tags)
" Delimiter     " Character that needs attention: parentheses, brackets, braces
" SpecialComment" Special things inside a comment (e.g., @param, TODO)
" Debug         " Debugging statements

" Underlined    " Text that stands out, HTML links (usually underlined)
" Ignore        " Left blank, hidden text (very low priority)
" Error         " Any erroneous construct, syntax errors
" Todo          " Anything that needs extra attention: TODO, FIXME, NOTE, XXX, HACK

" " ============================================
" " CURSOR AND LINES
" " ============================================

" Cursor        " The character under the cursor in normal mode
" CursorIM      " Like Cursor, but used when in IME (Input Method Editor) mode
" CursorLine    " The screen line that the cursor is on (when 'cursorline' is set)
" CursorLineNr  " Line number for the line with the cursor (when 'cursorline' and 'number' are set)
" CursorColumn  " The screen column that the cursor is in (when 'cursorcolumn' is set)
" TermCursor    " Cursor in a focused terminal window
" TermCursorNC  " Cursor in an unfocused terminal window

" " ============================================
" " LINE NUMBERS AND COLUMNS
" " ============================================

" LineNr        " Line number column (when 'number' or 'relativenumber' is set)
" LineNrAbove   " Line numbers above the cursor line (Vim 9.0+)
" LineNrBelow      " Line numbers below the cursor line (Vim 9.0+)
" SignColumn       " Column where signs are displayed (left margin for marks/breakpoints)
" ColorColumn      " Column set with 'colorcolumn' (vertical ruler at specific column)
" FoldColumn       " Column showing fold indicators ('+', '-' for folded/unfolded lines)
" VertSplit        " Vertical separator between split windows (traditional)
" WinSeparator     " Separator between window splits (NeoVim, replaces VertSplit)

" " ============================================
" " STATUS AND TAB LINES
" " ============================================

" StatusLine       " Status line of current window (bottom bar)
" StatusLineNC     " Status line of non-current windows
" StatusLineTerm   " Status line of current terminal window
" StatusLineTermNC " Status line of non-current terminal windows
" TabLine          " Tab pages line, inactive tabs
" TabLineFill      " Tab pages line, where there are no labels (filler)
" TabLineSel       " Tab pages line, active/selected tab

" " ============================================
" " SEARCH AND SELECTION
" " ============================================

" Search           " Last search pattern highlighting (when 'hlsearch' is on)
" IncSearch        " Incremental search highlighting (while typing search pattern)
" CurSearch        " Current search match under cursor (Vim 9.0+, differentiates from other matches)
" Substitute       " Substitute replacement text preview (when 'inccommand' is set in Neovim)
" Visual           " Visual mode selection (highlighted text)
" VisualNOS        " Visual mode selection when Vim is "Not Owning the Selection" (X11 only)

" " ============================================
" " MENUS AND POPUPS
" " ============================================

" Menu             " Current font, background, and foreground colors of menus
" Scrollbar        " Main window's scrollbar colors
" Tooltip          " Tooltip colors (when hovering over items)
" Pmenu            " Popup menu: normal item (completion menu background)
" PmenuSel         " Popup menu: selected item (highlighted item in completion menu)
" PmenuSbar        " Popup menu: scrollbar background
" PmenuThumb       " Popup menu: scrollbar thumb (the draggable part)
" PmenuKind        " Popup menu: kind indicator for normal item (e.g., function, variable icon)
" PmenuKindSel     " Popup menu: kind indicator for selected item
" PmenuExtra       " Popup menu: extra text for normal item (additional info)
" PmenuExtraSel    " Popup menu: extra text for selected item

" " ============================================
" " MESSAGES AND PROMPTS
" " ============================================

" Directory        " Directory names (in listings, file explorers)
" Question         " Hit-enter prompt and yes/no questions
" MoreMsg          " More-prompt (-- More -- when output doesn't fit on screen)
" ModeMsg          " Mode message (e.g., -- INSERT --, -- VISUAL --)
" WarningMsg       " Warning messages
" ErrorMsg         " Error messages on the command line
" Title            " Titles for output from :set all, :autocmd, etc.
" MsgArea          " Area for messages and command-line (Neovim)
" MsgSeparator     " Separator for scrolled messages (Neovim)

" " ============================================
" " DIFF MODE
" " ============================================

" DiffAdd          " Diff mode: Added line (line that exists in new file but not old)
" DiffChange       " Diff mode: Changed line (line that exists in both but differs)
" DiffDelete       " Diff mode: Deleted line (line that exists in old file but not new)
" DiffText         " Diff mode: Changed text within a changed line (specific characters that differ)

" " ============================================
" " FOLDING
" " ============================================

" Folded           " Line used for closed folds (the placeholder line showing "... X lines folded")
" FoldColumn       " Column on the left showing fold status (already listed above, fold indicators)

" " ============================================
" " MATCHING AND SPELLING
" " ============================================

" MatchParen       " Character under the cursor or just before it, if it's a paired bracket ()[]{}
" QuickFixLine     " Current line in the quickfix window (highlighted when navigating errors)
" SpellBad         " Word not recognized by spellchecker (misspelled word)
" SpellCap         " Word that should start with a capital letter
" SpellLocal       " Word recognized as one from another region/language
" SpellRare        " Word recognized as one that is rarely used

" " ============================================
" " SPECIAL PURPOSE
" " ============================================

" WildMenu         " Current match in 'wildmenu' completion (command-line completion menu)
" WinBar           " Window bar of current window (window-local statusline, Vim 9.0+)
" WinBarNC         " Window bar of not-current windows (Vim 9.0+)

  " " ============================================
" " FLOATING WINDOWS (Neovim specific)
" " ============================================

" FloatBorder      " Border of floating windows
" FloatTitle       " Title of floating windows
" NormalFloat      " Normal text in floating windows (popup windows)

" " ============================================
" " TERMINAL MODE (additional)
" " ============================================

" " Note: Terminal colors are usually defined as:
" " Terminal color palette (0-15) used in :terminal
" " These are not highlight groups but terminal color definitions:
" " g:terminal_color_0 through g:terminal_color_15

" " ============================================
" " LINKING GROUPS
" " ============================================

" " Groups are often linked to maintain consistency:
" " Example: highlight link CursorLineNr LineNr
" " This makes CursorLineNr use the same colors as LineNr

" " ============================================
" " EXAMPLE USAGE
" " ============================================

" " Set Normal text colors
" " highlight Normal guifg=#FFFFFF guibg=#000000 ctermfg=white ctermbg=black

" " Set Comment color to green and italic
" " highlight Comment guifg=#00FF00 gui=italic ctermfg=green cterm=italic

" " Link Function to Identifier (make them look the same)
" " highlight link Function Identifier

" " Clear a highlight group (revert to default)
" " highlight clear Comment

" " View current settings
" " :highlight Normal
" " :highlight Comment

" " ============================================
" " COLOR ATTRIBUTES
" " ============================================

" " guifg=       GUI foreground color (hex: #RRGGBB or color name)
" " guibg=       GUI background color
" " ctermfg=     Terminal foreground color (0-255 or color name)
" " ctermbg=     Terminal background color
" " gui=         GUI attributes (bold, italic, underline, undercurl, strikethrough, reverse, inverse, standout, NONE)
" " cterm=       Terminal attributes (same as gui)
" " guisp=       GUI special color (for undercurl/underline color)

" " ============================================
" " TOTAL COUNT: 110+ highlight groups
" " ============================================

"for verilog/systemverilog syntax
call s:hi("verilogStatement",    s:red,      "NONE", "NONE")
call s:hi("verilogBeginEnd",     s:blue,     "NONE", "NONE")
call s:hi("verilogIdentifier",   s:red,      "NONE", "NONE")
call s:hi("verilogMethod",       "#bf65cf",  "NONE", "NONE")
call s:hi("verilogNumber",       s:red,      "NONE", "NONE")
call s:hi("verilogGlobal",       s:blue,     "NONE", "NONE")
call s:hi("verilogObject",       s:red,      "NONE", "NONE")
call s:hi("verilogConditional",  "#bf65cf",  "NONE", "NONE")
call s:hi("verilogRepeat",       "#bf65cf",  "NONE", "NONE")
call s:hi("verilogOperator",     s:blue,     "NONE", "NONE")
call s:hi("Comment",             s:white,    "NONE", "italic")
call s:hi("Todo",                s:green,    "NONE", "underline,italic")
call s:hi("String",              s:cyan,     "NONE", "NONE")

"for other synxtax
call s:hi("Function",       "#bf65cf",  "NONE",      "NONE")
call s:hi("Number",         s:blue,     "NONE",      "NONE")
call s:hi("Constant",       s:blue,     "NONE",      "NONE")
call s:hi("Conditional",    "#bf65cf",  "NONE",      "NONE")
call s:hi("Function",       "#bf65cf",  "NONE",      "NONE")
call s:hi("Operator",       s:red,      "NONE",      "NONE")
call s:hi("Special",        s:red,      "NONE",      "NONE")
call s:hi("Repeat",         "#bf65cf",  "NONE",      "NONE")
call s:hi("Statement",      s:blue,     "NONE",      "NONE")
call s:hi("Pmenu",          s:blue,     "#363636",   "NONE")
call s:hi("PmenuSel",       s:blue,     "#575757",   "underline,italic")
call s:hi("StatusLine",     s:blue,     "NONE",      "NONE")
call s:hi("StatusLineNC",   s:blue,     "NONE",      "NONE")
call s:hi("VertSplit",      s:blue,     "NONE",      "NONE")
call s:hi("DiffAdd",        s:blue,     "NONE",      "NONE")
call s:hi("DiffChange",     s:blue,     "NONE",      "NONE")
call s:hi("DiffDelete",     s:blue,     "NONE",      "NONE")
call s:hi("DiffText",       s:blue,     "NONE",      "NONE") 
