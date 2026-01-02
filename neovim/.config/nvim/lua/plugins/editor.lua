-- Custom editor plugins and overrides
return {
  -- File explorer customization
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = false,
        },
      },
    },
  },

  -- Telescope customization
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
    },
  },

  -- Git integration
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true,
    },
  },
}
