local net = require('@lune/net')
local serde = require('@lune/serde')

-- defs
local expected_error_codes = { 403, 429 }
export type GitHubRelease = {
	tagName: string,
	name: string,
	body: string,
	htmlUrl: string,
	createdAt: string,
	publishedAt: string,
}

-- functions
local function get_latest_release(owner: string, repo: string): GitHubRelease?
	-- if 'lune crash when request during a require' then return end

	local response = net.request({
		url = `https://api.github.com/repos/{owner}/{repo}/releases/latest`,
		headers = {
			['Accept'] = 'application/vnd.github.v3+json',
			['User-Agent'] = 'Lune-Script',
		},
	})

	if response.statusCode ~= 200 and table.find(expected_error_codes, response.statusCode) then
		warn(response.statusMessage)
		return
	elseif response.statusCode ~= 200 then
		error(response.statusMessage)
	end

	local data = serde.decode('json', response.body)
	return {
		tagName = data.tag_name,
		name = data.name,
		body = data.body,
		htmlUrl = data.html_url,
		createdAt = data.created_at,
		publishedAt = data.published_at,
	}
end

type version = string
local function get_latest_release_version(owner: string, repo: string): version
	local release = get_latest_release(owner, repo)
	assert(release, `couldnt possible get a version for package {owner}/{repo}`)

	return release.tagName:sub(2)
end

-- module
return table.freeze {
	get_latest_version = get_latest_release_version,
	get_latest = get_latest_release,
}
