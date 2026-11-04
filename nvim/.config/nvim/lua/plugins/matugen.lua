-- Paleta generada por matugen (lua/matugen_palette.lua); si falta, LazyVim usa su tema normal.
local has_palette = pcall(require, "matugen_palette")

return {
  {
    "nvim-mini/mini.base16",
    lazy = false,
    priority = 1000,
    enabled = has_palette,
    config = function()
      require("mini.base16").setup({ palette = require("matugen_palette"), use_cterm = true })
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = function(_, opts)
      if has_palette then opts.colorscheme = function() end end
    end,
  },
}
