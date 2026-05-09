# nvim-surround — quick reference

Install: `require("nvim-surround").setup()` (we used lazy.nvim).

Core operations (same style as vim-surround):
- `ys{motion}{char}` — **y**ank surround: surround the {motion} with {char}
  - Example: `ysiw)` -> surrounds inner word with parentheses: (word)
  - `ys$"` -> surround to end of line with quotes

- `ds{char}` — **d**elete surrounding {char}
  - Example: `ds]` removes surrounding brackets

- `cs{target}{replacement}` — **c**hange surrounding
  - Example: `cs'"` changes surrounding single quotes to double quotes
  - Example: `csth1<CR>` change tag to `<h1>...</h1>`

Visual mode:
- Select text and use `S{char}` in visual to surround selection (plugin supports visual)

Other useful bits:
- Dot-repeatable (works with `.`)
- Supports treesitter-aware surrounds if treesitter components are present
- Use `:h nvim-surround` in Neovim for full docs

Source: plugin README. :contentReference[oaicite:5]{index=5}

