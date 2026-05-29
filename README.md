<img width="1080" height="814" alt="21aa18861a4d8eb121b3fd8be771292e39ad188bffcf3bc3dbf0baa51d039ec9" src="https://github.com/user-attachments/assets/5de8e43e-07ad-4046-8fd5-050551ee8279" />

# 🖥️ GVIM Personal Configuration — haoz.vimrc

> **Author**: haoz.ng
> **Version**: 6.36
> **Last Modified**: 2026-05-30
> **Description**: Personal GVIM configuration featuring custom themes, keymaps, WinList panel, NERDTree integration, diff highlighting, folding, auto-save, and more.

---

## 📋 Table of Contents

- [Requirements](#-requirements)
- [Installation](#-installation)
- [Features Overview](#-features-overview)
- [Auto Fullscreen](#-auto-fullscreen)
- [Basic Settings](#-basic-settings)
- [Theme & Colors](#-theme--colors)
- [Cursor Shape](#-cursor-shape)
- [Status Line](#-status-line)
- [Comment System](#-comment-system)
- [haoz Annotation](#-haoz-annotation)
- [Auto Save](#-auto-save)
- [Keybindings Reference](#-keybindings-reference)
- [NERDTree Integration](#-nerdtree-integration)
- [WinList Panel](#-winlist-panel)
- [Folding](#-folding)
- [Diff Mode](#-diff-mode)
- [Plugins Used](#-plugins-used)

---

## 📦 Requirements

| Requirement            | Notes                                               |
|------------------------|-----------------------------------------------------|
| **GVIM / Vim 8+**      | Required for `timer_start()`, `win_getid()`, etc.  |
| **wmctrl**             | For auto fullscreen on Linux (X11)                  |
| **NERDTree**           | File explorer integration                           |
| **indentLine**         | Visual indent guides                                |
| **vim-bookmark**       | Bookmark line highlighting                          |
| **colorscheme `haoz`** | Custom color scheme (must be installed separately)  |

> ⚠️ This config is primarily designed for **GVIM on Linux (X11)**. Some features (fullscreen, clipboard, cursor shape) may behave differently on Windows or macOS.

---

## 🚀 Installation

1️⃣ **Back up your existing config:**
```bash
cp ~/.vimrc ~/.vimrc.backup
cp -r ~/.vim ~/.vim.backup
```

2️⃣ **Copy this config file:**
```bash
cp haoz.vimrc ~/.vimrc
```

3️⃣ **Install required plugins** (using [vim-plug](https://github.com/junegunn/vim-plug) as an example):

Add to the top of your `.vimrc` before the config body:
```vim
call plug#begin('~/.vim/plugged')
    Plug 'preservim/nerdtree'
    Plug 'Yggdroot/indentLine'
    Plug 'MattesGroeger/vim-bookmarks'
call plug#end()
```

Then run inside Vim:
```
:PlugInstall
```

4️⃣ **Install `wmctrl`** (for auto fullscreen):
```bash
sudo apt install wmctrl       # Debian / Ubuntu
sudo pacman -S wmctrl         # Arch Linux
```

5️⃣ **Install the `haoz` colorscheme:**
```bash
cp haoz.vim ~/.vim/colors/haoz.vim
```

---

## ✨ Features Overview

| Feature                   | Description                                               |
|---------------------------|-----------------------------------------------------------|
| 🖥️ Auto Fullscreen        | GVIM launches maximized; toggle with `F11`                |
| 🎨 Custom Theme           | `haoz` dark colorscheme with fine-tuned highlights        |
| 📊 Dynamic Status Line    | Color changes based on current mode (Normal/Insert/Replace)|
| 💬 Comment System         | Toggle comments for multiple file types                   |
| ✏️ haoz Annotations       | Mark lines with `// haoz` tag at end or beginning         |
| 💾 Auto Save              | Saves automatically on text change or leaving insert mode |
| 🗂️ WinList Panel          | Sidebar showing all open windows across all tabs          |
| 🌳 NERDTree               | Smart file explorer with auto-close behavior              |
| 📐 Indent Guides          | Visual indentation lines via `indentLine`                 |
| 🔖 Bookmarks              | Line bookmarks with custom highlight colors               |
| 🔀 Diff Mode              | Enhanced diff highlights with keyboard shortcuts          |
| 📁 Folding                | Indent-based folding for Verilog/SystemVerilog files      |

---

## 🖥️ Auto Fullscreen

GVIM automatically launches in a **maximized window** using `wmctrl`.

| Key   | Action                   |
|-------|--------------------------|
| `F11` | Toggle fullscreen on/off |

> 💡 Requires `wmctrl` installed and an X11-based desktop environment.

---

## ⚙️ Basic Settings

| Setting        | Value          | Description                           |
|----------------|----------------|---------------------------------------|
| `encoding`     | `utf-8`        | Full UTF-8 support                    |
| `font`         | `Monospace 11` | Default GUI font                      |
| `tabstop`      | `4`            | Tab width = 4 spaces                  |
| `expandtab`    | ✅ on          | Tabs converted to spaces              |
| `number`       | ✅ on          | Line numbers shown                    |
| `cursorline`   | ✅ on          | Highlight current line                |
| `cursorcolumn` | ✅ on          | Highlight current column              |
| `hlsearch`     | ✅ on          | Highlight all search matches          |
| `ignorecase`   | ✅ on          | Case-insensitive search               |
| `smartcase`    | ✅ on          | Case-sensitive if uppercase used      |
| `autoread`     | ✅ on          | Auto-reload files changed outside Vim |
| `nowrap`       | ✅ on          | No line wrapping by default           |
| `foldlevel`    | `99`           | All folds open by default             |
| `showtabline`  | `2`            | Always show tab bar                   |
| `laststatus`   | `2`            | Always show status line               |

---

## 🎨 Theme & Colors

- **Colorscheme**: `haoz` (dark background)
- **Pure black** background (`#000000`) for all panels: normal area, line numbers, sign column, fold column
- **Cursor line / column**: deep navy `#001933`
- **Cyan cursor line number**: `#00ffff`
- **Search highlight**: blue on grey
- **Fold highlight**: white on dark blue `#003366`
- **Vertical split border**: cyan `#00ffff`

---

## 🖱️ Cursor Shape

| Mode    | Shape              | Blink                |
|---------|--------------------|----------------------|
| Normal  | Vertical bar 25%   | No blink             |
| Insert  | Vertical bar 25%   | 500ms on / 500ms off |
| Replace | Horizontal bar 20% | 500ms on / 500ms off |

> In terminal Vim, uses `t_SI` / `t_EI` escape codes for cursor shape changes.

---

## 📊 Status Line

The status line displays:
```
/full/path/to/file.v          [filetype] [line/total] [indent-size spaces/tabs]
```

### Dynamic Color by Mode

| Mode    | Background Color    |
|---------|---------------------|
| Normal  | Dark navy `#001933` |
| Insert  | Dark red `#661900`  |
| Replace | Dark green `#006619`|

> 🔄 Polled every **500ms** via `timer_start()`. Timer pauses when Vim loses focus.

---

## 💬 Comment System

Supports toggling comments for the following file types:

| File Types                                          | Comment Style |
|-----------------------------------------------------|---------------|
| `c`, `cpp`, `java`, `scala`, `v`, `sv`, `svh`       | `//`          |
| `sh`, `python`, `ruby`, `csh`, `tcsh`, `conf`, `txt`| `#`           |
| `tex`                                               | `%`           |
| `mail`                                              | `>`           |
| `vim`                                               | `"`           |
| `nasm`                                              | `;`           |

| Key  | Mode   | Action                               |
|------|--------|--------------------------------------|
| `cc` | Normal | Toggle comment on current line       |
| `cc` | Visual | Toggle comment on all selected lines |

> **Smart toggle**: If all selected lines are commented → uncomment. If any line is uncommented → comment all.

---

## ✏️ haoz Annotation

Two special annotation modes for marking lines during code review or debugging.

### `hh` — Append `// haoz` at End of Line

```
signal <= data;          →    signal <= data; // haoz
signal <= data; // haoz  →    signal <= data;
```

| Key  | Mode            | Action                           |
|------|-----------------|----------------------------------|
| `hh` | Normal / Visual | Toggle `// haoz` at end of line  |

### `ch` — Prepend `// haoz` at Beginning of Line

```
    signal <= data;              →      // haoz signal <= data;
    // haoz signal <= data;      →      signal <= data;
```

| Key  | Mode            | Action                                        |
|------|-----------------|-----------------------------------------------|
| `ch` | Normal          | Toggle `// haoz` at beginning of line         |
| `ch` | Visual          | Toggle `// haoz` at beginning of selected lines|

---

## 💾 Auto Save

Files are **automatically saved** when:
- Text is changed in normal mode (`TextChanged`)
- Leaving insert mode (`InsertLeave`)

> ⚠️ Only saves if the file is **not read-only** and **has unsaved changes**. Files without a type are assigned `log` filetype automatically.

---

## ⌨️ Keybindings Reference

### General

| Key         | Mode   | Action                                      |
|-------------|--------|---------------------------------------------|
| `F5`        | Normal | Force reload current file (discard changes) |
| `F10`       | Normal | Toggle menu bar & toolbar                   |
| `F11`       | Normal | Toggle fullscreen                           |
| `F12`       | Normal | Copy full file path to clipboard            |
| `Ctrl+N`    | Normal | Open new tab                                |
| `Ctrl+W`    | Normal | Close current window                        |
| `Ctrl+\`    | Normal | Vertical split                              |
| `Ctrl+O`    | Normal | Open file browser (`:E`)                    |
| `Ctrl+A`    | Normal | Select all                                  |
| `Shift+L`   | Normal | Clear search highlight                      |
| `Alt+Z`     | Normal | Toggle line wrap                            |
| `Shift+Del` | Normal | Delete current line                         |

### Copy / Paste / Cut

| Key      | Mode            | Action                  |
|----------|-----------------|-------------------------|
| `Ctrl+C` | Normal          | Copy current line       |
| `Ctrl+C` | Visual          | Copy selection          |
| `Ctrl+V` | Normal / Insert | Paste from clipboard    |
| `Ctrl+X` | Normal          | Cut current line        |
| `Ctrl+X` | Visual          | Cut selection           |

### Selection

| Key      | Mode            | Action                                               |
|----------|-----------------|------------------------------------------------------|
| `Ctrl+L` | Normal          | Select current line (visual line)                    |
| `Ctrl+L` | Insert          | Exit insert + select current line                    |
| `V`      | Normal          | Enter **block visual** mode (remapped from `Ctrl+V`) |
| `Ctrl+D` | Normal          | Select current word (visual)                         |
| `Ctrl+F` | Normal          | Highlight all occurrences of word under cursor       |
| `Ctrl+F` | Visual          | Highlight all occurrences of selection               |

### Shift+Arrow Selection

| Key                        | Mode                    | Action                   |
|----------------------------|-------------------------|--------------------------|
| `Shift+Left/Right/Up/Down` | Normal / Insert / Visual| Extend selection         |
| `Shift+Home/End`           | Normal / Insert / Visual| Extend to line start/end |
| `Ctrl+Shift+Left/Right`    | Insert                  | Extend selection by word |

### Ctrl+Arrow Navigation

| Key          | Mode   | Action                  |
|--------------|--------|-------------------------|
| `Ctrl+Right` | Normal | Jump to next word       |
| `Ctrl+Left`  | Normal | Jump to previous word   |
| `Ctrl+Right` | Visual | Extend to end of word   |
| `Ctrl+Left`  | Visual | Extend to previous word |
| `Ctrl+Right` | Insert | Move to next word       |
| `Ctrl+Left`  | Insert | Move to previous word   |

### Indentation

| Key         | Mode   | Action                               |
|-------------|--------|--------------------------------------|
| `Tab`       | Normal | Smart indent current line forward    |
| `Shift+Tab` | Normal | Smart de-indent current line         |
| `Tab`       | Visual | Indent all selected lines            |
| `Shift+Tab` | Visual | De-indent all selected lines         |

### Undo

| Key      | Mode                    | Action |
|----------|-------------------------|--------|
| `Ctrl+Z` | Normal / Insert / Visual| Undo   |

### Search Navigation

| Key | Action                             |
|-----|------------------------------------|
| `n` | Next match, centered on screen     |
| `N` | Previous match, centered on screen |

### Case Toggle

| Key      | Mode   | Action                           |
|----------|--------|----------------------------------|
| `Ctrl+U` | Normal | Toggle case of word under cursor |
| `Ctrl+U` | Visual | Toggle case of selection         |

### Home Key

| Key    | Mode            | Action                                      |
|--------|-----------------|---------------------------------------------|
| `Home` | Normal / Insert | Jump to first **non-whitespace** character  |

---

## 🌳 NERDTree Integration

| Key      | Action                                         |
|----------|------------------------------------------------|
| `Ctrl+B` | Toggle NERDTree (smart: opens at current file) |

### Smart Open Behavior (`SmartNERDTreeToggle`)

- If NERDTree is **open** → close it
- If the current buffer is **empty** → open at CWD
- If the current buffer is a **readable file** → `NERDTreeFind` (reveal in tree)
- Otherwise → open at the file's **parent directory**

### File Opening from NERDTree

When you press `Enter` or **double-click** a file in NERDTree:
- The file opens in a **vertical split** to the right of existing windows
- NERDTree **auto-closes** after opening the file (50ms delay)

---

## 🗂️ WinList Panel

The **WinList Panel** is a custom sidebar that shows all open windows **across all tabs** in a single panel.

### Appearance

```
=== Tab 1 ===
> 1: main.v              ← active window (marked with >)
     …/a/b/c
  2: config.sv [+]       ← modified file
     …/a/b/d
=== Tab 2 ===
  1: testbench.sv
     …/a/d
```

- `>` marks the **currently active** window
- `[+]` marks **unsaved / modified** buffers
- Paths are **shortened** to last 5 directory components with `…/` prefix

### Keybindings

| Key          | Action                           |
|--------------|----------------------------------|
| `<leader>w`  | Toggle WinList panel             |
| `<leader>W`  | Fix / reset WinList panel width  |
| `<leader>wa` | Open WinList in **all tabs**     |

### Inside WinList Panel

| Key             | Action                              |
|-----------------|-------------------------------------|
| `Enter`         | Jump to the selected window         |
| `Double-click`  | Jump to the selected window (mouse) |
| `q`             | Close WinList panel                 |
| `r`             | Refresh WinList panel (all tabs)    |

### Commands

| Command             | Description                   |
|---------------------|-------------------------------|
| `:WinList`          | Open WinList panel            |
| `:WinListClose`     | Close WinList panel           |
| `:WinListFix`       | Fix panel width               |
| `:WinListRefresh`   | Refresh panel content         |
| `:WinListAllTabs`   | Open WinList in all tabs      |

### Width Configuration

```vim
let g:winlist_min_width  = 15   " Minimum panel width
let g:winlist_max_width  = 75   " Maximum panel width
let g:winlist_padding    = 2    " Extra padding
let g:winlist_width      = 36   " Default starting width
```

> Width is **auto-calculated** based on the longest filename + path displayed.

### Auto-Behaviors

- ✅ WinList **opens automatically** on `VimEnter`
- ✅ WinList **refreshes** on `BufEnter`, `WinEnter`, `BufDelete`, `TextChanged`
- ✅ WinList **state is preserved** per tab (if open before tab-switch, reopens on return)
- ✅ Auto-closes the **entire tab** (or Vim) when the last real file window is closed

---

## 📁 Folding

- **Default**: All folds open at startup (`foldlevel=99`)
- **Verilog / SystemVerilog** (`.v`, `.sv`, `.svh`): indent-based folding enabled
- `matchit.vim` macro loaded for enhanced `%` matching (begin/end blocks)

---

## 🔀 Diff Mode

| Highlight    | Dark Background   | Light Background |
|--------------|-------------------|------------------|
| `DiffAdd`    | Green `#29762e`   | `#cce8cc`        |
| `DiffChange` | Blue `#304e75`    | `#cce0fa`        |
| `DiffDelete` | Red `#772e2e`     | `#facccc`        |
| `DiffText`   | Bright red `#aa3a3a` | `#ffbaba`     |

### Diff Keybindings (active only in diff mode)

| Key  | Action                                |
|------|---------------------------------------|
| `dn` | Jump to **next** diff hunk (`]c`)     |
| `db` | Jump to **previous** diff hunk (`[c`) |
| `df` | **Apply** current hunk (`dp`)         |

> All diff windows have folding **disabled** automatically on open.

---

## 🔌 Plugins Used

| Plugin | Purpose |
|--------|---------|
| [preservim/nerdtree](https://github.com/preservim/nerdtree) | File tree explorer |
| [Yggdroot/indentLine](https://github.com/Yggdroot/indentLine) | Visual indent guides |
| [MattesGroeger/vim-bookmarks](https://github.com/MattesGroeger/vim-bookmarks) | Line bookmarks |

### Plugin Configuration

```vim
" IndentLine
let g:indentLine_color_gui = '#0055aa'   " Guide color: steel blue
let g:indentLine_char      = '┆'         " Guide character

" Vim Bookmark
let g:bookmark_highlight_lines = 1
let g:bookmark_sign            = '=='
let g:bookmark_center          = 1
" Highlight: navy background #001933, cyan sign #00ffff
```

---

## 📝 Notes

- **`x` and `Del`** keys are **disabled** in normal mode to prevent accidental single-character deletion. Use `d` motions instead.
- **Cursor position** is restored when reopening a file (via `BufReadPost` autocmd).
- **Auto-comment insertion** (`formatoptions-=cro`) is disabled for all file types to prevent Vim from auto-inserting comment leaders on new lines.
- The `guitablabel=%t%M` setting shows only the **filename** (not full path) in the tab bar, with `[+]` for modified files.

---

## 📜 License

Personal configuration — free to use, modify, and distribute.
