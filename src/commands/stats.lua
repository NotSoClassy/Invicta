local toast = require 'toast'

return {
	name = 'stats',
	description = 'Get info on the bot.',
	execute = function(msg)
		local client = msg.client
		return toast.Embed()
			:setTitle('Info on ' .. client.user.name)
			:addField('Guilds:', tostring(#client.guilds), true)
			:addField('Shards:', (tostring(client.shardCount) or '1') ..' / '.. (tostring(client.totalShardCount) or '1'), true)
			:addField('Uptime:', toast.util.formatLong(math.floor(msg.client.uptime:getTime():toMilliseconds())), true)
			:addField('Other:', 'This bot is written in ' .. _VERSION)
			:setFooter(client.user.name .. ' has ' .. #client.commands .. ' commands')
			:setColor('DARK_AQUA')
			:send(msg.channel)
	end
}