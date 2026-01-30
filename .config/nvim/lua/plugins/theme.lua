return {
  { "folke/tokyonight.nvim", lazy = false },
  { "bluz71/vim-moonfly-colors", name = "moonfly", lazy = false },
  { "zenbones-theme/zenbones.nvim", dependencies = "rktjmp/lush.nvim", lazy = false },
  { "ellisonleao/gruvbox.nvim", lazy = false },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = { transparent_background = false },
    config = function(_, opts)
      if vim.g.is_dynamic then
        local matugen_path = vim.fn.expand("~/.config/matugen/generated/neovim-colors.lua")
        local f = loadfile(matugen_path)
        if f then
          local ok, colors = pcall(f)
          if ok then
            opts.color_overrides = { mocha = colors }
          end
        end
      else
        opts.color_overrides = {}
      end
      require("catppuccin").setup(opts)
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
