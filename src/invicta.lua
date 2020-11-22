local toast = require('toast')
local loader = require('./loader')
local config = require('./config')

local client = toast.Client {
	prefix = {'?', '+'},
	defaultHelp = true
}

-- Commands

for _, command in pairs(loader.loadCommands('commands')) do
	client:addCommand(command)
end

client:login(config.token)