return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Search file contents" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Open buffers" },
  },
  config = function()
    require("telescope").load_extension("fzf")
  end,
}
