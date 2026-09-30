#!/usr/bin/env bash
# Copy dotfiles from this repo into $HOME for a profile (common + personal|work).
# Usage: install.sh [--profile personal|work] [--dry-run]
# Existing differing targets are backed up to <target>.bak before overwrite.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
MANIFEST="$ROOT/manifest.txt"
PROFILE_FILE="$HOME/.dotfiles-profile"
PROFILE=""
DRY_RUN=0

while [ $# -gt 0 ]; do
  case "$1" in
    --profile) PROFILE="${2:-}"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) sed -n '2,4p' "$0"; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

[ -z "$PROFILE" ] && [ -f "$PROFILE_FILE" ] && PROFILE="$(cat "$PROFILE_FILE")"
case "$PROFILE" in
  personal|work) ;;
  *) echo "profile required: --profile personal|work" >&2; exit 2 ;;
esac

layer_present() {
  # work layer is a private submodule; empty dir means not checked out
  [ "$1" != work ] || [ -e "$ROOT/work/.git" ]
}

if ! layer_present "$PROFILE"; then
  echo "skip: '$PROFILE' layer not checked out (git submodule update --init --checkout work)"
fi

copied=0
while read -r layer repo_path home_path; do
  case "$layer" in ''|\#*) continue ;; esac
  [ "$layer" = common ] || [ "$layer" = "$PROFILE" ] || continue
  layer_present "$layer" || continue
  src="$ROOT/$layer/$repo_path"
  dst="${home_path/#\~/$HOME}"
  if [ ! -e "$src" ]; then echo "missing in repo: $layer/$repo_path" >&2; continue; fi
  if [ -e "$dst" ] && diff -rq "$src" "$dst" >/dev/null 2>&1; then continue; fi
  if [ "$DRY_RUN" = 1 ]; then
    echo "would copy: $layer/$repo_path -> $dst$([ -e "$dst" ] && echo ' (backup .bak)')"
  else
    mkdir -p "$(dirname "$dst")"
    [ -e "$dst" ] && cp -R "$dst" "$dst.bak"
    cp -R "$src" "$dst"
    # ssh refuses loose permissions
    case "$dst" in "$HOME"/.ssh/*) chmod 700 "$HOME/.ssh"; chmod 600 "$dst" ;; esac
    echo "copied: $layer/$repo_path -> $dst"
  fi
  copied=$((copied + 1))
done < "$MANIFEST"

echo "$copied file(s) $([ "$DRY_RUN" = 1 ] && echo 'would change' || echo 'changed') (profile: $PROFILE)"
[ "$DRY_RUN" = 1 ] || echo "$PROFILE" > "$PROFILE_FILE"
