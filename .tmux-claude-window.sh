#!/bin/bash
# Open a new window with the Claude Code 3-pane layout in the current session.
# Intended to be invoked from prefix + Enter in .tmux.conf.
# Usage: ~/.tmux-claude-window.sh [dir]
#
# Layout (same as .tmux-claude.sh):
#   +----------------------------+-------------+
#   |                            | diff (nano) |
#   |       claude code          +-------------+
#   |       (wide)               | shell       |
#   +----------------------------+-------------+

DIR="${1:-$PWD}"

# Create the new window and capture its id and first pane
win=$(tmux new-window -c "$DIR" -P -F '#{window_id}')
main=$(tmux list-panes -t "$win" -F '#{pane_id}' | head -n1)

# Right column: diff (nano) and shell
side_git=$(tmux split-window -h -l 35% -c "$DIR" -t "$main"     -P -F '#{pane_id}')
side_sh=$(tmux  split-window -v        -c "$DIR" -t "$side_git" -P -F '#{pane_id}')

# Pane titles
tmux select-pane -t "$main"     -T "claude code"
tmux select-pane -t "$side_git" -T "diff (nano)"
tmux select-pane -t "$side_sh"  -T "shell"

# Initial command per pane (hints)
tmux send-keys -t "$side_git" 'echo "diff: git diff | nano -v -   (all: git diff HEAD | nano -v -)"' C-m
tmux send-keys -t "$side_sh"  'echo "shell: dev server / test / logs etc."' C-m
tmux send-keys -t "$main"     'echo "run claude here (claude code)"' C-m

# Focus the main pane
tmux select-window -t "$win"
tmux select-pane -t "$main"
