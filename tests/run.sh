#!/usr/bin/env bash
# Run every check in this repo. Exits non-zero if any fails.
#   tests/run.sh          Neovim (warm) + shell checks
#   tests/run.sh --cold   Neovim on fresh data dirs (slow: simulates a new machine) + shell checks
set -uo pipefail

dir="$(cd "$(dirname "$0")" && pwd)"
status=0
run() {
	echo "== ${1#"$dir"/}"
	"$@" || status=1
}

run "$dir/nvim/run.sh" "$@"
for check in "$dir"/shell/check_*.sh; do
	run "$check"
done

if [ $status -eq 0 ]; then echo "== all checks passed"; else echo "== SOME CHECKS FAILED"; fi
exit $status
