# flash.nvim — quick reference

What it does:
- Adds label-based quick jumps (search labels), enhanced `f/t` motions, and Tree-sitter aware jumps.

Common usage patterns:
- `require("flash").jump()` — jump mode (we mapped this to `s` in the example config)
- `require("flash").treesitter()` — show labels for Treesitter nodes (we mapped example to `S`)
- Integrates with normal `/` search so matches show labels for fast jumps
- Works across windows and is dot-repeatable

Notes:
- Flash is highly configurable; you can change modes (exact, fuzzy, search).
- If you use LazyVim or other starter configs, check for existing `s`/`S` bindings and remap accordingly.

Source: plugin README and examples. :contentReference[oaicite:6]{index=6}

