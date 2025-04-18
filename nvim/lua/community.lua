-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.colorscheme.catppuccin" },
  { import = "astrocommunity.motion.flash-nvim" },
  -- { import = "astrocommunity.file-explorer.telescope-file-browser-nvim" },
  { import = "astrocommunity.motion.nvim-surround" },
}
