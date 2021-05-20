local Queue = {
    storage = {}
}

function Queue.push(key, value)
    if Queue.storage[key] == nil then
        Queue.storage[key] = {}
    end
    table.insert(Queue.storage[key], value)
end

function Queue.pop(key)
    return table.remove(Queue.storage[key])
end

return Queue
