# tmux-setting

My personal tmux configuration and a helper script that opens a 6-pane workspace in one command.

## Contents

- `.tmux.conf` — tmux configuration (prefix, status bar, mouse, clipboard, key bindings)
- `.tmux-6pane.sh` — script that creates a `work` session split into 6 evenly tiled panes

## Requirements

- macOS (uses `pbcopy`, `pmset`, `ipconfig` — all built-in)
- [tmux](https://github.com/tmux/tmux) (3.0+ recommended)
- `zsh` at `/bin/zsh` (default on modern macOS)

No external CLI tools are required. SSID and battery percentage in the status bar are derived from macOS built-in commands (`ipconfig getsummary en0`, `pmset -g batt`).

## Install

Place both files directly in your home directory:

```sh
git clone https://github.com/<you>/tmux-setting.git
cp tmux-setting/.tmux.conf ~/.tmux.conf
cp tmux-setting/.tmux-6pane.sh ~/.tmux-6pane.sh
chmod +x ~/.tmux-6pane.sh
```

Reload the config inside an existing tmux session:

```sh
tmux source-file ~/.tmux.conf
```

## Usage

### Start a normal session

```sh
tmux
```

### Start the 6-pane workspace

```sh
~/.tmux-6pane.sh
```

This kills any existing `work` session, creates a fresh one with 6 tiled panes, and attaches to it.

#### Optional: add a shell shortcut

For convenience, add the following function to your `~/.zshrc` so you can launch the 6-pane workspace by simply typing `tmux-dev`:

```sh
tmux-dev() {
  ~/.tmux-6pane.sh
}
```

Reload your shell (`source ~/.zshrc`) and run:

```sh
tmux-dev
```

## Key bindings

The prefix is remapped from the tmux default `C-b` to **`C-q`**.

| Binding         | Action                                              |
| --------------- | --------------------------------------------------- |
| `C-q`           | Prefix                                              |
| `prefix` + `\|` | Split pane horizontally (left/right)                |
| `prefix` + `-`  | Split pane vertically (top/bottom)                  |
| Mouse drag      | Select text; copies to macOS clipboard on release   |
| Mouse wheel     | Enter copy mode and scroll                          |

## Status bar

- Positioned at the **top** of the screen, centered window list.
- Left: `hostname:[pane-index]`
- Right: `Wi-Fi status (📶/❌) battery% [YYYY-MM-DD(Day) HH:MM]` (via `ifconfig` and `pmset`)
- Refreshes every 1 second.

## Clipboard

`set-clipboard on` is enabled and the copy command is set to `pbcopy`, so anything you select with the mouse (or yank in copy mode) lands in the macOS system clipboard.
