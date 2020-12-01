local Embed = require 'toast'.Embed
local util = require '../util'

return {
	name = 'settings',
	description = 'Get info on the command settings',
	userPerms = {'manageGuild'},
	execute = function(msg, _, conn)
		local guildSettings = util.getGuildSettings(msg.guild.id, conn)
		guildSettings.guild_id = nil

		local description = ''

		for i, v in pairs(guildSettings) do
			description = description .. i .. ': ' .. v .. '\n'
		end

		return Embed()
			:setTitle('Guild Settings')
			:setDescription(description)
			:setColor('random')
			:send(msg.channel)
	end,
	subCommands = {
		{
			name = 'set',
			description = 'Set the value of a custom command',
			example = '<setting> <value>',
			userPerms = {'manageGuild'},
			execute = function(msg, args, conn, cmd)
				if #args < 2 then return msg:reply('You are missing some required arguments. e.g `' .. cmd.example .. '`') end

				local setting = table.remove(args, 1):lower()
				local value = table.concat(args):gsub('^"', ''):gsub('"$', '')

				if setting == 'guild_id' then return msg:reply('You are not allowed to change this') end

				local success, stmt = pcall(conn.prepare, conn, 'UPDATE guild_settings SET ' .. setting .. ' = ? WHERE guild_id = ?;')

				if not success then return msg:reply('No setting found for `' .. setting .. '`') end

				stmt:reset():bind(value, msg.guild.id):step()
				stmt:close()

				msg:reply('`' .. setting .. '` has been set to `' .. value .. '`')
			end
		}
	}
}