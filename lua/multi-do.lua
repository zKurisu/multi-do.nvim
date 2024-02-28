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
local selectKey = "<C-x>"
local getCommandKey = "<C-s>"
local buf

-- get file list


-- open a new window in "left", "right"
local function openNewWin(posi)
  local command
  if posi == "left" then
    command = "let &splitright=0 | vnew | set nonumber norelativenumber"
  elseif posi == "right" then
    command = "set splitright | vnew | set nonumber norelativenumber"
  end
  vim.api.nvim_command(command)
end


-- display list in buffer
local function listItems(items)
  vim.api.nvim_buf_set_option(buf, "modifiable", true)
  -- change list to base name
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, items)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
end

-- append a item to list
-- item is the line number under cursor
-- delete the line number in selected list
function SelectCancelToggle()
  local lineNr = tonumber(vim.api.nvim_win_get_cursor(0)[1])
  local text = vim.api.nvim_get_current_line()
  local isDir = vim.fn.isdirectory(text)
  local items

  if isDir == 1 or text == ".." then
    dir = utils.getDir(text)
    items = utils.getItems(dir)
    listItems()
    highlight.highlightLines(buf, items)
  else
    if vim.tbl_count(selectedItems) == 0 then
      selectedItems[text] = lineNr
    else
      local notExist = true
      for k, v in pairs(selectedItems) do
        if v == lineNr then
          notExist = false
          selectedItems[k] = nil
          break
        end
      end

      if notExist then
        selectedItems[text] = lineNr
      end
    end
  end

  highlight.highlightSelectedList(buf, items, selectedItems)
end

local function run(command)
  for item, _ in pairs(selectedItems) do
    vim.api.nvim_command("argadd "..item)
  end

  vim.api.nvim_command("silent argdo "..command)
end

-- get command to run
function GetCommand()
  vim.ui.input({}, function (input)
    run(input)
  end)
end

local function keymapSetting()
  vim.api.nvim_buf_set_keymap(buf, "n", selectKey, "<cmd>lua SelectCancelToggle()<CR>", {})
  vim.api.nvim_buf_set_keymap(buf, "n", getCommandKey, "<cmd>lua GetCommand()<CR>", {})
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

  openNewWin(winPosi)
  vim.api.nvim_win_set_buf(0, buf)
  listItems(items)
  highlight.highlightLines(buf, items)
end
