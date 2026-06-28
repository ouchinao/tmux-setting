# tmux-setting

My personal tmux configuration and a helper script that opens a **nano-centric "lightweight IDE"** 6-pane workspace in one command. No Vim/LazyVim required — editing is done with plain `nano`.

## Contents

- `.tmux.conf` — tmux configuration (prefix, status bar, mouse, clipboard, key bindings, `nano` as default editor)
- `.tmux-6pane.sh` — script that creates a `work` session laid out as a nano-centric IDE workspace
- `.tmux-claude.sh` — script that creates a `claude` session laid out for running Claude Code
- `.nanorc` — handy nano defaults (line numbers, syntax highlighting, mouse, auto-indent, …)

## Layout

```
+-------------------------+---------------+
|                         | git (lazygit) |
|                         +---------------+
|     editor (nano)       | def jump      |
|                         +---------------+
|                         | search rg/fzf |
+------------+------------+---------------+
| run / test |   shell    |               |
+------------+------------+---------------+
```

| Pane         | Purpose                                                   |
| ------------ | -------------------------------------------------------- |
| editor       | Main editing pane — `nano <file>` to edit                |
| run / test   | Run your build / tests                                   |
| shell        | Free shell                                               |
| git          | `lazygit` (auto-started if installed)                    |
| def jump     | Jump to definitions with `rg` (`rg -n "def <symbol>"`)   |
| search       | Search the project with `rg` / `rg --files \| fzf`       |

### Claude Code layout (`.tmux-claude.sh`)

A leaner layout for running [Claude Code](https://claude.com/claude-code) — Claude already handles editing, search and git internally, so it gets one big wide pane with a nano diff viewer and a shell alongside.

```
+----------------------------+-------------+
|                            | diff (nano) |
|       claude code          |             |
|       (wide)               +-------------+
|                            | shell       |
+----------------------------+-------------+
```

| Pane        | Purpose                                                  |
| ----------- | ------------------------------------------------------- |
| claude code | Run `claude` here (not auto-started — a hint is printed) |
| diff (nano) | Review Claude's changes in nano (see below)              |
| shell       | Free shell for dev server / tests / logs                |

Review Claude's diffs **in nano** (no extra tools needed — `nano -` reads stdin and `patch.nanorc` colorizes the diff):

```sh
git diff | nano -v -        # unstaged changes, read-only (-v = view mode)
git diff HEAD | nano -v -   # all changes incl. staged
```

Start it with `~/.tmux-claude.sh [project-dir]` (creates a separate `claude` session, independent of `work`).

## Requirements

- macOS (uses `pbcopy`, `pmset`, `ifconfig` — all built-in)
- [tmux](https://github.com/tmux/tmux) (3.0+ recommended)
- `zsh` at `/bin/zsh` (default on modern macOS)
- `nano` (default editor for the workspace)

Optional (the workspace degrades gracefully without them):

- [`lazygit`](https://github.com/jesseduffield/lazygit) — git pane (`brew install lazygit`)
- [`ripgrep`](https://github.com/BurntSushi/ripgrep) (`rg`) — def-jump & search panes (`brew install ripgrep`)
- [`fzf`](https://github.com/junegunn/fzf) — fuzzy file picking (`brew install fzf`)

SSID and battery percentage in the status bar are derived from macOS built-in commands (`ifconfig`, `pmset -g batt`).

## Install

Place both files directly in your home directory:

```sh
git clone https://github.com/<you>/tmux-setting.git
cp tmux-setting/.tmux.conf ~/.tmux.conf
cp tmux-setting/.tmux-6pane.sh ~/.tmux-6pane.sh
cp tmux-setting/.tmux-claude.sh ~/.tmux-claude.sh
cp tmux-setting/.nanorc ~/.nanorc
chmod +x ~/.tmux-6pane.sh ~/.tmux-claude.sh
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
~/.tmux-6pane.sh            # use the current directory as the project
~/.tmux-6pane.sh ~/code/app # or pass a project directory
```

This kills any existing `work` session, creates a fresh nano-centric workspace (see [Layout](#layout)) rooted at the given project directory, and attaches to it. The git pane auto-starts `lazygit` if it is installed; the def-jump and search panes print `rg`/`fzf` hints.

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

## Editing with nano

The workspace is built around `nano` instead of Vim/LazyVim, so there are no modes to learn — just start typing. `EDITOR`/`VISUAL` are set to `nano` in `.tmux.conf`, and `.nanorc` enables line numbers, syntax highlighting, mouse support and auto-indent.

Common nano commands (all use `Ctrl`, shown as `^`):

| Key      | Action                          |
| -------- | ------------------------------- |
| `^O`     | Save (write Out)                |
| `^X`     | Exit                            |
| `^K`     | Cut current line                |
| `^U`     | Paste (Uncut)                   |
| `^W`     | Search (Where Is) — `^W ^W` next |
| `^\`     | Search & replace                |
| `^G`     | Help (full command list)        |
| `^_`     | Go to line/column               |
| `M-U`    | Undo (`M-` = Alt/Option)        |
| `M-E`    | Redo                            |

## Status bar

- Positioned at the **top** of the screen, centered window list.
- Left: `hostname:[pane-index]`
- Right: `Wi-Fi status (📶/❌) battery% [YYYY-MM-DD(Day) HH:MM]` (via `ifconfig` and `pmset`)
- Refreshes every 1 second.

## Clipboard

`set-clipboard on` is enabled and the copy command is set to `pbcopy`, so anything you select with the mouse (or yank in copy mode) lands in the macOS system clipboard.
