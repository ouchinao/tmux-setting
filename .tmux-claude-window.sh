#!/bin/bash
# Open a new window with the Claude Code 4-pane layout in the current session.
# Intended to be invoked from prefix + Enter in .tmux.conf.
# Usage: ~/.tmux-claude-window.sh [dir]
#
# Layout (same as .tmux-claude.sh):
#   +-----------------+-----------------+
#   | claude code     | lazygit         |
#   +-----------------+-----------------+
#   | shell           | nano (diff)     |
#   +-----------------+-----------------+

DIR="${1:-$PWD}"

# Create the new window and capture its id and first pane
win=$(tmux new-window -c "$DIR" -P -F '#{window_id}')
main=$(tmux list-panes -t "$win" -F '#{pane_id}' | head -n1)

# Build the 4-pane grid
top_right=$(tmux split-window -h -l 50% -c "$DIR" -t "$main"      -P -F '#{pane_id}')
bot_left=$(tmux  split-window -v -l 50% -c "$DIR" -t "$main"      -P -F '#{pane_id}')
bot_right=$(tmux split-window -v -l 50% -c "$DIR" -t "$top_right" -P -F '#{pane_id}')

# Pane titles
tmux select-pane -t "$main"      -T "claude code"
tmux select-pane -t "$top_right" -T "lazygit"
tmux select-pane -t "$bot_left"  -T "shell"
tmux select-pane -t "$bot_right" -T "nano (diff)"

# Initial command per pane
tmux send-keys -t "$top_right" 'lazygit' C-m
tmux send-keys -t "$bot_left"  'echo "shell: dev server / test / logs etc."' C-m
tmux send-keys -t "$bot_right" 'echo "diff: git diff | nano -v -   (all: git diff HEAD | nano -v -)"' C-m
tmux send-keys -t "$main"      'echo "run claude here (claude code)"' C-m

# Focus the main pane
tmux select-window -t "$win"
tmux select-pane -t "$main"
