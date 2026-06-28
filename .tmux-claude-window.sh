#!/bin/bash
# 現在のセッションに「Claude Code 用3ペイン」レイアウトの新規ウィンドウを作る。
# .tmux.conf の prefix + c から呼ばれる想定。
# 使い方: ~/.tmux-claude-window.sh [dir]
#
# レイアウト (.tmux-claude.sh と同じ):
#   +----------------------------+-------------+
#   |                            | diff (nano) |
#   |       claude code          +-------------+
#   |       (大きく・横長)        | shell       |
#   +----------------------------+-------------+

DIR="${1:-$PWD}"

# 新規ウィンドウを作成し、そのIDと最初のペインを取得
win=$(tmux new-window -c "$DIR" -P -F '#{window_id}')
main=$(tmux list-panes -t "$win" -F '#{pane_id}' | head -n1)

# 右カラム: diff(nano) と shell
side_git=$(tmux split-window -h -l 35% -c "$DIR" -t "$main"     -P -F '#{pane_id}')
side_sh=$(tmux  split-window -v        -c "$DIR" -t "$side_git" -P -F '#{pane_id}')

# 各ペインのタイトル
tmux select-pane -t "$main"     -T "claude code"
tmux select-pane -t "$side_git" -T "diff (nano)"
tmux select-pane -t "$side_sh"  -T "shell"

# 各ペインの初期コマンド (ヒント表示)
tmux send-keys -t "$side_git" 'echo "diff: git diff | nano -v -   (全部: git diff HEAD | nano -v -)"' C-m
tmux send-keys -t "$side_sh"  'echo "shell: dev server / test / log など"' C-m
tmux send-keys -t "$main"     'echo "claude で起動 (claude code)"' C-m

# メインペインにフォーカス
tmux select-window -t "$win"
tmux select-pane -t "$main"
