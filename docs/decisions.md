# Decision log

Why this setup looks the way it does. It started on 2026-11-07 as a migration from a
lazy.nvim config and plain Ghostty panes to Neovim 0.12 built-ins, herdr and chezmoi, using
[craftzdog's dotfiles](https://github.com/craftzdog/dotfiles) as a reference. Nothing was
copied wholesale: each item below was chosen deliberately, with the reason next to it.
Code comments point here by section number (e.g. "decision log §3.4").

---

## 0. Context & goals

### Workflow this is built for
- Coding agents do much of the writing (Claude Code today, OpenCode + local models next),
  usually one at a time, sometimes several: git worktrees for the same repo, separate
  sessions for different repos.
- Editor time is **~80% reading and reviewing, ~20% writing**, so review and navigation
  matter more than editing tricks.
- Languages: TypeScript/JavaScript, Go, Python, SQL, Bash.

### Pain points to solve
1. Closing the terminal window loses every session and layout.
2. Agents finish or block without me noticing, so I keep checking panes.
3. Typing `@path` references to code by hand.

### Hard constraint: works across machines
The repo is used on several Macs. Every change must also update what a fresh machine needs
(`Brewfile`, `.zshrc`, `.zprofile`, the chezmoi-managed links). Nothing machine-specific is
assumed silently.

### Project split
1. **Neovim migration + terminal layer**: one project (they're coupled through split
   navigation and Claude Code terminal settings). Done.
2. **Local models (Ollama + OpenCode)**: a separate project, after #1 is stable.

---

## 1. Terminal layer

| Decision | Choice | Why |
|---|---|---|
| Multiplexer | **herdr** | Solves pain #1 (detach, session and layout restore) and #2 (per-pane agent state: working / blocked / idle, with notifications) out of the box, for Claude Code *and* OpenCode. |
| Alternatives considered | tmux, Zellij, tmux + Claude Squad, cmux, desktop apps (Conductor, Pane, Orca), Claude Agent Teams | tmux and Zellij need home-made agent alerts; cmux replaces Ghostty; desktop apps leave the terminal; Agent Teams is Claude-only. Zellij is the strongest fallback. |
| Prefix key | **`ctrl+space`** | `ctrl+b` is awkward to reach. Needs macOS's ⌃Space input-source shortcut turned off. |
| Ghostty Cmd-key → herdr mappings | Deferred | Revisit after living with the prefix. |
| Agent integrations | `herdr integration install claude` (and `opencode` when present), run by the bootstrap script | The hooks report agent state to herdr. They live in `~/.claude/settings.json`, which isn't tracked (see §3.8). |
| Config | `prefix = "ctrl+space"`; pane focus = herdr's `prefix+h/j/k/l`; `[ui.toast] delivery = "system"` (macOS notification on done and needs-input, skipped for the active tab); `terminal-notifier` in the Brewfile so clicking a notification focuses the terminal; sidebar expanded, since agent status is the main pain; `onboarding = false` | |

Notes from reading the source (2026-11-07):
- herdr v0.9.5, Apache-2.0, very active. OpenCode is a first-class detected agent. It has
  worktree commands, `pane send-text`, `agent prompt` and a socket API.
- craftzdog moved from tmux to herdr on 2026-11-04 by porting his tmux keys (prefix
  `ctrl+t`), keeps the sidebar collapsed and keeps a tmux config as a fallback.
- If this ever falls back to tmux: Claude Code needs `allow-passthrough on`,
  `extended-keys on` and `terminal-features 'xterm*:extkeys'`.

---

## 2. Neovim foundation

| Decision | Choice | Why |
|---|---|---|
| Plugin manager | **Built-in `vim.pack`** (lazy.nvim dropped); layout: `config/`, `plugins/` grouped by area, `utils/`, plugin keymaps loaded last | Fewer dependencies, built on Neovim 0.12. |
| Keymaps | Decided group by group, see §3 | |

### 2.1 Options & behaviour
- **Basics**: persistent undo (`~/.cache/nvim/undodir`), ignorecase + smartcase,
  scrolloff 10 / sidescrolloff 8, splitright + splitbelow, cursorline only in the active
  window, signcolumn always on, rounded float borders, yank highlight, updatetime 300 /
  timeoutlen 500 / ttimeoutlen 0, treesitter folds starting unfolded, title on, 2-space
  indent + expandtab + smartindent, `path+=**`, wildmode `longest:full,full` + wildignore,
  pumheight 10 / pumblend 10, showmatch, `╱` diff fill.
- **Mouse on**: most of the time is reading and reviewing.
- **Wrap everywhere**, with `linebreak` + `breakindent` so wrapped code stays readable.
  `j`/`k` move by real lines; `gj`/`gk` for screen lines.
- **Messages**: `cmdheight 0`, Neovim 0.12's **ui2** (corner popups for short messages, a
  pager for long output) and **tiny-cmdline.nvim**, a floating `:` box centered in the
  window. ui2 is experimental in 0.12.
