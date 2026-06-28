#!/bin/bash
# Claude Code 用ワークスペース (macOS / tmux 3.x)
# 使い方: ~/.tmux-claude.sh [project-dir]
#
# レイアウト (3ペイン):
#   +----------------------------+-------------+
#   |                            | diff (nano) |
#   |       claude code          |             |
#   |       (大きく・横長)        +-------------+
#   |                            | shell       |
#   +----------------------------+-------------+

SESSION="claude"
DIR="${1:-$PWD}"

# 既存セッションがあれば削除
tmux kill-session -t "$SESSION" 2>/dev/null

# --- メイン(claude)ペインでセッション作成 ---
tmux new-session -d -s "$SESSION" -c "$DIR"
main=$(tmux list-panes -t "$SESSION" -F '#{pane_id}' | head -n1)

# --- 右カラム: diff(nano) と shell ---
side_git=$(tmux split-window -h -l 35% -c "$DIR" -t "$main"     -P -F '#{pane_id}')
side_sh=$(tmux  split-window -v        -c "$DIR" -t "$side_git" -P -F '#{pane_id}')

# --- 各ペインのタイトル (.tmux.conf で pane-border-status top を有効に) ---
tmux select-pane -t "$main"     -T "claude code"
tmux select-pane -t "$side_git" -T "diff (nano)"
tmux select-pane -t "$side_sh"  -T "shell"

# --- 各ペインの初期コマンド ---
# diff: nano で差分を確認する使い方を表示 (Claudeの変更を nano で読む)
#   git diff | nano -v -        … 未ステージの変更を読み取り専用で表示
#   git diff HEAD | nano -v -   … ステージ済みも含めた全変更を表示
tmux send-keys -t "$side_git" 'echo "diff: git diff | nano -v -   (全部: git diff HEAD | nano -v -)"' C-m

# shell: 自由なシェル (dev server / test / ログ用)
tmux send-keys -t "$side_sh" 'echo "shell: dev server / test / log など"' C-m

# claude: メインペインにヒントを表示 (自動起動はしない)
tmux send-keys -t "$main" 'echo "claude で起動 (claude code)"' C-m

# メインペインにフォーカスしてアタッチ
tmux select-pane -t "$main"
tmux attach -t "$SESSION"
