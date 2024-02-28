#! /usr/bin/lua
--
-- multi-substitute.lua
-- function
-- Copyright (Lua) Jie
-- 2024-02-27
--
--

vim.keymap.set("n", "md", "<cmd>lua MultidoList()<CR>")

local selectedItems = {}

local function getDir(path)
  if vim.fn.isdirectory(path) == 1 then
    return path.."/"
  else
    return string.match(path, "^(.-)[^/]-$")
  end
end

local dir = getDir(vim.fn.expand('%:p'))

local winPosi = "left"
local highlightGroupNamePrefix = "Multido"
local selectKey = "<C-x>"
local getCommandKey = "<C-s>"
local buf

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

initHighlightGroups()


-- get file list
local function getItems()
  local items = vim.split(vim.fn.glob(dir .. '*'), "\n")
  table.insert(items, 1, "..")
  table.insert(items, 1, ".")
  return items
end


local function highlightLine(lineNr, type)
  vim.api.nvim_buf_add_highlight(buf, -1, highlightGroupNamePrefix..type, lineNr, 0, -1)
end

local function clearHighlight(lineNr)
  vim.api.nvim_buf_clear_namespace(buf, -1, lineNr, lineNr)
end

local function highlightLines()
  vim.api.nvim_buf_set_option(buf, "modifiable", true)

  local items = getItems()

  for lineNr, path in pairs(items) do
    local filetype
    if vim.fn.isdirectory(path) == 1 or path == "." or path == ".." then
      filetype = "Dir"
    else
      filetype = "File"
    end
    highlightLine(lineNr-1, filetype)
  end

  vim.api.nvim_buf_set_option(buf, "modifiable", false)
end

-- whether it's a file or dir, selected has a high order
local function highlightSelectedList()
  vim.api.nvim_buf_set_option(buf, "modifiable", true)

  local items = getItems()

  for i, _ in pairs(items) do
    local lineNr = i
    for _, v in pairs(selectedItems) do
      if lineNr == v then
        clearHighlight(lineNr)
        highlightLine(lineNr-1, "Select")
      end
    end
  end

  vim.api.nvim_buf_set_option(buf, "modifiable", false)
end

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
local function listItems()
  vim.api.nvim_buf_set_option(buf, "modifiable", true)
  -- change list to base name
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
  local items = getItems()
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

  if isDir == 1 or text == ".." then
    dir = getDir(text)
    listItems()
    highlightLines()
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

  highlightSelectedList()
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
  listItems()
  highlightLines()
end

