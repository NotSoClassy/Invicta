local toast = require 'toast'
local moduleHandler = require '../../moduleHandler'

local concat, remove = table.concat, table.remove
local perms = {'administrator'}

local settingColoums = {
	log_channel = {
		name = 'log_channel',
		description = 'The channel where logs are sent to',
		args = '<channel id>'
	},
	prefix = {
		name = 'prefix',
		description = 'The prefix for the bot (The prefix command is better)',
		args = '<prefix>'
	}
}

local function showSettings(settings)

	local description = ''

	for _, v in pairs(settingColoums) do
		description = description .. v.name .. ' : ' .. tostring(settings[v.name]) .. '\n'
	end

	return toast.Embed()
		:setTitle('Settings')
		:setDescription(description)
		:setColor('GREEN')
end

local function showModules(settings)

	local description = ''

	for _, mod in pairs(moduleHandler.moduleNames) do
		description = description .. mod.name .. ' : ' .. (settings.disabled_modules[mod.name] and 'Disabled' or 'Enabled') .. '\n'
	end

	return toast.Embed()
		:setTitle('Modules')
		:setDescription(description)
		:setColor('GREEN')
end

return {
	name = 'settings',
	description = 'List of customizable settings',
	example = '[setting]',
	execute = function(msg, args, settings)
		local query = concat(args, ' '):lower()
		local coloum = settingColoums[query]

		if coloum then
			return toast.Embed()
				:setTitle(coloum.name)
				:setDescription(coloum.description)
				:addField('Value:', settings[coloum.name])
				:setFooter('Arguments for setting: ' .. coloum.args)
				:setColor('GREEN')
				:send(msg.channel)
		else
			return showSettings(settings):send(msg.channel)
		end
	end,
	subCommands = {
		{
			name = 'set',
			description = 'Change the value of a setting',
			example = '<setting> <value>',
			userPerms = perms,
			execute = function(msg, args, _, conn)
				if #args < 2 then return msg:reply('Missing required arguments (use help command for more info)') end

				local query = remove(args, 1):lower()
				local value = concat(args, ' ')

				if not settingColoums[query] then return msg:reply('No setting found for `' .. query .. '`') end

				local stmt = conn:prepare('UPDATE guild_settings SET ' .. query .. ' = ? WHERE guild_id = ?;')
				stmt:reset():bind(value, msg.guild.id):step()
				stmt:close()

				msg:reply('`' .. query .. '` has been set to `' .. value .. '`')
			end
		},
		{
			name = 'modules',
			description = 'A list of all modules',
			example = '[module]',
			execute = function(msg, args, settings)
				local query = concat(args, ' '):lower()
				local mod = moduleHandler.moduleNames[query]

				if mod then
					return toast.Embed()
						:setTitle(mod.name)
						:setDescription(mod.description)
						:addField('Value:', settings.disabled_modules[mod.name] and 'Disabled' or 'Enabled')
						:setColor('GREEN')
						:send(msg.channel)
				else
					return showModules(settings):send(msg.channel)
				end
			end,
			subCommands = {
				{
					name = 'enable',
					description = 'Enable a disabled module',
					example = '<module>',
					userPerms = perms,
					execute = function(msg, args, settings, conn)
						local query = concat(args, ' '):lower()

						if not moduleHandler.moduleNames[query] then return msg:reply('No module found for `' .. query .. '`') end

						moduleHandler.enable(query, msg.guild, settings, conn)
						msg:reply('`' .. query .. '` has been enabled')
					end
				},
				{
					name = 'disable',
					description = 'Disable a enabled module',
					example = '<module>',
					userPerms = perms,
					execute = function(msg, args, settings, conn)
						local query = concat(args, ' '):lower()

						if not moduleHandler.moduleNames[query] then return msg:reply('No module found for `' .. query .. '`') end

						moduleHandler.disable(query, msg.guild, settings, conn)
						msg:reply('`' .. query .. '` has been disabled')
					end
				}
			}
		}
	}
}