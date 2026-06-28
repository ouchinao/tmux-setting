#!/bin/bash
# Claude Code workspace (macOS / tmux 3.x)
# Usage: ~/.tmux-claude.sh [project-dir]
#
# Layout (3 panes):
#   +----------------------------+-------------+
#   |                            | diff (nano) |
#   |       claude code          |             |
#   |       (wide)               +-------------+
#   |                            | shell       |
#   +----------------------------+-------------+

SESSION="claude"
DIR="${1:-$PWD}"

# Kill any existing session with the same name
tmux kill-session -t "$SESSION" 2>/dev/null

# --- Create the session with the main (claude) pane ---
tmux new-session -d -s "$SESSION" -c "$DIR"
main=$(tmux list-panes -t "$SESSION" -F '#{pane_id}' | head -n1)

# --- Right column: diff (nano) and shell ---
side_git=$(tmux split-window -h -l 35% -c "$DIR" -t "$main"     -P -F '#{pane_id}')
side_sh=$(tmux  split-window -v        -c "$DIR" -t "$side_git" -P -F '#{pane_id}')

# --- Pane titles (requires pane-border-status top in .tmux.conf) ---
tmux select-pane -t "$main"     -T "claude code"
tmux select-pane -t "$side_git" -T "diff (nano)"
tmux select-pane -t "$side_sh"  -T "shell"

# --- Initial command per pane ---
# diff: print how to review changes in nano (read Claude's diff with nano)
#   git diff | nano -v -        ... show unstaged changes, read-only
#   git diff HEAD | nano -v -   ... show all changes including staged
tmux send-keys -t "$side_git" 'echo "diff: git diff | nano -v -   (all: git diff HEAD | nano -v -)"' C-m

# shell: free shell (dev server / test / logs)
tmux send-keys -t "$side_sh" 'echo "shell: dev server / test / logs etc."' C-m

# claude: print a hint in the main pane (not auto-started)
tmux send-keys -t "$main" 'echo "run claude here (claude code)"' C-m

# Focus the main pane and attach
tmux select-pane -t "$main"
tmux attach -t "$SESSION"
