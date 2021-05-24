local Dir = {}

-- @param path string
-- @returns table
function Dir.getFilesAsModules(path, modulepath)
    if vim.endswith(modulepath, '.') then
        error('[FileSystem] Cannot have `modulepath` end with `.`')
    end

    local files = {}
    local fs, fail = vim.loop.fs_scandir(path)
    if fail then
        error(fail)
    end

    local name, type = vim.loop.fs_scandir_next(fs)
    while name ~= nil do
        if type == 'file' then
            local namelist = vim.split(name, '.', true)
            local module = namelist[1]
            table.insert(files, modulepath .. '.' .. module)
        end

        -- next iterator
        name, type = vim.loop.fs_scandir_next(fs)
    end

    return files
end

return Dir
