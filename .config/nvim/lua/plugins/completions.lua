return {
  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        menu = {
          max_height = 10,
          min_width = 15,
          border = "rounded",
          scrolloff = 2,
          scrollbar = false,
          draw = {
            columns = { { "kind_icon" }, { "label", "label_description", gap = 1 } },
            components = {
              label = { width = { fill = true, max = 30 } },
              label_description = { width = { max = 20 } },
            },
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
          window = {
            max_width = 50,
            max_height = 15,
            border = "rounded",
          },
        },
      },

      -- CORRECTED: Removed the invalid 'height' field
      signature = {
        window = {
          border = "rounded",
          -- signature help is automatically sized to fit the text,
          -- so we don't need (and can't use) a fixed height.
        },
      },
    },
  },
}
