-- lua/plugins/theme.lua
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha", -- your preferred variant
      transparent_background = true,
      -- integrations = {
        -- gitsigns = true,
      -- },
      styles = {
        comments = { "italic" },
        functions = { "bold" },
      },
      -- dim_inactive = {
      --   enabled = true,
      --   percentage = 0.1,
      -- },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")
    end,
  }
}
