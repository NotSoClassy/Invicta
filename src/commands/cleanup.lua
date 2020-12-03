return {
	name = 'cleanup',
	description = 'Clear bot messages.',
	userPerms = {'manageMessages'},
	execute = function(msg)
		for m in msg.channel:getMessages(100) do
			if m.author == m.client.user then
				m:delete()
			end
		end
	end
}