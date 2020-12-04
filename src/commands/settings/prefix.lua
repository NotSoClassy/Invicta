return {
	name = 'prefix',
	description = 'Change the bot prefix for the guild.',
	example = '[prefix]',
	userPerms = {'administrator'},
	execute = function(msg, args, settings, conn)
		local prefix = table.concat(args, ' ')

		if #prefix == 0 then return msg:reply('The current prefix is `' .. settings.prefix .. '`') end
		if prefix == settings.prefix then return msg:reply('The prefix is already `' .. prefix .. '`') end

		local stmt = conn:prepare('UPDATE guild_settings SET prefix = ? WHERE guild_id = ?;')
		stmt:reset():bind(prefix, msg.guild.id):step()
		stmt:close()

		return msg:reply('The prefix has been changed to `' .. prefix .. '`')
	end
}