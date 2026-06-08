return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = { "prettier", "ruff", "goimports" },
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "neovim/nvim-lspconfig",
      "saghen/blink.cmp",
    },
    config = function()
      vim.lsp.config('*', {
        capabilities = require('blink.cmp').get_lsp_capabilities(),
      })

      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "ts_ls", "gopls", "prismals", "basedpyright", "bashls", "sqls", "ruff" },
      })


      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local buf = args.buf
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = buf, desc = "Go to definition" })
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = buf, desc = "Go to declaration" })
          vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = buf, desc = "Hover documentation" })
          vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, { buffer = buf, desc = "Signature help" })
          -- gr*, gri, grn, gra, grt, grr are Neovim 0.11 built-ins
        end,
      })
    end,
  },
}
