local moduleHandler = require './moduleHandler'
local discordia = require 'discordia'
local config = require './config'
local loader = require 'loader'
local toast = require 'toast'
local util = require 'util'
local json = require 'json'
local sql = require 'sqlite3'

local conn = sql.open 'invicta.db'
--local clock = discordia.Clock()

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

local client = toast.Client {
	prefix = function(msg)
		if not util.getGuildSettings(msg.guild.id, conn) then
			setupGuild(msg.guild.id)
		end
		return util.getGuildSettings(msg.guild.id, conn).prefix
	end,
	customParams = { function(msg)
		return util.getGuildSettings(msg.guild.id, conn)
	end, conn}
}

moduleHandler.load()

-- Events

--[[
clock:on('min', function()
	for guild in client.guilds:iter() do
		moduleHandler.runEvent('clock.min', guild, conn, guild)
	end
end)
]]

client:on('ready', function()
	client:setGame(config.prefix .. 'help')
end)

client:on('guildCreate', function(guild)
	if not util.getGuildSettings(guild.id, conn) then
		setupGuild(guild.id)
	end
end)

client:on('memberJoin', function(member)
	moduleHandler.runEvent('client.memberJoin', member.guild, conn, member)
end)

client:on('memberLeave', function(member)
	moduleHandler.runEvent('client.memberLeave', member.guild, conn, member)
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