local timer = require 'timer'
local rex = require 'rex'

local perms = {'manageMessages'}
local hooks = {postCommand = function(_, msg)
	if not msg then return end
	timer.sleep(3000)
	msg:delete()
end}

return {
	name = 'purge',
	description = 'Delete up to most recent messages.',
	example = '[2-100]',
	userPerms = perms,
	botPerms = perms,
	hooks = hooks,
	aliases = {'prune'},
	execute = function(msg, args)
		msg:delete()
		local amount = args[1] and tonumber(args[1]) or 50

		if amount < 2 or amount > 100 then return msg:reply('The amount must be in between 2-100.') end

		local success = msg.channel:bulkDelete(msg.channel:getMessages(amount))

		if success then
			return msg:reply('Successfully purged messages!')
		else
			return msg:reply('Could not purge messages, most likely due to one 2 weeks or older.')
		end
	end,
	subCommands = {
		{
			name = 'match',
			description = 'Delete every message that matches with a RegExp.',
			example = '<RegExp> [2-100]',
			userPerms = perms,
			botPerms = perms,
			hooks = hooks,
			execute = function(msg, args)
				msg:delete()
				local amount = args[2] and tonumber(args[2]) or 50

				if amount < 2 or amount > 100 then return msg:reply('The amount must be inbetween 2-100') end
				if not pcall(rex.find, '', args[1]) then return msg:reply('Invalid Regex') end

				local ids = {}
				for msg in msg.channel:getMessages(amount):iter() do
					if rex.find(msg.content, args[1]) then
						table.insert(ids, msg.id)
					end
				end

				local success = msg.channel:bulkDelete(ids)

				if success then
					return msg:reply('Successfully purged messages!')
				else
					return msg:reply('Could not purge messages, most likely due to one 2 weeks or older.')
				end
			end,
		},
		{
			name = 'find',
			description = 'Delete every message that has the provided text in it.',
			example = '<text to find> [2-100]',
			userPerms = perms,
			botPerms = perms,
			hooks = hooks,
			execute = function(msg, args)
				msg:delete()
				if #args < 1 then return msg:reply('Missing required arguments') end

				local amount = args[2] and tonumber(args[2]) or 50

				if amount < 2 or amount > 100 then return msg:reply('The amount must be inbetween 2-100') end

				local ids = {}
				for msg in msg.channel:getMessages(amount):iter() do
					if string.find(msg.content, args[1]) then
						table.insert(ids, msg.id)
					end
				end

				local success = msg.channel:bulkDelete(ids)

				if success then
					return msg:reply('Successfully purged messages!')
				else
					return msg:reply('Could not purge messages, most likely due to one 2 weeks or older.')
				end
			end
		}
	}
}