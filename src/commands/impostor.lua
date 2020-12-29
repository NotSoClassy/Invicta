local toast = require 'toast'

local f = string.format

local baseURL = 'https://notsoclassy.xyz/api/'

return {
	name = 'impostor',
	description = 'Make an Amoung Us impostor GIF',
	cooldown = 5000,
	args = {
		{
			name = 'target',
			value = 'member',
			default = function(msg) return msg.member end
		},
		{
			name = 'isImposter',
			value = 'boolean',
			default = false
		}
	},
	execute = function(msg, args)

		local target = args.target
		local url = baseURL .. f('impostor?avatar=%s&name=%s&impostor=%s',
			target.avatarURL,
			target.name,
			tostring(args.isImposter)
		)

		return toast.Embed()
			:setTitle('Amoung Us')
			:setImage(url)
			:setColor('random')
			:send(msg.channel)
	end
}