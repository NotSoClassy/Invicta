local baseURL = 'https://discord.com/api/oauth2/authorize?client_id=%s&permissions=8&scope=bot'

return {
    name = 'invite',
    description = 'Invite link for the bot.',
    execute = function(msg)
        msg:reply(string.format(baseURL, msg.client.user.id))
    end
}