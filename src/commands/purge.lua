local timer = require 'timer'
local util = require 'util'
local rex = require 'rex'

local perms = {'manageMessages'}
local hooks = {postCommand = function(_, msg)
	if not msg then return end
	timer.sleep(3000)
	msg:delete()
end}
local amount = {
	name = 'amount',
	value = 'number',
	default = 50
}

return {
	name = 'purge',
	description = 'Delete most recent messages. (Messages 2 weeks or older will be ignored, this applies for the sub commands too)',
	userPerms = perms,
	botPerms = perms,
	hooks = hooks,
	aliases = {'prune'},
	args = {amount},
	execute = function(msg, args)
		local amount = args.amount

		if amount < 2 or amount > 100 then msg:reply('The amount must be in between 2-100.'); return end

		msg:delete()

		local ids = {}
		for msg in msg.channel:getMessages(amount):iter() do
			if util.canBulkDelete(msg) then
				table.insert(ids, msg.id)
			end
		end

		if #ids < 2 then msg:reply('Couldn\'t find enough messages to delete.'); return end

		local success = msg.channel:bulkDelete(ids)

		if success then
			return msg:reply('Successfully purged ' .. #ids .. ' messages!')
		end
	end,
	subCommands = {
		{
			name = 'match',
			description = 'Delete every message that matches with a RegExp.',
			userPerms = perms,
			botPerms = perms,
			hooks = hooks,
			args = {
				{
					name = 'regexp',
					value = 'string',
					required = true
				},
				amount
			},
			execute = function(msg, args)
				local amount = args.amount

				if amount < 2 or amount > 100 then msg:reply('The amount must be inbetween 2-100'); return end
				if not pcall(rex.find, '', args.regexp) then msg:reply('Invalid Regex'); return end

				msg:delete()

				local ids = {}
				for msg in msg.channel:getMessages(amount):iter() do
					if rex.find(msg.content, args.regexp) and util.canBulkDelete(msg) then
						table.insert(ids, msg.id)
					end
				end

				if #ids < 2 then msg:reply('Couldn\'t find enough messages to delete.'); return end

				local success = msg.channel:bulkDelete(ids)

				if success then
					return msg:reply('Successfully purged ' .. #ids .. ' messages!')
				end
			end,
		},
		{
			name = 'find',
			description = 'Delete every message that has the provided text in it.',
			userPerms = perms,
			botPerms = perms,
			hooks = hooks,
			args = {
				{
					name = 'text',
					value = 'string',
					required = true
				},
				amount
			},
			execute = function(msg, args)
				if #args < 1 then msg:reply('Missing required arguments'); return end

				local amount = args.amount

				if amount < 2 or amount > 100 then msg:reply('The amount must be in between 2-100'); return end

				msg:delete()

				local ids = {}
				for msg in msg.channel:getMessages(amount):iter() do
					if string.find(msg.content, args.text) and util.canBulkDelete(msg) then
						table.insert(ids, msg.id)
					end
				end

				if #ids < 2 then msg:reply('Couldn\'t find enough messages to delete.'); return end

				local success = msg.channel:bulkDelete(ids)

				if success then
					return msg:reply('Successfully purged ' .. #ids .. ' messages!')
				end
			end
		},
		{
			name = 'from',
			description = 'Delete every message that was sent by the member provided',
			userPerms = perms,
			botPerms = perms,
			hooks = hooks,
			args = {
				{
					name = 'member',
					value = 'member',
					required = true
				},
				amount
			},
			execute = function(msg, args)
				local amount = args.amount

				if amount < 2 or amount > 100 then msg:reply('The amount must be in between 2-100'); return end

				local member = args.member

				msg:delete()

				local ids = {}
				for msg in msg.channel:getMessages(amount):iter() do
					if msg.author.id == member.id and util.canBulkDelete(msg) then
						table.insert(ids, msg.id)
					end
				end

				if #ids < 2 then msg:reply('Couldn\'t find enough messages to delete.'); return end

				local success = msg.channel:bulkDelete(ids)

				if success then
					return msg:reply('Successfully purged ' .. #ids .. ' messages!')
				end
			end
		}
	}
}