local urlencode = require 'querystring' .urlencode
local http = require 'coro-http'

local f = string.format

local baseURL = 'https://notsoclassy.xyz/api/'

return {
	name = 'impostor',
	description = 'Make an Amoung Us impostor GIF',
	cooldown = 5000,
	hidden = true,
	aliases = {'imposter'},
	args = {
		{
			name = 'target',
			value = 'member',
			default = function(msg) return msg.member end
		}
	},
	flags = {
		{
			name = 'impostor',
			value = 'boolean'
		}
	},
	execute = function(msg, args)

		local target = args.target

		local isImpostor = (args.flags.impostor or args.flags.imposter or args.flags.i) or math.random(10) == 1

		local url = baseURL .. f('impostor?avatar=%s&name=%s%s',
			urlencode(target.user.avatarURL),
			urlencode(target.name),
			isImpostor and '&impostor=true' or ''
		)

		local res, body = http.request('GET', url)

		if not body or res.code ~= 200 then return msg:reply('An error has occured with the API. (Most likely ratelimited)') end

		return msg:reply {
			file = { 'impostor.gif', body }
		}

	end
}
