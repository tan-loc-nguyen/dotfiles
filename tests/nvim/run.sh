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

# Headless nvim exits 0 even when init.lua throws; errors only show on stderr. Run nvim,
# echo its stderr, and fail if that stderr contains an error.
errlog="$(mktemp)"
run_nvim() {
	nvim --headless "$@" 2>"$errlog"
	local rc=$?
	cat "$errlog" >&2
	if grep -qE '(^|[^A-Za-z])Error|E[0-9]{2,4}:| error:' "$errlog"; then
		echo "FAIL nvim printed an error (see above)"
		return 1
	fi
	return $rc
}

if [ "${1:-}" = "--cold" ]; then
	cold="$(mktemp -d)"
	export XDG_DATA_HOME="$cold/data" XDG_STATE_HOME="$cold/state" XDG_CACHE_HOME="$cold/cache"
	# Private copy of the config too: vim.pack writes its lockfile next to init.lua, and a
	# cold install must not rewrite the lockfile the warm data dir matches.
	mkdir -p "$cold/config" && cp -R "$XDG_CONFIG_HOME/nvim" "$cold/config/nvim"
	rm -f "$cold/config/nvim/nvim-pack-lock.json"
	export XDG_CONFIG_HOME="$cold/config"
	echo "cold run in $cold"
	# First start installs plugins; it must itself be error-free. It also waits for parser
	# installs, otherwise their orphaned downloads race with the next nvim's downloads.
	run_nvim -c 'lua require("tan.plugins.treesitter").installing:wait(600000)' +qa || {
		echo "FAIL first (installing) start was not clean"
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
	if (cd "$TESTS_DIR/fixtures" 2>/dev/null || cd "$TESTS_DIR"; run_nvim -c "luafile $check"); then
		:
	else
		status=1
	fi
done

rm -f "$errlog"
if [ -n "${cold:-}" ]; then rm -rf "$cold"; fi
exit $status
