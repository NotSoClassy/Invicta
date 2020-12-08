local toast = require 'toast'

local function embedGen(self, usage)
    local aliases = table.concat(self._aliases, ', ')
    local perms = table.concat(self._userPerms, ', ')
    local other = self._nsfw and 'NSFW only'
    local sub = ''

    for _, cmd in pairs(self._subCommands) do
        sub = sub .. cmd.name .. ' - ' .. cmd.description .. '\n'
    end

    return toast.Embed()
       :setColor('GREEN')
       :setTitle(self._name:gsub('^(.)', string.upper))
       :setDescription(self._description)
       :addField('Usage:', usage .. ' ' .. self._example, true)
       :addField('Aliases:', #aliases == 0 and 'None' or aliases, true)
       :addField('Permissions:', #perms == 0 and 'None' or perms, true)
       :addField('Sub Commands:', #sub == 0 and 'None' or sub, true)
       :addField('Other:', other and other or 'None', true)
       :setFooter(self._cooldown ~= 0 and 'This command has a ' .. math.floor(self._cooldown / 1000)  .. ' second cooldown' or 'This command has no cooldown')
 end

local function findCommand(cmds, q)
    if not cmds or not q then return end
    q = q:lower()
    for _, v in pairs(cmds) do
        if v.name == q or v == q or findCommand(v.aliases, q) then
            return v
        end
    end
end

return toast.Command('help', {
    description = 'This command!',
    example = '[name | alias]',
    execute = function(msg, args, settings)
        local cmd = table.remove(args, 1)
        local prefix = settings.prefix or msg.client.prefix[1]

        if cmd and #cmd ~= 0 then
            local command = findCommand(msg.client.commands, cmd)

            if not command then return msg:reply('No command or alias found for `' .. cmd .. '`') end

            local usage = prefix .. command.name

            for _, sub in ipairs(args) do
                local temp = findCommand(command.subCommands, sub)
                if not temp then usage = toast.util.getPrefix(msg) .. command.name break end
                usage = usage .. ' ' .. temp.name
                command = temp or command
            end

            return embedGen(command, usage):send(msg.channel)
        else
            local description = ''

            for _, cmd in pairs(msg.client.commands) do
                if cmd.hidden == false then
                    description = description .. cmd.name .. ' - ' .. cmd.description .. '\n'
                end
            end

            return toast.Embed()
                :setColor('GREEN')
                :setTitle('Commands')
                :setDescription(description)
				:setFooter('You can do `' .. prefix .. 'help [command]` for alias, usage, permission and sub command info')
                :send(msg.channel)
        end
    end
})