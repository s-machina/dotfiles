-- Custom editor plugins and overrides
return {
  -- Disable neo-tree entirely - use snacks explorer instead
  {
    "nvim-neo-tree/neo-tree.nvim",
    enabled = false,
  },

  -- Telescope customization - now that neo-tree is disabled, restore file finding
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
    },
  },

  -- Configure snacks explorer for file browsing
  {
    "folke/snacks.nvim",
    opts = {
      explorer = {
        enabled = true,
      },
    },
  },

  -- Disable markdown diagnostics/warnings
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        marksman = {
          -- Disable markdown LSP diagnostics
          handlers = {
            ["textDocument/publishDiagnostics"] = function() end,
          },
        },
      },
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
