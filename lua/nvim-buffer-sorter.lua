local M = {}
local M_private = {}
local M_external = {}

-- public
function M.setup(params)
    M_private.init()

    M_external.update_callback = params.update_callback
end

function M.shift_left()
    local current_buffer_index = M_private.get_buffer_index(M_external.get_current_buffer_id())

    if current_buffer_index < 2 then
        return
    end

    M_private.buffers_list[current_buffer_index], M_private.buffers_list[current_buffer_index - 1] = M_private.buffers_list[current_buffer_index - 1], M_private.buffers_list[current_buffer_index]

    M_external.update_status()
end

function M.shift_right()
    local current_buffer_index = M_private.get_buffer_index(M_external.get_current_buffer_id())

    if current_buffer_index == 0 then
        return
    end

    if current_buffer_index >= M_private.get_buffers_list_size() then
        return
    end

    M_private.buffers_list[current_buffer_index], M_private.buffers_list[current_buffer_index + 1] = M_private.buffers_list[current_buffer_index + 1], M_private.buffers_list[current_buffer_index]

    M_external.update_status()
end

function M.go_next()
    local current_buffer_index = M_private.get_buffer_index(M_external.get_current_buffer_id())

    local next_buffer_index = current_buffer_index + 1

    while true do
        if next_buffer_index > M_private.get_buffers_list_size() then
            return
        end

        if M_private.go_to(next_buffer_index) then
            return
        else
            next_buffer_index = next_buffer_index + 1
        end
    end
end

function M.go_prev()
    local current_buffer_index = M_private.get_buffer_index(M_external.get_current_buffer_id())

    local prev_buffer_index = current_buffer_index - 1

    while true do
        if prev_buffer_index < 1 then
            return
        end

        if M_private.go_to(prev_buffer_index) then
            return
        else
            prev_buffer_index = prev_buffer_index - 1
        end
    end
end

function M.go_to(buffer_index)
    if buffer_index < 1 or buffer_index > M_private.get_buffers_list_size() then
        return
    end

    M_private.go_to(buffer_index)
end

function M.get_buffers_list()
    return M_private.buffers_list
end

-- private
M_private.buffers_list = {}

function M_private.init()
    M_private.buffers_list = M_external.get_buffers_list()

    M_external.create_autocmds()
end

function M_private.get_buffers_list_size()
    return table.getn(M_private.buffers_list)
end

function M_private.get_buffer_index(buffer_id)
    for i,v in pairs(M_private.buffers_list) do
        if v == buffer_id then
            return i
        end
    end

    return 0
end

function M_private.on_buffer_add(buffer_id)
    table.insert(M_private.buffers_list, buffer_id)
end

function M_private.on_buffer_delete(buffer_id)
    local current_buffer_index = M_private.get_buffer_index(buffer_id)

    if current_buffer_index == 0 then
        return
    end

    table.remove(M_private.buffers_list, current_buffer_index)
end

function M_private.go_to(buffer_index)
    return M_external.go_to(M_private.buffers_list[buffer_index])
end

-- external (vim API dependent)
function M_external.get_buffers_list()
    return vim.api.nvim_list_bufs()
end

function M_external.get_current_buffer_id()
    return vim.api.nvim_get_current_buf()
end

function M_external.create_autocmds()
    vim.api.nvim_create_autocmd({'BufAdd'}, {
        pattern = {'*'},
        callback = function(ev)
            M_private.on_buffer_add(ev.buf)
        end
    })

    vim.api.nvim_create_autocmd({"BufDelete"}, {
        pattern = { "*" },
        callback = function(ev)
            M_private.on_buffer_delete(ev.buf)
        end
    })
end

function M_external.go_to(buffer_id)
    local status, err = pcall(function()vim.cmd('buffer '..buffer_id)end)

    if err and string.match(err, 'Buffer %d+ does not exist') then
        M_private.on_buffer_delete(buffer_id)

        return false
    end

    return true
end

function M_external.update_status()
    if not M_external.update_callback then
        return
    end

    M_external.update_callback()
end

return M
