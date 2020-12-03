local json = require 'json'
local util = {}

local jsonColoums = {
	disabled_modules = true,
	disabled_commands = true
}

local function format(tbl)
	if type(tbl) ~= 'table' then return end
	for i, v in pairs(tbl) do
		if jsonColoums[i] then
			tbl[i] = json.parse(v[1])
		else
			tbl[i] = v[1]
		end
	end
	return tbl
end

function util.getGuildSettings(id, conn)
	local settings = conn:exec('SELECT * FROM guild_settings WHERE guild_id=' .. id .. ';', 'k')
	return format(settings)
end

function util.safeSend(chnl, content)
	if not chnl.guild:getMember(chnl.client.user.id):hasPermission('sendMessages') then return end
	return chnl:send(content)
end

return util