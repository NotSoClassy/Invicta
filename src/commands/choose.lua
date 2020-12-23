return {
	name = 'choose',
	description = 'Chooses a random choice',
	args = {{ name = 'choices', value = '...' }},
	execute = function(msg, args)
		if #args.choices < 2 then return msg:reply('You need to provide at least 2 choices.') end
		msg:reply(args[math.random(#args)])
	end
}