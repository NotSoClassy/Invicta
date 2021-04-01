local toast = require 'toast'
local muteUtil = require 'muteUtil'

local function compareRoles(role1, role2)
    if role1.position == role2.position then
        return role2.id - role1.id
    end
    return role1.position - role2.position
end

return {
    name = 'mute',
    description = 'Mutes a member.',
    args = {
        {
            name = 'target',
            value = 'member',
            required = true
        },
        {
            name = 'time',
            value = 'time',
            required = true
        },
        {
            name = 'reason',
            value = '...'
        }
    },
    userPerms = {'manageRoles'},
    botPerms = {'manageRoles'},
    execute = function(msg, args, settings, conn)

        if not settings.mute_role then return msg:reply('There isn\'t a mute role set.') end
        if args.target == msg.member then return msg:reply('I am not going to mute you!') end
        if args.target.bot then return msg:reply('I am not going to mute a bot!') end
        if args.time < 300 then return msg:reply('Mutes under five minutes are not supported!') end

        local role = msg.guild:getRole(settings.mute_role)

        if not role then return msg:reply('The mute role is invalid!') end
        if not toast.util.manageable(args.target) then
            return msg:reply('I cannot manage this user!')
        elseif compareRoles(args.target.highestRole, msg.member.highestRole) > 0 then
            return msg:reply('You cannot manage this user!')
        end

        if muteUtil.isMuted(conn, msg.guild.id, args.target.id) then
            muteUtil.remute(conn, msg.guild.id, args.target.id, args.time)
        else
            muteUtil.mute(conn, msg.guild.id, args.target.id, args.time)
        end

        args.target:addRole(role.id)

        args.target:send('You have been muted in %s%s%s', msg.guild.name, args.reason and ' because ' or '.',
            args.reason or '')
        return msg:reply(args.target.name .. ' has been muted!')
    end
}