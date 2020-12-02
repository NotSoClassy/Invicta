local commandHandler = require './commandHandler'
local moduleHandler = require './moduleHandler'
local discordia = require 'discordia'
local loader = require './loader'
local config = require './config'
local toast = require 'toast'
local util = require './util'
local sql = require 'sqlite3'

local conn = sql.open 'invicta.db'
local clock = discordia.Clock()
local client = toast.Client {
	prefix = config.prefix,
	commandHandler = function(msg)
		return commandHandler(msg, conn)
	end,
	defaultHelp = true
}

moduleHandler.load()

local function setupGuild(id)
	local disabled = {}
	for _, mod in pairs(moduleHandler.modules) do
		if mod.disabledByDefault then
			disabled[mod.name] = true
		end
	end
	local encoded = json.encode(disabled)
	conn:exec('INSERT INTO guild_settings (guild_id, disabled_modules) VALUES (\''..id..'\', \'' .. encoded .. '\')')
end

-- Events

clock:on('min', function()
	for guild in client.guilds:iter() do
		moduleHandler.runEvent('clock.min', guild, conn, guild)
	end
end)

client:on('ready', function()
	client:setGame(config.prefix .. 'help')
end)

client:on('guildCreate', function(guild)
	if not util.getGuildSettings(guild.id, conn) then
		setupGuild(guild.id)
	end
end)

client:on('messageUpdate', function(msg)
	if not msg.guild then return end
	moduleHandler.runEvent('client.messageUpdate', msg.guild, conn, msg)
end)

client:on('messageDelete', function(msg)
	if not msg.guild then return end
	moduleHandler.runEvent('client.messageDelete', msg.guild, conn, msg)
end)

-- Commands

for _, command in ipairs(loader.load('commands')) do
	client:addCommand(command)
end

client:login(config.token)