#! /usr/bin/lua
--
-- multi-substitute.lua
-- function
-- Copyright (Lua) Jie
-- 2024-02-27
--
--
vim.keymap.set("n", "md", "<cmd>lua MultidoList()<CR>")

local highlight = require('multi-do.highlight')
local utils = require('multi-do.utils')
highlight.initHighlightGroups()

local selectedItems = {}

local dir = utils.getDir(vim.fn.expand('%:p'))

local winPosi = "left"
local selectKey = "<C-p>"
local getCommandKey = "<C-s>"
local buf

local function keymapSetting()
  vim.api.nvim_buf_set_keymap(buf, "n", selectKey, "<cmd>lua SelectCancelToggle()<CR>", {})
  vim.api.nvim_buf_set_keymap(buf, "n", getCommandKey, "<cmd>lua GetCommand()<CR>", {})
end

-- append a item to list
-- item is the line number under cursor
-- delete the line number in selected list
function SelectCancelToggle()
  local lineNr = tonumber(vim.api.nvim_win_get_cursor(0)[1])
  local path = vim.api.nvim_get_current_line()
  local isDir = vim.fn.isdirectory(path)
  local items = utils.getItems(dir)

  if isDir == 1 or path == ".." or path == "." then
    if path == ".." then
      dir = string.match(string.sub(dir,1,-2), "^(.-)[^/]-$")
    elseif path == "." then
    else
      dir = utils.getDir(path)
    end

    items = utils.getItems(dir)
    utils.listItems(buf, items)
    highlight.highlightLines(buf, items)
  else
    if vim.tbl_count(selectedItems) == 0 then
      selectedItems[path] = lineNr
    else
      local notExist = true
      for selectedPath, selectedLineNr in pairs(selectedItems) do
        if selectedPath == path and selectedLineNr == lineNr then
          notExist = false
          selectedItems[selectedPath] = nil
          highlight.clearHighlight(buf, lineNr)

          highlight.highlightLine(buf, selectedLineNr, utils.getSelectedType(items[selectedLineNr]))
          highlight.highlightLine(buf, selectedLineNr+1, utils.getSelectedType(items[selectedLineNr+1]))
          break
        end
      end

      if notExist then
        selectedItems[path] = lineNr
      end
    end
  end

  highlight.highlightSelectedList(buf, items, selectedItems)
end

local function run(command)
  for item, _ in pairs(selectedItems) do
    vim.api.nvim_command("argadd "..item.." | argdedupe")
  end

  vim.api.nvim_command("argdo "..command)
end

-- get command to run
function GetCommand()
  vim.ui.input({}, function (input)
    if input == nil  then
      input = "silent"
    end
    run(input)
    utils.closeWin()
  end)
end

function MultidoList()
  local items = utils.getItems(dir)
  local options = {
    bufhidden = 'wipe',
    buftype = 'nowrite',
    modifiable = true,
  }
  buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(buf, "File list")
  keymapSetting()

  for opt, val in pairs(options) do
    vim.api.nvim_buf_set_option(buf, opt, val)
  end

  utils.openNewWin(winPosi)
  vim.api.nvim_win_set_buf(0, buf)
  utils.listItems(buf, items)
  highlight.highlightLines(buf, items)
  highlight.highlightSelectedList(buf, items, selectedItems)
end
