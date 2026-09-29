return {
  {
    "folke/sidekick.nvim",
    opts = function(_, opts)
      opts.nes = opts.nes or {}
      opts.nes.enabled = false

      opts.cli = opts.cli or {}
      opts.cli.win = opts.cli.win or {}
      opts.cli.win.layout = "right"
    end,
  },
}