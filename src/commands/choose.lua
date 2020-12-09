return {
	name = 'choose',
	description = 'Chooses a random choice',
	example = '<choice1> <choice2> [choice3] ...',
	execute = function(msg, args)
		if #args < 2 then return msg:reply('You need to provide at least 2 choices.') end
		msg:reply(args[math.random(#args)])
	end
}