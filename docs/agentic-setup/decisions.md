# Agentic Setup — Decision Log

Running record of decisions made while migrating to a new Neovim + terminal setup,
loosely based on `docs/agentic-setup/guidelines.md` (craftzdog's setup). We do
**not** copy the guide wholesale — each item is chosen deliberately.

- Branch: `feat/agentic-coding-setup`
- Started: 2026-11-07
- Status: **implemented** on `feat/agentic-coding-setup` (2026-11-08). Design:
  `docs/superpowers/specs/2026-11-08-agentic-setup-design.md`; plan:
  `docs/superpowers/plans/2026-11-08-agentic-setup.md`. Implementation-time choices
  (builder rulings) are listed in the PR description.

Legend: **(you)** = your decision · **(rec)** = Claude's recommendation you accepted ·
**(Claude's call)** = decided by Claude, open to override.

---

## 0. Context & goals

### Current workflow (as of 2026-11-07)
- Main agent: **Claude Code**. Want to add **OpenCode + local models** (reasons:
  learning/tinkering, offline, privacy for work code, cost).
- Machine: MacBook Pro M5 Pro, **48 GB RAM** → ~30B-class quantized local models are realistic.
- Sessions: usually one at a time, sometimes several. Same repo → git worktrees;
  different repos → separate sessions.
- Terminal today: Ghostty panes in one window (`Cmd+D`).
- Reviewing agent changes today: lazygit, opening files in nvim, Claude's own diffs,
  running it. Liked Cursor's review style.
- Giving context today: typing `@path` by hand, describing in words.
- Editor time: **~80% reading/reviewing, ~20% writing**.
- Languages: TS/JS, Go, Python, SQL/Bash.

### Pain points to solve
1. Closing the window loses every session/layout → must reopen everything.
2. Agents finish/block without me noticing → I keep checking panes.
3. Typing `@path` references by hand.

### Hard constraint: works across machines (you, 2026-11-08)
This repo is used on several machines. Every change must also update what a fresh machine
needs: **`Brewfile`** (brew bundle), **`.zshrc`**, **`.zprofile`** — and the symlinks.
Nothing machine-specific may be assumed silently.

### Project split (Claude's call)
1. **Neovim migration + terminal layer** — one project (coupled via split navigation
   and Claude Code terminal settings).
2. **Local models (Ollama + OpenCode)** — separate project, after #1 is stable.

---

## 1. Terminal layer

| Decision | Choice | Why |
|---|---|---|
| Multiplexer | **herdr** (you) | Solves pain #1 (detach + layout/session restore) and #2 (per-pane agent state: working/blocked/idle, notifications) built-in, for Claude Code *and* OpenCode. |
| Alternatives considered | tmux, Zellij, tmux + Claude Squad, cmux, desktop apps (Conductor/Pane/Orca), Claude Agent Teams | tmux/Zellij need DIY agent alerts; cmux replaces Ghostty; desktop apps leave the terminal; Agent Teams is Claude-only. Zellij = strongest fallback (mature, smart-splits support). |
| Prefix key | **`ctrl+space`** (you) | `ctrl+b` felt awkward. |
| Ghostty Cmd-key → herdr mappings (e.g. `Cmd+D` split) | **Deferred** (you) | Revisit later. |
| herdr Claude integration (`herdr integration install claude`) | Install; it writes hooks (SessionStart, PreToolUse, Stop) into `~/.claude/settings.json` → track that change in this repo | (Claude's call) |
| Config location | `.config/herdr/config.toml` in this repo, symlinked like nvim/ghostty | (Claude's call) |
| Final config (implemented 2026-11-08) | `prefix = "ctrl+space"`; pane focus = herdr defaults `prefix+h/j/k/l`; `[ui.toast] delivery = "system"` (macOS notification on done + needs-input, skipped for the active tab); `terminal-notifier` added to Brewfile so clicking a notification focuses the terminal; sidebar left at herdr default (expanded) since agent status is the main pain; `onboarding = false` | (Claude's calls within the decided scope) |

Facts gathered (from reading source, 2026-11-07):
- herdr v0.9.5, Apache-2.0, very active (62 releases). OpenCode is a first-class detected agent.
  Has worktree commands, `pane send-text`, `agent prompt`, `pane neighbor`, socket API.
- craftzdog: tmux user since 2020; added herdr on 2026-11-04 by porting his tmux keys
  (prefix `ctrl+t`), keeps sidebar collapsed by default, runs his own herdr fork. Keeps
  tmux config as fallback.
- Claude Code in tmux needs `allow-passthrough on`, `extended-keys on`,
  `terminal-features 'xterm*:extkeys'` (official terminal-config docs) — relevant only if
  we fall back to tmux.

**Action items for you**
- [ ] macOS: System Settings → Keyboard → Keyboard Shortcuts → Input Sources → untick
      "Select the previous input source" (⌃Space). Fn keeps switching input sources.
- herdr is currently installed via `brew install herdr` (trial). Undo:
  `brew uninstall herdr && rm -rf ~/.config/herdr`.

---

## 2. Neovim foundation

| Decision | Choice | Why |
|---|---|---|
| Migration depth | **Full**: drop lazy.nvim → built-in `vim.pack`; restructure to the guide's layout (`utils/`, plugin group files, plugin keymaps file loaded last) (you) | Fewer dependencies; built on Neovim 0.12 built-ins. Have nvim 0.12.6. |
| Keymaps | Decided **group by group** (you) — see §3 | |

### 2.1 Options & behaviour (guide 1.2–1.7)
- **Basics bundle accepted** (you): undofile (persistent undo in `~/.cache/nvim/undodir`),
  ignorecase + smartcase, scrolloff 10 / sidescrolloff 8, splitright + splitbelow,
  cursorline only in the active window, signcolumn always on, rounded float borders
  (winborder), yank highlight flash, updatetime 300 / timeoutlen 500 / ttimeoutlen 0,
  treesitter folds with foldlevel 99 (start unfolded), title on. Also from the guide:
  2-space indent + expandtab + smartindent, `path+=**`, wildmode `longest:full,full` +
  wildignore, pumheight 10 / pumblend 10, showmatch (matchtime 2), `╱` diff fill
  (Claude's call — non-controversial guide items).
- **Mouse: on** (you) — 80% of time is reading/reviewing.
- **Wrap: everywhere** (you), with `linebreak` + `breakindent` so wrapped code stays
  readable (Claude's call). **j/k move by real lines** (you); use `gj`/`gk` for screen lines.
- **Messages: full guide setup** (you): cmdheight 0, Neovim 0.12 **ui2** (corner popups for
  short messages, pager for long output), **tiny-cmdline.nvim** floating `:` box.
  Note: ui2 is experimental in 0.12.
- **Swapfile + writebackup: off** (you). Undo history + git cover recovery.
- **Statusline: global** (laststatus 3) (you).
- **Kept from current config** (you): `:W` save without formatting; auto-reload changed
  files (checktime on BufEnter/CursorHold/FocusGained — needed for live agent edits);
  system clipboard (`unnamedplus`).
- Diagnostics look → see §2.2.

### 2.2 Look & feel
- **Colorscheme: Catppuccin Mocha** (you) — matches Ghostty + Starship; keep transparent bg.
- **Diagnostics: full message as virtual lines under the cursor line only** (you, same as
  today: `virtual_lines = { current_line = true }`, `virtual_text = false`); other lines show
  sign + underline. Guide's inline `● message` rejected.
- **Statusline: guide's full lualine** (you), global bar: mode · git branch · project root +
  icon + path · macro recording + diagnostics + git diff · progress · line:col.
  Macro section is required because `cmdheight 0` hides the "recording @q" message.
- **Per-split file labels: incline.nvim** tag top-right (you). No winbar breadcrumbs
  (would need an extra plugin; `<leader>fs` covers "where am I") — add later if needed.
- **Tabline**: custom, shown only with 2+ tabs, `[+]` for unsaved; colors adapted to
  Catppuccin instead of the guide's solarized (Claude's call).
- **Icons: mini.icons**, mocking nvim-web-devicons (you).
- **todo-comments + nvim-highlight-colors** (you), using Catppuccin Mocha colors
  (catppuccin has a todo-comments integration).
- **snacks statuscolumn** (you): `[diagnostic/mark] [number] [git/fold]` — git signs always
  on the right next to the code, so they're never hidden by diagnostics.
- snacks extras already chosen in §3.1: notifier, indent guides, lazygit float, word highlight.

---

## 3. Keymaps

### 3.1 Pickers (snacks.nvim picker)
- Picker: **snacks.nvim picker** (you). Considered fzf-lua (leaner, picker-only).
- snacks extras enabled: **notifier, indent guides, lazygit float, word highlight** (you).
- Keys: keep **`<leader>f*`** (you):
  `<leader>ff` files, `<leader>fF` files incl. ignored, `<leader>fg` grep,
  `<leader>fG` grep incl. ignored, `<leader>fb` buffers, `<leader>fh` help,
  `<C-p>` / Ghostty `Cmd+P` files.
- Added via LSP group: `<leader>fd` diagnostics, `<leader>fs` document symbols,
  `<leader>fS` workspace symbols.

### 3.2 Buffers, windows, tabs
- Buffers: **`<Tab>` / `<S-Tab>`** cycle (you). Because `<Tab>` = `<C-i>` in terminals,
  remap jump-forward (guide uses `<C-m>`; exact key = Claude's call during design).
- Close buffers (you, convention over guide):
  - **`<leader>bd`** close current buffer, keep window layout (snacks bufdelete).
  - **`<leader>bh`** close all hidden buffers, skip unsaved ones (guide's helper).
  - No close-others.
- Splits: **guide's s-prefix** (you): `ss` horizontal, `sv` vertical, `sh/sj/sk/sl` move.
  Built-in `<C-w>` keys for close/resize/equalize.
- **Two-layer navigation** (rec): `s*` moves between nvim windows; `ctrl+space h/j/k/l`
  moves between herdr panes. **smart-splits.nvim dropped** (doesn't support herdr).
- Vim tabs: **review-only + `te`** (rec): diff/history views open in their own tab;
  `te` new tab; built-in `gt`/`gT` to cycle; custom tabline shown only with 2+ tabs.
  Rule of thumb: tabs for throwaway layouts (diffs, history), splits for working layout.

### 3.3 Git review
Review model: **git-based, after-write** (you). Agent writes freely; I review per hunk.
Staged = accepted, reset = rejected (Cursor-style keep/undo via git).

- **gitsigns only** for signs/inline (rec). No mini.diff, no craftzdog fork
  (fork = 1 commit on a personal branch, behind upstream).
  - Hunk nav **`]h` / `[h`**; actions under **`<leader>g*`** (you):
    `<leader>gs` stage hunk, `<leader>gr` reset hunk, `<leader>gp` preview inline;
    buffer-wide variants + `<leader>gb` blame popup (exact keys = Claude's call).
  - Keep current-line inline blame on.
- **codediff.nvim** (`esmuellert/codediff.nvim` — beware same-named repos) for side-by-side
  review (rec). Why: built for "review while the agent keeps running", live refresh via a
  watcher process, side-by-side + inline layouts, hunk stage/discard, history, conflicts.
  Cost: downloads prebuilt binaries (diff lib + watcher); very fast-moving (447 commits in
  6 months). diffview.nvim rejected: no commits since 2024-06.
  - **One key scheme everywhere** (you): remap codediff's `]c`/`[c` → `]h`/`[h`,
    `<leader>h*` → `<leader>g*`; move its in-view `<leader>b` explorer toggle off the
    `<leader>b` buffer group.
- **Lazygit**: snacks float, keep **`<leader>gg`** and **`<leader>gf`** (current file) (you).

### 3.4 Agent helpers
- **`<leader>yf`** copy relative reference, format **`@path#L12-20`** (you):
  normal → `@src/api.ts#L42`; visual → range; oil → file or dir (`@src/routes/`).
- **`<leader>yp`** same, absolute path (you).
- **`<leader>as`** send reference to an agent pane via herdr (you + rec on key):
  - Target: **always pick** from a picker of all herdr agents (you).
  - Types text **without Enter**; **refuses if the agent is blocked** on a prompt
    (herdr docs warn typed text can answer approval dialogs).
  - Focus **jumps to the agent pane** after sending (you).
  - Outside herdr → falls back to clipboard.
  - Group rule: `<leader>y*` = puts text in a register; `<leader>a*` = acts on an agent.
- No code-block copy for now (Claude's call — YAGNI; add a key later if needed).
- No claudecode.nvim (rec — Claude-only; ties workflow to one agent).
- To verify: whether OpenCode understands `#L` ranges.

### 3.5 Editing basics
- `x` deletes **without copying** (you). Cost: lose `xp` letter-swap idiom.
- `<leader>p` pastes **last yank** (`"0p`), normal **and visual** (you + rec).
- `<C-a>` = **select all** (you). No increment remap (you don't use increment);
  `<C-x>` stays built-in decrement.
- `-` = **oil in place**; `sf` = **oil float with preview**, `q` closes (you).
- `-` is **not** part of a word (no `iskeyword+=-`) (you).
- Skipped: `<leader>d`/`<leader>c` no-copy (prefix clashes), guide's backwards `dw`
  (fights Phase 5 motion training), `<leader>o`/`<leader>O`.

### 3.6 LSP
| Action | Key |
|---|---|
| Definition | `gd` (snacks picker if multiple) |
| Declaration | `gD` |
| Hover | `K` |
| References / implementation / type definition | `grr` / `gri` / `grt` → snacks picker |
| Rename / code action | `<leader>cr` / `<leader>ca` (built-in `grn`/`gra` still work) |
| Signature help | `<C-k>` normal, `<C-s>` insert (built-in) + blink.cmp auto signature |
| Diagnostics list | `<leader>fd` |
| Diagnostic nav (kept) | `]d [d`, `]e [e`, `]w [w`, `<leader>cd` line float |
| Symbols | `<leader>fs` file, `<leader>fS` workspace |
| Inlay hints | off by default, toggle `<leader>ci` |

Why: 80% reading + Go interfaces → `gri`/`grt` and symbol pickers earn their keys.
Avoid guide's bare `gr` (shadows built-in `gr*` keys).

---

### 3.7 Languages & tools
- **TypeScript: vtsls** (you). Uses each project's own TS version; update-imports on
  file move. tsgo (TS 7 native, GA 2026-07-08, config exists in nvim-lspconfig) = later experiment.
- **JS/TS lint: eslint + oxlint + biome, per project** (you) — each server only attaches
  when the repo has its config file.
- **Formatting, per project config** (you): oxfmt / biome / prettierd(→prettier) chosen by
  which config the repo declares. **No formatter config → no format on save**; format
  manually with **`<leader>cf`** (you). Avoids whole-file rewrites in repos that don't format.
- Format-on-save timeout **1000 ms** (you). `:W` still skips formatting.
- **Python: ty** (Astral) type checker + ruff (lint/format) (you). Fallback: basedpyright.
- **Go: gopls + goimports**, with extra gopls analyses + inlay hints enabled (you).
  No golangci-lint, no gofumpt.
- **AI inline completion: none for now** (you) — revisit in the local-models project.

### 3.8 Cross-machine setup
- Machines: **all macOS (Apple Silicon) for now**; Linux later (you) → keep Linux possible
  (chezmoi `.chezmoi.os` checks) but don't build it yet.
- **Dotfiles manager: chezmoi** (you), like craftzdog.
  - **Source dir stays `~/Workspace/dotfiles`** (you) → set `sourceDir` in chezmoi config.
  - **Symlink mode** (you): normal files become symlinks into the repo (templates are
    still rendered copies). DX note: a *new* file created under `~/.config/...` is not
    in the repo until `chezmoi add` — create new config files in the repo instead.
  - Repo restructure to chezmoi naming: `.config/` → `dot_config/`, `.zshrc` → `dot_zshrc`,
    `.zprofile` → `dot_zprofile`, `.claude/` → `dot_claude/`, etc. Planning docs
    (`AGENTIC-*.md`, `TODO.md`) move out of the applied tree or go in `.chezmoiignore`
    (Claude's call). `.superpowers/` → `.gitignore` + `.chezmoiignore`.
  - **Per-machine values via chezmoi templates** (you): e.g. git email/name prompted once
    (`promptStringOnce`), Android SDK / CocoaPods PATHs only where present.
  - Brewfile applied by a `run_onchange_` script keyed on the Brewfile hash (craftzdog pattern).
- **Tool sources** (rec): **brew** = CLI tools (herdr, git-delta, jq, ripgrep, fd, …) ·
  **mise** = runtimes (node, go, python, …) · **Mason** = language servers + formatters,
  auto-installed by nvim on first start.
- **nvim-pack-lock.json: ignored** (you, like craftzdog) — machines may drift on plugin
  versions; accepted.
- **Claude Code config**: keep sharing `CLAUDE.md` + `statusline.sh`; **don't track
  `~/.claude/settings.json`** (Claude + herdr rewrite it); a chezmoi **run_once** script runs
  `herdr integration install claude` and `... opencode` on new machines (you + rec).
  (craftzdog tracks no Claude config at all.)

### 3.9 Machine setup specifics
- **Brewfile** (you): add `chezmoi`, `herdr`, `git-delta`, `jq`, `zsh-autosuggestions`,
  `zsh-syntax-highlighting`; **remove** `tmux`, `luarocks`, `vim`.
- **Shell** (you): **drop oh-my-zsh** (history shows 0 uses of its git aliases vs 437 plain
  `git` commands). Replace with plain zsh: compinit, history (large, shared, dedupe),
  ↑/↓ prefix history search, auto-cd. Add zsh-autosuggestions + zsh-syntax-highlighting.
  Keep starship, zoxide, fzf, mise, `ll` alias.
- **`EDITOR=nvim`** in `.zprofile` (you, fixes audit gap).
- **Git config as chezmoi template** (you): user name/email prompted once; `core.editor = nvim`;
  **delta** as pager; nvim as difftool/mergetool; global gitignore moved into the repo.
- **Lua: tabs, stylua defaults** (you); lua_ls with Neovim runtime awareness (guide).

### 3.10 Claude's calls (override any)
- Treesitter parsers: bash, c, css, diff, dockerfile, git_config, gitcommit, git_rebase,
  gitignore, go, gomod, gosum, html, javascript, jsdoc, json, lua, luadoc, markdown,
  markdown_inline, prisma, python, query, regex, sql, toml, tsx, typescript, vim, vimdoc, yaml.
  `:TSUpdate` on vim.pack's PackChanged event (guide).
- Keep LSPs: gopls, prismals, sqls, bashls (+shellcheck), ruff. Add lua_ls.
  **Add jsonls + yamlls with SchemaStore.nvim** (you, 2026-11-08 — you often read CI
  workflows, compose files, tsconfig/package.json).
- **Implementation process** (you): one go, new nvim config replaces the old in place (no
  side-by-side); one commit per step; push + open a PR at the end. Per-file chezmoi links
  accepted. All replacement files created complete in the repo before `chezmoi apply`.
- Keep formatters: goimports, ruff_format, shfmt (sh/bash); stylua for Lua.
- `TODO.md`: rewrite to reflect this plan (tmux/smart-splits → herdr/two-layer nav;
  markdown preview done; keep Go testing/debugger, Phase 5 training, local models).
- Keep markdown-preview.nvim, nvim-autopairs-equivalent (guide uses mini.pairs) → mini.pairs.

## 4. Still to decide
- [x] Options & behaviour → §2.1
- [x] Look & feel → §2.2
- [x] Languages & tools (main choices) → §3.7
- [ ] Lua tooling (lua_ls, stylua, tabs vs spaces), treesitter parser list, SQL/Bash/Markdown servers
- [x] Cross-machine setup (manager, mode, tool sources) → §3.8
- [ ] Concrete Brewfile / `.zshrc` / `.zprofile` / gitconfig changes
- [x] Agent notifications, per-language format policy, agent CLI install, statusline
      bootstrap, symlink shape, no auto-deletes → design doc §5.4
- Design doc: `docs/superpowers/specs/2026-11-08-agentic-setup-design.md` (awaiting approval)
- [ ] Ghostty Cmd-key mappings to herdr (deferred)
- [ ] Old `TODO.md` reconciliation (smart-splits → dropped; tmux → herdr; markdown preview done)
- [ ] Project 2: local models (Ollama + OpenCode)

## 5. Known gaps in the current config (from the 2026-11-07 audit)
Carry these into the migration rather than fixing on the old config:
- telescope-fzf-native built but never loaded (moot after snacks picker).
- Missing treesitter parsers: tsx, json, yaml, toml, sql, dockerfile.
- `EDITOR` not set in `.zshrc`/`.zprofile`.
- No undofile / ignorecase+smartcase / scrolloff / splitright+splitbelow / cursorline / updatetime.
- No bootstrap/README recording the symlinks; oh-my-zsh not installed by anything tracked.
- `~/.gitconfig`, `~/.config/git/ignore` untracked; stale Fig files in `~/.config/fish/conf.d`.

## 6. References
- Guide: `docs/agentic-setup/guidelines.md`; source: https://github.com/craftzdog/dotfiles
- herdr: https://github.com/herdrdev/herdr · https://herdr.dev/docs/
- codediff.nvim: https://github.com/esmuellert/codediff.nvim
- Claude Code terminal config (tmux notes): https://code.claude.com/docs/en/terminal-config
- Scratch clones (throwaway, safe to delete):
  `/private/tmp/claude-501/-Users-tan-nguyen-Workspace-dotfiles/bc58472c-f505-4aa9-a926-47bbbc4ca131/scratchpad/repos/`
