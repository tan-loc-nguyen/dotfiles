#!/usr/bin/env bash
# Claude Code status line — Catppuccin Mocha palette, Nerd Font icons
# Icons used — all Material Design (nf-md-*) set:
#   󰉋 nf-md-folder           directory
#   󰘬 nf-md-source_branch    git branch
#   󰚩 nf-md-robot             model
#   󰍛 nf-md-memory            context window
#   󰓅 nf-md-speedometer       quota (5h rate limit)
#   󰥔 nf-md-clock             reset countdown

input=$(cat)

# ANSI-C quoting so the ESC byte is stored literally
RESET=$'\033[0m'
PEACH=$'\033[38;5;216m'    # peach
YELLOW=$'\033[38;5;222m'   # yellow
SAPPHIRE=$'\033[38;5;117m' # sapphire
LAVENDER=$'\033[38;5;183m' # lavender
GREEN=$'\033[38;5;150m'    # green
OVERLAY=$'\033[38;5;245m'  # overlay1 (dim separators)
RED=$'\033[38;5;210m'      # red
BRIGHT_BLUE=$'\033[38;5;75m'  # bright cornflower blue (effort segment)

SEP=" ${OVERLAY}${RESET} "

# --- Directory (truncated to 3 segments like Starship) ---
cwd_raw=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
cwd_display="${cwd_raw/#$HOME/~}"
IFS='/' read -ra parts <<< "$cwd_display"
len="${#parts[@]}"
if [ "$len" -gt 3 ]; then
  dir="…/${parts[$((len-2))]}/${parts[$((len-1))]}"
else
  dir="$cwd_display"
fi

# --- Git branch (prefer workspace.git_worktree when available) ---
branch=""
git_wt=$(echo "$input" | jq -r '.workspace.git_worktree // empty')
if [ -n "$git_wt" ]; then
  branch="$git_wt"
elif git_branch=$(git -C "$cwd_raw" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null); then
  branch="$git_branch"
fi

# --- Model ---
model=$(echo "$input" | jq -r '.model.display_name // empty')

# --- Context window ---
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$used_pct" ]; then
  used_int=$(printf '%.0f' "$used_pct")
  if [ "$used_int" -ge 80 ]; then
    ctx_color="$RED"
  elif [ "$used_int" -ge 50 ]; then
    ctx_color="$YELLOW"
  else
    ctx_color="$GREEN"
  fi
  ctx_str="${used_int}%"
else
  ctx_color="$OVERLAY"
  ctx_str="--"
fi

# --- 5h rate limit quota + reset countdown ---
five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')

quota_str=""
if [ -n "$five_pct" ]; then
  five_int=$(printf '%.0f' "$five_pct")
  quota_str="${SEP}${SAPPHIRE}󰓅 ${five_int}%${RESET}"
fi

reset_str=""
if [ -n "$five_reset" ]; then
  now=$(date +%s)
  secs=$((five_reset - now))
  if [ "$secs" -gt 0 ]; then
    h=$((secs / 3600))
    m=$(((secs % 3600) / 60))
    if [ "$h" -gt 0 ]; then
      reset_fmt="${h}h${m}m"
    else
      reset_fmt="${m}m"
    fi
    reset_str="${SEP}${SAPPHIRE}󰥔 ${reset_fmt}${RESET}"
  fi
fi

# --- Thinking effort glyph ---
effort=$(jq -r '.effortLevel // empty' $HOME/.claude/settings.json 2>/dev/null)
case "$effort" in
  max)   effort_glyph="⊛" ;;
  xhigh) effort_glyph="⊕" ;;
  high)  effort_glyph="⊙" ;;
  medium) effort_glyph="○" ;;
  low)   effort_glyph="·" ;;
  *)     effort_glyph="" ;;
esac

# Git branch segment only if a branch was resolved
branch_seg=""
if [ -n "$branch" ]; then
  branch_seg="${SEP}${YELLOW}󰘬 ${branch}${RESET}"
fi

effort_seg=""
if [ -n "$effort_glyph" ]; then
  effort_seg="${SEP}${BRIGHT_BLUE}${effort_glyph} ${effort}${RESET}"
fi

printf "${PEACH}󰉋 %s${RESET}%s${SEP}${LAVENDER}󰚩 %s${RESET}%s${SEP}${ctx_color}󰍛 %s${RESET}%s%s" \
  "$dir" "$branch_seg" "$model" "$effort_seg" "$ctx_str" "$quota_str" "$reset_str"
