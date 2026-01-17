return {
  { "folke/tokyonight.nvim", lazy = false },
  { "bluz71/vim-moonfly-colors", name = "moonfly", lazy = false },
  { "zenbones-theme/zenbones.nvim", dependencies = "rktjmp/lush.nvim", lazy = false },
  { "ellisonleao/gruvbox.nvim", lazy = false },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000, -- High priority
    opts = {
      transparent_background = false,
      color_overrides = {
        mocha = { base = "#000000", mantle = "#000000", crust = "#000000" },
      },
    },
    config = function(_, opts)
      if vim.g.is_dynamic then
        require("catppuccin").setup(opts)
      else
        require("catppuccin").setup({ color_overrides = {} })
      end
      -- No vim.cmd.colorscheme here, the autocmd handles it
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        return vim.g.lazyvim_colorscheme or "tokyonight"
      end,
    },
  },
}