local f = string.format

return {
    name = 'mute-handler-leave',
    description = 'This makes the mute inactive, so once they join back they will be unmuted/muted again.',
	event = 'client.memberJoin',
	hidden = false,
	disabledByDefault = true,
    execute = function(member, _, conn)
        local entry = conn:exec(f('SELECT * FROM mutes WHERE guild_id = "%s" AND user_id = "%s";', member.guild.id, member.id))
		if entry then
			conn:exec('UPDATE mutes SET is_active = 0 WHERE guild_id = "%s" AND user_id = "%s";', member.guild.id, member.id)
		end
    end
}