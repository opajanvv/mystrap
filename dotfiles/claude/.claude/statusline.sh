#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract data from JSON
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
project_name=$(basename "$cwd")
model=$(echo "$input" | jq -r '.model.display_name')
context_used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')

# Git information (skip optional locks for safety)
git_branch=""
if git -C "$cwd" rev-parse --is-inside-work-tree &>/dev/null; then
  branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)
  if [[ -n "$branch" ]]; then
    git_branch=" $branch"
  fi
fi

# Build progress bar for context usage
progress_bar=""
if [[ -n "$context_used" ]]; then
  # Convert to integer
  used_int=${context_used%.*}
  bar_width=20
  filled=$((used_int * bar_width / 100))
  empty=$((bar_width - filled))

  # Build bar with color based on usage
  bar=""
  for ((i=0; i<filled; i++)); do bar+="█"; done
  for ((i=0; i<empty; i++)); do bar+="░"; done

  # Color code based on usage level
  if [[ $used_int -ge 90 ]]; then
    # Red for 90%+
    progress_bar=$(printf " [\033[31m%s\033[0m] \033[31m%s%%\033[0m" "$bar" "$context_used")
  elif [[ $used_int -ge 75 ]]; then
    # Yellow for 75-89%
    progress_bar=$(printf " [\033[33m%s\033[0m] \033[33m%s%%\033[0m" "$bar" "$context_used")
  else
    # Green for <75%
    progress_bar=$(printf " [\033[32m%s\033[0m] \033[32m%s%%\033[0m" "$bar" "$context_used")
  fi
fi

# Format tokens
token_info=""
if [[ "$total_input" -gt 0 ]] || [[ "$total_output" -gt 0 ]]; then
  token_info=$(printf " %dk↑ %dk↓" $((total_input / 1000)) $((total_output / 1000)))
fi

# Build status line
# Format: model | progress bar | tokens | git branch | project
output=""
output+=$(printf "\033[34m%s\033[0m" "$model")
if [[ -n "$progress_bar" ]]; then
  output+=$(printf " \033[32m|\033[0m")
  output+="$progress_bar"
fi
if [[ -n "$token_info" ]]; then
  output+=$(printf " \033[32m|\033[0m")
  output+=$(printf "\033[35m%s\033[0m" "$token_info")
fi
if [[ -n "$git_branch" ]]; then
  output+=$(printf " \033[32m|\033[0m")
  output+=$(printf "\033[32m%s\033[0m" "$git_branch")
fi
output+=$(printf " \033[32m|\033[0m ")
output+=$(printf "\033[36m%s\033[0m" "$project_name")

echo "$output"
