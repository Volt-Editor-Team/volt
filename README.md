# Volt

Volt is a buffer-centric TUI written in VLang. It is currently developing as a playground project, aiming to incorporate features from the greats — Neovim, Helix, and Emacs — into a standalone binary smaller than all of them!

The philosophy of Volt is simple: treat everything as a buffer to provide a predictable, consistent, and natural editor experience.

## Build Instructions

```
git clone https://github.com/yourusername/volt.git
cd volt
v run main.v
```

## Features

**Fuzzy Finder** — fast and smart file search using Levenshtein Distance and Jaro-Winkler Similarity.

**Multiple Buffers** — easily manage multiple files at once.

**CLI Integration** — work seamlessly from the command line.

**Directory Buffer** — browse and edit your filesystem directly, inspired by Neovim’s oil.nvim.

**Doctor Buffer** — view diagnostics directly from v doctor.

## Lightweight

Compiles to just 529 KB, making it fast, efficient, and portable.
