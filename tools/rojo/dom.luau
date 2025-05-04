-- defs
export type node = {
    ['$path']: string?,
    ['$className']: string?,
    ['$properties']: { [string]: any }?,
    ['$ignoreUnknownInstances']: boolean?,
    [string]: node,
}

-- functions
local function node(class_name: string, properties: { [string]: any }?): node
    return {
        ['$properties'] = properties,
        ['$className'] = class_name,
    }
end
local function get_node(root: node, roblox_path: {string}): node
    for _,name in roblox_path do
        if not root[name] then
            root[name] = {}
        end
        root = root[name]
    end
    return root
end

-- module
return table.freeze {
    get_node = get_node,
    node = node,
}