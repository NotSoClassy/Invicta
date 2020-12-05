local moduleHandler = require '../../moduleHandler'
local toast = require 'toast'
local json = require 'json'

local concat, remove = table.concat, table.remove
local perms = {'administrator'}

local blacklistedCommands = {
	settings = true
}

local settingColoums = {
	log_channel = {
		name = 'log_channel',
		description = 'The channel where logs are sent to.',
		args = '<channel id>'
	},
	welcome_channel = {
		name = 'welcome_channel',
		description = 'Welcomes/Goodbyes people who join/leave. (You also need to enable the modules for this to work)',
		args = '<channel id>'
	},
	auto_role = {
		name = 'auto_role',
		description = 'Gives someone a role when they join. (You also need to enable the module for this to work)',
		args = '<role id>'
	},
	prefix = {
		name = 'prefix',
		description = 'The prefix for the bot. (The prefix command is better)',
		args = '<prefix>'
	}
}

local function updateSettings(where, what, id, conn)
	local stmt = conn:prepare('UPDATE guild_settings SET ' .. where .. ' = ? WHERE guild_id = ?;')
	stmt:reset():bind(what, id):step()
	stmt:close()
end

return {
	name = 'settings',
	description = 'List of customizable settings.',
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
			local description = ''

			for _, v in pairs(settingColoums) do
				description = description .. v.name .. ' : ' .. tostring(settings[v.name]) .. '\n'
			end

			return toast.Embed()
				:setTitle('Settings')
				:setDescription(description)
				:setColor('GREEN')
				:send(msg.channel)
		end
	end,
	subCommands = {
		{
			name = 'set',
			description = 'Change the value of a setting.',
			example = '<setting> <value>',
			userPerms = perms,
			execute = function(msg, args, _, conn)
				if #args < 2 then return msg:reply('Missing required arguments (use help command for more info)') end

				local query = remove(args, 1):lower()
				local value = concat(args, ' ')

				if not settingColoums[query] then return msg:reply('No setting found for `' .. query .. '`') end

				updateSettings(query, value, msg.guild.id, conn)

				return msg:reply('`' .. query .. '` has been set to `' .. value .. '`')
			end
		},
		{
			name = 'modules',
			description = 'A list of all modules.',
			example = '[module]',
			execute = function(msg, args, settings)
				local query = concat(args, ' '):lower()
				local mod = moduleHandler.moduleNames[query]

				if mod then
					return toast.Embed()
						:setTitle(mod.name)
						:setDescription(mod.description)
						:addField('Value:', settings.disabled_modules[mod.name] and 'disabled' or 'enabled')
						:setColor('GREEN')
						:send(msg.channel)
				else
					local description = ''

					for _, mod in pairs(moduleHandler.moduleNames) do
						if not mod.hidden then
							description = description .. mod.name .. ' : ' .. (settings.disabled_modules[mod.name] and 'disabled' or 'enabled') .. '\n'
						end
					end

					return toast.Embed()
						:setTitle('Modules')
						:setDescription(description)
						:setColor('GREEN')
						:send(msg.channel)
				end
			end,
			subCommands = {
				{
					name = 'enable',
					description = 'Enable a disabled module.',
					example = '<module>',
					userPerms = perms,
					execute = function(msg, args, settings, conn)
						local query = concat(args, ' '):lower()

						if not moduleHandler.moduleNames[query] then return msg:reply('No module found for `' .. query .. '`') end

						moduleHandler.enable(query, msg.guild, settings, conn)
						return msg:reply('`' .. query .. '` has been enabled')
					end
				},
				{
					name = 'disable',
					description = 'Disable a enabled module.',
					example = '<module>',
					userPerms = perms,
					execute = function(msg, args, settings, conn)
						local query = concat(args, ' '):lower()

						if not moduleHandler.moduleNames[query] then return msg:reply('No module found for `' .. query .. '`') end

						moduleHandler.disable(query, msg.guild, settings, conn)
						return msg:reply('`' .. query .. '` has been disabled')
					end
				}
			}
		},
		{
			name = 'commands',
			description = 'A list of commands and if its disabled or enabled.',
			execute = function(msg, _, settings)
				local description = ''

				for _, v in ipairs(msg.client.commands) do
					if not v.visble then
						description = description .. v.name .. ' : ' .. (settings.disabled_commands[v.name] and 'disabled' or 'enabled') .. '\n'
					end
				end

				return toast.Embed()
					:setTitle('Modules')
					:setDescription(description)
					:setFooter('If you want info on a command just use the help command')
					:setColor('GREEN')
					:send(msg.channel)
			end,
			subCommands = {
				{
					name = 'enable',
					description = 'Enables a disabled command.',
					example = '<command (not an alias)>',
					userPerms = perms,
					execute = function(msg, args, settings, conn)
						local query = concat(args, ' '):lower()
						local command

						for _, v in ipairs(msg.client.commands) do
							if v.name == query then
								command = v
								break
							end
						end

						if not settings.disabled_commands[query] then return msg:reply('`' .. query .. '` has been enabled') end
						if not command then return msg:reply('No command found for `' .. query .. '`') end

						settings.disabled_commands[command.name] = nil

						updateSettings('disabled_commands', json.encode(settings.disabled_commands), msg.guild.id, conn)
						return msg:reply('`' .. command.name .. '` has been enabled')
					end
				},
				{
					name = 'disable',
					description = 'Disables a enabled command.',
					example = '<command (not an alias)>',
					userPerms = perms,
					execute = function(msg, args, settings, conn)
						local query = concat(args, ' '):lower()
						local command

						if blacklistedCommands[query] then return msg:reply('You aren\'t allow to disable this command') end

						for _, v in ipairs(msg.client.commands) do
							if v.name == query then
								command = v
								break
							end
						end

						if settings.disabled_commands[query] then return msg:reply('`' .. query .. '` has been disabled') end
						if not command then return msg:reply('No command found for `' .. query .. '`') end

						settings.disabled_commands[command.name] = true

						updateSettings('disabled_commands', json.encode(settings.disabled_commands), msg.guild.id, conn)
						return msg:reply('`' .. command.name .. '` has been disabled')
					end
				}
			}
		}
	}
}