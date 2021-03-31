local toast = require 'toast'

return {
	name = 'message-delete-log',
	description = 'Logs all the deleted messages.',
	event = 'client.messageDelete',
	hidden = false,
	disabledByDefault = true,
	execute = function(msg, settings)
		if not msg.guild or not settings or #msg.content == 0 then return end

		local chnl = msg.guild:getChannel(settings.log_channel)

		if not chnl then return true, 'Invalid channel' end

		return toast.Embed()
			:setAuthor('Message Deleted')
			:setDescription('**Content:**\n'  .. msg.cleanContent)
			:addField('Author:', msg.author.mentionString, true)
			:addField('Channel:', msg.channel.mentionString, true)
			:setFooter('Message ID: ' .. msg.id)
			:setColor('RED')
			:send(chnl)
	end
}