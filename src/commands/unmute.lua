local toast = require 'toast'
local util = require 'muteUtil'

return {
    name = 'unmute',
    description = 'Unmutes a member.',
    args = {
        {
            name = 'target',
            value = 'member',
            required = true
        }
    },
    userPerms = {'manageRoles'},
    botPerms = {'manageRoles'},
    execute = function(msg, args, settings, conn)

        if not settings.mute_role then return msg:reply('There isn\'t a mute role set.') end

        local role = msg.guild:getRole(settings.mute_role)

        if not role then return msg:reply('The mute role is invalid!') end
        if not toast.util.manageable(args.target) then
            return msg:reply('I cannot manage this user!')
        end

        local target = args.target
        local logs = settings.log_channel and msg.guild:getChannel(settings.log_channel)

        util.unmute(conn, msg.guild.id, target, settings.mute_role)
        util.muteEmbed(logs, target.name .. ' has been unmuted by ' .. msg.author.name, 'YELLOW')
        return msg:reply(target.name .. ' has been unmuted!')
    end
}