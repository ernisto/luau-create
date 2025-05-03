local editor = require('@lib/editor')
local merge = require('@utils/merge')
local simple_dict = require("./simple_dict")
local fs = require('@lune/fs')

-- vars
local ignored_globs = if fs.isFile('.gitignore') then fs.readFile('.gitignore'):split('\n') else {}
local attributes = if fs.isFile('.gitattributes') then simple_dict.decode(fs.readFile('.gitattributes')) else {}

-- functions
local function save()
    fs.writeFile('.gitignore', table.concat(ignored_globs, '\n'))
    fs.writeFile('.gitattributes', simple_dict.encode(attributes))
end

type glob = string
local function ignore_globs(...: glob)
    table.insert(ignored_globs, `# {debug.info(2, 'n')}`)
    for _,glob in {...} do
        if table.find(ignored_globs, glob) then continue end
        table.insert(ignored_globs, glob)
    end
end

type attribute = string
local function set_attribute(glob: glob, ...: attribute)
    attributes[glob] = merge(attributes[glob] or {}, {...})
end

local function setup()
    editor.hide_globs(".gitignore", ".gitattributes")
end

-- module
return table.freeze {
    save = save,
    setup = setup,
    ignore_globs = ignore_globs,
    set_attribute = set_attribute,
}
