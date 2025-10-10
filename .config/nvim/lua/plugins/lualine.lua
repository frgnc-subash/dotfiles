return {
    "nvim-lualine/lualine.nvim",
    lazy = false,
    dependencies = {"nvim-tree/nvim-web-devicons"},
    opts = (function()
        local colors = {
            BG = "#1F222A",
            FG = "#FFFFFF",
            YELLOW = "#FFE066",
            CYAN = "#4FFFE1",
            DARKBLUE = "#3B72FF",
            GREEN = "#00FF99",
            ORANGE = "#FFBB55",
            VIOLET = "#C88DFF",
            MAGENTA = "#FF77B5",
            BLUE = "#66B2FF",
            RED = "#FF6677"
        }

        local function get_mode_color()
            local mode_color = {
                n = colors.DARKBLUE,
                i = colors.VIOLET,
                v = colors.RED,
                [""] = colors.BLUE,
                V = colors.RED,
                c = colors.MAGENTA,
                no = colors.RED,
                s = colors.ORANGE,
                S = colors.ORANGE,
                [""] = colors.ORANGE,
                ic = colors.YELLOW,
                R = colors.ORANGE,
                Rv = colors.ORANGE,
                cv = colors.RED,
                ce = colors.RED,
                r = colors.CYAN,
                rm = colors.CYAN,
                ["r?"] = colors.CYAN,
                ["!"] = colors.RED,
                t = colors.RED
            }
            return mode_color[vim.fn.mode()]
        end

        local function get_opposite_color(mode_color)
            local opposite_colors = {
                [colors.RED] = colors.CYAN,
                [colors.BLUE] = colors.ORANGE,
                [colors.GREEN] = colors.MAGENTA,
                [colors.MAGENTA] = colors.DARKBLUE,
                [colors.ORANGE] = colors.BLUE,
                [colors.CYAN] = colors.YELLOW,
                [colors.VIOLET] = colors.GREEN,
                [colors.YELLOW] = colors.RED,
                [colors.DARKBLUE] = colors.VIOLET
            }
            return opposite_colors[mode_color] or colors.FG
        end

        local function create_separator(side, use_mode_color)
            return {
                function()
                    return side == "left" and "" or ""
                end,
                color = function()
                    local color = use_mode_color and get_mode_color() or get_opposite_color(get_mode_color())
                    return {
                        fg = color
                    }
                end,
                padding = {
                    left = 0
                }
            }
        end

        local function create_mode_based_component(content, icon, color_fg, color_bg)
            return {
                content,
                icon = icon,
                color = function()
                    local mode_color = get_mode_color()
                    local opposite_color = get_opposite_color(mode_color)
                    return {
                        fg = color_fg or colors.FG,
                        bg = color_bg or opposite_color,
                        gui = "bold"
                    }
                end
            }
        end

        local function mode()
            local mode_map = {
                n = "N",
                i = "I",
                v = "V",
                [""] = "V",
                V = "V",
                c = "C",
                no = "N",
                s = "S",
                S = "S",
                ic = "I",
                R = "R",
                Rv = "R",
                cv = "C",
                ce = "C",
                r = "R",
                rm = "M",
                ["r?"] = "?",
                ["!"] = "!",
                t = "T"
            }
            return mode_map[vim.fn.mode()] or "[UNKNOWN]"
        end

        local config = {
            options = {
                component_separators = "",
                section_separators = "",
                theme = {
                    normal = {
                        c = {
                            fg = colors.FG,
                            bg = colors.BG
                        }
                    },
                    inactive = {
                        c = {
                            fg = colors.FG,
                            bg = colors.BG
                        }
                    }
                },
                disabled_filetypes = {"neo-tree", "undotree", "sagaoutline", "diff"}
            },
            sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = {},
                lualine_x = {},
                lualine_y = {},
                lualine_z = {}
            },
            inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = {{
                    "location",
                    color = {
                        fg = colors.FG,
                        gui = "bold"
                    }
                }},
                lualine_x = {{
                    "filename",
                    color = {
                        fg = colors.FG,
                        gui = "bold,italic"
                    }
                }},
                lualine_y = {},
                lualine_z = {}
            }
        }

        local function ins_left(component)
            table.insert(config.sections.lualine_c, component)
        end
        local function ins_right(component)
            table.insert(config.sections.lualine_x, component)
        end

        ins_left({
            mode,
            color = function()
                return {
                    fg = colors.BG,
                    bg = get_mode_color(),
                    gui = "bold"
                }
            end,
            padding = {
                left = 1,
                right = 1
            }
        })

        ins_left(create_separator("left", true))

        ins_left({
            function()
                return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
            end,
            icon = " ",
            color = function()
                local virtual_env = vim.env.VIRTUAL_ENV
                return {
                    fg = get_mode_color(),
                    gui = virtual_env and "bold,strikethrough" or "bold"
                }
            end
        })

        ins_left(create_separator("right"))
        ins_left(create_mode_based_component("filename", nil, colors.BG))
        ins_left(create_separator("left"))

        return config
    end)()
}
