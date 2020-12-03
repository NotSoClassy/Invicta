local util = require '../util'

return {
	name = 'member-goodbye',
	description = 'Says goodbye to members that leave.',
	event = 'client.memberLeave',
	disabledByDefault = false,
	execute = function(member, settings)
		if not settings.welcome_channel then return end

		local chnl = member.guild:getChannel(settings.welcome_channel)

		if not chnl then return end

		return util.safeSend(chnl, 'Goodbye ' .. member.tag .. ', sad to see you go.')
	end
}