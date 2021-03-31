local toast = require 'toast'
local muteUtil = require 'muteUtil'

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

        muteUtil.unmute(conn, msg.guild.id, args.target, settings.mute_role)
        return msg:reply(args.target.name .. ' has been unmuted!')
    end
}