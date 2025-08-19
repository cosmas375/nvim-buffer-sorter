# nvim-buffer-sorter

## vim-bufferline integration example

Configure bufferline:

```
local nvim_buffer_sorter = require("nvim-buffer-sorter")

vim.g.Bufferline_get_buffers_list = nvim_buffer_sorter.get_buffers_list
```

Configure bufferline:

```
local nvim_buffer_sorter = require("nvim-buffer-sorter")

nvim_buffer_sorter.setup({
    update_callback = function()
        vim.print(vim.api.nvim_call_function('bufferline#get_echo_string', {}))
    end
})

-- your remaps
vim.keymap.set("n", "J", nvim_buffer_sorter.go_prev)
vim.keymap.set("n", "K", nvim_buffer_sorter.go_next)
vim.keymap.set("n", "<<", nvim_buffer_sorter.shift_left)
vim.keymap.set("n", ">>", nvim_buffer_sorter.shift_right)
```

##
