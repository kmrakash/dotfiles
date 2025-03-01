---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "lua",
      "vim",
      "typescript",
      "javascript",
      "tsx",
      "json",
      -- add more arguments for adding more treesitter parsers
    },
  },
}
