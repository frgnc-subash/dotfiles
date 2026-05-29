local function is_ryo()
  local f = io.open(vim.fn.stdpath("config") .. "/theme_name.txt", "r")
  if not f then
    return false
  end

  local name = f:read("*all"):gsub("%s+", "")
  f:close()

  return name == "ryo"
end

local ryo_theme = {
  normal = {
    a = { fg = "#071017", bg = "#8bd5ff", gui = "bold" },
    b = { fg = "#eef5ff", bg = "#263447" },
    c = { fg = "#d7e2ef", bg = "#10141b" },
  },
  insert = {
    a = { fg = "#071017", bg = "#8ff0c7", gui = "bold" },
    b = { fg = "#eef5ff", bg = "#263447" },
    c = { fg = "#d7e2ef", bg = "#10141b" },
  },
  visual = {
    a = { fg = "#071017", bg = "#c7a8ff", gui = "bold" },
    b = { fg = "#eef5ff", bg = "#263447" },
    c = { fg = "#d7e2ef", bg = "#10141b" },
  },
  replace = {
    a = { fg = "#071017", bg = "#ff8f9b", gui = "bold" },
    b = { fg = "#eef5ff", bg = "#263447" },
    c = { fg = "#d7e2ef", bg = "#10141b" },
  },
  command = {
    a = { fg = "#071017", bg = "#ffd88a", gui = "bold" },
    b = { fg = "#eef5ff", bg = "#263447" },
    c = { fg = "#d7e2ef", bg = "#10141b" },
  },
  inactive = {
    a = { fg = "#9aa8ba", bg = "#10141b" },
    b = { fg = "#9aa8ba", bg = "#10141b" },
    c = { fg = "#9aa8ba", bg = "#10141b" },
  },
}

return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      if not is_ryo() then
        return
      end

      opts.options = opts.options or {}
      opts.options.theme = ryo_theme
      opts.options.globalstatus = true
    end,
  },
}
