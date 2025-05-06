export type license_name = 'BoostSoftWare' | 'Apache' | 'MIT' | 'GNU'
export type license = {
    content: string, -- placeholders: ${program} ${year} ${host}
    permissions: {string},
    limitations: {string},
    conditions: {string},
}

-- module
return table.freeze {
    BoostSoftWare = require('@self/BoostSoftWare'),
    Apache = require('@self/Apache'),
    MIT = require('@self/MIT'),
    GNU = require('@self/GNU'),
} :: { [license_name]: license }