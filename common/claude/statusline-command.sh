#!/bin/bash
# Claude Code statusLine — white text, lightning-bolt lead-in (from Michael's zsh
# PROMPT), emoji-labeled segments: dir + git branch/status, venv, context %,
# rate-limit usage, model.

input=$(cat)

WHITE=$'\033[97m'
CYAN=$'\033[36m'
RESET=$'\033[0m'
PIPE="${CYAN} │ ${WHITE}"

model=$(echo "$input" | jq -r '.model.display_name // empty')
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
dir_name=$(basename "$cwd")

# virtualenv / conda env, if active in the process environment
venv=""
if [ -n "$VIRTUAL_ENV" ]; then
  venv="$(basename "$VIRTUAL_ENV")"
elif [ -n "$CONDA_DEFAULT_ENV" ]; then
  venv="$CONDA_DEFAULT_ENV"
fi

# folder
folder_seg="📁 $dir_name"

# git branch + dirty flag (skip optional locks per repo convention)
branch_seg=""
if git -C "$cwd" --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)
  dirty=""
  if [ -n "$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)" ]; then
    dirty="*"
  fi
  [ -n "$branch" ] && branch_seg="🌳 $branch$dirty"
fi

venv_seg=""
[ -n "$venv" ] && venv_seg="🐍 $venv"

# context window usage
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
ctx_seg=""
[ -n "$used" ] && ctx_seg="$(printf '📊 %.0f%%' "$used")"

# claude.ai subscription rate-limit usage (5h / 7d), when present
five=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
usage_seg=""
[ -n "$five" ] && usage_seg="⏱️ 5h $(printf '%.0f' "$five")%"
[ -n "$week" ] && usage_seg="${usage_seg:+$usage_seg }7d $(printf '%.0f' "$week")%"

model_seg=""
[ -n "$model" ] && model_seg="🧠 $model"

# order: folder, branch, venv, context %, model, rate-limit usage last (most
# expendable if the terminal ever truncates a long line)
line="$folder_seg"
[ -n "$branch_seg" ] && line="$line$PIPE$branch_seg "
[ -n "$venv_seg" ] && line="$line$PIPE$venv_seg"
[ -n "$ctx_seg" ] && line="$line$PIPE$ctx_seg"
[ -n "$model_seg" ] && line="$line$PIPE$model_seg"
[ -n "$usage_seg" ] && line="$line$PIPE$usage_seg"

printf '%s⚡️ %s%s' "$WHITE" "$line" "$RESET"

# preserve the caveman plugin's badge (mode + savings), if active
CAVEMAN_SCRIPT=$(ls -dt "$HOME"/.claude/plugins/cache/caveman/caveman/*/hooks/caveman-statusline.sh 2>/dev/null | head -1)
if [ -f "$CAVEMAN_SCRIPT" ]; then
  caveman_out=$(printf '%s' "$input" | bash "$CAVEMAN_SCRIPT" 2>/dev/null)
  [ -n "$caveman_out" ] && printf ' %s' "$caveman_out"
fi
