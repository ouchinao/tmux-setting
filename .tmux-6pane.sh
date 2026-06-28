#!/bin/bash
# nano-centric "lightweight IDE" workspace (macOS / tmux 3.x)
# Usage: ~/.tmux-6pane.sh [project-dir]
#
# Layout (6 panes):
#   +-------------------------+---------------+
#   |                         | git (lazygit) |
#   |                         +---------------+
#   |     editor (nano)       | def jump      |
#   |                         +---------------+
#   |                         | search rg/fzf |
#   +------------+------------+---------------+
#   | run / test |   shell    |               |
#   +------------+------------+---------------+

SESSION="work"
DIR="${1:-$PWD}"

# Kill any existing session with the same name
tmux kill-session -t "$SESSION" 2>/dev/null

# --- Create the session with the main (editor) pane ---
tmux new-session -d -s "$SESSION" -c "$DIR"
main=$(tmux list-panes -t "$SESSION" -F '#{pane_id}' | head -n1)

# --- Right column: git / def jump / search ---
side_git=$(tmux split-window -h -l 40% -c "$DIR" -t "$main"     -P -F '#{pane_id}')
side_def=$(tmux split-window -v        -c "$DIR" -t "$side_git" -P -F '#{pane_id}')
side_rg=$(tmux  split-window -v        -c "$DIR" -t "$side_def" -P -F '#{pane_id}')

# --- Bottom row: run/test and shell ---
bot_run=$(tmux split-window -v -l 25% -c "$DIR" -t "$main"    -P -F '#{pane_id}')
bot_sh=$(tmux  split-window -h        -c "$DIR" -t "$bot_run" -P -F '#{pane_id}')

# --- Pane titles (requires pane-border-status top in .tmux.conf) ---
tmux select-pane -t "$main"     -T "editor (nano)"
tmux select-pane -t "$bot_run"  -T "run / test"
tmux select-pane -t "$bot_sh"   -T "shell"
tmux select-pane -t "$side_git" -T "git (lazygit)"
tmux select-pane -t "$side_def" -T "def jump"
tmux select-pane -t "$side_rg"  -T "search (rg/fzf)"

# --- Initial command per pane ---
# git: start lazygit if installed, otherwise print a hint
tmux send-keys -t "$side_git" 'command -v lazygit >/dev/null && lazygit || echo "brew install lazygit"' C-m

# def jump / search: print usage hints (rg/fzf based workflow)
tmux send-keys -t "$side_def" 'echo "def jump: rg -n \"def <symbol>\" . etc."' C-m
tmux send-keys -t "$side_rg"  'echo "search: rg <pattern>  /  rg --files | fzf"' C-m

# editor: print a hint in the main pane (use nano <file> to edit)
tmux send-keys -t "$main" 'echo "editor: nano <file> to edit  (Ctrl+O save / Ctrl+X exit)"' C-m

# Focus the main pane and attach
tmux select-pane -t "$main"
tmux attach -t "$SESSION"
