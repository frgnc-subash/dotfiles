-- Live Reload Logic
local theme_name_file = vim.fn.stdpath("config") .. "/theme_name.txt"
local watcher = vim.loop.new_fs_event()

watcher:start(theme_name_file, {}, vim.schedule_wrap(function()
  local f = io.open(theme_name_file, "r")
  if not f then return end
  local name = f:read("*all"):gsub("%s+", "")
  f:close()

  if name == "catppuccin-dynamic" then
    vim.g.is_dynamic = true
    require("catppuccin").setup({
      color_overrides = { mocha = { base = "#000000", mantle = "#000000", crust = "#000000" } },
    })
    vim.cmd.colorscheme("catppuccin-mocha")
  elseif name == "catppuccin-mocha" then
    vim.g.is_dynamic = false
    require("catppuccin").setup({ color_overrides = {} })
    vim.cmd.colorscheme("catppuccin-mocha")
  else
    vim.g.is_dynamic = false
    vim.cmd.colorscheme(name)
  end
end))