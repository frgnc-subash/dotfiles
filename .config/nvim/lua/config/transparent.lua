local M = {}

local explicit_groups = {
  "Normal",
  "NormalNC",
  "NormalFloat",
  "FloatBorder",
  "FloatTitle",
  "SignColumn",
  "EndOfBuffer",
  "LineNr",
  "FoldColumn",
  "StatusLine",
  "StatusLineNC",
  "TabLine",
  "TabLineFill",
  "WinSeparator",
  "LazyNormal",
  "MasonNormal",
  "NeoTreeNormal",
  "NeoTreeNormalNC",
  "TelescopeNormal",
  "TelescopeBorder",
  "WhichKeyNormal",
}

local function clear_group_background(group)
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
  if ok and not vim.tbl_isempty(hl) then
    hl.bg = "NONE"
    hl.ctermbg = "NONE"
    vim.api.nvim_set_hl(0, group, hl)
  else
    vim.api.nvim_set_hl(0, group, { bg = "NONE", ctermbg = "NONE" })
  end
end

local function should_keep_background(group)
  return group:match("^lualine_") ~= nil
end

function M.apply()
  for group, hl in pairs(vim.api.nvim_get_hl(0, { link = false })) do
    if type(group) == "string" and not should_keep_background(group) and (hl.bg or hl.ctermbg) then
      clear_group_background(group)
    end
  end

  for _, group in ipairs(explicit_groups) do
    clear_group_background(group)
  end
end

function M.apply_deferred()
  M.apply()
  vim.schedule(M.apply)
  vim.defer_fn(M.apply, 50)
  vim.defer_fn(M.apply, 250)
end

return M
