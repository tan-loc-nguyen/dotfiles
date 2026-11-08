# dotfiles

macOS (Apple Silicon) dev setup, managed by [chezmoi](https://chezmoi.io): Ghostty → herdr →
Neovim + coding agents (Claude Code). Every decision and its reason is in
[`docs/agentic-setup/decisions.md`](docs/agentic-setup/decisions.md).

## New machine

```sh
# 1. Homebrew, then put it on PATH for this shell (Apple Silicon installs to /opt/homebrew)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
brew install chezmoi git

# 2. Clone to the expected place and apply (asks once for git name / email / GitHub user)
git clone https://github.com/tan-loc-nguyen/dotfiles ~/Workspace/dotfiles
chezmoi init --source ~/Workspace/dotfiles --apply

# 3. Runtimes, in a new login shell so the new ~/.zprofile and mise are active.
#    Mason needs node/npm and go to install most language servers.
exec zsh -l
mise install

# 4. Open nvim once: plugins, parsers and language servers install themselves
nvim
```

`chezmoi apply` runs these scripts (in order):

| Script | Runs when | Does |
|---|---|---|
| `10-install-homebrew-packages` | Brewfile changes | installs Homebrew if missing, `brew bundle --no-upgrade` (installs missing only; upgrade with `brew upgrade` yourself) |
| `20-install-claude-code` | once (if `claude` missing) | Claude Code native installer |
| `30-herdr-integrations` | an agent CLI appears | `herdr integration install claude/opencode` |

Then do by hand:
- System Settings → Keyboard → Keyboard Shortcuts → Input Sources → untick
  **"Select the previous input source" (⌃Space)** — herdr's prefix is `ctrl+space`.

## Daily rules
- **Edit config in place** (`~/.config/...`) — plain files are symlinks into this repo.
  Exceptions are copies rendered by chezmoi; edit them **in the repo**, then `chezmoi apply`:
  `~/.gitconfig` and `~/.zprofile` (templates).
- **New config files**: create them in the repo (then `chezmoi apply`), or `chezmoi add` them —
  a new file under `~/.config` isn't in the repo by itself.
- **Where tools come from**: brew = CLI tools (`Brewfile`) · mise = runtimes · Mason (inside
  nvim) = language servers + formatters.
- Not tracked on purpose: everything in `~/.claude` — `CLAUDE.md` and `statusline.sh` are
  per-machine and `settings.json` is rewritten by Claude Code and herdr; also
  `nvim-pack-lock.json` (plugins float per machine).

## Keys

**zsh**: `Shift+Tab` (or `→`) accepts the faded history suggestion · `Tab` completes (`**<Tab>` = fzf picker, e.g. `nvim **<Tab>`).

**herdr** (prefix `ctrl+space`): `prefix h/j/k/l` move between panes · `prefix v` / `prefix -`
split · `prefix b` sidebar · `prefix q` detach (`herdr` reattaches) · `prefix ?` help.

**Neovim** (leader = Space):

| Area | Keys |
|---|---|
| Find | `<leader>ff` files · `fg` grep (capital = incl. ignored) · `fb` buffers · `fh` help · `fd` diagnostics · `fs`/`fS` symbols · `<C-p>` / Cmd+P |
| Buffers | `<Tab>`/`<S-Tab>` cycle · `<leader>bd` close · `<leader>bh` close hidden · `<C-n>` jump forward |
| Windows | `ss`/`sv` split · `sh sj sk sl` move · `te` new tab (`gt`/`gT`) |
| Files | `-` oil here · `sf` oil float (`q` closes) |
| Git review | `]h`/`[h` hunks · `<leader>gs` stage (accept) · `gr` reset (reject) · `gp` preview · `gS`/`gR` buffer · `gb` blame · `gd` CodeDiff tab · `gh`/`gH` history · `gg` lazygit · `gf` file log |
| Code | `gd` `gD` `grr` `gri` `grt` · `K` · `<C-k>` signature · `<leader>cr` rename · `ca` action · `cf` format · `ci` inlay hints · `cd` line diagnostics · `]d` `]e` `]w` |
| Agents | `<leader>yf` copy `@path#L12-20` (normal/visual/oil) · `yp` absolute · `<leader>as` send to a herdr agent (no Enter; refuses a blocked agent) |
| Editing | `x` no-copy delete · `<leader>p` paste last yank · `<C-a>` select all · `:W` save without formatting |

Format on save only runs when the project declares a formatter (oxfmt / biome / prettier /
ruff / editorconfig for shfmt / stylua); Go always uses goimports.

## Tests

```sh
tests/nvim/run.sh          # headless checks: startup, keymaps, LSP, formatting, parsers, agent helpers
tests/nvim/run.sh --cold   # same on fresh data dirs (simulates a new machine; skips LSP)
tests/shell/check_zsh.sh   # interactive zsh keeps emacs keys, comments, Delete/Home/End
tests/shell/check_bootstrap.sh  # run_ scripts render + shellcheck; brew never upgrades
```

## Restore the pre-chezmoi setup
A snapshot taken before the migration is in `~/.dotfiles-backup/2026-11-08/` (on the original
machine) with `RESTORE.md`; repo files are in the `main` history.
