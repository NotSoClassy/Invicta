local class = require 'discordia' .class
local toast = require 'toast'
local ownerOnly = require '../checks/ownerOnly'

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

local function hasPerms(member, channel, perms)
	if not member or not channel.guild then return true end
	local userPerms = member:getPermissions(channel)
	return userPerms:has(unpack(perms))
 end

return {
	name = 'sudo',
	description = 'Runs a command without checking user permissions',
	example = '[command] [...subcommands] [...command args]',
	hidden = true,
	hooks = {check = ownerOnly},
	execute = function(msg, args, settings, conn)
		if #args == 0 then return end

		local cmd = table.remove(args, 1)
		local command

		for _, v in pairs(msg.client.commands) do
			if v.name == cmd or search(v.aliases, cmd) then
				command = v
				break
			end
		end

		if not command then return msg:reply('Command not found') end

		local cmdArgs

		for i = 1, #args + 1 do
			local sub = findSub(command._subCommands, args[i])
			if not sub then cmdArgs = {unpack(args, i, #args)}; break end
			command = sub
		end

		if not hasPerms(msg.guild:getMember(msg.client.user.id), msg.channel, command.botPerms) then
			return msg:reply(toast.util.errorEmbed(nil, 'I am missing permission to run this command (' .. table.concat(command.botPerms, ', ') .. ')'))
		end

		if msg.client._toastOptions.advancedArgs and #command.args > 0 then
			local parsed, err = toast.argparser.parse(msg, cmdArgs, command)

			if err then
			   return msg:reply(toast.util.errorEmbed('Error with arguments', err))
			end

			cmdArgs = parsed
		 end

		command.hooks.preCommand(msg)

		local success, err = pcall(command.execute, msg, cmdArgs, settings, conn, command)

		command.hooks.postCommand(msg, class.type(err) == 'Message' and err or nil)

		if not success then
			return msg:reply('```lua\n' .. err .. '```')
		end
	end
}