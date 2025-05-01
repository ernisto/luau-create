local vsc = require('vsc')

local function hide_glob(glob: string)
    vsc.hidden_files[glob] = true
end

return table.freeze {
    hide_glob = hide_glob,
    vsc = vsc,
}