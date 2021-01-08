local moduleHandler = require './moduleHandler'
local discordia = require 'discordia'
local toast = require 'toast'
local json = require 'json'
local util = require 'util'
local rex = require 'rex'

local class, enums = discordia.class, discordia.enums

local function search(tbl, q)
	for i, v in pairs(tbl) do
		if q == v then
		   return i
		end
	 end
end

local function findSub(tbl, q)
	if not q then return end
	for _, v in pairs(tbl) do
		if v.name == q or search(v.aliases, q) then
			return v
		end
	end
end

local function setupGuild(id, conn)
	local disabled = {}
	for _, mod in pairs(moduleHandler.modules) do
		if mod.disabledByDefault then
			disabled[mod.name] = true
		end
	end
	local encoded = json.encode(disabled)
	conn:exec('INSERT INTO guild_settings (guild_id, disabled_modules) VALUES (\''..id..'\', \'' .. encoded .. '\')')
end

return function(msg, conn)

	if msg.author.bot then return end

	if msg.guild and not msg.guild:getMember(msg.client.user.id):hasPermission(enums.permission.sendMessages) then
	   return
	end

	local self = msg.client
	local _, settings = pcall(util.getGuildSettings, msg.guild.id, conn)
	local pre = settings and settings.prefix or self._prefix[1]

	if msg.guild and not settings then
		setupGuild(msg.guild.id, conn)
		settings = util.getGuildSettings(msg.guild.id, conn)
		pre = settings.prefix
	end

	if msg.content == '<@!' .. msg.client.user.id .. '>' then
		return msg:reply('My prefix is `' .. pre .. '`')
	end

	local prefix = msg.content:find(pre, 1, true) == 1 and pre

	if not prefix then return end

	local cmd, msgArg = string.match(msg.content:sub(#pre + 1), '^(%S+)%s*(.*)')

	if not cmd then return end

	cmd = cmd:lower()

	local args = {}
	for arg in string.gmatch(msgArg, '%S+') do
	   table.insert(args, arg)
	end

	local command

	for _, v in pairs(self._commands) do
		if v.name == cmd or search(v.aliases, cmd) then
			command = v
			break
		end
	end

	if not command then

		local cc = settings.custom_commands[cmd]

		if not cc then return end

		local author = msg.author
		local guild = msg.guild

		local vars = {
			author = { name = author.name, mentionString = author.mentionString, id = author.id, tag = author.tag},
			guild = { name = guild.name, id = guild.id },
			pp = 'pp'
		}

		local content = rex.gsub(cc.command, '{(.*?)}', function(str)
			local value
			for i in string.gmatch(str, '[^%.]+') do
				if value and not value[i] and not vars[i] then
					value = 'undefined'
					break
				else
					value = value and value[i] or vars[i]
				end
			end
			return value
		end)

		return msg:reply(content)
	end

	if not command or settings.disabled_commands[command.name] then return end

	for i = 1, #args + 1 do
		local sub = findSub(command._subCommands, args[i])
		if not sub then args = {unpack(args, i, #args)}; break end
		command = sub
	end

	local check, content = command:check(msg)
	if not check then return msg:reply(toast.util.errorEmbed(nil, content)) end

	if command:onCooldown(msg.author.id) then
	   local _, time = command:onCooldown(msg.author.id)
	   return msg:reply(toast.util.errorEmbed('Slow down, you\'re on cooldown', 'Please wait ' .. toast.util.formatLongfunction(time)))
	end

	if self._toastOptions.advancedArgs and #command.args > 0 then
		local parsed, err = toast.argparser.parse(msg, args, command)

		if err then
		   return msg:reply(toast.util.errorEmbed('Error with arguments', err))
		end

		args = parsed
	 end

	command.hooks.preCommand(msg)

	local success, err = pcall(command.execute, msg, args, settings, conn, command)

	command.hooks.postCommand(msg, class.type(err) == 'Message' and err or nil)

	if not success then
	   self:error('ERROR WITH ' .. command.name .. ': ' .. err)
	   msg:reply(toast.util.errorEmbed(nil, 'Please try this command later'))
	else
	   command:startCooldown(msg.author.id)
	end
end