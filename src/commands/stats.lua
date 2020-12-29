local toast = require 'toast'
local ffi = require 'ffi'

local osInfo = string.format('Hosted on %s %s using %s', ffi.os, ffi.arch, _VERSION)

return {
	name = 'stats',
	description = 'Get info on the bot.',
	execute = function(msg)
		local client = msg.client
		return toast.Embed()
			:setTitle('Info on ' .. client.user.name)
			:addField('Guilds:', tostring(#client.guilds), true)
			:addField('Shards:', (tostring(client.shardCount) or '1') ..' / '.. (tostring(client.totalShardCount) or '1'), true)
			:addField('Uptime:', toast.util.formatLongfunction(math.floor(msg.client.uptime:getTime():toMilliseconds())), true)
			:addField('Other:', osInfo)
			:setFooter(client.user.name .. ' has ' .. #client.commands .. ' commands')
			:setColor('DARK_AQUA')
			:send(msg.channel)
	end
}