- **No swapfile or writebackup**: undo history and git cover recovery.
- **Global statusline** (laststatus 3).
- **`:W`** saves without formatting; **auto-reload** of files changed outside nvim
  (checktime on BufEnter / CursorHold / FocusGained), needed for live agent edits; system
  clipboard (`unnamedplus`).

### 2.2 Look & feel
- **Catppuccin Mocha**, transparent background, matching Ghostty and Starship.
- **Diagnostics**: the full message as virtual lines under the cursor's line only
  (`virtual_lines = { current_line = true }`, `virtual_text = false`); other lines show
  only a sign and an underline.
- **Statusline (lualine)**, global: mode · git branch · project root + icon + path ·
  macro recording + diagnostics + git diff · progress · line:col. The macro section is
  required because `cmdheight 0` hides the "recording @q" message.
- **Per-split file labels**: incline.nvim, top right. No winbar breadcrumbs:
  `<leader>fs` covers "where am I".
- **Tabline**: custom, shown only with 2+ tabs, `[+]` for unsaved, Catppuccin colours.
- **Icons**: mini.icons, standing in for nvim-web-devicons.
- **todo-comments + nvim-highlight-colors**, with Catppuccin colours.
- **Statuscolumn (snacks)**: `[diagnostic/mark] [number] [git/fold]`, so git signs sit
  next to the code and are never hidden by diagnostics.

---

## 3. Keymaps

### 3.1 Pickers (snacks.nvim)
- **snacks.nvim picker** (fzf-lua considered: leaner, picker-only). Other snacks modules
  in use: notifier, indent guides, lazygit float, word highlight.
- `<leader>ff` files, `fF` files incl. ignored, `fg` grep, `fG` grep incl. ignored, `fb`
  buffers, `fh` help, `<C-p>` (Ghostty `Cmd+P`) files.
- From the LSP group: `<leader>fd` diagnostics, `fs` document symbols, `fS` workspace
  symbols.

### 3.2 Buffers, windows, tabs
- Buffers: **`<Tab>` / `<S-Tab>`** cycle. `<Tab>` is `<C-i>` in most terminals, so
  jump-forward moves to `<C-n>` (its built-in meaning is just `j`; `<C-m>` would be Enter).
- Closing: **`<leader>bd`** closes the current buffer and keeps the window layout;
  **`<leader>bh`** closes every hidden buffer, skipping unsaved ones. No close-others.
- Splits: **`s` prefix**: `ss` below, `sv` right, `sh/sj/sk/sl` move. Built-in `<C-w>`
  keys for close / resize / equalize.
- **Two-layer navigation**: `s*` moves between nvim windows, `ctrl+space h/j/k/l` between
  herdr panes. smart-splits.nvim dropped (it doesn't support herdr).
- Tabs are for **throwaway layouts** (diff and history views); `te` new tab, `gt`/`gT`
  cycle. Splits are for the working layout.

### 3.3 Git review
Review model: **git-based, after the agent writes**. The agent writes freely; I review
per hunk. **Staged = accepted, reset = rejected**, like Cursor's keep/undo but with git.

- **gitsigns** for signs, inline preview and blame (no mini.diff).
  - Hunks: **`]h` / `[h`**; actions under **`<leader>g*`**: `gs` stage, `gr` reset, `gp`
    preview inline, `gS`/`gR` whole buffer, `gb` blame popup. Current-line blame on.
- **codediff.nvim** (`esmuellert/codediff.nvim`; beware same-named repos) for the
  side-by-side review tab. Built for "review while the agent keeps running": live refresh
  through a watcher process, side-by-side and inline layouts, hunk stage/discard, history,
  conflicts. Cost: downloads prebuilt binaries and moves fast. diffview.nvim rejected: no
  commits since 2024-06.
  - **One key scheme everywhere**: codediff's `]c`/`[c` → `]h`/`[h`, `<leader>h*` →
    `<leader>g*`, and its explorer toggle moves off the `<leader>b` buffer group.
- **Lazygit** in a snacks float: `<leader>gg`, and `<leader>gf` for the current file.

### 3.4 Agent helpers
- **`<leader>yf`** copies a reference as **`@path#L12-20`**: normal mode → current line,
  visual → the range, oil → the file or folder (`@src/routes/`). Relative to nvim's
  working directory. **`<leader>yp`**: same, absolute.
- **`<leader>as`** sends the reference to an agent pane through herdr:
  - **always asks** which agent, from all herdr agents;
  - the path is relative to **that agent's** working directory (absolute when the file is
    outside it), since the agent may be in another worktree or repo;
  - types the text **without pressing Enter**, and **refuses an agent that's blocked** on a
    prompt (typed text could answer an approval dialog);
  - **focus jumps** to the agent pane afterwards;
  - outside herdr, or with no agent running, it copies to the clipboard instead.
