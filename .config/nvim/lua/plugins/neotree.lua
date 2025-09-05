return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {"nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", -- optional, for file icons
    "MunifTanjim/nui.nvim"},
    config = function()
        require("neo-tree").setup({
            close_if_last_window = true, -- close Neo-tree if it's the last window
            enable_git_status = true,
            enable_diagnostics = true,
            filesystem = {
                filtered_items = {
                    visible = false,
                    hide_dotfiles = true,
                    hide_gitignored = true
                },
                follow_current_file = true -- focus file in tree when opening
            },
            window = {
                width = 35,
                mappings = {
                    ["<space>"] = "toggle_node",
                    ["<cr>"] = "open",
                    ["S"] = "open_split",
                    ["s"] = "open_vsplit",
                    ["t"] = "open_tabnew",
                    ["R"] = "refresh",
                    ["a"] = "add",
                    ["d"] = "delete",
                    ["r"] = "rename"
                }
            }
        })

        -- Keymap to toggle Neo-tree
        vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", {
            desc = "Toggle File Explorer"
        })
    end
}
