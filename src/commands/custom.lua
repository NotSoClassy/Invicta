local json = require 'json'

local function search(tbl, q)
	for i, v in pairs(tbl) do
		if q == v then
		   return i
		end
	 end
end

return {
	name = 'custom',
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
        local name = args.commandName:lower()

        for _, v in ipairs(msg.client.commands) do
            if v.name == name or search(v.aliases, name) then
                return msg:reply('A command with that name already exists')
            end
        end

        local cc = { name = name, command = args.commandString }

        settings.custom_commands[name] = cc

        local encoded = json.encode(settings.custom_commands)

        local stmt = conn:prepare('UPDATE guild_settings SET custom_commands = ? WHERE guild_id = ?;')
        stmt:reset():bind(encoded, msg.guild.id):step()
        stmt:close()

        return msg:reply('Custom command created!')
	end
}