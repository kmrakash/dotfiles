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
-- Local Variables
-- --------------------------
local leet_arg = "leetcode.nvim"

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

   -- Tree-sitter ( text parser )
   -- Telescope (fuzzy finder)
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.6",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- nvim-treesitter + textobjects (add to lazy.nvim plugin list)
{
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  -- load early so highlighting & textobjects are available
  lazy = false,
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
  },
  config = function()
    require("nvim-treesitter.configs").setup({
      -- Parsers to always ensure installed
      ensure_installed = { "lua", "python", "javascript", "html" },

      -- Install parsers synchronously (helpful first run)
      sync_install = true,

      -- Highlighting
      highlight = {
        enable = true,
        -- fallback to regex highlighting for some langs if needed
        additional_vim_regex_highlighting = false,
      },

      -- Incremental selection (smart expand/shrink selection)
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "gnn",        -- start selection (go to node)
          node_incremental = "grn",      -- expand to next node
          node_decremental = "grm",      -- shrink selection
          scope_incremental = "grc",     -- expand to scope (optional)
        },
      },

      -- Textobjects (select/ move / swap based on syntax)
      textobjects = {
        select = {
          enable = true,
          lookahead = true, -- jump forward to textobj
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
            ["aa"] = "@parameter.outer",
            ["ia"] = "@parameter.inner",
          },
        },
        move = {
          enable = true,
          set_jumps = true, -- add to jumplist
          goto_next_start = {
            ["]m"] = "@function.outer",
            ["]]"] = "@class.outer",
          },
          goto_previous_start = {
            ["[m"] = "@function.outer",
            ["[["] = "@class.outer",
          },
        },
        swap = {
          enable = true,
          swap_next = { ["<leader>a"] = "@parameter.inner" },
         swap_previous = { ["<leader>A"] = "@parameter.inner" },
         },
       },
     })
   end,
 },

   -- leetcode.nvim (solve LeetCode problems in Neovim)
   {
     "kawre/leetcode.nvim",
     lazy = leet_arg ~= vim.fn.argv(0, -1),
     build = ":TSUpdate html",
     dependencies = {
       "nvim-lua/plenary.nvim",
       "MunifTanjim/nui.nvim",
     },
     opts = { arg = leet_arg },
   },

   -- gruvbox theme
   {
     "ellisonleao/gruvbox.nvim",
     priority = 1000,
     config = function()
       require("gruvbox").setup({
         contrast = "hard",
       })
     end,
   },

}, {
  -- lazy.nvim options
  defaults = { lazy = true },
})
-- --------------------------
-- Colorscheme: gruvbox
-- --------------------------
vim.cmd("colorscheme gruvbox")

