local M = {}
local M_private = {}
local M_external = {}

-- public
function M.setup(params)
    M_private.init()

    M_external.update_callback = params.update_callback
end

function M.shift_left()
    local current_buffer_index = M_private.get_current_buffer_index()

    if current_buffer_index < 2 then
        return
    end

    M_private.buffers_list[current_buffer_index], M_private.buffers_list[current_buffer_index - 1] = M_private.buffers_list[current_buffer_index - 1], M_private.buffers_list[current_buffer_index]

    M_external.update_status()
end

function M.shift_right()
    local current_buffer_index = M_private.get_current_buffer_index()

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
    current_buffer_index = M_private.get_current_buffer_index()

    next_buffer_index = current_buffer_index + 1

    if next_buffer_index > M_private.get_buffers_list_size() then
        return
    end

    M_private.go_to(next_buffer_index)
end

function M.go_prev()
    current_buffer_index = M_private.get_current_buffer_index()

    prev_buffer_index = current_buffer_index - 1

    if prev_buffer_index < 1 then
        return
    end

    M_private.go_to(prev_buffer_index)
end

function M.go_to(buffer_index)
    if buffer_index < 1 or buffer_index > M_private.get_buffers_list_size() then
        return
    end

    M_private.go_to(buffer_index)
end

function M.get_buffers_list()
    -- vim.print(table.concat(M_private.buffers_list, " "))

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

function M_private.get_current_buffer_index()
    local current_buffer_id = M_external.get_current_buffer_id()

    for i,v in pairs(M_private.buffers_list) do
        if v == current_buffer_id then
            return i
        end
    end

    return 0
end

function M_private.on_buffer_add(buffer_id)
    table.insert(M_private.buffers_list, buffer_id)
end

function M_private.on_buffer_delete(buffer_id)
    for i,v in pairs(M_private.buffers_list) do
        if M_private.buffers_list[i] == buffer_id then
            table.remove(M_private.buffers_list, i)
            break
        end
    end
end

function M_private.go_to(buffer_index)
    vim.cmd('buffer '..M_private.buffers_list[buffer_index])
end

-- external (nvim api dependent)
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

function M_external.update_status()
    if not M_external.update_callback then
        return
    end

    M_external.update_callback()
end

return M
