#!/usr/bin/env bash
# chezmoi bootstrap scripts: render every run_ template, shellcheck it, and make sure
# `chezmoi apply` never upgrades existing packages (a surprise Neovim upgrade can break the
# config, which uses Neovim 0.12's experimental ui2 module).
set -uo pipefail

repo="$(cd "$(dirname "$0")/../.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
fail=0

for tmpl in "$repo"/run_*.sh.tmpl; do
	out="$tmp/$(basename "$tmpl" .tmpl)"
	chezmoi execute-template <"$tmpl" >"$out"
	if shellcheck -s bash "$out"; then echo "ok   shellcheck $(basename "$tmpl")"; else echo "FAIL shellcheck $(basename "$tmpl")"; fail=1; fi
done

if grep -q 'brew bundle --no-upgrade' "$tmp/run_onchange_before_10-install-homebrew-packages.sh"; then
	echo "ok   brew bundle does not upgrade existing packages"
else
	echo "FAIL brew bundle would upgrade existing packages (add --no-upgrade)"
	fail=1
fi
exit $fail
