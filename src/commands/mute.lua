local time = require 'toast' .util.format
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
        local name = target.name:gsub('@', '@\226\128\139')

        util.muteEmbed(logs, name .. ' has been muted', 'RED', 'Reason: ' .. (reason or 'No reason provided'))

        args.target:sendf('You have been muted in %s%s%s\nLength: %s', msg.guild.name, reason and ' because ' or '.', reason or '', time(args.time * 1000))
        return msg:reply(name .. ' has been muted!')
    end
}