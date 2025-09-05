return {
    "neovim/nvim-lspconfig",
    dependencies = { -- LSP management
    "williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim", -- Completion
    "hrsh7th/nvim-cmp", "hrsh7th/cmp-buffer", "hrsh7th/cmp-path", "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-nvim-lua",
    "saadparwaiz1/cmp_luasnip", -- Snippets
    "L3MON4D3/LuaSnip", "rafamadriz/friendly-snippets", -- Optional: better Lua dev experience
    "folke/neodev.nvim"},

    config = function()
        ----------------------------------------------------------------------
        -- Neodev: provides full Neovim Lua API autocomplete
        ----------------------------------------------------------------------
        require("neodev").setup()

        ----------------------------------------------------------------------
        -- Mason setup
        ----------------------------------------------------------------------
        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed = {"lua_ls", "intelephense", "ts_ls", -- TypeScript
            "eslint", "pyright"}
        })

        ----------------------------------------------------------------------
        -- LSP handlers
        ----------------------------------------------------------------------
        local lspconfig = require("lspconfig")

        local lsp_defaults = lspconfig.util.default_config
        lsp_defaults.capabilities = vim.tbl_deep_extend("force", lsp_defaults.capabilities,
            require("cmp_nvim_lsp").default_capabilities())

        -- Lua LSP setup (recognize 'vim' global)
        lspconfig.lua_ls.setup({
            settings = {
                Lua = {
                    runtime = {
                        version = "LuaJIT"
                    },
                    diagnostics = {
                        globals = {"vim"}
                    },
                    workspace = {
                        library = vim.api.nvim_get_runtime_file("", true)
                    },
                    telemetry = {
                        enable = false
                    }
                }
            }
        })

        ----------------------------------------------------------------------
        -- Diagnostics UI
        ----------------------------------------------------------------------
        vim.diagnostic.config({
            virtual_text = true,
            severity_sort = true,
            float = {
                style = "minimal",
                border = "rounded",
                header = "",
                prefix = ""
            },
            signs = {
                text = {
                    [vim.diagnostic.severity.ERROR] = "✘",
                    [vim.diagnostic.severity.WARN] = "▲",
                    [vim.diagnostic.severity.HINT] = "⚑",
                    [vim.diagnostic.severity.INFO] = "»"
                }
            }
        })

        -- Borders for hover/signatureHelp
        vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
            border = "rounded"
        })
        vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
            border = "rounded"
        })

        ----------------------------------------------------------------------
        -- Keymaps (buffer-local on LspAttach)
        ----------------------------------------------------------------------
        vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(event)
                local opts = {
                    buffer = event.buf
                }
                local map = vim.keymap.set

                map("n", "K", vim.lsp.buf.hover, opts)
                map("n", "gd", vim.lsp.buf.definition, opts)
                map("n", "gD", vim.lsp.buf.declaration, opts)
                map("n", "gi", vim.lsp.buf.implementation, opts)
                map("n", "go", vim.lsp.buf.type_definition, opts)
                map("n", "gr", vim.lsp.buf.references, opts)
                map("n", "gs", vim.lsp.buf.signature_help, opts)
                map("n", "gl", vim.diagnostic.open_float, opts)
                map("n", "<F2>", vim.lsp.buf.rename, opts)
                map({"n", "x"}, "<F3>", function()
                    vim.lsp.buf.format({
                        async = true
                    })
                end, opts)
                map("n", "<F4>", vim.lsp.buf.code_action, opts)
            end
        })

        ----------------------------------------------------------------------
        -- Autoformat for specific filetypes
        ----------------------------------------------------------------------
        local autoformat_filetypes = {"lua", "typescript", "javascript", "python", "php"}
        vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(args)
                local client = vim.lsp.get_client_by_id(args.data.client_id)
                if not client then
                    return
                end
                if vim.tbl_contains(autoformat_filetypes, vim.bo.filetype) then
                    vim.api.nvim_create_autocmd("BufWritePre", {
                        buffer = args.buf,
                        callback = function()
                            vim.lsp.buf.format({
                                bufnr = args.buf,
                                id = client.id
                            })
                        end
                    })
                end
            end
        })

        ----------------------------------------------------------------------
        -- Autocompletion (nvim-cmp + LuaSnip)
        ----------------------------------------------------------------------
        local cmp = require("cmp")
        require("luasnip.loaders.from_vscode").lazy_load()
        vim.opt.completeopt = {"menu", "menuone", "noselect"}

        cmp.setup({
            preselect = "item",
            completion = {
                completeopt = "menu,menuone,noinsert"
            },
            window = {
                documentation = cmp.config.window.bordered()
            },
            sources = {{
                name = "path"
            }, {
                name = "nvim_lsp"
            }, {
                name = "buffer",
                keyword_length = 3
            }, {
                name = "luasnip",
                keyword_length = 2
            }},
            snippet = {
                expand = function(args)
                    require("luasnip").lsp_expand(args.body)
                end
            },
            formatting = {
                fields = {"abbr", "menu", "kind"},
                format = function(entry, item)
                    local source = entry.source.name
                    item.menu = ({
                        nvim_lsp = "[LSP]",
                        buffer = "[BUF]",
                        path = "[PATH]",
                        luasnip = "[SNIP]"
                    })[source] or ("[" .. source .. "]")
                    return item
                end
            },
            mapping = cmp.mapping.preset.insert({
                ["<CR>"] = cmp.mapping.confirm({
                    select = false
                }),
                ["<C-f>"] = cmp.mapping.scroll_docs(5),
                ["<C-u>"] = cmp.mapping.scroll_docs(-5),
                ["<C-e>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.abort()
                    else
                        cmp.complete()
                    end
                end),
                ["<Tab>"] = cmp.mapping(function(fallback)
                    local col = vim.fn.col(".") - 1
                    if cmp.visible() then
                        cmp.select_next_item({
                            behavior = "select"
                        })
                    elseif col == 0 or vim.fn.getline("."):sub(col, col):match("%s") then
                        fallback()
                    else
                        cmp.complete()
                    end
                end, {"i", "s"}),
                ["<S-Tab>"] = cmp.mapping.select_prev_item({
                    behavior = "select"
                }),
                ["<C-d>"] = cmp.mapping(function(fallback)
                    if require("luasnip").jumpable(1) then
                        require("luasnip").jump(1)
                    else
                        fallback()
                    end
                end, {"i", "s"}),
                ["<C-b>"] = cmp.mapping(function(fallback)
                    if require("luasnip").jumpable(-1) then
                        require("luasnip").jump(-1)
                    else
                        fallback()
                    end
                end, {"i", "s"})
            })
        })
    end
}
