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
	echo "dupes:$(print -l $path | sort | uniq -d | wc -l | tr -d " ")"
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
check "dupes:0" "PATH has no duplicate entries (even when the parent shell set them)"
# Ruby gems: the .zprofile line, run against a fake gems folder, adds only the NEWEST
# version (numeric order: 10.0.0 > 3.4.0), so an old version never shadows the new one.
gems_line="$(grep "/opt/homebrew/lib/ruby/gems/" "$tmp/.zprofile" | grep -v "^#")"
fake="$tmp/gems"
mkdir -p "$fake/3.4.0/bin" "$fake/10.0.0/bin"
got="$(zsh -f -c "path=(/usr/bin); ${gems_line//\/opt\/homebrew\/lib\/ruby\/gems/$fake}; print -l \$path")"
if [ "$(grep -c "$fake" <<<"$got")" -eq 1 ] && grep -q "$fake/10.0.0/bin" <<<"$got"; then
	echo "ok   ruby gems: only the newest version on PATH"
else
	echo "FAIL ruby gems: only the newest version on PATH (got: $(tr '\n' ' ' <<<"$got"))"; fail=1
fi
# ...and a clean login shell (nothing inherited) on a machine with Homebrew Ruby gets it.
newest="$(ls -d /opt/homebrew/lib/ruby/gems/*/bin 2>/dev/null | sort -V | tail -1)"
if [ -n "$newest" ]; then
	clean="$(env -i HOME="$HOME" ZDOTDIR="$tmp" TERM=dumb /bin/zsh -l -c 'print -l $path' 2>/dev/null)"
	if grep -qx "$newest" <<<"$clean"; then
		echo "ok   ruby gems: a clean login shell finds $newest"
	else
		echo "FAIL ruby gems: a clean login shell finds $newest"; fail=1
	fi
fi
exit $fail
