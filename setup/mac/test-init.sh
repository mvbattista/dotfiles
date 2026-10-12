#!/usr/bin/env bash
# Exercise setup/mac/init.sh without changing this machine.
# Usage: setup/mac/test-init.sh <personal|work> [computer-name]
#
# Safety layers (never run init.sh directly to test it; it installs real software):
#   1. $HOME is a scratch directory, and the environment is cleared (env -i).
#   2. PATH holds only stub commands plus system dirs, so real Homebrew is unreachable.
#      `brew shellenv` rewrites PATH, so init.sh also honours BREW_BIN, which points at the stub.
#   3. macOS sandbox-exec denies writes to Homebrew's prefix and /Applications.
#   4. git clone/submodule are stubbed, so the real work/ checkout is never moved.
# install.sh does run for real, but only into the scratch $HOME.
set -euo pipefail

PROFILE="${1:?usage: test-init.sh <personal|work> [computer-name]}"
NAME="${2:-}"
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
STUBS="$T/stubs"; LOG="$T/stub.log"; H="$T/home"
mkdir -p "$STUBS" "$H"; : > "$LOG"

for c in scutil ioreg defaults xcode-select open brew; do
  printf '#!/bin/sh\necho "%s $*" >> "%s"\n' "$c" "$LOG" > "$STUBS/$c"
done
# init.sh pipes curl output into a shell (Homebrew and Oh My Zsh installers): hand it a no-op script
printf '#!/bin/sh\necho "curl $*" >> "%s"\necho ": stub installer"\n' "$LOG" > "$STUBS/curl"
printf '#!/bin/sh\ncase "$*" in *clone*|*submodule*) echo "git $*" >> "%s"; exit 0 ;; esac\nexec "%s" "$@"\n' "$LOG" "$(command -v git)" > "$STUBS/git"
ln -s "$(command -v jq)" "$STUBS/jq"   # install.sh needs jq for merged JSON files
chmod +x "$STUBS"/*

TEST_PATH="$STUBS:/usr/bin:/bin:/usr/sbin:/sbin"
[ "$(PATH="$TEST_PATH" command -v brew)" = "$STUBS/brew" ] || { echo "ABORT: real brew is reachable on the test PATH" >&2; exit 1; }

guard=()
if command -v sandbox-exec >/dev/null 2>&1; then
  guard=(sandbox-exec -p '(version 1)(allow default)(deny file-write* (subpath "/opt/homebrew") (subpath "/usr/local/Homebrew") (subpath "/Applications"))')
  if "${guard[@]}" sh -c ': > /Applications/.dotfiles-test-probe' 2>/dev/null; then
    rm -f /Applications/.dotfiles-test-probe; echo "ABORT: sandbox is not enforcing" >&2; exit 1
  fi
else
  echo "note: sandbox-exec unavailable; relying on PATH isolation only" >&2
fi

echo "== init.sh $PROFILE ${NAME:-<no name>} (scratch HOME, stubbed system commands)"
set +e
env -i HOME="$H" PATH="$TEST_PATH" BREW_BIN="$STUBS/brew" TERM=dumb \
  GIT_SSH_COMMAND="ssh -o BatchMode=yes -o ConnectTimeout=10" \
  ${guard[@]+"${guard[@]}"} sh "$ROOT/setup/mac/init.sh" "$PROFILE" ${NAME:+"$NAME"} >"$T/out.txt" 2>&1
rc=$?
set -e

fail=0
check() { # description, condition result (0 = pass)
  if [ "$2" -eq 0 ]; then echo "PASS  $1"; else echo "FAIL  $1"; fail=1; fi
}
has() { grep -qE -- "$1" "$LOG"; }
count() { grep -cE -- "$1" "$LOG" || true; }

check "init.sh exited 0 (rc=$rc)" "$rc"
if [ -n "$NAME" ]; then
  check "computer name set three times to $NAME" "$([ "$(count "^scutil --set .*Name $NAME$|^scutil --set HostName $NAME$")" -eq 3 ] && echo 0 || echo 1)"
else
  check "no scutil calls without a computer name" "$([ "$(count '^scutil')" -eq 0 ] && echo 0 || echo 1)"
fi
check "common Brewfile bundled" "$(has "^brew bundle --file=.*/common/Brewfile" && echo 0 || echo 1)"
if [ -f "$ROOT/$PROFILE/Brewfile" ]; then
  check "$PROFILE Brewfile bundled" "$(has "^brew bundle --file=.*/$PROFILE/Brewfile" && echo 0 || echo 1)"
else
  check "no $PROFILE Brewfile, so only the common one is bundled" "$([ "$(count '^brew bundle')" -eq 1 ] && echo 0 || echo 1)"
fi
check "work submodule step only for the work profile" "$([ "$PROFILE" = work ] && { has 'submodule update --init --checkout work' && echo 0 || echo 1; } || { has 'submodule' && echo 1 || echo 0; })"
check "Oh My Zsh installer fetched, 2 plugins cloned" "$({ has '^curl .*ohmyzsh' && [ "$(count '^git clone .*zsh-users')" -eq 2 ]; } && echo 0 || echo 1)"
check "3 apps opened" "$([ "$(count '^open -a')" -eq 3 ] && echo 0 || echo 1)"
check "profile recorded as $PROFILE" "$([ "$(cat "$H/.dotfiles-profile" 2>/dev/null)" = "$PROFILE" ] && echo 0 || echo 1)"
check "dotfiles installed (.zshrc, .gitconfig)" "$([ -f "$H/.zshrc" ] && [ -f "$H/.gitconfig" ] && echo 0 || echo 1)"
check ".zprofile is the installed common file with one brew shellenv line" "$([ "$(grep -c 'brew shellenv' "$H/.zprofile")" -eq 1 ] && grep -q 'Docker Desktop' "$H/.zprofile" && echo 0 || echo 1)"
check "line init.sh appended to .zprofile was backed up before install.sh replaced it" "$(find "$H/.dotfiles-backup" -name .zprofile 2>/dev/null | grep -q . && echo 0 || echo 1)"

echo "--- stubbed commands init.sh attempted:"; sed "s#$T/##g" "$LOG" | cut -c1-140
[ "$fail" -eq 0 ] && echo "ALL CHECKS PASSED" || { echo "SOME CHECKS FAILED; init.sh output:"; sed "s#$T/##g" "$T/out.txt" | tail -15; exit 1; }
