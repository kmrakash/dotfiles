return {
  "ThePrimeagen/harpoon",
  enabled = true,
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
  config = function()
    local harpoon = require "harpoon"
    harpoon:setup {}

    -- Basic telescope configuration
    local conf = require("telescope.config").values

    local function toggle_telescope(harpoon_files)
      local file_paths = {}
      for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
      end

      require("telescope.pickers")
        .new({}, {
          prompt_title = "Harpoon",
          finder = require("telescope.finders").new_table { results = file_paths },
          previewer = conf.file_previewer {},
          sorter = conf.generic_sorter {},
        })
        :find()
    end

    -- Keybindings for Harpoon
    vim.keymap.set("n", "<Leader>he", function() toggle_telescope(harpoon:list()) end, { desc = "Open harpoon window" })

    vim.keymap.set("n", "<Leader>ha", function() harpoon:list():add() end, { desc = "Add file to harpoon" })
    vim.keymap.set("n", "<Leader>hc", function() harpoon:list():clear() end, { desc = "Clear files to harpoon" })
    vim.keymap.set("n", "<Leader>hd", function() harpoon:list():remove() end, { desc = "Remove file to harpoon" })
    vim.keymap.set("n", "<Leader>h1", function() harpoon:list():select(1) end, { desc = "Harpoon file 1" })
    vim.keymap.set("n", "<Leader>h2", function() harpoon:list():select(2) end, { desc = "Harpoon file 2" })
    vim.keymap.set("n", "<Leader>h3", function() harpoon:list():select(3) end, { desc = "Harpoon file 3" })
    vim.keymap.set("n", "<Leader>h4", function() harpoon:list():select(4) end, { desc = "Harpoon file 4" })

    vim.keymap.set(
      "n",
      "<Leader>hp",
      function() require("harpoon"):list():prev() end,
      { desc = "Previous Harpoon buffer" }
    )
    vim.keymap.set("n", "<Leader>hn", function() require("harpoon"):list():next() end, { desc = "Next Harpoon buffer" })
  end,
}
