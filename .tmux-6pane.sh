#!/bin/bash
# nano中心の「軽量IDE」ワークスペース (macOS / tmux 3.x)
# 使い方: ~/.tmux-6pane.sh [project-dir]
#
# レイアウト (6ペイン):
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

# 既存セッションがあれば削除
tmux kill-session -t "$SESSION" 2>/dev/null

# --- メイン(editor)ペインでセッション作成 ---
tmux new-session -d -s "$SESSION" -c "$DIR"
main=$(tmux list-panes -t "$SESSION" -F '#{pane_id}' | head -n1)

# --- 右カラム: git / def jump / search ---
side_git=$(tmux split-window -h -l 40% -c "$DIR" -t "$main"     -P -F '#{pane_id}')
side_def=$(tmux split-window -v        -c "$DIR" -t "$side_git" -P -F '#{pane_id}')
side_rg=$(tmux  split-window -v        -c "$DIR" -t "$side_def" -P -F '#{pane_id}')

# --- 下段: run/test と shell ---
bot_run=$(tmux split-window -v -l 25% -c "$DIR" -t "$main"    -P -F '#{pane_id}')
bot_sh=$(tmux  split-window -h        -c "$DIR" -t "$bot_run" -P -F '#{pane_id}')

# --- 各ペインのタイトル (.tmux.conf で pane-border-status top を有効に) ---
tmux select-pane -t "$main"     -T "editor (nano)"
tmux select-pane -t "$bot_run"  -T "run / test"
tmux select-pane -t "$bot_sh"   -T "shell"
tmux select-pane -t "$side_git" -T "git (lazygit)"
tmux select-pane -t "$side_def" -T "def jump"
tmux select-pane -t "$side_rg"  -T "search (rg/fzf)"

# --- 各ペインの初期コマンド ---
# git: lazygit があれば起動、無ければ案内
tmux send-keys -t "$side_git" 'command -v lazygit >/dev/null && lazygit || echo "brew install lazygit"' C-m

# def jump / search: 使い方のヒントを表示 (rg/fzf を直接叩くワークフロー)
tmux send-keys -t "$side_def" 'echo "def jump: rg -n \"def <symbol>\" . など"' C-m
tmux send-keys -t "$side_rg"  'echo "search: rg <pattern>  /  rg --files | fzf"' C-m

# editor: メインペインにヒントを表示 (nano <file> で編集)
tmux send-keys -t "$main" 'echo "editor: nano <file> で編集  (Ctrl+O 保存 / Ctrl+X 終了)"' C-m

# メインペインにフォーカスしてアタッチ
tmux select-pane -t "$main"
tmux attach -t "$SESSION"
