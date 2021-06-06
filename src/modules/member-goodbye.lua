local util = require 'util'

return {
	name = 'member-goodbye',
	description = 'Says goodbye to members that leave.',
	event = 'client.memberLeave',
	hidden = false,
	disabledByDefault = true,
	execute = function(member, settings)
		if not settings.welcome_channel then return true, 'Missing channel' end

		local chnl = member.guild:getChannel(settings.welcome_channel)

		if not chnl then return true, 'Invalid channel' end

		local success, err = util.safeSend(chnl, 'Goodbye ' .. member.tag .. ', sad to see you go.')
		return not success, err
	end
}