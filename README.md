<img width="1080" height="814" alt="21aa18861a4d8eb121b3fd8be771292e39ad188bffcf3bc3dbf0baa51d039ec9" src="https://github.com/user-attachments/assets/5de8e43e-07ad-4046-8fd5-050551ee8279" />

# 🖥️ GVIM Personal Configuration — `haoz.ng`

> **Version:** 6.36 · **Last Modified:** 2026-05-30  
> **Author:** haoz.ng  
> A fully-featured personal GVIM configuration with custom themes, keymaps, WinList panel, NERDTree integration, diff support, folding, auto-save, and much more.

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Requirements](#-requirements)
- [Installation](#-installation)
- [Features](#-features)
  - [Auto Fullscreen](#-auto-fullscreen)
  - [Basic Settings](#-basic-settings)
  - [Theme & Colors](#-theme--colors)
  - [Cursor Shape](#-cursor-shape)
  - [Status Line](#-status-line)
  - [Comment System](#-comment-system)
  - [Auto Save](#-auto-save)
  - [WinList Panel](#-winlist-panel)
  - [NERDTree Integration](#-nerdtree-integration)
  - [Diff Mode](#-diff-mode)
  - [Folding](#-folding)
  - [Split Expand / Restore](#-split-expand--restore)
  - [IndentLine](#-indentline)
  - [Vim Bookmark](#-vim-bookmark)
- [Keybindings Reference](#-keybindings-reference)
  - [General](#general)
  - [Navigation](#navigation)
  - [Copy / Paste / Cut](#copy--paste--cut)
  - [Selection](#selection)
  - [Tab Management](#tab-management)
  - [Indentation](#indentation)
  - [Comment](#comment)
  - [Diff Mode](#diff-mode-keys)
  - [WinList Panel](#winlist-panel-keys)
  - [Miscellaneous](#miscellaneous)
- [Plugin Dependencies](#-plugin-dependencies)
- [Custom Commands](#-custom-commands)
- [File Structure](#-file-structure)

---

## 🔍 Overview

This is a **personal, hand-crafted GVIM configuration** designed for productivity in software/hardware development environments (C, C++, Python, Verilog, SystemVerilog, Shell scripts, and more).

It includes:
- 🎨 Custom dark colorscheme (`haoz`)
- 📂 A custom **WinList** side panel showing all open windows across all tabs
- 🌲 Smart **NERDTree** integration
- 💬 Smart **comment/uncomment** system for multiple file types
- 💾 **Auto-save** on text change or insert-leave
- 🔀 Full **diff mode** support with custom colors
- 📐 Smart **indentation** (Tab / Shift-Tab) in normal, insert, and visual modes
- 🪟 **Double-Enter** split expand / restore
- ⌨️ Familiar IDE-style keybindings (Ctrl+C, Ctrl+V, Ctrl+Z, etc.)

---

## ✅ Requirements

| Requirement | Details |
|---|---|
| **GVIM** | Version 8.0+ recommended (with GUI support) |
| **wmctrl** | For fullscreen toggle on Linux (`sudo apt install wmctrl`) |
| **NERDTree** | Vim plugin — [preservim/nerdtree](https://github.com/preservim/nerdtree) |
| **indentLine** | Vim plugin — [Yggdroot/indentLine](https://github.com/Yggdroot/indentLine) |
| **vim-bookmark** | Vim plugin — [MattesGroeger/vim-bookmarks](https://github.com/MattesGroeger/vim-bookmarks) |
| **haoz colorscheme** | Custom colorscheme file (`colors/haoz.vim`) must be present |
| **Font** | `Monospace Regular 11` (standard on most Linux systems) |

---

## ⚙️ Installation

### 1️⃣ Clone or copy the config

```bash
# Backup your existing config first
cp ~/.vimrc ~/.vimrc.backup

# Copy this config
cp vimrc ~/.vimrc
