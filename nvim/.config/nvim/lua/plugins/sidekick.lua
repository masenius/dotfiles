return {
  {
    "folke/sidekick.nvim",
    opts = function(_, opts)
      opts.cli = opts.cli or {}
      opts.cli.win = opts.cli.win or {}
      opts.cli.win.layout = "right"
    end,
  },
}