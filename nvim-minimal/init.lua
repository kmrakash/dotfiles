-- ~/.config/nvim/init.lua
-- Minimal lazy.nvim based config with nvim-surround, flash.nvim, Base2Tone (Earth)
-- For Neovim 0.9.5 on Ubuntu

-- --------------------------
-- Bootstrap lazy.nvim
-- --------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- --------------------------
-- Basic settings
-- --------------------------
vim.g.mapleader = " "                -- leader = space
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.clipboard = "unnamedplus"
vim.opt.termguicolors = true
vim.opt.timeoutlen = 500            -- useful for jj combo timing

-- jj -> <Esc> in insert mode (fast escape)
vim.keymap.set("i", "jj", "<Esc>", { noremap = true, silent = true, desc = "Escape insert (jj)" })

-- --------------------------
-- Plugins (lazy)
-- --------------------------
require("lazy").setup({
  -- plugin manager extras
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- Base2Tone colorschemes for neovim (collection)
  {
    "atelierbram/Base2Tone-nvim",
    lazy = false,
    priority = 1000,
  },

  -- nvim-surround (add/change/delete surrounds)
  {
    "kylechui/nvim-surround",
    version = "^3.0.0",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        -- defaults are fine; add your overrides here
      })
    end,
  },

  -- flash.nvim (jump/labels)
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      -- don't overwrite your usual keys; example maps:
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash jump" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash treesitter" },
    },
  },

}, {
  -- lazy.nvim options
  defaults = { lazy = true },
})
-- --------------------------
-- Colorscheme: Base2Tone Earth (example)
-- --------------------------
-- The Base2Tone-nvim plugin exposes colorscheme names like:
--  base2tone_<name>_dark  and base2tone_<name>_light
-- "Earth" is one of the available flavors (see plugin repo/demo for exact names)
-- We'll try the "earth" dark variant below. If it errors, run :colorscheme to list.
vim.cmd("colorscheme base2tone_earth_dark")

