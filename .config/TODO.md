# Neovim Setup Roadmap

## Phase 1 — Core daily loop

### Terminal
- [ ] tmux setup (Ghostty → tmux → Neovim stack)
- [ ] smart-splits.nvim (seamless Ctrl+hjkl navigation + resizing across nvim splits and tmux panes)

### Navigation
- [ ] Buffer navigation keymaps
- [ ] Window/split navigation keymaps

### Telescope
- [ ] Bounded search (include/exclude file patterns) for find files and live grep

## Phase 2 — Language-specific polish
- [ ] Go: testing workflow
- [ ] Go: debugger (low priority)
- [ ] Markdown preview

## Phase 3 — Git visibility
- [ ] Hunk preview / stage / reset
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

## Future optimisations
- [ ] Replace Telescope with fzf-lua (faster, toggle-ignore/toggle-hidden on the fly with ctrl-i/ctrl-h)

## Done
- [x] Add tree-sitter support for prisma, bash
- [x] Set up nvim-lspconfig
- [x] Set up mason.nvim + mason-lspconfig.nvim
- [x] TypeScript/JavaScript (ts_ls)
- [x] LSP keymaps: go-to-definition, references, rename, hover, code actions
- [x] Lazygit integration (lazygit.nvim)
- [x] Git gutter signs (gitsigns.nvim)
- [x] Inline current-line blame (gitsigns.nvim)
- [x] File explorer with git status (oil.nvim + oil-git-status.nvim)
- [x] Telescope find files including gitignored files (`<leader>fF`)
- [x] Go (gopls)
- [x] Inline diagnostics display (native `virtual_lines = { current_line = true }`)
- [x] Prisma (prismals)
- [x] Python (basedpyright)
- [x] SQL (sqls)
- [x] Bash (bash-language-server + shellcheck)
- [x] Diagnostics navigation keymaps (`]d`/`[d`, `]e`/`[e`, `]w`/`[w`, `<leader>cd`)
- [x] Completion engine — blink.cmp (with LSP source, super-tab preset)
- [x] Snippet engine (friendly-snippets via blink.cmp)
- [x] Formatter integration — conform.nvim (format on save, `:W` to skip)
- [x] TS/JS: prettier
- [x] Go: goimports
- [x] Python: ruff
- [x] Keymap discovery helper (which-key.nvim)
