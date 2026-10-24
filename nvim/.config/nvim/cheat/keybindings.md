# Neovim Keybindings — quick reference

Leader key: `<Space>`

## File Explorer
| Key | Action |
|-----|--------|
| `<leader>e` | Toggle nvim-tree (file explorer) |

## Fuzzy Finder (Telescope)
| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep (search in files) |
| `<leader>fb` | List open buffers |
| `<leader>fh` | Search help tags |

## Buffers
| Key | Action |
|-----|--------|
| `<Tab>` | Next buffer |
| `<S-Tab>` | Previous buffer |

## LSP
| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Show references |
| `K` | Hover documentation |
| `<leader>ca` | Code actions |

## Navigation (Flash)
| Key | Action |
|-----|--------|
| `s` | Flash jump (label-based) |
| `S` | Flash treesitter (node jump) |

## Surround (nvim-surround)
| Key | Action |
|-----|--------|
| `ys{motion}{char}` | Add surround (e.g. `ysiw)` wraps word in `()`) |
| `ds{char}` | Delete surround (e.g. `ds"` removes `"`) |
| `cs{from}{to}` | Change surround (e.g. `cs'"` changes `'` to `"`) |
| `S{char}` | Surround visual selection |

## Treesitter text objects
| Key | Action |
|-----|--------|
| `af` / `if` | Outer / inner function |
| `ac` / `ic` | Outer / inner class |
| `aa` / `ia` | Outer / inner parameter |
| `]m` / `[m` | Next / prev function start |
| `]]` / `[[` | Next / prev class start |
| `<leader>a` | Swap parameter forward |
| `<leader>A` | Swap parameter backward |

## Treesitter selection
| Key | Action |
|-----|--------|
| `gnn` | Start incremental selection |
| `grn` | Expand node |
| `grm` | Shrink node |
| `grc` | Expand scope |

## Terminal
| Key | Action |
|-----|--------|
| `<leader>t` | Toggle floating terminal |

## Insert mode
| Key | Action |
|-----|--------|
| `jj` | Exit to normal mode |

## Tip
Press `<Space>` and pause — which-key will show all available bindings in a popup.
Open this file: `:e ~/.config/nvim/cheat/keybindings.md`
