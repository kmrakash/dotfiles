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

-- --------------------------
-- Code Folding
-- --------------------------
-- vim.opt.foldmethod = "expr"
-- vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldenable = true
vim.opt.foldmethod = "syntax"  -- or "syntax" for language-aware folding
vim.opt.foldlevel = 99         -- Start with everything unfolded

-- jj -> <Esc> in insert mode (fast escape)
vim.keymap.set("i", "jj", "<Esc>", { noremap = true, silent = true, desc = "Escape insert (jj)" })

-- Disable netrw (use nvim-tree instead)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Auto-start nvim-tree on directory open
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function(data)
    if vim.fn.isdirectory(data.file) == 1 then
      vim.cmd("NvimTreeToggle")
    end
  end,
})

-- Set up keybindings after plugins load
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyDone",
  callback = function()
    vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { noremap = true, silent = true, desc = "Toggle file explorer" })
  end,
})

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
    cmd = "Telescope",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- nvim-treesitter (syntax highlighting and parsing)
  {
    "nvim-treesitter/nvim-treesitter",
    commit = "42fc28ba",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "python", "javascript", "html", "typescript", "tsx", "json", "markdown" },
        sync_install = false,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "gnn",
            node_incremental = "grn",
            node_decremental = "grm",
            scope_incremental = "grc",
          },
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
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
            set_jumps = true,
            goto_next_start = {
              ["]m"] = "@function.outer",
              ["]]"] = "@class.outer",
            },
            goto_previous_start = {
              ["[m"] = "@function.outer",
              ["["] = "@class.outer",
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

     -- nvim-tree (file explorer)
     {
       "nvim-tree/nvim-tree.lua",
       dependencies = { "nvim-tree/nvim-web-devicons" },
       cmd = "NvimTreeToggle",
       config = function()
         require("nvim-tree").setup({
           view = { width = 30 },
           renderer = { icons = { show = { git = true } } },
           hijack_netrw = true,
           auto_reload_on_write = true,
         })
       end,
     },

     -- bufferline (buffer tabs)
     {
       "akinsho/bufferline.nvim",
       dependencies = { "nvim-tree/nvim-web-devicons" },
       event = "BufEnter",
       config = function()
         require("bufferline").setup({})
       end,
     },

     -- mason (LSP manager)
     {
       "williamboman/mason.nvim",
       event = "VeryLazy",
       config = function()
         require("mason").setup()
       end,
     },
     {
       "williamboman/mason-lspconfig.nvim",
       event = "VeryLazy",
       config = function()
         require("mason-lspconfig").setup({
           ensure_installed = { "ts_ls", "emmet_ls", "jsonls" },
         })
       end,
     },

     -- nvim-lspconfig
     {
       "neovim/nvim-lspconfig",
       ft = { "javascript", "typescript", "tsx", "jsx", "json", "html" },
       config = function()
         vim.lsp.config('ts_ls', {})
         vim.lsp.config('emmet_ls', {})
         vim.lsp.config('jsonls', {})
         vim.lsp.enable({ 'ts_ls', 'emmet_ls', 'jsonls' })
       end,
     },

     -- nvim-cmp (completion)
     {
       "hrsh7th/nvim-cmp",
       dependencies = {
         "hrsh7th/cmp-nvim-lsp",
         "hrsh7th/cmp-buffer",
         "hrsh7th/cmp-path",
       },
       event = "InsertEnter",
       config = function()
         local cmp = require("cmp")
         cmp.setup({
           mapping = cmp.mapping.preset.insert({
             ["<C-b>"] = cmp.mapping.scroll_docs(-4),
             ["<C-f>"] = cmp.mapping.scroll_docs(4),
             ["<C-Space>"] = cmp.mapping.complete(),
             ["<C-e>"] = cmp.mapping.abort(),
             ["<CR>"] = cmp.mapping.confirm({ select = true }),
           }),
           sources = cmp.config.sources({
             { name = "nvim_lsp" },
             { name = "buffer" },
             { name = "path" },
           }),
         })
       end,
     },

     -- lualine (status line)
     {
       "nvim-lualine/lualine.nvim",
       event = "VeryLazy",
       config = function()
         require("lualine").setup({
           options = { theme = "ayu_dark" },
         })
       end,
     },

     -- gitsigns (git signs)
     {
       "lewis6991/gitsigns.nvim",
       event = "BufEnter",
       config = function()
         require("gitsigns").setup()
       end,
     },

     -- toggleterm (terminal)
     {
       "akinsho/toggleterm.nvim",
       event = "TermOpen",
       config = function()
         require("toggleterm").setup({
           direction = "float",
         })
       end,
     },

    -- ayu theme
    {
      "Shatur/neovim-ayu",
      priority = 1000,
      config = function()
        require("ayu").setup({
          mirage = false,
          terminal = true,
          overrides = {},
        })
      end,
    },

}, {
  -- lazy.nvim options
  defaults = { lazy = true },
})

-- --------------------------
-- Key Bindings for IDE Features
-- --------------------------
-- Buffer Navigation
vim.keymap.set("n", "<Tab>", ":BufferLineCycleNext<CR>", { noremap = true, silent = true, desc = "Next buffer" })
vim.keymap.set("n", "<S-Tab>", ":BufferLineCyclePrev<CR>", { noremap = true, silent = true, desc = "Previous buffer" })

-- Telescope (fuzzy finder)
vim.keymap.set("n", "<leader>ff", ":Telescope find_files<CR>", { noremap = true, silent = true, desc = "Find files" })
vim.keymap.set("n", "<leader>fg", ":Telescope live_grep<CR>", { noremap = true, silent = true, desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", ":Telescope buffers<CR>", { noremap = true, silent = true, desc = "Buffers" })
vim.keymap.set("n", "<leader>fh", ":Telescope help_tags<CR>", { noremap = true, silent = true, desc = "Help tags" })

-- LSP Actions
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { noremap = true, silent = true, desc = "Go to definition" })
vim.keymap.set("n", "gr", vim.lsp.buf.references, { noremap = true, silent = true, desc = "References" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { noremap = true, silent = true, desc = "Hover" })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { noremap = true, silent = true, desc = "Code actions" })

-- Terminal
vim.keymap.set("n", "<leader>t", ":ToggleTerm<CR>", { noremap = true, silent = true, desc = "Toggle terminal" })

-- --------------------------
-- Colorscheme: ayu-dark
-- --------------------------
vim.cmd("colorscheme ayu-dark")

