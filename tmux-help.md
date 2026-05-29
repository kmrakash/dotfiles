# tmux-help — dotfiles tmux configuration reference

## Name

**tmux-help** — synopsis of options, key bindings, and helper scripts added or changed in this repository’s `~/.tmux.conf` (symlinked from `dotfiles/.tmux.conf`).

## Synopsis

```text
Prefix   default: C-a (Ctrl+a)
         send real C-a: C-a C-a

Splits   Prefix |     horizontal split
         Prefix -     vertical split

Reload   Prefix r     source ~/.tmux.conf; show message

Sync     Prefix S     toggle synchronize-panes; show on|off

Sessions Prefix f     fuzzy pick session (fzf popup); needs fzf + tmux-fzf-session.sh

Copy     Prefix [     enter copy mode (default)
         in copy mode (vi): v, C-v, y, mouse drag end → clipboard (wl-copy | xclip)
```

## Description

This file documents **what changed** relative to an earlier minimal config (prefix, mouse, splits, base index, tpm plugins only). New behavior covers terminal color settings, editor-friendly timings, scrollback, titles, clipboard integration, vi copy mode, reload/sync/fuzzy-session keys, and a small shell helper for **fzf**(1).

## Environment

| Variable / condition | Effect |
|----------------------|--------|
| `WAYLAND_DISPLAY` set and `wl-copy`(1) in `PATH` | Copy mode **y** and mouse-drag-end copy use Wayland clipboard. |
| `WAYLAND_DISPLAY` unset and `xclip`(1) in `PATH` | Same bindings use X11 clipboard (`-selection clipboard`). |
| `fzf`(1) in `PATH` | Enables **Prefix f** if `tmux-fzf-session.sh` is executable next to the real `~/.tmux.conf` (see **Files**). |

## Options

Options are set in `.tmux.conf` with **tmux**(1) `set` / `set-window-option` / `set-option -s` as noted.

| Option | Command form | Purpose |
|--------|----------------|---------|
| `default-terminal` | `set -g default-terminal "tmux-256color"` | Advertise tmux’s 256-color terminfo to child programs (replaces `screen-256color`). |
| `terminal-features` | `set -as terminal-features ",*:RGB"` | Enable RGB color for capable outer terminals. |
| `renumber-windows` | `set -g renumber-windows on` | After closing a window, renumber remaining windows to stay contiguous. |
| `escape-time` | `set -sg escape-time 0` | Milliseconds tmux waits after Esc; **0** reduces delay in Vim/Neovim. |
| `focus-events` | `set -g focus-events on` | Emit focus in/out events so editors may refresh on pane focus. |
| `history-limit` | `set -g history-limit 50000` | Lines of scrollback per pane. |
| `set-titles` | `set -g set-titles on` | Update the outer terminal’s window title. |
| `set-titles-string` | `set -g set-titles-string '#S:#I:#W - #T'` | Title format: session, window index, window name, pane title. |
| `set-clipboard` | `set -s set-clipboard on` | Allow clipboard integration (e.g. OSC 52) where the terminal supports it. |
| `mode-keys` | `setw -g mode-keys vi` | Copy mode uses vi key tables (`copy-mode-vi`). |

Unchanged from before (still in use): `prefix C-a`, `mouse on`, `base-index` / `pane-base-index` 1, status styling, **|** / **-** splits, tpm plugins (vim-tmux-navigator, themepack, resurrect, continuum).

## Key bindings

Bindings use the **prefix** table unless noted (`bind-key` → `Prefix` + key).

| Binding | Action |
|---------|--------|
| **Prefix r** | `source-file ~/.tmux.conf` then `display-message` “tmux.conf reloaded”. **Note:** path is `~/.tmux.conf`, not the repo path; keep the symlink there when editing this repo. |
| **Prefix S** | Toggle window option `synchronize-panes`; show `synchronize-panes: on` or `off` using `#{?pane_synchronized,...}`. |
| **Prefix f** | If `fzf` exists and the helper script is executable: `display-popup -E` running `tmux-fzf-session.sh` (session list → fzf → `switch-client`). If conditions fail, binding is not set (no error). |

**copy-mode-vi** (after **Prefix [** or **Prefix PageUp** per your habits):

| Binding | Action |
|---------|--------|
| **v** | `begin-selection` |
| **C-v** | `rectangle-toggle` |
| **y** | `copy-pipe-and-cancel` to `wl-copy` or `xclip` (see **Environment**) |
| **MouseDragEnd1Pane** | Same pipe as **y** (mouse selection release copies and exits copy mode) |

Default **copy-mode-vi f** remains “jump forward” (not the prefix session switcher).

## Files

| Path | Role |
|------|------|
| `dotfiles/.tmux.conf` | Main configuration (often `ln -s` → `~/.tmux.conf`). |
| `dotfiles/tmux-fzf-session.sh` | Executable: `tmux list-sessions` piped to **fzf**(1), then **tmux**(1) `switch-client -t`. |
| `~/.tmux/plugins/tpm` | Plugin manager; installed per **tpm**(7) / plugin README. |

**Prefix f** resolution: on startup, **tmux** runs **sh**(1) to set **Prefix f** only if `fzf` exists and `$dirname($(readlink -f $HOME/.tmux.conf)))/tmux-fzf-session.sh` is executable. So **`~/.tmux.conf` should be a symlink** into this repo (or the script must live beside the resolved real config).

## Plugins (unchanged)

| Plugin | Purpose |
|--------|---------|
| `tmux-plugins/tpm` | Plugin manager. |
| `christoomey/vim-tmux-navigator` | Move between vim and tmux panes with Ctrl+h/j/k/l. |
| `jimeh/tmux-themepack` | Themes; `@themepack 'powerline/default/cyan'`. |
| `tmux-plugins/tmux-resurrect` | Save/restore layouts and programs; `@resurrect-capture-pane-contents on`. |
| `tmux-plugins/tmux-continuum` | Periodic save; `@continuum-restore on`. |

Install/update plugins: **Prefix I** (capital I) after **tpm** is loaded (standard **tpm** binding).

## Diagnostics

```bash
# Reload from shell (same as Prefix r if prefix is C-a)
tmux source-file ~/.tmux.conf

# Show an option
tmux show -gv history-limit

# List prefix bindings
tmux list-keys -T prefix
```

If colors break on a host, check `infocmp tmux-256color` and install full **ncurses** terminfo packages if needed.

## See also

**tmux**(1), **tmux.conf**(5), **fzf**(1), **wl-copy**(1), **xclip**(1).
