-- Fix: lazygit (and other snacks floating terminals) losing focus after a
-- zellij/kitty pane switch.
--
-- When switching away from and back to the Neovim pane, the terminal emulator
-- sends focus-lost -> focus-gained escape sequences. On FocusGained, Neovim can
-- end up focused on the document window behind the floating terminal and drop
-- out of terminal-mode, so lazygit stops receiving keystrokes until it is
-- closed and reopened. snacks' auto_insert only fires on BufEnter of the
-- terminal window, which never happens because focus landed on the wrong
-- window.
--
-- This re-focuses an open floating terminal on FocusGained and re-enters
-- terminal-mode. It is a no-op when no floating terminal is open, so it does
-- not interfere with normal editing.
return {
  "folke/snacks.nvim",
  opts = {
    terminal = {
      auto_insert = true,
      start_insert = true,
    },
  },
  init = function()
    local group = vim.api.nvim_create_augroup("LazygitFocusFix", { clear = true })

    local function is_float_terminal(win)
      local cfg = vim.api.nvim_win_get_config(win)
      if cfg.relative == "" then
        return false
      end
      local buf = vim.api.nvim_win_get_buf(win)
      local ft = vim.bo[buf].filetype
      local bt = vim.bo[buf].buftype
      return ft == "snacks_terminal" or bt == "terminal"
    end

    vim.api.nvim_create_autocmd("FocusGained", {
      group = group,
      callback = function()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if is_float_terminal(win) then
            vim.api.nvim_set_current_win(win)
            vim.schedule(function()
              pcall(vim.cmd.startinsert)
            end)
            return
          end
        end
      end,
    })
  end,
}
