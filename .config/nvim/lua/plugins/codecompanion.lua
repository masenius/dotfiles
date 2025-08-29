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
    extensions = {
      mcphub = {
        callback = "mcphub.extensions.codecompanion",
        opts = {
          make_tools = true,
          show_server_tools_in_chat = true,
          add_mcp_prefix_to_tool_names = true,
          show_result_in_chat = true,
          format_tool = nil,
          make_vars = true,
          make_slash_commands = true,
        },
      },
    },
  },
}