- Key groups: `<leader>y*` puts text in a register; `<leader>a*` acts on an agent.
- Not added: a code-block copy key (not needed yet), claudecode.nvim (Claude-only; would
  tie the workflow to one agent).
- To verify: whether OpenCode understands `#L` ranges.

### 3.5 Editing basics
- `x` deletes **without copying** (loses the `xp` letter-swap idiom).
- `<leader>p` pastes the **last yank** (`"0p`), in normal and visual mode.
- `<C-a>` selects all (increment isn't used); `<C-x>` stays built-in decrement.
- `-` opens **oil in place**; `sf` opens **oil in a float** with preview, `q` closes.
- `-` is not part of a word (no `iskeyword+=-`).
- Skipped: `<leader>d`/`<leader>c` no-copy variants (prefix clashes), remapping `dw`
  (fights learning the real motions), `<leader>o`/`<leader>O`.

### 3.6 LSP
| Action | Key |
|---|---|
| Definition | `gd` (snacks picker if several) |
| Declaration | `gD` |
| Hover | `K` |
| References / implementations / type definition | `grr` / `gri` / `grt` → snacks picker |
| Rename / code action | `<leader>cr` / `<leader>ca` (built-in `grn`/`gra` still work) |
| Signature help | `<C-k>` normal, `<C-s>` insert (built-in), plus blink.cmp's automatic signature |
| Diagnostics list | `<leader>fd` |
| Diagnostic navigation | `]d [d`, `]e [e` errors, `]w [w` warnings, `<leader>cd` line float |
| Symbols | `<leader>fs` file, `<leader>fS` workspace |
| Inlay hints | off by default, toggle with `<leader>ci` |

Why: mostly reading code, and Go interfaces, so `gri`/`grt` and the symbol pickers earn
their keys. No bare `gr` (it would shadow the built-in `gr*` keys).

### 3.7 Languages & tools
- **TypeScript: vtsls**: uses each project's own TypeScript version, updates imports on
  file move. tsgo (TypeScript 7 native) is a later experiment.
- **JS/TS linting: eslint + oxlint + biome, per project**: each server only attaches when
  the repo has its config.
- **Formatting follows the project**: oxfmt, biome or prettierd (→ prettier), chosen by
  which config the repo declares, searched up to the git root. A `prettier` key in
  `package.json` counts only as a table or a shared-config name. oxfmt and biome are only
  trusted with JS/TS/JSON; CSS, HTML, Markdown, YAML and Vue go through prettier. **No
  formatter config → nothing runs on save**, so repos that don't format are never
  rewritten; **`<leader>cf`** formats on demand anyway. Save timeout 1000 ms; `:W` skips
  formatting.
- **Python: ty** (type checker) + **ruff** (lint and format, when the project configures
  it). Fallback: basedpyright.
- **Go: gopls + goimports** (always: gofmt style is universal), with extra gopls analyses
  and inlay hints. No golangci-lint, no gofumpt.
- **Shell: bashls + shellcheck**, shfmt when the project has an `.editorconfig`.
  **Lua: lua_ls** (Neovim-aware) + stylua when the project has a `stylua.toml`.
- **AI inline completion: none for now**; revisit with local models.

### 3.8 Cross-machine setup
- Machines: **macOS (Apple Silicon)** now; Linux later, kept possible through chezmoi's
  `.chezmoi.os` checks but not built yet.
- **chezmoi**, like craftzdog:
  - the source directory is the clone (`~/Workspace/dotfiles`);
  - **symlink mode**: plain files become symlinks into the repo, so editing
    `~/.config/...` edits the repo. Templates (`.gitconfig`, `.zprofile`) are rendered
    copies. A *new* file under `~/.config` isn't in the repo until `chezmoi add`;
  - **per-machine values through templates**: git name / email / GitHub user prompted once
    (`promptStringOnce`); Docker and Android SDK PATHs only where those folders exist;
  - **one bootstrap script** (`run_onchange_bootstrap.sh.tmpl`), re-run whenever it, the
    Brewfile or the installed agent CLIs change: Homebrew + Brewfile (`--no-upgrade`, so
    Neovim is never upgraded behind your back), Claude Code's native installer, herdr's
    agent integrations, then this repo's pre-commit hook. Every step skips work already done.
- **Tool sources**: **brew** = CLI tools · **mise** = runtimes (node, go, python, …) ·
  **Mason** = language servers and formatters, installed by nvim on first start.
- **`nvim-pack-lock.json` is not tracked** (like craftzdog): machines may drift on plugin
  versions; accepted.
- **Nothing in `~/.claude` is tracked**: `settings.json` is rewritten by Claude Code and
  herdr, and `CLAUDE.md` / `statusline.sh` are per machine.

### 3.9 Machine setup specifics
- **Brewfile** adds chezmoi, herdr, git-delta, gitleaks, jq, terminal-notifier,
  zsh-autosuggestions, zsh-syntax-highlighting; tmux, luarocks and vim were removed.
- **Shell: plain zsh, no oh-my-zsh** (shell history showed its git aliases unused):
  compinit with a menu, a large shared history without duplicates, ↑/↓ prefix search,
  auto-cd, emacs keys (`EDITOR=nvim` would otherwise switch zsh to vi mode),
  autosuggestions (`Shift+Tab` accepts) and syntax highlighting. Keeps starship, zoxide,
  fzf, mise and an `ll` alias.
- **`.zprofile`**: `EDITOR=nvim`; PATH entries added through zsh's `path` array with
  `typeset -U`, so nested shells don't duplicate them; Homebrew Ruby's newest gems folder
  found at shell start.
- **Git config as a template**: name / email prompted once, `core.editor = nvim`, **delta**
  as the pager, nvimdiff as diff and merge tool, `zdiff3` conflicts, global gitignore in
  the repo.
- **Lua**: tabs, stylua defaults.

### 3.10 Other choices
- **Treesitter parsers**: bash, c, css, diff, dockerfile, git_config, gitcommit,
  git_rebase, gitignore, go, gomod, gosum, html, javascript, jsdoc, json, lua, luadoc,
  markdown, markdown_inline, prisma, python, query, regex, sql, toml, tsx, typescript, vim,
  vimdoc, yaml. `:TSUpdate` runs on vim.pack's PackChanged event.
- **Language servers**: vtsls, eslint, oxlint, biome, ty, ruff, gopls, prismals, sqls,
  bashls, lua_ls, plus **jsonls and yamlls with SchemaStore** (CI workflows, compose files,
  `tsconfig` / `package.json` get completion and validation).
- **Formatters**: goimports, ruff_format, shfmt, stylua, prettierd / prettier, oxfmt, biome.
- **markdown-preview.nvim**; **mini.pairs** for auto-pairs.

### 3.11 Hardening after review (2026-11-10)
Four review rounds on the finished setup. What changed, and what was deliberately left:
- **Formatting**: `<leader>cf` stops after the first available formatter, like
  format-on-save; a `prettier` devDependency or `"prettier": null` no longer counts as a
  config.
- **Agent helpers** never throw: herdr missing from PATH or printing `null` falls back to
  the clipboard; oil views that aren't local folders (trash, ssh) warn instead.
- **UI**: `%` in file names is escaped in the tabline; oil tabs and incline tags show
  `folder/`; the active-window cursorline leaves floating windows alone.
- **Left as is, measured**: lualine's root lookup costs ~0.01 ms per redraw; `compinit -C`
  would save ~13 ms per shell but miss completions that new brew installs add.
- **Left as is, by design**: biome's "formatter disabled" check is a single pattern (a
  nested object before `enabled` can fool it; a full parse costs more than it saves).

### 3.12 Publishing (2026-11-10)
- **Secrets and personal data are blocked**: gitleaks' default rules plus two of our own
  (email addresses, `/Users/<name>` paths) run as a pre-commit hook (`.githooks/`, wired by
  the bootstrap) and in CI over the full history. Accepted findings go in
  `.gitleaksignore` with a reason.
- **Commits carry only the GitHub noreply address, and no AI co-author lines**; history
  was rewritten before publishing to make that true, and to drop personal agent notes
  (`CLAUDE.md`, `AGENTS.md`) and the migration's working documents.
- Migration working documents (design, plan, the reference guide) stay local and aren't
  published.
- **MIT license**, except third-party files that keep their own terms (see `LICENSE`).

## References
- craftzdog's dotfiles: https://github.com/craftzdog/dotfiles
- herdr: https://github.com/herdrdev/herdr · https://herdr.dev/docs/
- codediff.nvim: https://github.com/esmuellert/codediff.nvim
- Claude Code terminal config (tmux notes): https://code.claude.com/docs/en/terminal-config
