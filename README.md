# Wormhole
Remote development plugin for neovim

## Installation
### [Lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{
  "irohn/wormhole.nvim",
  lazy = true,
  dependencies = {
    "nvim-lua/plenary.nvim",
    -- "folke/snacks.nvim", -- Optional but recommended to improve 'vim.ui.select()', any plugin that implements 'vim.ui.select()' will work
    -- "stevearc/oil.nvim", -- Optional for better file explorer over ssh
  },
  cmd = { "Wormhole", "Wh" },
  keys = {
    { "<leader>ss", "<cmd>Wormhole ssh<cr>", desc = "wormhole ssh" },
    { "<leader>se", "<cmd>Wormhole explore<cr>", desc = "wormhole explorer" },
  },
  opts = {},
}
```

