local fs = require('@lune/fs')

-- vars
local ignored_globs = if fs.isFile('.gitignore') then fs.readFile('.gitignore'):split('\n') else {}

-- functions
local function save()
    fs.writeFile('.gitignore', table.concat(ignored_globs, '\n'))
end

type glob = string
local function ignore_globs(...: glob)
    table.insert(ignored_globs, `# {debug.info(2, 'n')}`)
    for _,glob in {...} do
        if table.find(ignored_globs, glob) then continue end
        table.insert(ignored_globs, glob)
    end
end

-- module
return table.freeze {
    save = save,
    ignore_globs = ignore_globs
}
