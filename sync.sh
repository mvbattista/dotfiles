#!/usr/bin/env bash
# Keep $HOME and this repo aligned, per manifest.txt.
#   sync.sh check   diff home vs repo; non-zero exit on drift
#   sync.sh pull    copy drifted home files back into the repo (never commits or pushes)
#   sync.sh push    repo -> home (runs install.sh)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
MANIFEST="$ROOT/manifest.txt"
PROFILE_FILE="$HOME/.dotfiles-profile"
CMD="${1:-check}"

# pull refuses files that look like they hold secrets or machine-specific data
SECRET_RE='AKIA[0-9A-Z]{16}|gh[pou]_[A-Za-z0-9]{20,}|github_pat_|xox[baprs]-|-----BEGIN [A-Z ]*PRIVATE KEY|[A-Za-z_]*(TOKEN|_KEY|SECRET)[A-Za-z_]*=[^ ]|[Pp]assword *=|([0-9]{1,3}\.){3}[0-9]{1,3}|/Users/[A-Za-z0-9._-]+'

[ -f "$PROFILE_FILE" ] || { echo "no $PROFILE_FILE; run install.sh --profile personal|work first" >&2; exit 2; }
PROFILE="$(cat "$PROFILE_FILE")"

layer_present() { [ "$1" != work ] || [ -e "$ROOT/work/.git" ]; }

if [ "$CMD" = push ]; then exec "$ROOT/install.sh" --profile "$PROFILE"; fi
case "$CMD" in check|pull) ;; *) echo "usage: sync.sh check|pull|push" >&2; exit 2 ;; esac

drift=0
while read -r layer repo_path home_path; do
  case "$layer" in ''|\#*) continue ;; esac
  [ "$layer" = common ] || [ "$layer" = "$PROFILE" ] || continue
  layer_present "$layer" || continue
  src="$ROOT/$layer/$repo_path"
  dst="${home_path/#\~/$HOME}"
  [ -e "$dst" ] || { echo "missing in home: $dst"; drift=1; continue; }
  [ -e "$src" ] || { echo "missing in repo: $layer/$repo_path"; drift=1; continue; }
  diff -rq "$src" "$dst" >/dev/null 2>&1 && continue
  drift=1
  if [ "$CMD" = check ]; then
    echo "drift: $layer/$repo_path"
  elif grep -rEIq "$SECRET_RE" "$dst"; then
    echo "REFUSED (secret/machine pattern) at: $(grep -rEIn "$SECRET_RE" "$dst" | cut -d: -f1,2 | head -5 | tr '\n' ' ')" >&2
    echo "  fix the home file or move the value to ~/.secrets, then re-run" >&2
  else
    cp -R "$dst" "$src"
    echo "pulled: $dst -> $layer/$repo_path"
  fi
done < "$MANIFEST"

if [ "$CMD" = pull ]; then
  git -C "$ROOT" status --short
  layer_present work && git -C "$ROOT/work" status --short || true
fi
[ "$CMD" = check ] && [ "$drift" = 1 ] && exit 1
exit 0
