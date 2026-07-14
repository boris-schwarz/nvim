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
    -- fzf-native needs `make` to build; on machines without it (Windows),
    -- fall back to telescope's default sorter instead of erroring.
    pcall(require("telescope").load_extension, "fzf")
  end,
}
