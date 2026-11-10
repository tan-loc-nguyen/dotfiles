#!/usr/bin/env bash
# The repo is public: secrets and personal data (emails, /Users/<name> paths) must not get
# in. Checks the pre-commit hook really blocks them, that bootstrap wires it up, that CI
# scans full history, and that history is clean today. Test values are built at runtime so
# this file never contains one.
set -uo pipefail

repo="$(cd "$(dirname "$0")/../.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
fail=0
check() {
	if eval "$1"; then echo "ok   $2"; else echo "FAIL $2"; fail=1; fi
}

check 'grep -q "^brew \"gitleaks\"" "$repo/Brewfile"' "gitleaks is in the Brewfile"
check 'chezmoi execute-template <"$repo/run_onchange_bootstrap.sh.tmpl" | grep -q "core.hooksPath .githooks"' "bootstrap points git at .githooks"
check '[ "$(git -C "$repo" config core.hooksPath)" = ".githooks" ]' "this clone uses .githooks"
check 'grep -q "fetch-depth: 0" "$repo/.github/workflows/gitleaks.yml" && grep -q "sha256sum -c" "$repo/.github/workflows/gitleaks.yml"' "CI scans full history with a checksum-pinned gitleaks"
check 'gitleaks git --no-banner --redact --config "$repo/.gitleaks.toml" "$repo" >/dev/null 2>&1' "full history has no findings"

# The hook, in a scratch repo
git -C "$tmp" init -q
cp -R "$repo/.githooks" "$repo/.gitleaks.toml" "$tmp/"
git -C "$tmp" config core.hooksPath .githooks
git -C "$tmp" config user.name test
git -C "$tmp" config user.email test@example.com
git -C "$tmp" add .githooks .gitleaks.toml && git -C "$tmp" commit -qm base >/dev/null 2>&1

commit_with() { # $1 = file content; succeeds if the commit went through
	printf '%s\n' "$1" >"$tmp/f.txt"
	git -C "$tmp" add f.txt
	if git -C "$tmp" commit -qm t >/dev/null 2>&1; then return 0; fi
	git -C "$tmp" reset -q f.txt
	return 1
}
aws="AKIA$(LC_ALL=C tr -dc 'A-Z2-7' </dev/urandom | head -c 16)"
email="someone.real@$(printf 'corp')mail.com"
home="/Us""ers/someone/.config/x"
check '! commit_with "key = \"$aws\""' "hook blocks an AWS access key"
check '! commit_with "author = $email"' "hook blocks an email address"
check '! commit_with "path = $home"' "hook blocks a /Users/<name> path"
check 'commit_with "path = ~/.config/x"' "hook lets a clean change through"
exit $fail
