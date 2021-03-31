local moduleHandler = require '../../moduleHandler'
local toast = require 'toast'
local json = require 'json'

local perms = {'administrator'}

local blacklistedCommands = {
	settings = true,
	eval = true
}

local settingColumns = {
	log_channel = {
		name = 'log_channel',
		description = 'The channel where logs are sent to.',
		args = '<channel id>',
		modules = {'message-delete-log', 'message-edit-log'}
	},
	welcome_channel = {
		name = 'welcome_channel',
		description = 'Welcomes/Goodbyes people who join/leave.',
		args = '<channel id>',
		modules = {'member-welcome', 'member-goodbye'}
	},
	auto_role = {
		name = 'auto_role',
		description = 'Gives someone a role when they join.',
		args = '<role id>',
		modules = {'member-auto-role'}
	},
	mute_role = {
		name = 'mute_role',
		description = 'Set the role that is given when the mute command is ran.',
		args = '<role id>',
		modules = {'mute-handler', 'mute-handler-leave', 'mute-handler-join'}
	},
	prefix = {
		name = 'prefix',
		description = 'The prefix for the bot. (The prefix command is better)',
		args = '<prefix>',
		modules = {}
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
	args = {{ name = 'setting', value = 'string' }},
	aliases = {'config'},
	execute = function(msg, args, settings)
		local query = args.setting
		local coloum = settingColumns[query]

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

			for _, v in pairs(settingColumns) do
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
			userPerms = perms,
			args = {
				{
					name = 'setting',
					value = 'string',
					required = true
				},
				{
					name = 'value',
					value = 'string',
					required = true
				}
			},
			execute = function(msg, args, settings, conn)
				local query = args.setting
				local value = args.value

				if not settingColumns[query] then return msg:reply('No setting found for `' .. query .. '`') end

				updateSettings(query, value, msg.guild.id, conn)

				for _, v in pairs(settingColumns[query].modules) do
					settings.disabled_modules[v] = nil
				end

				updateSettings('disabled_modules', json.encode(settings.disabled_modules), msg.guild.id, conn)

				return msg:reply('`' .. query .. '` has been set to `' .. value .. '`')
			end
		},
		{
			name = 'modules',
			description = 'A list of all modules.',
			args = {{ name = 'module', value = 'string' }},
			execute = function(msg, args, settings)
				local query = args.module
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

					for _, v in pairs(moduleHandler.moduleNames) do
						if not v.hidden then
							description = description .. v.name .. ' : ' .. (settings.disabled_modules[v.name] and 'disabled' or 'enabled')
								.. '\n'
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
					args = {{ name = 'module', value = 'string' }},
					execute = function(msg, args, settings, conn)
						local query = args.module

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
					args = {{ name = 'module', value = 'string' }},
					execute = function(msg, args, settings, conn)
						local query = args.module

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
					if not v.hidden then
						description = description .. v.name .. ' : ' .. (settings.disabled_commands[v.name] and 'disabled' or 'enabled')
							.. '\n'
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
					args = {{ name = 'command', value = 'string' }},
					execute = function(msg, args, settings, conn)
						local query = args.command
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
					args = {{ name = 'command', value = 'string' }},
					execute = function(msg, args, settings, conn)
						local query = args.command
						local command

						if blacklistedCommands[query] then return msg:reply('You aren\'t allowed to disable this command') end

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