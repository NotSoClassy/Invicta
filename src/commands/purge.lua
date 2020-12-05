local rex = require 'rex'

local perms = {'manageMessages'}

return {
	name = 'purge',
	description = 'Delete up to most recent messages.',
	example = '[2-100]',
	userPerms = perms,
	botPerms = perms,
	aliases = {'prune'},
	execute = function(msg, args)
		local amount = args[1] and tonumber(args[1]) or 50

		if amount < 2 or amount > 100 then return msg:reply('The amount must be in between 2-100.') end

		msg:delete()
		msg.channel:bulkDelete(msg.channel:getMessages(amount))
		return msg:reply('Successfully purged messages!')
	end,
	subCommands = {
		{
			name = 'match',
			description = 'Delete every message that matches with a RegExp.',
			example = '<RegExp> [2-100]',
			userPerms = perms,
			botPerms = perms,
			execute = function(msg, args)
				local amount = args[2] and tonumber(args[2]) or 50

				if amount < 2 or amount > 100 then return msg:reply('The amount must be inbetween 2-100') end
				if not pcall(rex.find, '', args[1]) then return msg:reply('Invalid Regex') end

				local ids = {}
				for msg in msg.channel:getMessages(amount):iter() do
					if rex.find(msg.content, args[1]) then
						table.insert(ids, msg.id)
					end
				end

				msg.channel:bulkDelete(ids)
				return msg:reply('Successfully purged messages!')
			end
		},
		{
			name = 'find',
			description = 'Delete every message that has the provided text in it.',
			example = '<text to find> [2-100]',
			userPerms = perms,
			botPerms = perms,
			execute = function(msg, args)
				if #args < 1 then return msg:reply('Missing required arguments') end

				local amount = args[2] and tonumber(args[2]) or 50

				if amount < 2 or amount > 100 then return msg:reply('The amount must be inbetween 2-100') end

				local ids = {}
				for msg in msg.channel:getMessages(amount):iter() do
					if string.find(msg.content, args[1]) then
						table.insert(ids, msg.id)
					end
				end

				msg.channel:bulkDelete(ids)
				return msg:reply('Successfully purged message!')
			end
		}
	}
}