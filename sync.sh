#!/usr/bin/env bash
# Keep $HOME and this repo aligned, per manifest.txt.
#   sync.sh check   diff home vs repo; non-zero exit on drift
#   sync.sh pull    copy drifted home files back into the repo (never commits or pushes)
#   sync.sh push    repo -> home (runs install.sh)
#   sync.sh scan    refuse staged content that looks like a secret (run by hooks/pre-commit)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
MANIFEST="$ROOT/manifest.txt"
PROFILE_FILE="$HOME/.dotfiles-profile"
CMD="${1:-check}"

# shellcheck source=secret-patterns.sh
. "$ROOT/secret-patterns.sh"

# credentials are refused everywhere; machine/internal details only outside the private work layer
pattern_for() { if [ "$1" = work ]; then echo "$CRED_RE"; else echo "$CRED_RE|$PUBLIC_RE"; fi; }

if [ "$CMD" = scan ]; then
  top="$(git rev-parse --show-toplevel)"
  # inside the work/ submodule the repo is private; at the top level it is public
  if [ -n "$(git -C "$top" rev-parse --show-superproject-working-tree)" ]; then re="$(pattern_for work)"; else re="$(pattern_for public)"; fi
  bad=0
  while IFS= read -r f; do
    [ "$f" = secret-patterns.sh ] && continue
    # submodule pointers (mode 160000) have no content to scan
    git -C "$top" ls-files -s -- "$f" | grep -q '^160000' && continue
    hits="$(git -C "$top" show ":$f" | grep -EIn "$re" | cut -d: -f1 | head -5 | tr '\n' ' ' || true)"
    [ -z "$hits" ] || { echo "REFUSED: $f (line(s): $hits)" >&2; bad=1; }
  done < <(git -C "$top" diff --cached --name-only --diff-filter=ACM)
  [ "$bad" = 0 ] || { echo "commit blocked: fix the content (values belong in ~/.secrets)" >&2; exit 1; }
  exit 0
fi

[ -f "$PROFILE_FILE" ] || { echo "no $PROFILE_FILE; run install.sh --profile personal|work first" >&2; exit 2; }
PROFILE="$(cat "$PROFILE_FILE")"
if [ "$CMD" = push ]; then exec "$ROOT/install.sh" --profile "$PROFILE"; fi
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
# shellcheck source=lib.sh
. "$ROOT/lib.sh"

case "$CMD" in check|pull) ;; *) echo "usage: sync.sh check|pull|push|scan" >&2; exit 2 ;; esac

drift=0
while read -r layer repo_path home_path flag; do
  case "$layer" in ''|\#*) continue ;; esac
  [ "$layer" = common ] || [ "$layer" = "$PROFILE" ] || continue
  layer_present "$layer" || continue
  dst="${home_path/#\~/$HOME}"
  [ -e "$dst" ] || { echo "missing in home: $dst"; drift=1; continue; }
  if [ "${flag:-}" = merge ]; then
    src="$(merged_json "$repo_path")"
    json_same "$src" "$dst" && continue
    drift=1
    echo "drift (merged): common/$repo_path + $PROFILE overlay vs $dst"
    if [ "$CMD" = pull ]; then
      echo "  merged files are not pulled automatically; edit the layer files by hand."
      echo "  top-level keys only in home: $(jq -rn --slurpfile h "$dst" --slurpfile m "$src" '(($h[0]|keys)-($m[0]|keys))|join(",")')"
    fi
    continue
  fi
  src="$ROOT/$layer/$repo_path"
  [ -e "$src" ] || { echo "missing in repo: $layer/$repo_path"; drift=1; continue; }
  diff -rq "$src" "$dst" >/dev/null 2>&1 && continue
  drift=1
  if [ "$CMD" = check ]; then
    echo "drift: $layer/$repo_path"
  elif grep -rEIq "$(pattern_for "$layer")" "$dst"; then
    echo "REFUSED (secret/machine pattern) at: $(grep -rEIn "$(pattern_for "$layer")" "$dst" | cut -d: -f1,2 | head -5 | tr '\n' ' ')" >&2
    echo "  fix the home file or move the value to ~/.secrets, then re-run" >&2
  else
    if [ -d "$dst" ]; then mkdir -p "$src"; rsync -a --delete "$dst/" "$src/"; else cp "$dst" "$src"; fi
    echo "pulled: $dst -> $layer/$repo_path"
  fi
done < "$MANIFEST"

if [ "$CMD" = pull ]; then
  git -C "$ROOT" status --short
  layer_present work && git -C "$ROOT/work" status --short || true
fi
[ "$CMD" = check ] && [ "$drift" = 1 ] && exit 1
exit 0
