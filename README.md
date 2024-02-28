# multi-do

    ✅️ Get command input
    ✅️ Run vim command in multiple files
    ✅️ List the files/dirs (diff color) of current directory (specific color) 
    ✅️ Could open last/next level dirctory
    Space or enter to select/unselect a file with background color 

# Installation
## Plugin Managers
### packer
```lua
use {
    'zkurisu/multi-do.nvim',
}
```

### vim-plug
```vim
Plug 'zkurisu/multi-do.nvim'
```

### lazy
```lua
return {
  "zkurisu/multi-do.nvim",
  version = "*",
  lazy = false,
  config = function()
    require("multi-do")
  end,
}
```

# Basic usage
## Keymapping
Run `:lua MultidoList()` or set a keybinding for it, adding `vim.keymap.set("n", "md", "<cmd>lua MarkdownTree()<CR>")` to `init.vim` or `init.lua`.

For lazy, you could add it to config:
```lua
return {
  "zkurisu/multi-do.nvim",
  version = "*",
  lazy = false,
  config = function()
    require("multi-do")
    vim.keymap.set("n", "md", "<cmd>lua MultidoList()<CR>")
  end,
}
```

## Select items
Press `<C-p>` to select an item.

## Get command input
Press `<C-s>` to get command input.



