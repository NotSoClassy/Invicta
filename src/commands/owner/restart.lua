local ownerOnly = require('../checks/ownerOnly')

return {
	name = 'restart',
	description = 'Restarts the bot.',
	hidden = true,
	hooks = {check = ownerOnly},
	execute = function()
		return os.exit()
	end
}