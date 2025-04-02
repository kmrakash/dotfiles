-- if true then return end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

if not vim.g.vscode then return end

-- Basic settings for VSCode mode
-- Add defer to load UI properly on vscode
vim.defer_fn(function()
  vim.opt.number = true
  vim.opt.relativenumber = true
end, 100)

vim.opt.clipboard = "unnamedplus"
vim.opt.cursorline = true
vim.api.nvim_create_autocmd("InsertEnter", {
  pattern = "*",
  callback = function() vim.opt.relativenumber = false end,
})
vim.api.nvim_create_autocmd("InsertLeave", {
  pattern = "*",
  callback = function() vim.opt.relativenumber = true end,
})

-- LazyVim Plugin Support (Partial)
require("lazy").setup {
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function() require("nvim-surround").setup {} end,
  },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    ---@type Flash.Config
    opts = {},
  -- stylua: ignore
  keys = {
    { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
    { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
    { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
    { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
  },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    -- event = "VeryLazy",
    enabled = false,
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      ensure_installed = { "json", "javascript" },
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = {
        enable = true,
      },
      auto_install = true,
    },
    config = function(_, opts) require("nvim-treesitter.configs").setup(opts) end,
  },
}
--
-- require "custom_vscode.keybindings"
