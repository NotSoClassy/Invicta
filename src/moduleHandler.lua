local loader = require 'loader'
local json = require 'json'
local util = require 'util'

local handler = {
	modules = {},
	moduleNames = {}
}

function handler.load()
	local mods = loader.load('modules')
	for _, mod in ipairs(mods) do
		table.insert(handler.modules, mod)
		handler.moduleNames[mod.name] = {name = mod.name, description = mod.description}
	end
end

function handler.enable(mod, guild, settings, conn)
	if not settings.disabled_modules[mod] then return end

	local disabled = settings.disabled_modules
	settings.disabled_modules[mod] = nil

	local encoded = json.encode(disabled)
	local stmt = conn:prepare('UPDATE guild_settings SET disabled_modules = ? WHERE guild_id = ?;')
	stmt:reset():bind(encoded, guild.id):step()
	stmt:close()
end

function handler.disable(mod, guild, settings, conn)
	if settings.disabled_modules[mod] then return end

	local disabled = settings.disabled_modules
	settings.disabled_modules[mod] = true

	local encoded = json.encode(disabled)
	local stmt = conn:prepare('UPDATE guild_settings SET disabled_modules = ? WHERE guild_id = ?;')
	stmt:reset():bind(encoded, guild.id):step()
	stmt:close()
end

function handler.runEvent(event, guild, conn, ...)
	local settings = util.getGuildSettings(guild.id, conn)
	local success, err = pcall(function(...)
		for _, mod in ipairs(handler.modules) do
			if mod.event == event and not settings.disabled_modules[mod.name] then
				mod.execute(..., settings, conn)
			end
		end
	end, ...)
	if not success then
		guild.client:error('ERROR AT ' .. guild.id .. ': ' .. err)
	end
end

return handler