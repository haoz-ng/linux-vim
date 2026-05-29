<img width="1080" height="814" alt="21aa18861a4d8eb121b3fd8be771292e39ad188bffcf3bc3dbf0baa51d039ec9" src="https://github.com/user-attachments/assets/5de8e43e-07ad-4046-8fd5-050551ee8279" />

# 🖥️ GVIM Personal Configuration — `vimrc` v6.36

> **Author:** haoz.ng
> **Version:** 6.36
> **Last Modified:** 2026-05-30
> **Description:** Personal GVIM configuration featuring custom themes, keymaps, WinList panel, NERDTree integration, diff mode, folding, auto-save, and much more.

---

## 📑 Table of Contents

- [Requirements](#-requirements)
- [Installation](#-installation)
- [Feature Overview](#-feature-overview)
  - [Auto Fullscreen](#1️⃣-auto-fullscreen)
  - [Basic Settings](#2️⃣-basic-settings)
  - [Theme and Colors](#3️⃣-theme-and-colors)
  - [Cursor Shape](#4️⃣-cursor-shape)
  - [Status Line](#5️⃣-status-line)
  - [Comment System](#6️⃣-comment-system)
  - [Haoz Annotation Markers](#7️⃣-haoz-annotation-markers)
  - [Auto Save](#8️⃣-auto-save)
  - [Keybindings](#9️⃣-keybindings)
  - [Folding](#-folding)
  - [NERDTree Integration](#-nerdtree-integration)
  - [IndentLine Plugin](#-indentline-plugin)
  - [Vim Bookmark Plugin](#-vim-bookmark-plugin)
  - [GUI Settings](#-gui-settings)
  - [Diff Mode](#-diff-mode)
  - [WinList Panel](#-winlist-panel)
- [Keybinding Quick Reference](#-keybinding-quick-reference)
- [Plugin Dependencies](#-plugin-dependencies)
- [Customization Tips](#-customization-tips)
- [Notes](#-notes)

---

## 📦 Requirements

| Requirement           | Details                                           |
|-----------------------|---------------------------------------------------|
| **Vim / GVim**        | Version 8.0+ (requires `timer_start`, `win_getid`) |
| **GUI**               | GTK-based GVim recommended                        |
| **wmctrl**            | Required for fullscreen toggle on Linux           |
| **NERDTree**          | Plugin — file tree explorer                       |
| **indentLine**        | Plugin — visual indent guide lines                |
| **vim-bookmark**      | Plugin — line bookmarking                         |
| **haoz colorscheme**  | Custom colorscheme file (`haoz.vim`)              |

---

## 🔧 Installation

### 1. Copy the vimrc

```bash
cp vimrc ~/.vimrc
# or for GVim-specific config:
cp vimrc ~/.gvimrc
```

### 2. Install Required Plugins

Using [vim-plug](https://github.com/junegunn/vim-plug):

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

### 3. Install the Custom Colorscheme

Place `haoz.vim` inside:

```
~/.vim/colors/haoz.vim
```

### 4. Install `wmctrl` (Linux only — for fullscreen support)

```bash
sudo apt install wmctrl       # Debian / Ubuntu
sudo dnf install wmctrl       # Fedora
sudo pacman -S wmctrl         # Arch Linux
```

---

## 🚀 Feature Overview

---

### 1️⃣ Auto Fullscreen

When GVim starts, it automatically enters **maximized mode** using `wmctrl`.

- **Startup:** Window is maximized vertically and horizontally on launch.
- **Toggle:** Press `F11` to toggle maximized state at any time.

```
F11 → Toggle fullscreen (GVim only, requires wmctrl)
```

> ⚠️ Requires `wmctrl` to be installed. On non-Linux systems, this will silently fail and can be safely ignored.

---

### 2️⃣ Basic Settings

| Setting         | Value                  | Description                              |
|-----------------|------------------------|------------------------------------------|
| `encoding`      | `utf-8`                | Full UTF-8 support                       |
| `guifont`       | `Monospace Regular 11` | Default GUI font                         |
| `number`        | on                     | Show line numbers                        |
| `hlsearch`      | on                     | Highlight search results                 |
| `ignorecase`    | on                     | Case-insensitive search                  |
| `smartcase`     | on                     | Case-sensitive if uppercase is used      |
| `autoread`      | on                     | Auto-reload files changed outside Vim    |
| `tabstop`       | 4                      | Tab width = 4 spaces                     |
| `shiftwidth`    | 4                      | Indent width = 4 spaces                  |
| `expandtab`     | on                     | Use spaces instead of tab characters     |
| `autoindent`    | on                     | Auto-indent new lines                    |
| `nowrap`        | on                     | Disable line wrapping by default         |
| `cursorline`    | on                     | Highlight current line                   |
| `cursorcolumn`  | on                     | Highlight current column                 |
| `foldlevel`     | 99                     | All folds open by default                |
| `mouse`         | `a`                    | Enable mouse in all modes                |
| `showtabline`   | 2                      | Always show the tab bar                  |
| `laststatus`    | 2                      | Always show the status line              |

---

### 3️⃣ Theme and Colors

- **Colorscheme:** `haoz` (custom dark theme — must be installed separately)
- **Background:** Pure black (`#000000`) for all base elements
- **Accent color:** Cyan (`#00ffff`) used throughout UI elements

| Highlight Group  | Background  | Foreground  | Notes                      |
|------------------|-------------|-------------|----------------------------|
| `Normal`         | `#000000`   | —           | Main editor background     |
| `CursorLine`     | `#001933`   | —           | Active line highlight       |
| `CursorColumn`   | `#001933`   | —           | Active column highlight     |
| `CursorLineNr`   | `#001933`   | `#00ffff`   | Current line number         |
| `Folded`         | `#003366`   | `#ffffff`   | Folded region display       |
| `Search`         | `#888888`   | `#0000ff`   | Search result highlight     |
| `VertSplit`      | `#191E2A`   | `#00ffff`   | Window split divider        |
| `SpecialKey`     | `#001933`   | `#00ffff`   | Special/invisible chars     |
| `TabLineSel`     | cterm `0`   | cterm `159` | Active tab label            |

---

### 4️⃣ Cursor Shape

**In GVim:**

| Mode     | Shape              | Blink             |
|----------|--------------------|-------------------|
| Normal   | Vertical bar 25%   | No blink          |
| Insert   | Vertical bar 25%   | 500ms on/off      |
| Replace  | Horizontal bar 20% | 500ms on/off      |

**In Terminal Vim:**

| Mode    | Cursor       | Escape Code  |
|---------|--------------|--------------|
| Insert  | `\|` beam    | `\e[6 q`     |
| Normal  | Block        | `\e[2 q`     |

---

### 5️⃣ Status Line

The status line displays:

```
[Full file path]                    [FileType] [Line/Total] [IndentWidth spaces/tabs]
```

#### Dynamic Color Modes

The status bar **background color changes** to reflect the current editing mode,
updated every **500ms** via a background timer:

| Mode    | Status Bar Background  | Description          |
|---------|------------------------|----------------------|
| Normal  | `#001933` (dark blue)  | Default state        |
| Insert  | `#661900` (dark red)   | Actively editing     |
| Replace | `#006619` (dark green) | Replace mode active  |

> ✅ The timer starts automatically on `VimEnter` / `FocusGained` and stops on `FocusLost` / `QuitPre` for clean resource management.

---

### 6️⃣ Comment System

Context-aware commenting based on file type. Automatically detects the
correct comment syntax for the language you are editing.

#### Supported File Types

| File Types                                          | Comment Style |
|-----------------------------------------------------|---------------|
| `c`, `cpp`, `java`, `scala`, `v`, `sv`, `svh`      | `//`          |
| `sh`, `csh`, `python`, `ruby`, `conf`, `fstab`, `txt` | `#`         |
| `tex`                                               | `%`           |
| `mail`                                              | `>`           |
| `vim`                                               | `"`           |
| `nasm`                                              | `;`           |

#### Keybindings

| Key  | Mode   | Action                            |
|------|--------|-----------------------------------|
| `cc` | Normal | Toggle comment on current line    |
| `cc` | Visual | Toggle comment on selected lines  |

#### Smart Toggle Behavior

- If **all** selected lines are already commented → **uncomment** all.
- If **any** line is not commented → **comment** all.
- Preserves **leading whitespace** and indentation.
- **Skips blank lines** automatically.

---

### 7️⃣ Haoz Annotation Markers

Two special annotation systems for marking lines with personal `haoz` tags.
Useful for **code review**, **TODO tracking**, or **personal change markers**.

---

#### `hh` — Append marker at End of Line

Toggles a `// haoz` tag **at the end** of the current line.

```
// original code here              →  // original code here // haoz
// original code here // haoz      →  // original code here
```

| Key  | Mode          | Action                          |
|------|---------------|---------------------------------|
| `hh` | Normal/Visual | Toggle `// haoz` at end of line |

---

#### `ch` — Prepend marker at Beginning of Line

Toggles a `// haoz` marker **at the beginning** of the line
(after any existing indentation).

```
    some_code();              →      // haoz some_code();
    // haoz some_code();      →      some_code();
```

| Key  | Mode   | Action                                        |
|------|--------|-----------------------------------------------|
| `ch` | Normal | Toggle `// haoz` prefix on current line       |
| `ch` | Visual | Toggle `// haoz` prefix on all selected lines |

> Both `hh` and `ch` automatically use the correct comment syntax for
> the current file type (e.g., `#` for Python, `--` for SQL, etc.).

---

### 8️⃣ Auto Save

Files are **automatically saved** whenever:

- Text is changed in Normal mode (`TextChanged`)
- You leave Insert mode (`InsertLeave`)

| Condition              | Behavior              |
|------------------------|-----------------------|
| Buffer is writable     | ✅ Auto-saved silently |
| Buffer is read-only    | ❌ Never saved         |
| Buffer is not modified | ❌ Skipped             |

> ✅ Files with no detected filetype are automatically assigned the `log`
> filetype on open, ensuring they are handled gracefully.

---

### 9️⃣ Keybindings

#### 📁 File & Tab Management

| Key       | Action                                      |
|-----------|---------------------------------------------|
| `Ctrl+N`  | Open new tab                                |
| `Ctrl+W`  | Close current window / tab (`:q`)           |
| `Ctrl+\`  | Open vertical split                         |
| `Ctrl+O`  | Open file explorer (`:E`)                   |
| `F5`      | Reload current file (`:edit!`)              |
| `F12`     | Copy full file path to clipboard            |
| `1` – `9` | Jump to tab 1–9 (Normal mode)               |
| `0`       | Jump to tab 10 (Normal mode)                |

#### 🧭 Navigation

| Key          | Action                                       |
|--------------|----------------------------------------------|
| `Ctrl+Up`    | Go to previous tab                           |
| `Ctrl+Down`  | Go to next tab                               |
| `Alt+Left`   | Navigate to left split (wraps around)        |
| `Alt+Right`  | Navigate to right split (wraps around)       |
| `Ctrl+Right` | Move forward one word                        |
| `Ctrl+Left`  | Move backward one word                       |
| `Home`       | Jump to first non-blank character on line    |
| `n` / `N`    | Next / Prev search result (auto-centered)    |
| `Shift+L`    | Clear search highlight                       |

#### 🖱️ Selection

| Key                  | Mode          | Action                              |
|----------------------|---------------|-------------------------------------|
| `Ctrl+A`             | Normal        | Select all (`ggVG`)                 |
| `Ctrl+L`             | Normal/Insert | Select current line (visual)        |
| `V`                  | Normal        | Enter block-visual mode (`Ctrl+V`)  |
| `Ctrl+D`             | Normal/Insert | Select current word (visual)        |
| `Shift+Arrow`        | All modes     | Extend selection in direction       |
| `Ctrl+Shift+Left/Right` | Normal/Insert | Select word by word              |

#### 📋 Copy / Paste / Cut

| Key      | Mode                  | Action                          |
|----------|-----------------------|---------------------------------|
| `Ctrl+C` | Normal                | Copy current line to clipboard  |
| `Ctrl+C` | Visual                | Copy selection to clipboard     |
| `Ctrl+V` | Normal/Insert/Command | Paste from clipboard            |
| `Ctrl+X` | Normal                | Cut current line to clipboard   |
| `Ctrl+X` | Visual                | Cut selection to clipboard      |

#### ✏️ Editing

| Key         | Mode          | Action                             |
|-------------|---------------|------------------------------------|
| `Ctrl+Z`    | All modes     | Undo                               |
| `Shift+Del` | Normal        | Delete current line (`dd`)         |
| `Ctrl+U`    | Normal/Visual | Toggle case of word / selection    |
| `Tab`       | Normal        | Smart indent forward at cursor     |
| `Shift+Tab` | Normal        | Smart indent backward at cursor    |
| `Tab`       | Visual        | Indent all selected lines forward  |
| `Shift+Tab` | Visual        | Indent all selected lines backward |
| `Alt+Z`     | Normal        | Toggle line wrapping on/off        |

#### 🔍 Search

| Key      | Mode   | Action                                          |
|----------|--------|-------------------------------------------------|
| `Ctrl+F` | Normal | Highlight all occurrences of word under cursor  |
| `Ctrl+F` | Visual | Highlight all occurrences of selected text      |

#### 🚫 Disabled Keys

| Key    | Reason                                               |
|--------|------------------------------------------------------|
| `x`    | Disabled to prevent accidental single-char deletion  |
| `Del`  | Disabled in Normal mode                              |

---

### 📂 Folding

- **Default fold level:** `99` — all folds are open when a file loads.
- **Verilog / SystemVerilog** files (`.v`, `.sv`, `.svh`):
  Automatically uses **indent-based folding**.
- `matchit.vim` macro is loaded for enhanced `%` matching
  (matches `begin/end`, `if/endif`, HTML tags, etc.).

---

### 🌲 NERDTree Integration

#### Configuration

| Setting             | Value  | Description                          |
|---------------------|--------|--------------------------------------|
| Show hidden files   | Yes    | Dotfiles are visible in the tree     |
| Panel position      | Left   | NERDTree opens on the left side      |
| Panel width         | 75     | Default width in columns             |

#### Toggle Keybinding

| Key      | Action                               |
|----------|--------------------------------------|
| `Ctrl+B` | Toggle NERDTree (smart behavior)     |

#### Smart Toggle Logic

| Condition                  | Behavior                                      |
|----------------------------|-----------------------------------------------|
| Buffer has no file name    | Opens NERDTree at current working directory   |
| File exists on disk        | Opens NERDTree and **reveals** the file       |
| Other cases                | Opens NERDTree at the file's parent directory |

#### Smart File Open (`OpenSmart`)

When you open a file from NERDTree via `Enter` or **double-click**:

1. The file opens in a **vertical split** to the right of the last normal window.
2. **NERDTree automatically closes** after ~50ms.
3. The WinList panel **refreshes** after ~300ms.

#### Auto-close

If only the NERDTree window remains in a tab (all real files are closed),
it **auto-closes** to prevent an orphaned tree window.

---

### 🔷 IndentLine Plugin

Displays **vertical indent guide lines** at each indentation level.

| Setting           | Value     |
|-------------------|-----------|
| Color (`gui`)     | `#0055aa` |
| Guide character   | `┆`       |

---

### 🔖 Vim Bookmark Plugin

| Setting             | Value       |
|---------------------|-------------|
| Highlight lines     | Yes         |
| Bookmark sign       | `==`        |
| Auto-center on jump | Yes         |
| Line highlight bg   | `#001933`   |
| Sign foreground     | `#00ffff`   |

---

### 🖼️ GUI Settings

- Menu bar (`m`) and toolbar (`T`) are **hidden by default** on startup for a clean UI.
- Toggle them with:

| Key   | Action                            |
|-------|-----------------------------------|
| `F10` | Toggle menu bar + toolbar on/off  |

---

### 🔍 Diff Mode

Custom diff highlight colors for both dark and light backgrounds.

#### Dark Background Colors

| Group         | Background  | Meaning                    |
|---------------|-------------|----------------------------|
| `DiffAdd`     | `#29762e`   | Added lines (green)        |
| `DiffDelete`  | `#772e2e`   | Deleted lines (red)        |
| `DiffChange`  | `#304e75`   | Changed lines (blue)       |
| `DiffText`    | `#aa3a3a`   | Changed text within line   |
| `DiffRemoved` | `#772e2e`   | Removed content (red)      |
| `DiffNewFile` | `#29762e`   | New file indicator (green) |
| `DiffFile`    | `#304e75`   | File header (blue)         |

#### Light Background Colors

| Group         | Background  |
|---------------|-------------|
| `DiffAdd`     | `#cce8cc`   |
| `DiffDelete`  | `#facccc`   |
| `DiffChange`  | `#cce0fa`   |
| `DiffText`    | `#ffbaba`   |
| `DiffRemoved` | `#facccc`   |
| `DiffNewFile` | `#cce8cc`   |
| `DiffFile`    | `#cce0fa`   |

#### Diff Keybindings (active only when in diff mode)

| Key  | Action                         |
|------|--------------------------------|
| `dn` | Jump to **next** diff hunk     |
| `db` | Jump to **previous** diff hunk |
| `df` | Apply diff hunk (`:diffput`)   |

> ✅ All folds are **automatically disabled** in diff-mode windows,
> ensuring clean line-by-line comparison without collapsed regions.

---

### 📋 WinList Panel

A fully custom **side panel** that displays all open windows across all
tabs in a structured, navigable list — similar to an IDE's open-files panel.
No external plugin required; entirely implemented in Vimscript.

#### Panel Layout Example

```
=== Tab 1 ===
> 1: main.c
     …/project/src/core
  2: utils.h
     …/project/src/include
=== Tab 2 ===
  1: config.v [+]
     …/rtl/design/top
  2: testbench.sv
     …/rtl/sim
```

| Symbol  | Meaning                              |
|---------|--------------------------------------|
| `>`     | Currently active / focused window    |
| `[+]`   | Buffer has unsaved changes           |
| `…/`    | Path truncated (last 5 components)   |

#### Features

| Feature                   | Description                                                  |
|---------------------------|--------------------------------------------------------------|
| Multi-tab display         | Shows **all tabs** and all their windows in one panel        |
| Active window marker      | `>` highlights the currently focused window                  |
| Modified indicator        | `[+]` marks buffers with unsaved changes                     |
| Short path display        | Shows last 5 path components, prefixed with `…/`            |
| Auto-width                | Panel width adjusts dynamically to fit content               |
| Per-tab state             | Each tab independently remembers whether the panel was open  |
| Auto-close tab            | Tab closes automatically when no real windows remain         |
| Real-time refresh         | Updates on every buffer/window/text change event             |
| NERDTree/WinList skipped  | Special windows are excluded from the window list            |

#### Panel Keybindings (inside WinList buffer)

| Key / Action             | Behavior                                          |
|--------------------------|---------------------------------------------------|
| `Enter`                  | Jump to the window on the current line            |
| Double-click             | Jump to the window at the clicked line            |
| `q`                      | Close the WinList panel                           |
| `r`                      | Force-refresh all tab panels                      |

#### Global Keybindings

| Key           | Action                                      |
|---------------|---------------------------------------------|
| `<leader>w`   | Toggle WinList panel open / close           |
| `<leader>W`   | Fix / restore panel width                   |
| `<leader>wa`  | Open WinList panel in **all** tabs          |

#### Commands

| Command              | Description                                  |
|----------------------|----------------------------------------------|
| `:WinList`           | Open the WinList panel                       |
| `:WinListClose`      | Close the WinList panel                      |
| `:WinListFix`        | Fix/restore the panel width                  |
| `:WinListRefresh`    | Force-refresh all tab panels                 |
| `:WinListAllTabs`    | Open WinList panel in every tab              |

#### Width Behavior

| Setting       | Value             | Description                               |
|---------------|-------------------|-------------------------------------------|
| Min width     | 15 columns        | Never shrinks below this                  |
| Max width     | 75 columns        | Never grows beyond this                   |
| Default width | 36 columns        | Starting width                            |
| Auto-resize   | ±2 column hysteresis | Only resizes if content change > 2 cols |

#### Split Navigation with WinList Awareness

`Alt+Left` / `Alt+Right` navigate between **normal windows only**,
automatically **skipping** WinList and NERDTree panels.
Navigation **wraps around** when reaching the leftmost or rightmost window.

---

## ⌨️ Keybinding Quick Reference

```
┌─────────────────────────────────────────────────────────────┐
│                        NAVIGATION                           │
├────────────────────┬────────────────────────────────────────┤
│ Ctrl+Up / Down     │ Previous / Next tab                    │
│ Alt+← / →          │ Left / Right split window (smart)      │
│ Ctrl+← / →         │ Word-by-word navigation                │
│ 1 – 9, 0           │ Jump to tab N  (0 = tab 10)            │
│ Home               │ Jump to first non-blank char           │
│ n / N              │ Search next / prev  (centered)         │
│ Shift+L            │ Clear search highlight                 │
├────────────────────┼────────────────────────────────────────┤
│                        EDITING                              │
├────────────────────┬────────────────────────────────────────┤
│ cc                 │ Toggle comment  (line or selection)    │
│ hh                 │ Toggle // haoz at end of line          │
│ ch                 │ Toggle // haoz at start of line        │
│ Ctrl+Z             │ Undo                                   │
│ Ctrl+U             │ Toggle case  (word or selection)       │
│ Tab / Shift+Tab    │ Indent / De-indent                     │
│ Shift+Del          │ Delete current line                    │
│ Alt+Z              │ Toggle line wrap                       │
├────────────────────┼────────────────────────────────────────┤
│                    COPY / PASTE / CUT                       │
├────────────────────┬────────────────────────────────────────┤
│ Ctrl+C             │ Copy line or selection → clipboard     │
│ Ctrl+V             │ Paste from clipboard                   │
│ Ctrl+X             │ Cut line or selection → clipboard      │
├────────────────────┼────────────────────────────────────────┤
│                      FILE / TABS                            │
├────────────────────┬────────────────────────────────────────┤
│ Ctrl+N             │ New tab                                │
│ Ctrl+W             │ Close window                           │
│ Ctrl+\             │ Vertical split                         │
│ Ctrl+O             │ Open file explorer                     │
│ Ctrl+B             │ Toggle NERDTree                        │
│ F5                 │ Reload current file                    │
│ F10                │ Toggle menu bar + toolbar              │
│ F11                │ Toggle fullscreen                      │
│ F12                │ Copy full file path → clipboard        │
├────────────────────┼────────────────────────────────────────┤
│                     WINLIST PANEL                           │
├────────────────────┬────────────────────────────────────────┤
│ <leader>w          │ Toggle WinList panel                   │
│ <leader>W          │ Fix WinList panel width                │
│ <leader>wa         │ Open WinList in all tabs               │
└────────────────────┴────────────────────────────────────────┘
```

---

## 🔌 Plugin Dependencies

| Plugin                        | Purpose                   | Repository                                          |
|-------------------------------|---------------------------|-----------------------------------------------------|
| `preservim/nerdtree`          | File tree explorer        | https://github.com/preservim/nerdtree               |
| `Yggdroot/indentLine`         | Indent guide lines        | https://github.com/Yggdroot/indentLine              |
| `MattesGroeger/vim-bookmarks` | Line bookmarking          | https://github.com/MattesGroeger/vim-bookmarks      |

---

## 🎨 Customization Tips

### Change the Font

```vim
set guifont=JetBrains\ Mono\ 12
```

### Change Indent Size

```vim
set tabstop=2
set shiftwidth=2
```

### Change WinList Panel Width

```vim
let g:winlist_width     = 40   " default width
let g:winlist_min_width = 20   " minimum allowed width
let g:winlist_max_width = 80   " maximum allowed width
```

### Change NERDTree Panel Width

```vim
let g:NERDTreeWinSize = 50
```

### Disable Auto Save

Comment out or remove the `autosave` autogroup:

```vim
" augroup autosave
"     autocmd!
"     ...
" augroup END
```

### Add a New Comment Type

```vim
autocmd FileType rust let b:comment_leader = '\/\/'
autocmd FileType lua  let b:comment_leader = '--'
autocmd FileType sql  let b:comment_leader = '--'
```

### Disable the Status Line Timer (performance)

Comment out `StatuslineStartTimer()` in the `DynamicStatusLine` autogroup:

```vim
" autocmd VimEnter,FocusGained * silent! call StatuslineStartTimer()
```

---

## 📝 Notes

- The **`haoz` colorscheme** must be installed separately as it is not
  a standard built-in Vim colorscheme. Place it at `~/.vim/colors/haoz.vim`.

- The **WinList panel** is entirely custom-built in Vimscript —
  no external plugin is required.

- **Auto-save** triggers on both `TextChanged` and `InsertLeave`.
  If you prefer saving only when leaving Insert mode, remove `TextChanged`
  from the autogroup.

- The **status line color monitor** uses a polling timer at 500ms intervals.
  This has negligible performance impact but can be disabled by commenting
  out `StatuslineStartTimer()`.

- On **non-Linux systems**, the `wmctrl` fullscreen calls will silently
  fail and can be safely ignored — all other features remain fully functional.

- The **`1`–`9`, `0` number keys** are remapped in Normal mode to jump
  directly to tabs. This means they no longer function as count prefixes
  for motion commands. If you rely on count motions (e.g., `5j`, `3w`),
  consider remapping these to `<leader>1` – `<leader>9` instead.

- **NERDTree smart-open** uses a 50ms timer to close the tree after
  opening a file. On very slow systems, you may need to increase this value.

---

*Last updated: 2026-05-30 · haoz.ng*
