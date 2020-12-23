local ownerOnly = require('../checks/ownerOnly')

return {
	name = 'restart',
	description = 'Restarts the bot.',
	hidden = true,
	hooks = {check = ownerOnly},
	execute = function(_, _, _, conn)
		return conn:close(), os.exit()
	end
}