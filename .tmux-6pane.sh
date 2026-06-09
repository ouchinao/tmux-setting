#!/bin/bash
SESSION="work"

# 既存セッションがあれば削除
tmux kill-session -t $SESSION 2>/dev/null

# 新しいセッションを作成
tmux new-session -d -s $SESSION

# ペインを分割して6つにする（2列×3行のレイアウト例）
tmux split-window -h -t $SESSION       # 左右に分割 → 2ペイン
tmux split-window -v -t $SESSION:0.0   # 左上を上下分割 → 3ペイン
tmux split-window -v -t $SESSION:0.2   # 右を上下分割 → 4ペイン
tmux split-window -v -t $SESSION:0.0   # 左上をさらに分割 → 5ペイン
tmux split-window -v -t $SESSION:0.3   # 右上をさらに分割 → 6ペイン

# レイアウトを均等に整える
tmux select-layout -t $SESSION tiled

# セッションにアタッチ
tmux attach -t $SESSION