return {
	name = 'choose',
	description = 'Chooses a random choice',
	args = {{ name = 'choices', value = '...' }},
	execute = function(msg, args)
		if not args.choices then return msg:reply('You didn\'t provide any choices') end
		if #args.choices < 2 then return msg:reply('You need to provide at least 2 choices.') end
		msg:reply(args.choices[math.random(#args.choices)])
	end
}