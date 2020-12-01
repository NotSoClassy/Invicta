 -- I stole this idea from Yot https://github.com/object-Object/Yot
local loader = require './loader'
local util = require './util'
local handler = {
	modules = {}
}

function handler.load()
	local mods = loader.load('modules')
	for _, mod in ipairs(mods) do
		table.insert(handler.modules, mod)
	end
end

function handler.runEvent(event, guild, conn, ...)
	local settings = util.getGuildSettings(guild.id, conn)
	local success, err = pcall(function(...)
		for _, mod in ipairs(handler.modules) do
			if mod.event == event then
				mod.run(..., settings, conn)
			end
		end
	end, ...)
	if not success then
		guild.client:error('ERROR AT ' .. guild.id .. ': ' .. err)
	end
end

return handler