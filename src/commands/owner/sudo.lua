local ownerOnly = require('../checks/ownerOnly')

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

return {
	name = 'sudo',
	description = 'Runs a command without checking user permissions',
	example = '[command] [...args]',
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

		local cmdArgs

		for i = 1, #args + 1 do
			local sub = findSub(command._subCommands, args[i])
			if not sub then cmdArgs = {unpack(args, i, #args)}; break end
			command = sub
		end

		local success, err = pcall(command.execute, msg, cmdArgs, settings, conn, command)

		if not success then
			return msg:reply('```lua\n' .. err .. '```')
		end
	end
}