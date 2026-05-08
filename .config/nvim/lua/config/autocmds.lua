local name_file = vim.fn.stdpath("config") .. "/theme_name.txt"
local matugen_file = vim.fn.expand("~/.config/matugen/generated/neovim-colors.lua")
local transparent = require("config.transparent")

local function read_theme_name()
  local f = io.open(name_file, "r")
  if not f then
    return nil
  end

  local name = f:read("*all"):gsub("%s+", "")
  f:close()

  if name == "" then
    return nil
  end

  return name
end

local function apply_ryo_transparency()
  if read_theme_name() == "ryo" then
    transparent.apply_deferred()
  end
end

local function apply_theme()
  local name = read_theme_name()
  if not name then
    return
  end

  vim.schedule(function()
    if name == "catppuccin-dynamic" then
      vim.g.is_dynamic = true
      -- Small delay to ensure matugen finished writing the colors file
      vim.defer_fn(function()
        local colors_func = loadfile(matugen_file)
        if colors_func then
          local ok, colors = pcall(colors_func)
          if ok then
            require("catppuccin").setup({ color_overrides = { mocha = colors } })
            vim.cmd.colorscheme("catppuccin-mocha")
          end
        end
      end, 50)
    elseif name == "catppuccin-mocha" then
      vim.g.is_dynamic = false
      require("catppuccin").setup({ color_overrides = {} })
      vim.cmd.colorscheme("catppuccin-mocha")
    elseif name == "tokyonight" then
      vim.g.is_dynamic = false
      vim.cmd.colorscheme("tokyonight")
    elseif name == "moonfly" then
      vim.g.is_dynamic = false
      vim.cmd.colorscheme("moonfly")
    elseif name == "gruvbox" then
      vim.g.is_dynamic = false
      vim.cmd.colorscheme("gruvbox")
    elseif name == "ryo" then
      vim.g.is_dynamic = false
      vim.cmd.colorscheme("default")
      apply_ryo_transparency()
    else
      vim.g.is_dynamic = false
      pcall(vim.cmd.colorscheme, name)
    end
  end)
end

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = apply_ryo_transparency,
})

vim.api.nvim_create_autocmd({ "VimEnter", "User" }, {
  pattern = { "*", "LazyVimStarted" },
  callback = apply_ryo_transparency,
})

local function watch_file(path, callback)
  local w = vim.uv.new_fs_event()
  local on_change
  on_change = function(err, filename, events)
    if err then
      return
    end
    -- Reload the theme
    callback()
    -- Keep watching
    w:start(path, {}, on_change)
  end
  w:start(path, {}, on_change)
end

-- Apply on startup
apply_theme()

-- Watch files
watch_file(name_file, apply_theme)
watch_file(matugen_file, apply_theme)
