return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,
    config = function(_, opts)
      vim.opt.runtimepath:prepend(vim.fn.stdpath("data") .. "/site/")
      local tree_sitter = require("nvim-treesitter")

      tree_sitter.setup({ install_dir = vim.fn.stdpath('data') .. '/site' })
      
      local parsers = {
        "c", "cpp", "lua", "go", "python",
        "typescript", "javascript", "html", "css",
        "prisma", "markdown", "markdown_inline",
        "bash",
      }

      tree_sitter.install(parsers)

      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          pcall(vim.treesitter.start)
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
}

