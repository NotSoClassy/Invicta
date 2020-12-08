local util = require 'util'

return {
	name = 'member-welcome',
	description = 'Welcomes members when they join.',
	event = 'client.memberJoin',
	hidden = false,
	disabledByDefault = true,
	execute = function(member, settings)
		if not settings.welcome_channel then return end

		local chnl = member.guild:getChannel(settings.welcome_channel)

		if not chnl then return end

		return util.safeSend(chnl, 'Welcome to ' .. member.guild.name .. ', ' .. member.tag .. '!')
	end
}