return {
  "olimorris/codecompanion.nvim",
  config = true,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    --refer to: https://github.com/olimorris/codecompanion.nvim/blob/main/lua/codecompanion/config.lua
    strategies = {
      --NOTE: Change the adapter as required
      chat = { adapter = "copilot", model = "gpt-5" },
      inline = { adapter = "copilot", model = "gpt-5" },
      cmd = { adapter = "copilot", model = "gpt-5" },
      -- chat = { adapter = "ollama" },
      -- inline = { adapter = "ollama" },
    },
  },
}
