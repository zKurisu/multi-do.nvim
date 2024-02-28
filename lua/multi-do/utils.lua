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

return {
  getDir = getDir,
  getItems = getItems,
}
