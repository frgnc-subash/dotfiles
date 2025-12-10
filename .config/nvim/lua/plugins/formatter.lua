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
      yaml = { "prettierd", "prettier" },
      markdown = { "prettierd", "prettier" },

      lua = { "stylua" },

      toml = { "taplo" },

      python = { "black", "isort" },

      sh = { "shfmt" },
    },
  },
}
