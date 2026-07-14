  return {
    {
      "williamboman/mason.nvim",
      config = function()
        require("mason").setup()
      end,
    },
    {
      "williamboman/mason-lspconfig.nvim",
      dependencies = { "williamboman/mason.nvim" },
      config = function()
        require("mason-lspconfig").setup({
          ensure_installed = { "rust_analyzer" },
        })
      end,
    },
    {
      "neovim/nvim-lspconfig",
      dependencies = { "williamboman/mason-lspconfig.nvim" },
      config = function()
        vim.lsp.config("rust_analyzer", {})
        vim.lsp.enable("rust_analyzer")

        vim.diagnostic.config({
          virtual_lines = true,
          virtual_text = false,
          underline = true,
          signs = true,
          severity_sort = true,
          update_in_insert = false,
        })

        vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
        vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "Find references" })
        vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover docs" })
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })

        vim.api.nvim_create_autocmd("BufWritePre", {
          pattern = "*.rs",
          callback = function()
            vim.lsp.buf.format({ timeout_ms = 2000 })
          end,
          desc = "Format Rust files on save",
        })
      end,
    },
  }
