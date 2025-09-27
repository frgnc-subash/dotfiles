return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      -- Web
      javascript = { "prettierd", "prettier" },
      typescript = { "prettierd", "prettier" },
      javascriptreact = { "prettierd", "prettier" },
      typescriptreact = { "prettierd", "prettier" },
      css = { "prettierd", "prettier" },
      html = { "prettierd", "prettier" },
      json = { "prettierd", "prettier" },
      yaml = { "prettierd", "prettier" },
      markdown = { "prettierd", "prettier" },

      -- Lua
      lua = { "stylua" },

      -- Config files
      toml = { "taplo" },

      -- Python
      python = { "black", "isort" },

      -- Shell
      sh = { "shfmt" },
    },
  },
}
