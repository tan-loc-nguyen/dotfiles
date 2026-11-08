#!/usr/bin/env bash
# Interactive zsh must keep the editing behaviour oh-my-zsh used to provide: emacs keys
# (EDITOR=nvim would otherwise switch zsh to vi-mode), `# comments` in typed commands,
# and working Delete / Home / End keys. Runs a login + interactive shell with the repo files.
set -uo pipefail

repo="$(cd "$(dirname "$0")/../.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
cp "$repo/dot_zshrc" "$tmp/.zshrc"
chezmoi execute-template <"$repo/dot_zprofile.tmpl" >"$tmp/.zprofile"

out="$(ZDOTDIR="$tmp" zsh -l -i -c '
	bindkey -lL main
	[[ -o interactivecomments ]] && echo "comments:on"
	echo "del:$(bindkey "^[[3~")"
	echo "home:$(bindkey "^[[H")"
	echo "end:$(bindkey "^[[F")"
	echo "stab:$(bindkey "^[[Z")"
	echo "tab:$(bindkey "^I")"
' 2>/dev/null)"

fail=0
check() {
	if grep -q -- "$1" <<<"$out"; then echo "ok   $2"; else echo "FAIL $2"; fail=1; fi
}
check "emacs main" "emacs keymap (not vi-mode)"
check "comments:on" "interactive comments"
check "delete-char" "Delete key"
check "beginning-of-line" "Home key"
check "end-of-line" "End key"
check "stab:.*autosuggest-accept" "Shift+Tab accepts the suggestion"
check "tab:.*fzf-completion" "Tab still completes (fzf-completion)"
exit $fail
