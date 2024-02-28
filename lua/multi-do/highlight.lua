#! /usr/bin/lua
--
-- highlight.lua
-- function
-- Copyright (Lua) Jie
-- 2024-02-28
--
--
local utils = require('multi-do.utils')

local highlightGroupNamePrefix = "Multido"

local highlightGroups = {
  File = {fg= vim.g.terminal_color_2, bg= vim.g.terminal_color_2},
  Dir = {fg= vim.g.terminal_color_6, bg=vim.g.terminal_color_4},
  Select = {fg=vim.g.terminal_color_5, bg=vim.g.terminal_color_6},
}

local function initHighlightGroups()
  for hgname, color in pairs(highlightGroups) do
    local fg = color.fg
    local bg = color.bg

    vim.api.nvim_command("highlight "..highlightGroupNamePrefix..hgname.." guifg="..fg)
  end
end

local function highlightLine(buf, lineNr, type)
  vim.api.nvim_buf_add_highlight(buf, -1, highlightGroupNamePrefix..type, lineNr-1, 0, -1)
end

local function clearHighlight(buf, lineNr)
  print("clear "..lineNr)
  vim.api.nvim_buf_clear_namespace(buf, -1, lineNr, lineNr+1)
end

local function highlightLines(buf, lines)
  vim.api.nvim_buf_set_option(buf, "modifiable", true)

  for lineNr, path in pairs(lines) do
    local filetype
    if vim.fn.isdirectory(path) == 1 or path == "." or path == ".." then
      filetype = "Dir"
    else
      filetype = "File"
    end
    highlightLine(buf, lineNr, filetype)
  end

  vim.api.nvim_buf_set_option(buf, "modifiable", false)
end

-- whether it's a file or dir, selected has a high order
local function highlightSelectedList(buf, lines, selectedItems)
  vim.api.nvim_buf_set_option(buf, "modifiable", true)

  for i, path in pairs(lines) do
    local lineNr = i
    for k, v in pairs(selectedItems) do
      if k == path and v == lineNr then
        highlightLine(buf, lineNr, "Select")
        break
      end
    end
  end

  vim.api.nvim_buf_set_option(buf, "modifiable", false)
end

return {
  initHighlightGroups = initHighlightGroups,
  highlightLine = highlightLine,
  highlightLines = highlightLines,
  highlightSelectedList = highlightSelectedList,
  clearHighlight = clearHighlight,
}
