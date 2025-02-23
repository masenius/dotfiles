return {
  "OXY2DEV/markview.nvim",
  lazy = false, -- Recommended
  -- ft = "markdown" -- If you decide to lazy-load anyway

  dependencies = {
    -- You will not need this if you installed the
    -- parsers manually
    -- Or if the parsers are in your $RUNTIMEPATH
    "nvim-treesitter/nvim-treesitter",

    "nvim-tree/nvim-web-devicons",
  },

  config = function()
    require("markview").setup({

      preview = {
        modes = { "n", "no", "c" }, -- Change these modes
        -- to what you need

        -- normal mode
        hybrid_modes = { "n" }, -- Uses this feature on

        -- This is nice to have
        callbacks = {
          on_enable = function(_, win)
            vim.wo[win].conceallevel = 2
            vim.wo[win].conecalcursor = "c"
          end,
        },
      },
    })
  end,
}
