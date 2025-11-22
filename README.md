# Volt

> **Experimental**: This text editor is in early development, and features may change frequently. While all pushed commits are intended to be complete and runnable, use at your own risk. :)

Volt is a buffer-centric TUI written entirely in VLang. It is the **first known fully featured text editor to be implemented entirely in a single language**, developed as a playground project that introduces its own unique features, while incorporating ideas from the greats — Neovim, Helix, and Emacs — all within a standalone binary smaller than any of them!

The philosophy of Volt is simple: treat everything as a buffer to provide a predictable, consistent, and natural editor experience.

## Build Instructions

```
v -prod .
```
**or run no binary build with**

```
v run .
```

## Features

### Fuzzy Explorer (Upgraded Fuzzy Finder)

A fast and smart file search tool that uses **Levenshtein Distance** and **Jaro-Winkler Similarity** to find files even when your query is slightly off.

**Capabilities:**
- Navigate your project with fuzzy search by filename OR directory.
- Swap between fuzzy finder on directories or files with ``` ` ```.
- Select multiple files at once, with `,` for quick opening.
- Explore your working directory using `TAB` and `SHIFT + TAB`.
- Handles partial matches, typos, and reordering of letters.

### Multiple Buffers

Easily manage multiple files at once.

**Capabilities:**
- Switch between buffers using `b` and `n`

### Text Storage

Volt currently supports UTF-8 and UTF-16LE encoded text.

- By default, text is stored in a gap buffer for fast edits.
- Files larger than 2 MB are automatically handled with a list buffer for better performance.
- Rope buffer support is in development.

### CLI Integration

Volt is being integrated with the command line for seamless usage.

**Capabilities:**
- View available commands and options via:
```
v run . help
# or
<executable> help
```

### Directory Buffer [IN DEVELOPMENT]

Browse and edit your filesystem directly, inspired by Neovim’s oil.nvim. This feature will enable making key systems level changes directly from the editor:
- change working directory
- rename files
- create files
- delete files

## Size

Volt is REALLY small! Binary sizes may differ between platforms due to OS-specific linking and runtime requirements. This is normal and does not affect functionality.

| Platform | Binary Size  |
|----------|--------------|
| Windows  | ~615 KB      |
| macOS    | ~506 KB      |

## Planned / Experimental Features
- Rope buffer for large file editing
- More CLI commands and integrations
