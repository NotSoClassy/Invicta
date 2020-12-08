return {
	name = 'choose',
	description = 'Chooses a random choice',
	example = '<choice1> <choice2> [choice3] ...',
	execute = function(msg, args)
		if #args <= 0 then return msg:reply('You didn\'t ask anything') end
		msg:reply(args[math.random(#args)])
	end
}