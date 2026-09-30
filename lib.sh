# Shared helpers for install.sh and sync.sh. Sourced, not executed.
# Expects ROOT and PROFILE to be set by the caller.

# The work layer is a private submodule; it is absent until `git submodule update --init work`.
layer_present() { [ "$1" != work ] || [ -e "$ROOT/work/.git" ]; }

# Manifest rows flagged `merge` are JSON files built from common/<path> deep-merged with the
# profile overlay <profile>/<path with .json -> .<profile>.json>. Objects merge; arrays replace.
# Prints the path of the merged result (in $TMP).
merged_json() {
  local base="$ROOT/common/$1" overlay="$ROOT/$PROFILE/${1%.json}.$PROFILE.json" out="$TMP/merged.json"
  command -v jq >/dev/null || { echo "jq is required for merged files" >&2; exit 1; }
  if layer_present "$PROFILE" && [ -f "$overlay" ]; then
    jq -s '.[0] * .[1]' "$base" "$overlay" > "$out"
  else
    jq . "$base" > "$out"
  fi
  echo "$out"
}

# True when a merged JSON file and the installed file are equivalent (key order ignored).
json_same() { [ -e "$2" ] && [ "$(jq -S . "$1")" = "$(jq -S . "$2" 2>/dev/null)" ]; }
