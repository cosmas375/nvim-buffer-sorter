# nvim-buffer-sorter

The name of the plugin speaks for itself :)

## vim-bufferline integration example

1. Install `cosmas375/vim-bufferline`

2. Configure vim-bufferline:
```
local nvim_buffer_sorter = require("nvim-buffer-sorter")

vim.g.Bufferline_get_buffers_list = nvim_buffer_sorter.get_buffers_list
```

3. Install `cosmas375/nvim-buffer-sorter`

4. Configure nvim-buffer-sorter:

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

## API

```
nvim_buffer_sorter.setup({
    update_callback                         -- called after shifts (can be used to call the update function of your buffer viewer)
})
nvim_buffer_sorter.shift_left()             -- reduces the number of the current buffer
nvim_buffer_sorter.shift_right()            -- increases the number of the current buffer
nvim_buffer_sorter.go_next()                -- switch to next buffer
nvim_buffer_sorter.go_prev()                -- switch to previous buffer
nvim_buffer_sorter.go_to(buffer_number)     -- switch to buffer number `buffer_number`
nvim_buffer_sorter.get_buffers_list()       -- returns an array of ordered buffer ids (can be used by your buffer viewer to display buffers in the correct order)
```
