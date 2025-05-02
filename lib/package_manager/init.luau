
local wally = require('./wally')
local pesde = require('./pesde')
local npm = require('./npm')

-- functions
local function save()
    npm.save()
    wally.save()
    pesde.save()
end

-- module
return table.freeze {
    save = save
}