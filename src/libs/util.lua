local discordia = require 'discordia'
local json = require 'json'

local util = {}
local jsonColumns = {
	disabled_commands = true,
	disabled_modules = true
}

local levenshtein = discordia.extensions.string.levenshtein

local function format(tbl)
	if type(tbl) ~= 'table' then return end
	for i, v in pairs(tbl) do
		if jsonColumns[i] then
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

function util.searchMember(msg, query)

	if not query then return end

	local guild = msg.guild
	local members = guild.members
	local user = msg.mentionedUsers.first

	local member = user and guild:getMember(user) or members:get(query) -- try mentioned user or cache lookup by id
	if member then
		return member
	end

	if query:find('#', 1, true) then -- try username#discriminator combination
		local username, discriminator = query:match('(.*)#(%d+)$')
		if username and discriminator then
			member = members:find(function(m) return m.username == username and m.discriminator == discriminator end)
			if member then
				return member
			end
		end
	end

	local distance = math.huge
	local lowered = query:lower()

	for m in members:iter() do
		if m.nickname and m.nickname:lower():find(lowered, 1, true) then
			local d = levenshtein(m.nickname, query)
			if d == 0 then
				return m
			elseif d < distance then
				member = m
				distance = d
			end
		end
		if m.username:lower():find(lowered, 1, true) then
			local d = levenshtein(m.username, query)
			if d == 0 then
				return m
			elseif d < distance then
				member = m
				distance = d
			end
		end
	end

	if member then
		return member
	else
		return nil, string.format('No member found for `%s`', query)
	end

end

function util.canBulkDelete(msg)
	return msg.id > (discordia.Date() - discordia.Time.fromWeeks(2)):toSnowflake()
end

return util