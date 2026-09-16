-- Tokyo Night, matched to `theme.name = "tokyo-night"` in ~/.config/herdr/config.toml.
--
-- Transparent instead of a hardcoded bg: Herdr paints the pane background, so
-- inheriting it keeps the editor flush no matter which Tokyo Night variant
-- Herdr renders (night/storm/moon) or which Ghostty theme is active.
-- For an opaque editor instead, set transparent = false and give bg a hex below.

return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "night", -- night | storm | moon
      transparent = true,
      terminal_colors = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
      on_highlights = function(hl, c)
        -- Explorer sits flush with the editor, no seam between the panes.
        hl.NeoTreeNormal = { fg = c.fg_sidebar, bg = "NONE" }
        hl.NeoTreeNormalNC = { fg = c.fg_sidebar, bg = "NONE" }
        hl.NeoTreeEndOfBuffer = { bg = "NONE" }
        hl.NeoTreeWinSeparator = { fg = c.bg, bg = "NONE" }
        hl.NeoTreeVertSplit = { fg = c.bg, bg = "NONE" }
        hl.WinSeparator = { fg = c.bg_highlight, bg = "NONE" }
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },
  -- onedark came from the Herdr doc; Tokyo Night replaces it.
  { "navarasu/onedark.nvim", enabled = false },
}
