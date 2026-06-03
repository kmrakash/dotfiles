-- ~/.config/nvim/init.lua
-- Minimal lazy.nvim based config with nvim-surround, flash.nvim, and GitHub Dark Default
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
vim.o.guifont = "JetBrains Mono:h14"

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

-- Use oil.nvim instead of the built-in netrw browser
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function(data)
    if vim.fn.isdirectory(data.file) == 1 then
      vim.cmd("Oil " .. vim.fn.fnameescape(data.file))
    end
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

  -- which-key.nvim (discover keymaps)
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
      spec = {
        { "<leader>f", group = "Find" },
        { "<leader>g", group = "Git" },
        { "<leader>c", group = "Code" },
        { "<leader>t", group = "Terminal" },
      },
    },
    keys = {
      { "<leader>?", "<cmd>WhichKey<cr>", desc = "Which-key popup" },
    },
  },

  -- fzf-lua (fuzzy finder)
  {
    "ibhagwan/fzf-lua",
    cmd = "FzfLua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>ff", function() require("fzf-lua").files() end, desc = "Find files" },
      { "<leader>fg", function() require("fzf-lua").live_grep() end, desc = "Live grep" },
      { "<leader>fb", function() require("fzf-lua").buffers() end, desc = "Buffers" },
      { "<leader>fh", function() require("fzf-lua").help_tags() end, desc = "Help tags" },
    },
  },

  -- oil.nvim (file explorer)
  {
    "stevearc/oil.nvim",
    cmd = "Oil",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      delete_to_trash = true,
      view_options = {
        show_hidden = true,
      },
    },
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
    },
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
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
    opts = { arg = leet_arg },
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
      vim.lsp.config("ts_ls", {})
      vim.lsp.config("emmet_ls", {})
      vim.lsp.config("jsonls", {})
      vim.lsp.enable({ "ts_ls", "emmet_ls", "jsonls" })
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

  -- gitsigns (git signs)
  {
    "lewis6991/gitsigns.nvim",
    event = "BufEnter",
    config = function()
      require("gitsigns").setup()
    end,
  },

  -- lazygit.nvim (git UI)
  {
    "kdheepak/lazygit.nvim",
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
    },
  },

  -- codediff.nvim (structured diff review)
  {
    "esmuellert/codediff.nvim",
    cmd = "CodeDiff",
    keys = {
      { "<leader>gd", "<cmd>CodeDiff<cr>", desc = "Code diff" },
    },
  },

  -- alpha-nvim (start screen)
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      dashboard.section.header.val = {
        "  _   _                  ",
        " | \\ | | ___  _ __ ___   ",
        " |  \\| |/ _ \\| '_ ` _ \\  ",
        " | |\\  | (_) | | | | | | ",
        " |_| \\_|\\___/|_| |_| |_| ",
      }

      dashboard.section.buttons.val = {
        dashboard.button("f", "Find files", "<cmd>FzfLua files<cr>"),
        dashboard.button("r", "Recent files", "<cmd>FzfLua oldfiles<cr>"),
        dashboard.button("g", "Open LazyGit", "<cmd>LazyGit<cr>"),
        dashboard.button("c", "Edit config", "<cmd>edit " .. vim.fn.stdpath("config") .. "/init.lua<cr>"),
        dashboard.button("q", "Quit", "<cmd>qa<cr>"),
      }

      dashboard.section.footer.val = { "" }
      alpha.setup(dashboard.config)

      if vim.fn.argc() == 0 then
        vim.cmd("Alpha")
      end
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

  -- GitHub Dark Default theme to match Ghostty and tmux
  {
    "projekt0n/github-nvim-theme",
    lazy = false,
    priority = 1000,
    config = function()
      require("github-theme").setup({
        options = {
          transparent = false,
          terminal_colors = true,
          styles = {
            comments = "italic",
            keywords = "NONE",
            functions = "NONE",
            variables = "NONE",
            conditionals = "NONE",
            constants = "NONE",
            numbers = "NONE",
            operators = "NONE",
            strings = "NONE",
            types = "NONE",
          },
        },
      })
      vim.cmd.colorscheme("github_dark_default")
    end,
  },

  -- lualine (status line)
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    config = function()
      require("lualine").setup({
        options = { theme = "github_dark_default" },
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

-- LSP Actions
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { noremap = true, silent = true, desc = "Go to definition" })
vim.keymap.set("n", "gr", vim.lsp.buf.references, { noremap = true, silent = true, desc = "References" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { noremap = true, silent = true, desc = "Hover" })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { noremap = true, silent = true, desc = "Code actions" })

-- Terminal
vim.keymap.set("n", "<leader>t", ":ToggleTerm<CR>", { noremap = true, silent = true, desc = "Toggle terminal" })
