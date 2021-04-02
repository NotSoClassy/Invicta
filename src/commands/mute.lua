local util = require 'muteUtil'

return {
    name = 'mute',
    description = 'Mutes a member. (unmutes are checked every 5 seconds, so if you put less than that it will still take 5 seconds)',
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

        local role, err = util.validMute(msg, settings, args)
        if not role then
            return msg:reply(err)
        end

        local target = args.target

        if util.isMuted(conn, msg.guild.id, target.id) then
            util.remute(conn, msg.guild.id, target.id, args.time)
        else
            util.mute(conn, msg.guild.id, target.id, args.time)
        end

        args.target:addRole(role.id)

        local logs = settings.log_channel and msg.guild:getChannel(settings.log_channel)
        local reason = args.reason and table.concat(args.reason)

        util.muteEmbed(logs, target.name .. ' has been muted', 'RED', 'Reason: ' .. (reason or 'No reason provided'))

        args.target:send('You have been muted in %s%s%s', msg.guild.name, reason and ' because ' or '.', reason or '')
        return msg:reply(target.name .. ' has been muted!')
    end
}