# tmux-setting

My personal tmux configuration and a helper script that opens a 6-pane workspace in one command.

## Contents

- `.tmux.conf` — tmux configuration (prefix, status bar, mouse, clipboard, key bindings)
- `.tmux-6pane.sh` — script that creates a `work` session split into 6 evenly tiled panes

## Requirements

- macOS (uses `pbcopy` for clipboard — built-in)
- [tmux](https://github.com/tmux/tmux) **3.2+ recommended** (TrueColor / `tmux-256color`)
- `zsh` at `/bin/zsh` (default on modern macOS)

No external CLI tools are required.

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

| Binding                  | Action                                                   |
| ------------------------ | -------------------------------------------------------- |
| `C-q`                    | Prefix                                                   |
| `prefix` + `r`           | Reload `~/.tmux.conf`                                     |
| `prefix` + `\|`          | Split pane horizontally (inherits current path)          |
| `prefix` + `-`           | Split pane vertically (inherits current path)            |
| `prefix` + `c`           | New window (inherits current path)                       |
| `prefix` + `h/j/k/l`     | Move between panes, Vim-style                             |
| `prefix` + `H/J/K/L`     | Resize the pane (repeatable without re-pressing prefix)  |
| `prefix` + `Tab`         | Jump to the previously active window                     |
| `v` (copy mode)          | Start selection                                          |
| `y` (copy mode)          | Yank selection to clipboard                              |
| `r` (copy mode)          | Toggle rectangle (block) selection                      |
| Mouse drag               | Select text; copies to clipboard on release             |
| Mouse wheel              | Enter copy mode and scroll                              |

## What's modern here

- **TrueColor (24-bit)** output so modern color themes render correctly.
- **`tmux-256color`** terminal with `Tc` overrides.
- **No ESC delay** (`escape-time 10`) — Vim/Neovim feels instant.
- **Focus events** forwarded to terminal apps (Vim autoread, etc.).
- **100k-line scrollback** history.
- **1-based** window/pane indexing with **auto-renumbering** on close.
- **Vi copy mode** (`v`/`y`/`r`) plus mouse selection.
- **Minimal status bar** with a transparent background that blends into your terminal.

## Status bar

- Positioned at the **top** of the screen, centered window list.
- Left: session name in an accent color.
- Right: `hostname │ YYYY-MM-DD │ HH:MM`.
- Refreshes every 5 seconds.

## Clipboard

`set-clipboard on` is enabled and the copy command is set to `pbcopy`, so anything you select with the mouse (or yank in copy mode with `y`) lands in the macOS system clipboard.
