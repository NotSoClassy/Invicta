local responses = {
	{
		'It is certain', 'Without a doubt', 'You may rely on it', 'Yes definitely', 'It is decidedly so',
		'As I see it, yes', 'Most likely', 'Yes', 'Outlook good', 'Signs point to yes'
	}, -- Positive

	{
		'Don\'t count on it', 'Outlook not so good', 'My sources say no', 'Very doubtful',
		'My reply is no'
	}, -- Negative

	{
		'Reply hazy try again', 'Better not tell you now', 'Ask again later', 'Cannot predict now',
		'Concentrate and ask again'
	} -- Neutral
}

local flgs = {
	{
		name = 'neutral',
		value = 'boolean'
	},
	{
		name = 'negative',
		value = 'boolean'
	},
	{
		name = 'positive',
		value = 'boolean'
	}
}

return {
	name = '8ball',
	description = 'Ask the 8ball anything!',
	example = '<question>',
	flag = flgs,
	execute = function(msg, args)
		if #args.ungrouped <= 0 then return msg:reply('You didn\'t ask anything') end

		local flags = args.flags
		local c = ((flags.p or flags.positive) and 1) or (flags.negative and 2) or (flags.neutral and 3) or math.random(3)

		return msg:reply(responses[c][math.random(#responses[c])])
	end
}