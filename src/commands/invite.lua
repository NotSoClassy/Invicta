local baseURL = 'Invite the bot with this link\n<https://discord.com/api/oauth2/authorize?client_id=%s&permissions=8&scope=bot>'

return {
    name = 'invite',
    description = 'Invite link for the bot.',
    hidden = true,
    execute = function(msg)
        return msg:reply(string.format(baseURL, msg.client.user.id))
    end
}