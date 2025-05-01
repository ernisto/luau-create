local fs = require('@lune/fs')

local files = {}

local function add_file(path: string, content: string)
    assert(files[path] == nil, `path {path} already is being used`)
    files[path] = content
end

local function build()
    for path, content in files do

        local ancestors = path:split('/')
        for i = 1, #ancestors-1 do
            local depth_path = table.concat(ancestors, '/', 1, i)
            if not fs.isDir(depth_path) then
                fs.writeDir(depth_path)
            end
        end
        fs.writeFile(path, content)
    end
end

return table.freeze {
    add = add_file,
    build = build,
}