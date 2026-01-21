-- Markdown-specific configurations
return {
  -- Disable markdown language server diagnostics entirely
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}

      -- Disable marksman (markdown LSP)
      opts.servers.marksman = {
        enabled = false,
      }

      -- Also disable any other markdown-related LSPs
      opts.servers.remark_ls = {
        enabled = false,
      }
    end,
  },

  -- Configure diagnostics to ignore markdown files
  {
    "neovim/nvim-lspconfig",
    opts = function()
      -- Disable diagnostics for markdown files
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "markdown", "md" },
        callback = function()
          vim.diagnostic.disable(0)
        end,
      })
    end,
  },

  -- Override LazyVim's markdown extras to disable problematic parts
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      -- Remove markdown tools from auto-installation
      local markdown_tools = { "marksman", "remark-ls", "markdownlint" }
      for _, tool in ipairs(markdown_tools) do
        local index = vim.tbl_contains(opts.ensure_installed, tool)
        if index then
          table.remove(opts.ensure_installed, index)
        end
      end
    end,
  },

  -- Keep markdown preview but disable diagnostics
  {
    "iamcco/markdown-preview.nvim",
    enabled = true,
    build = function() vim.fn["mkdp#util#install"]() end,
  },
}