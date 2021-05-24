local Queue = {
    storage = {}
}

function Queue.push(key, value)
    if Queue.storage[key] == nil or vim.tbl_isempty(Queue.storage[key]) then
        Queue.storage[key] = {}
    end

    table.insert(Queue.storage[key], value)
end

function Queue.pop(key)
    return table.remove(Queue.storage[key])
end

function Queue.clean(key)
    Queue.storage[key] = nil
end

function Queue.get(key)
    return Queue.storage[key]
end

return Queue
