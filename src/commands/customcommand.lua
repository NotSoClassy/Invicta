local json = require 'json'

return {
	name = 'customcommand',
    description = 'Make custom commands.',
    userPerms = {'administrator'},
    aliases = {'cc'},
    args = {
        {
            name = 'commandName',
            value = 'string',
            required = true
        },
        {
            name = 'commandString',
            value = '...',
            required = true
        }
    },
    execute = function(msg, args, settings, conn)
        local cc = { name = args.commandName, command = args.commandString }

        settings.custom_commands[cc.name] = cc

        local encoded = json.encode(settings.custom_commands)

        local stmt = conn:prepare('UPDATE guild_settings SET custom_commands = ? WHERE guild_id = ?;')
        stmt:reset():bind(encoded, msg.guild.id):step()
        stmt:close()

        return msg:reply('Custom command created!')
	end
}