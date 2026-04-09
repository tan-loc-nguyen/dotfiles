# Neovim Setup Roadmap

## Phase 1 — Core daily loop

### LSP
- [ ] Prisma (prismals)
- [ ] Go (gopls)
- [ ] Python (pyright or basedpyright)
- [ ] SQL
- [ ] Bash (bash-language-server)
- [ ] Diagnostics navigation keymaps ([d / ]d)

### Completion
- [ ] Completion engine with LSP source
- [ ] Snippet engine

### Formatter
- [ ] Formatter integration (format on save)
- [ ] TS/JS: prettier
- [ ] Go: goimports
- [ ] Python: ruff or black

### Terminal
- [ ] Terminal toggle (split)

### Navigation
- [ ] Buffer navigation keymaps
- [ ] Window/split navigation keymaps
- [ ] Keymap discovery helper (which-key or similar)

### Telescope
- [ ] Bounded search (include/exclude file patterns) for find files and live grep

## Phase 2 — Language-specific polish
- [ ] Go: testing workflow
- [ ] Go: debugger (low priority)
- [ ] Markdown preview

## Phase 3 — Git visibility
- [ ] Git gutter signs
- [ ] Hunk preview / stage / reset
- [ ] Blame
- [ ] Diff view

## Phase 4 — Visual layer
- [ ] Statusline
- [ ] Bufferline / tab bar
- [ ] Better diagnostics display

## Phase 5 — Vim skill training
- [ ] Practice motions and text objects
- [ ] Learn registers
- [ ] Learn marks
- [ ] Learn macros

## Done
- [x] Add tree-sitter support for prisma, bash
- [x] Set up nvim-lspconfig
- [x] Set up mason.nvim + mason-lspconfig.nvim
- [x] TypeScript/JavaScript (ts_ls)
- [x] LSP keymaps: go-to-definition, references, rename, hover, code actions
