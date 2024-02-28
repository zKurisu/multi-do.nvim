#! /usr/bin/lua
--
-- utils.lua
-- function
-- Copyright (Lua) Jie
-- 2024-02-28
--
--

local function getDir(path)
  if vim.fn.isdirectory(path) == 1 then
    return path.."/"
  else
    return string.match(path, "^(.-)[^/]-$")
  end
end

local function getItems(dir)
  local items = vim.split(vim.fn.glob(dir .. '*'), "\n")
  table.insert(items, 1, "..")
  table.insert(items, 1, ".")
  return items
end

-- display list in buffer
local function listItems(buf, items)
  vim.api.nvim_buf_set_option(buf, "modifiable", true)
  -- change list to base name
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, items)
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

local function closeWin()
  vim.api.nvim_win_close(0, false)
end

return {
  getDir = getDir,
  getItems = getItems,
  listItems = listItems,
  openNewWin = openNewWin,
  closeWin = closeWin,
}

