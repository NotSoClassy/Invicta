local util = require 'util'

return {
	name = 'cleanup',
	description = 'Clear bot messages and messages that start with the bot prefix.',
	userPerms = {'manageMessages'},
	botPerms = {'manageMessages'},
	execute = function(msg, _, settings)
		local ids = {}
		for m in msg.channel:getMessages(50):iter() do
			if m.author == m.client.user or string.find(msg.content, settings.prefix or msg.client.prefix[1]) == 1 and util.canBulkDelete(msg) then
				table.insert(ids, m.id)
			end
		end
		msg.channel:bulkDelete(ids)
	end
}