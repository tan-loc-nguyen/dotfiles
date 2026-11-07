# Dev Setup Roadmap

The 2026-11 agentic-setup migration (chezmoi + herdr + vim.pack Neovim) is done — see
`docs/agentic-setup/decisions.md` for every choice and `README.md` for the key reference.

## Next projects
- [ ] Local models: Ollama + OpenCode (48 GB M5 Pro → ~30B-class quantized models)
  - [ ] Check whether OpenCode understands `@path#L12-20` references (`<leader>yf` / `<leader>as`)
  - [ ] Decide on AI inline completion in the editor (local model vs none)
- [ ] Ghostty Cmd-key → herdr action mappings (e.g. `Cmd+D` split) — deferred
- [ ] Try tsgo (TypeScript 7 native server) once projects move to TS 7

## Language polish
- [ ] Go: testing workflow
- [ ] Go: debugger (low priority)

## Vim skill training
- [ ] Practice motions and text objects
- [ ] Learn registers
- [ ] Learn marks
- [ ] Learn macros

## Dropped (superseded by the migration)
- tmux + smart-splits.nvim → herdr, with two-layer navigation (`s h/j/k/l` in nvim,
  `ctrl+space h/j/k/l` between herdr panes)
- Telescope bounded search / fzf-lua → snacks picker (`<leader>f*`; capitals include ignored files)

## Done
- [x] chezmoi-managed dotfiles (symlink mode), fresh-machine bootstrap scripts
- [x] herdr: persistent sessions + agent blocked/done notifications
- [x] Plain zsh (no oh-my-zsh), autosuggestions, syntax highlighting, `EDITOR=nvim`
- [x] Git: templated identity, delta pager, nvimdiff diff/merge tool
- [x] Neovim on vim.pack + 0.12 built-ins (ui2, vim.lsp.enable, after/lsp)
- [x] Buffer / window / tab navigation keymaps
- [x] Markdown preview
- [x] Hunk preview / stage / reset (gitsigns) and side-by-side review (codediff)
- [x] Statusline (lualine), tabline, incline labels, snacks statuscolumn
- [x] Per-project format-on-save policy; JSON/YAML schema validation
- [x] Agent reference copy (`<leader>yf`) and send-to-agent (`<leader>as`)
- [x] Headless test suite for the Neovim config (`tests/nvim/run.sh`)
