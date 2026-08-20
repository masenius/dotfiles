-- Keymaps are automatically loaded on the VeryLazy event (after LazyVim's defaults)
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Alt+h/j/k/l is pane navigation between nvim, sidekick and zellij (via smart-splits).
-- Remove LazyVim's default <A-j>/<A-k> line-move so it doesn't override navigation,
-- then bind smart-splits. Alt+Shift+J/K (<A-J>/<A-K>) replaces line/selection movement.
local ss = require("smart-splits")

for _, dir in ipairs({ { "h", "left" }, { "j", "down" }, { "k", "up" }, { "l", "right" } }) do
  pcall(vim.keymap.del, "n", "<A-" .. dir[1] .. ">")
  vim.keymap.set("n", "<A-" .. dir[1] .. ">", ss["move_cursor_" .. dir[2]], { desc = "Navigate " .. dir[2] })
  vim.keymap.set("t", "<A-" .. dir[1] .. ">", ss["move_cursor_" .. dir[2]], { desc = "Navigate " .. dir[2] })
end

vim.keymap.set("n", "<A-J>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
vim.keymap.set("n", "<A-K>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
vim.keymap.set("v", "<A-J>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
vim.keymap.set("v", "<A-K>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })
