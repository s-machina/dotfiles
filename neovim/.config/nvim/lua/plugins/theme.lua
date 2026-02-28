-- Theme configuration with auto dark mode switching
return {
  -- TokyoNight colorscheme
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "storm", -- default to storm, will be overridden by auto-dark-mode
    },
  },

  -- Auto dark mode - follows macOS system appearance (macOS only)
  {
    "f-person/auto-dark-mode.nvim",
    enabled = vim.fn.has("macunix") == 1,
    lazy = false,
    priority = 999,
    opts = {
      update_interval = 1000, -- check every second
      set_dark_mode = function()
        vim.api.nvim_set_option_value("background", "dark", {})
        vim.cmd.colorscheme("tokyonight-storm")
      end,
      set_light_mode = function()
        vim.api.nvim_set_option_value("background", "light", {})
        vim.cmd.colorscheme("tokyonight-day")
      end,
    },
  },
}
