#!/usr/bin/env bash
# chezmoi bootstrap: one script, run_onchange_bootstrap.sh.tmpl. Render it, shellcheck it,
# and check it: never upgrades existing packages (a surprise Neovim upgrade can break the
# config, which uses Neovim 0.12's experimental ui2 module), runs its steps in dependency
# order (brew → claude → herdr), and re-runs when the Brewfile or the agent CLIs change.
set -uo pipefail

repo="$(cd "$(dirname "$0")/../.." && pwd)"
tmpl="$repo/run_onchange_bootstrap.sh.tmpl"
out="$(mktemp)"
trap 'rm -f "$out"' EXIT
fail=0
check() {
	if eval "$1"; then echo "ok   $2"; else echo "FAIL $2"; fail=1; fi
}

check '[ -f "$tmpl" ]' "single bootstrap script exists"
check '[ "$(ls "$repo" | grep -c "^run_")" -eq 1 ] && [ ! -d "$repo/.chezmoiscripts" ]' "no other chezmoi scripts"
chezmoi execute-template <"$tmpl" >"$out" 2>/dev/null
check 'shellcheck -s bash "$out"' "shellcheck"
check 'grep -q "brew bundle --no-upgrade" "$out"' "brew bundle does not upgrade existing packages"
check 'grep -q "Brewfile hash: [0-9a-f]\{64\}" "$out"' "re-runs when the Brewfile changes"
check 'grep -q "claude:" "$out" && grep -q "opencode:" "$out"' "re-runs when an agent CLI appears"
brew_line=$(grep -n "brew bundle" "$out" | head -1 | cut -d: -f1)
claude_line=$(grep -n "claude.ai/install.sh" "$out" | head -1 | cut -d: -f1)
herdr_line=$(grep -n "herdr integration install" "$out" | head -1 | cut -d: -f1)
check '[ -n "$brew_line" ] && [ -n "$claude_line" ] && [ -n "$herdr_line" ] && [ "$brew_line" -lt "$claude_line" ] && [ "$claude_line" -lt "$herdr_line" ]' "steps run brew → claude → herdr"
exit $fail
