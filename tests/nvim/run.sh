#!/usr/bin/env bash
# Headless checks for the Neovim config in this repo (dot_config/nvim).
#   tests/nvim/run.sh          use the normal data dir (plugins already installed)
#   tests/nvim/run.sh --cold   fresh temporary data/state/cache: simulates a new machine
# Runs nvim against the repo files directly (XDG_CONFIG_HOME=<repo>/dot_config), so it
# doesn't depend on `chezmoi apply` having linked new files yet.
set -uo pipefail

repo="$(cd "$(dirname "$0")/../.." && pwd)"
export TESTS_DIR="$repo/tests/nvim"
export XDG_CONFIG_HOME="$repo/dot_config"

if [ "${1:-}" = "--cold" ]; then
	cold="$(mktemp -d)"
	export XDG_DATA_HOME="$cold/data" XDG_STATE_HOME="$cold/state" XDG_CACHE_HOME="$cold/cache"
	echo "cold run in $cold"
	# First start installs plugins; it must itself be error-free.
	nvim --headless +qa || {
		echo "FAIL first (installing) start exited non-zero"
		exit 1
	}
fi

status=0
for check in "$TESTS_DIR"/check_*.lua; do
	name="$(basename "$check" .lua)"
	# check_lsp needs Mason-installed servers; skip it on a cold run.
	if [ "${1:-}" = "--cold" ] && [ "$name" = "check_lsp" ]; then
		echo "skip $name (cold run)"
		continue
	fi
	if (cd "$TESTS_DIR/fixtures" 2>/dev/null || cd "$TESTS_DIR"; nvim --headless -c "luafile $check"); then
		:
	else
		status=1
	fi
done

if [ -n "${cold:-}" ]; then rm -rf "$cold"; fi
exit $status
