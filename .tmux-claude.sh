#!/bin/bash
# Claude Code workspace (macOS / tmux 3.x)
# Usage: ~/.tmux-claude.sh [project-dir]
#
# Behavior:
#   - Outside tmux: (re)create a session named "claude" and attach to it.
#   - Inside tmux  (e.g. via `prefix + Enter` in .tmux.conf): open a new
#     window in the current session. No attach.
#
# Layout (4 panes):
#   +-----------------+-----------------+
#   | claude code     | lazygit         |
#   +-----------------+-----------------+
#   | shell           | nano (diff)     |
#   +-----------------+-----------------+

SESSION="claude"
DIR="${1:-$PWD}"

if [ -z "$TMUX" ]; then
  # Outside tmux: (re)create the session; use its first pane as `main`
  tmux kill-session -t "$SESSION" 2>/dev/null
  tmux new-session -d -s "$SESSION" -c "$DIR"
  main=$(tmux list-panes -t "$SESSION" -F '#{pane_id}' | head -n1)
else
  # Inside tmux: open a new window in the current session
  win=$(tmux new-window -c "$DIR" -P -F '#{window_id}')
  main=$(tmux list-panes -t "$win" -F '#{pane_id}' | head -n1)
fi

# --- Build the 4-pane grid ---
# Top-right: lazygit (split main horizontally, 50% width)
top_right=$(tmux split-window -h -l 50% -c "$DIR" -t "$main"      -P -F '#{pane_id}')
# Bottom-left: shell (split main vertically, 50% height)
bot_left=$(tmux  split-window -v -l 50% -c "$DIR" -t "$main"      -P -F '#{pane_id}')
# Bottom-right: nano diff (split top_right vertically, 50% height)
bot_right=$(tmux split-window -v -l 50% -c "$DIR" -t "$top_right" -P -F '#{pane_id}')

# --- Pane titles (requires pane-border-status top in .tmux.conf) ---
tmux select-pane -t "$main"      -T "claude code"
tmux select-pane -t "$top_right" -T "lazygit"
tmux select-pane -t "$bot_left"  -T "shell"
tmux select-pane -t "$bot_right" -T "nano (diff)"

# --- Initial command per pane ---
# lazygit: launch the lazygit TUI
tmux send-keys -t "$top_right" 'lazygit' C-m

# shell: free shell (dev server / test / logs)
tmux send-keys -t "$bot_left" 'echo "shell: dev server / test / logs etc."' C-m

# nano: print how to review changes in nano (read Claude's diff with nano)
#   git diff | nano -v -        ... show unstaged changes, read-only
#   git diff HEAD | nano -v -   ... show all changes including staged
tmux send-keys -t "$bot_right" 'echo "diff: git diff | nano -v -   (all: git diff HEAD | nano -v -)"' C-m

# claude: print a hint in the main pane (not auto-started)
tmux send-keys -t "$main" 'echo "run claude here (claude code)"' C-m

# Focus the main pane
tmux select-pane -t "$main"

# Attach only when invoked from outside tmux
if [ -z "$TMUX" ]; then
  tmux attach -t "$SESSION"
fi
