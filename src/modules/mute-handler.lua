local util = require 'muteUtil'
local f = string.format

return {
	name = 'mute-handler',
	description = 'This handles the unmuting',
	event = 'mute.handler',
	hidden = false,
	disabledByDefault = true,
	execute = function(guild, settings, conn)
        if not settings.mute_role then return true, 'Missing role' end

        local role = guild:getRole(settings.mute_role)

        if not role then return true, 'Invalid role' end

        local logs = settings.log_channel and guild:getChannel(settings.log_channel)

        local mutes, nrow = conn:exec(f('SELECT * FROM mutes WHERE is_active = 1 AND end_timestamp <= %i AND guild_id = "%s";', os.time(), guild.id))

        if not mutes then return end

        for row = 1, nrow do
            local id = mutes.user_id[row]
            local member = guild:getMember(id)

            if not member then
                conn:exec(f('UPDATE mutes SET is_active = 0 WHERE guild_id = "%s" AND user_id = "%s";', guild.id, id))
                goto continue
            end

            local success, err = util.unmute(conn, guild.id, member, role)

            if not success then
                util.muteEmbed(logs, 'Could not unmute user ' .. member.name .. ' because ' .. err, 'RED')
                goto continue
            end

            util.muteEmbed(logs, member.name .. ' has been unmuted', 'YELLOW')
            member:send('You have been unmuted in ' .. guild.name .. '!')

            ::continue::
        end
	end
}