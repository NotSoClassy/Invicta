local timer = require 'timer'
local util = require 'util'
local rex = require 'rex'

local perms = {'manageMessages'}
local hooks = {postCommand = function(_, msg)
	if not msg then return end
	timer.sleep(3000)
	msg:delete()
end}

return {
	name = 'purge',
	description = 'Delete up to most recent messages. (Messages 2 weeks or older will be ignored, this applies for the sub commands too)',
	example = '[2-100]',
	userPerms = perms,
	botPerms = perms,
	hooks = hooks,
	aliases = {'prune'},
	execute = function(msg, args)
		local amount = args[1] and tonumber(args[1]) or 50

		if amount < 2 or amount > 100 then msg:reply('The amount must be in between 2-100.'); return end

		local ids = {}
		for msg in msg.channel:getMessages(amount):iter() do
			if util.canBulkDelete(msg) then
				table.insert(ids, msg.id)
			end
		end

		msg:delete()
		local success = msg.channel:bulkDelete(ids)

		if success then
			return msg:reply('Successfully purged ' .. #ids .. ' messages!')
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
				local amount = args[2] and tonumber(args[2]) or 50

				if amount < 2 or amount > 100 then msg:reply('The amount must be inbetween 2-100'); return end
				if not pcall(rex.find, '', args[1]) then msg:reply('Invalid Regex'); return end

				local ids = {}
				for msg in msg.channel:getMessages(amount):iter() do
					if rex.find(msg.content, args[1]) and util.canBulkDelete(msg) then
						table.insert(ids, msg.id)
					end
				end

				msg:delete()
				local success = msg.channel:bulkDelete(ids)

				if success then
					return msg:reply('Successfully purged ' .. #ids .. ' messages!')
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
				if #args < 1 then msg:reply('Missing required arguments'); return end

				local amount = args[2] and tonumber(args[2]) or 50

				if amount < 2 or amount > 100 then msg:reply('The amount must be in between 2-100'); return end

				local ids = {}
				for msg in msg.channel:getMessages(amount):iter() do
					if string.find(msg.content, args[1]) and util.canBulkDelete(msg) then
						table.insert(ids, msg.id)
					end
				end

				msg:delete()
				local success = msg.channel:bulkDelete(ids)

				if success then
					return msg:reply('Successfully purged ' .. #ids .. ' messages!')
				end
			end
		},
		{
			name = 'from',
			description = 'Delete every message that was sent by the member provided',
			example = '<user> [2-100]',
			userPerms = perms,
			botPerms = perms,
			hooks = hooks,
			execute = function(msg, args)
				if #args < 1 then msg:reply('Missing required arguments'); return end

				local amount = args[2] and tonumber(args[2]) or 50

				if amount < 2 or amount > 100 then msg:reply('The amount must be in between 2-100'); return end

				local member, err = util.searchMember(msg, args[1])

				if not member then msg:reply(err); return end

				local ids = {}
				for msg in msg.channel:getMessages(amount):iter() do
					if msg.author.id == member.id and util.canBulkDelete(msg) then
						table.insert(ids, msg.id)
					end
				end

				msg:delete()
				local success = msg.channel:bulkDelete(ids)

				if success then
					return msg:reply('Successfully purged ' .. #ids .. ' messages!')
				end
			end
		}
	}
}