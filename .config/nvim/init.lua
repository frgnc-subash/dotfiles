local theme_file = vim.fn.stdpath("config") .. "/theme_name.txt"
local f = io.open(theme_file, "r")
if f then
  local name = f:read("*all"):gsub("%s+", "")
  f:close()
  if name == "catppuccin-dynamic" then
    vim.g.lazyvim_colorscheme = "catppuccin-mocha"
    vim.g.is_dynamic = true
  else
    vim.g.lazyvim_colorscheme = name
    vim.g.is_dynamic = false
  end
end
require("config.lazy")
