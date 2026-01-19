local name_file = vim.fn.stdpath("config") .. "/theme_name.txt"
local matugen_file = vim.fn.expand("~/.config/matugen/generated/neovim-colors.lua")

local function apply_theme()
  local f = io.open(name_file, "r")
  if not f then
    return
  end
  local name = f:read("*all"):gsub("%s+", "")
  f:close()

  if name == "catppuccin-dynamic" then
    vim.g.is_dynamic = true
    vim.defer_fn(function()
      local colors_func = loadfile(matugen_file)
      if colors_func then
        local ok, colors = pcall(colors_func)
        if ok then
          require("catppuccin").setup({ color_overrides = { mocha = colors } })
          vim.cmd.colorscheme("catppuccin-mocha")
        end
      end
    end, 100)
  elseif name == "catppuccin-mocha" then
    vim.g.is_dynamic = false
    require("catppuccin").setup({ color_overrides = {} })
    vim.cmd.colorscheme("catppuccin-mocha")
  else
    vim.g.is_dynamic = false
    vim.cmd.colorscheme(name)
  end
end

local function watch_file(path, callback)
  local w = vim.loop.new_fs_event()
  local on_change
  on_change = function(err)
    if err then
      return
    end
    w:stop()
    w:start(path, {}, vim.schedule_wrap(on_change))
    callback()
  end
  w:start(path, {}, vim.schedule_wrap(on_change))
end

watch_file(name_file, apply_theme)
watch_file(matugen_file, apply_theme)
