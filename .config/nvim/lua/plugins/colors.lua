local function enable_transparency()
    vim.api.nvim_set_hl(0, "Normal", {
        bg = "none"
    })
    vim.api.nvim_set_hl(0, "NormalFloat", {
        bg = "none"
    })
    vim.api.nvim_set_hl(0, "LineNr", {
        bg = "none"
    })
end

return {{
    "folke/tokyonight.nvim",
    config = function()
        vim.cmd.colorscheme "tokyonight"
        enable_transparency()
    end
}, {
    "nvim-lualine/lualine.nvim",
    dependencies = {"nvim-tree/nvim-web-devicons"},
    opts = {
        theme = 'tokyonight'
    }
}}
