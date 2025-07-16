-- AstroUI provides the basis for configuring the AstroNvim User Interface
-- Configuration documentation can be found with `:h astroui`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  {
    "AstroNvim/astroui",
    ---@type AstroUIOpts
    opts = {
      -- change colorscheme
      colorscheme = "github_dark_default",
      -- AstroUI allows you to easily modify highlight groups easily for any and all colorschemes
      highlights = {
        init = {},
        github_dark_default = { -- GitHub theme specific overrides
          -- Use GitHub's actual dark colors for better integration
          StatusLine = { bg = "#0d1117", fg = "#f0f6fc" },
          -- StatusLineNC = { bg = "#161b22", fg = "#7d8590" },

          -- Tabline improvements
          -- TabLine = { bg = "#0d1117", fg = "#7d8590" },
          -- TabLineFill = { bg = "#0d1117" },
          -- TabLineSel = { bg = "#21262d", fg = "#f0f6fc", bold = true },
        },
        astrodark = { -- a table of overrides/changes when applying the astrotheme theme
          -- Normal = { bg = "#000000" },
        },
      },
      -- Icons can be configured throughout the interface
      icons = {
        -- configure the loading of the lsp in the status line
        LSPLoading1 = "⠋",
        LSPLoading2 = "⠙",
        LSPLoading3 = "⠹",
        LSPLoading4 = "⠸",
        LSPLoading5 = "⠼",
        LSPLoading6 = "⠴",
        LSPLoading7 = "⠦",
        LSPLoading8 = "⠧",
        LSPLoading9 = "⠇",
        LSPLoading10 = "⠏",
      },
    },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      window = {
        position = "right",
        width = 40,
      },
    },
  },
}
