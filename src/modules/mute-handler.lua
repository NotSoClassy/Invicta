local muteUtil = require 'muteUtil'

return {
	name = 'mute-handler',
	description = 'This handles the unmuting',
	event = 'clock.min',
	hidden = false,
	disabledByDefault = false,
	execute = function(guild, settings, conn)
        if not settings.mute_role then return true, 'Missing role' end

        local role = guild:getRole(settings.mute_role)

        if not role then return true, 'Invalid role' end

        local logs = settings.log_channel and guild:getChannel(settings.log_channel)

        local mutes, nrow = conn:exec('SELECT * FROM mutes WHERE is_active = 1 AND end_timestamp <= ' .. os.time()
            .. ' AND guild_id = "' .. guild.id .. '";')

        if not mutes then return end

        for row = 1, nrow do
            local member = guild:getMember(mutes.user_id[row])

            if not member then
                conn:exec('UPDATE mutes SET is_active = 0 WHERE guild_id = "' .. guild.id .. '" '
                    .. 'AND user_id = "' .. mutes.user_id[row] .. '";')
                goto continue
            end

            local success, err = muteUtil.unmute(conn, guild.id, member, role)

            if not success then
                if logs then logs:send('Could not unmute user ' .. member.name .. ' because ' .. err) end
                goto continue
            end

            if logs then logs:send(member.name .. ' has been unmuted') end
            member:send('You have been unmuted in ' .. guild.name .. '!')

            ::continue::
        end
	end
}