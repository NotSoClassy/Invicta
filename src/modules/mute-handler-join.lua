local muteUtil = require 'muteUtil'

return {
	name = 'mute-handler-join',
	description = 'This reactives the mute, so when they join back they will get muted/unmuted.',
	event = 'client.memberLeave',
	hidden = false,
	disabledByDefault = false,
	execute = function(member, settings, conn)
        if not settings.mute_role then return true, 'Missing role' end

        local role = member.guild:getRole(settings.mute_role)

        if not role then return true, 'Invalid role' end

        local logs = settings.log_channel and member.guild:getChannel(settings.log_channel)

		local entry = conn:exec('SELECT * FROM mutes WHERE guild_id = "'..member.guild.id..'"'
			.. 'AND user_id = "'..member.id..'";')
		if entry then
			local t = entry.end_timestamp[1]
			if t <= os.time() then
				muteUtil.unmute(conn, member.guild.id, member, role)
				if logs then logs:send(member.name .. ' has been unmuted') end
			else
				member:addRole(role)
			end
		end
	end
}