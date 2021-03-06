local toast = require 'toast'

return {
	name = 'message-edit-log',
	description = 'Logs all the edited messages.',
	event = 'client.messageUpdate',
	hidden = false,
	disabledByDefault = true,
	execute = function(msg, settings)
		if not msg.guild or not settings or not msg.oldContent then return end

		local chnl = msg.guild:getChannel(settings.log_channel)

		if not chnl then return true, 'Invalid channel' end

		local oldContent = msg.oldContent[msg.editedTimestamp]
		local newContent = msg.content

		if #oldContent == 0 and #newContent == 0 then return end

		local success, err = toast.Embed()
			:setAuthor('Message Edited')
			:addField('Old Content:', oldContent)
			:addField('New Content:', newContent)
			:addField('Author:', msg.author.mentionString, true)
			:addField('Channel:', msg.channel.mentionString, true)
			:setFooter('Message ID: ' .. msg.id)
			:setColor('YELLOW')
			:send(chnl)
		return not success, err
	end
}