local loader = require 'loader'
local json = require 'json'
local util = require 'util'

local format = string.format

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

local function update(conn, what, id)
	local stmt = conn:prepare('UPDATE guild_settings SET disabled_modules = ? WHERE guild_id = ?;')
	stmt:reset():bind(what, id):step()
	stmt:close()
end

function handler.enable(mod, guild, settings, conn)
	if not settings.disabled_modules[mod] then return end

	local disabled = settings.disabled_modules
	settings.disabled_modules[mod] = nil

	local encoded = json.encode(disabled)
	update(conn, encoded, guild.id)
end

function handler.disable(mod, guild, settings, conn)
	if settings.disabled_modules[mod] then return end

	local disabled = settings.disabled_modules
	settings.disabled_modules[mod] = true

	local encoded = json.encode(disabled)
	update(conn, encoded, guild.id)
end

function handler.runEvent(event, guild, conn, ...)
	local settings = util.getGuildSettings(guild.id, conn)
	local success, err = pcall(function(...)
		for _, mod in ipairs(handler.modules) do
			if mod.event == event and not settings.disabled_modules[mod.name] then
				local shouldDisable, reason = mod.execute(..., settings, conn)
				if shouldDisable == true then
					handler.disable(mod.name, guild, settings, conn)
					local logs = settings.log_channel and guild:getChannel(settings.log_channel)
					local err = format('Module `%s` was disabled, Error: %s', mod.name, reason)
					if not logs then
						guild.owner:send(err)
					else
						logs:send(err)
					end
				end
			end
		end
	end, ...)
	if not success then
		guild.client:error('ERROR AT ' .. guild.id .. ': ' .. err)
	end
end

return handler