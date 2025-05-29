local net = require('@lune/net')
local serde = require('@lune/serde')

-- defs
export type RepositoryFile = {
	name: string,
	path: string,
	type: string,
	size: number,
	url: string,
}

-- functions
local function read_file(owner: string, repo: string, path: string, branch: string?): string?
	local response = net.request({
		url = string.format('https://raw.githubusercontent.com/%s/%s/%s/%s', owner, repo, branch or 'main', path),
		headers = {
			['Accept'] = 'application/vnd.github.v3.raw',
			['User-Agent'] = 'Lune-Script',
		},
	})
	if response.statusCode == 404 then return end

	assert(response.ok and response.statusCode == 200, response.statusMessage)
	return response.body
end

local function list_files(owner: string, repo: string, path: string?, branch: string?): { RepositoryFile }
	local response = net.request({
		url = string.format(
			'https://api.github.com/repos/%s/%s/contents/%s%s',
			owner,
			repo,
			path or '',
			branch and ('?ref=' .. branch) or ''
		),
		headers = {
			['Accept'] = 'application/vnd.github.v3+json',
			['User-Agent'] = 'Lune-Script',
		},
	})

	local data = serde.decode('json', response.body)
	assert(type(data) == 'table', `unexpected response from github (expected a table, got {type(data)})`)

	local files: { RepositoryFile } = {}
	for _, item in data do
		if type(item) == 'table' then
			table.insert(files, {
				name = item.name,
				path = item.path,
				type = item.type,
				size = item.size,
				url = item.url,
			})
		end
	end

	return files
end

-- module
return table.freeze {
	read_file = read_file,
	list_files = list_files,
}
