-- ~/.config/nvim/init.lua
-- Minimal lazy.nvim based config with nvim-surround, flash.nvim, Catppuccin Macchiato
-- For Neovim 0.12+

-- --------------------------
-- Bootstrap lazy.nvim
-- --------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
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
-- Code Folding (native treesitter folding, 0.10+)
-- --------------------------
vim.opt.foldenable = true
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
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

  -- git diff reviewer
   {
     "zion-off/diff",
     cmd = { "DiffNvimOpen", "DiffNvimToggle", "DiffNvimClose", "DiffNvimRefresh" },
     config = function()
       require("diff").setup()
     end,
   },

  -- which-key (keybinding popup helper)
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("which-key").setup({
        preset = "modern",
        delay = 400,
      })
      require("which-key").add({
        { "<leader>f", group = "Find (Telescope)" },
        { "<leader>e", desc = "Toggle file explorer" },
        { "<leader>t", desc = "Toggle terminal" },
        { "<leader>ca", desc = "Code actions" },
        { "<leader>a", desc = "Swap param next" },
        { "<leader>A", desc = "Swap param prev" },
        { "gd", desc = "Go to definition" },
        { "gr", desc = "References" },
        { "K",  desc = "Hover docs" },
        { "s",  desc = "Flash jump", mode = { "n", "x", "o" } },
        { "S",  desc = "Flash treesitter", mode = { "n", "x", "o" } },
        -- Java
        { "<leader>j",  group = "Java" },
        { "<leader>ji", desc = "Organize imports" },
        { "<leader>jv", desc = "Extract variable" },
        { "<leader>jm", desc = "Extract method" },
        { "<leader>jt", desc = "Test nearest method" },
        { "<leader>jT", desc = "Test class" },
        { "<leader>jn", desc = "Run nearest test (neotest)" },
        { "<leader>js", desc = "Test summary (neotest)" },
        -- Debug
        { "<leader>d",  group = "Debug" },
        { "<leader>db", desc = "Toggle breakpoint" },
        { "<leader>dc", desc = "Continue" },
        { "<leader>do", desc = "Step over" },
        { "<leader>di", desc = "Step into" },
        { "<leader>dO", desc = "Step out" },
        { "<leader>du", desc = "DAP UI toggle" },
        { "<leader>dr", desc = "DAP REPL" },
        -- Format
        { "<leader>cf", desc = "Format file" },
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
    branch = "0.1.x",
    cmd = "Telescope",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- nvim-treesitter (syntax highlighting and parsing)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      -- nvim-treesitter v1: only manages parsers; highlight/selection are Neovim built-ins
      require("nvim-treesitter").setup({
        ensure_installed = { "lua", "python", "javascript", "html", "typescript", "tsx", "json", "markdown", "java" },
        sync_install = false,
      })
      require("nvim-treesitter-textobjects").setup({
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
            ["[["] = "@class.outer",
          },
        },
        swap = {
          enable = true,
          swap_next = { ["<leader>a"] = "@parameter.inner" },
          swap_previous = { ["<leader>A"] = "@parameter.inner" },
        },
      })
    end,
  },

  -- leetcode.nvim (solve LeetCode problems in Neovim)
   -- {
   --   "kawre/leetcode.nvim",
   --   lazy = leet_arg ~= vim.fn.argv(0, -1),
   --   build = ":TSUpdate html",
   --   dependencies = {
   --     "nvim-lua/plenary.nvim",
   --     "MunifTanjim/nui.nvim",
   --   },
   --   opts = { arg = leet_arg },
   -- },

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
           ensure_installed = { "ts_ls", "emmet_ls", "jsonls", "jdtls" },
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
           options = { theme = "catppuccin" },
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
       cmd = "ToggleTerm",
       config = function()
         require("toggleterm").setup({
           direction = "float",
         })
       end,
     },

     -- nvim-jdtls (Java LSP)
     {
       "mfussenegger/nvim-jdtls",
       ft = { "java" },
       dependencies = { "mfussenegger/nvim-dap" },
       config = function()
         local jdtls = require("jdtls")
         local root_dir = jdtls.setup.find_root({ "pom.xml", "build.gradle", "build.gradle.kts", ".git" })
         local workspace = vim.fn.stdpath("data") .. "/jdtls-workspaces/" .. vim.fn.fnamemodify(root_dir, ":t")
         local capabilities = require("cmp_nvim_lsp").default_capabilities()

         jdtls.start_or_attach({
           cmd = { vim.fn.stdpath("data") .. "/mason/bin/jdtls", "-data", workspace },
           root_dir = root_dir,
           capabilities = capabilities,
           on_attach = function(_, bufnr)
             jdtls.setup_dap({ hotcodereplace = "auto" })
             local opts = function(desc) return { buffer = bufnr, noremap = true, silent = true, desc = desc } end
             vim.keymap.set("n", "<leader>ji", jdtls.organize_imports,                opts("Organize imports"))
             vim.keymap.set("n", "<leader>jv", jdtls.extract_variable,                opts("Extract variable"))
             vim.keymap.set("n", "<leader>jm", jdtls.extract_method,                  opts("Extract method"))
             vim.keymap.set("n", "<leader>jt", jdtls.test_nearest_method,             opts("Test nearest method"))
             vim.keymap.set("n", "<leader>jT", jdtls.test_class,                      opts("Test class"))
           end,
           settings = {
             java = {
               format = { enabled = true },
               completion = { importOrder = {} },
               inlayHints = { parameterNames = { enabled = "all" } },
             },
           },
         })
       end,
     },

     -- nvim-dap (debugger core)
     {
       "mfussenegger/nvim-dap",
       lazy = true,
       keys = {
         { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
         { "<leader>dc", function() require("dap").continue() end,          desc = "Continue" },
         { "<leader>do", function() require("dap").step_over() end,         desc = "Step over" },
         { "<leader>di", function() require("dap").step_into() end,         desc = "Step into" },
         { "<leader>dO", function() require("dap").step_out() end,          desc = "Step out" },
         { "<leader>dr", function() require("dap").repl.open() end,         desc = "DAP REPL" },
       },
     },

     -- nvim-dap-ui (debugger UI)
     {
       "rcarriga/nvim-dap-ui",
       dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
       keys = {
         { "<leader>du", function() require("dapui").toggle() end, desc = "DAP UI toggle" },
       },
       config = function()
         local dapui = require("dapui")
         dapui.setup()
         local dap = require("dap")
         dap.listeners.after.event_initialized["dapui_config"]  = function() dapui.open() end
         dap.listeners.before.event_terminated["dapui_config"]  = function() dapui.close() end
         dap.listeners.before.event_exited["dapui_config"]      = function() dapui.close() end
       end,
     },

     -- conform.nvim (auto-formatter; install google-java-format via :MasonInstall google-java-format)
     {
       "stevearc/conform.nvim",
       event = "BufWritePre",
       keys = {
         { "<leader>cf", function() require("conform").format({ async = true, lsp_fallback = true }) end, desc = "Format file" },
       },
       config = function()
         require("conform").setup({
           formatters_by_ft = {
             java       = { "google-java-format" },
             javascript = { "prettier" },
             typescript = { "prettier" },
             json       = { "prettier" },
           },
           format_on_save = { timeout_ms = 3000, lsp_fallback = true },
         })
       end,
     },

     -- neotest + neotest-java (JUnit test runner UI)
     {
       "nvim-neotest/neotest",
       dependencies = {
         "nvim-neotest/nvim-nio",
         "nvim-lua/plenary.nvim",
         "nvim-treesitter/nvim-treesitter",
         "rcasia/neotest-java",
       },
       ft = { "java" },
       keys = {
         { "<leader>jn", function() require("neotest").run.run() end,             desc = "Run nearest test" },
         { "<leader>js", function() require("neotest").summary.toggle() end,      desc = "Test summary" },
       },
       config = function()
         require("neotest").setup({
           adapters = { require("neotest-java") },
         })
       end,
     },

     -- Catppuccin theme to match Ghostty and herdr
     {
       "catppuccin/nvim",
       name = "catppuccin",
       lazy = false,
       priority = 1000,
       config = function()
         require("catppuccin").setup({
           flavour = "macchiato",
           integrations = {
             bufferline = true,
             cmp = true,
             flash = true,
             gitsigns = true,
             mason = true,
             nvimtree = true,
             telescope = true,
             treesitter = true,
             lualine = true,
             notify = false,
             neotree = false,
           },
         })

         vim.cmd.colorscheme("catppuccin")
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
