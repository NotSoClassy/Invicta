local toast = require 'toast'

local function mute(conn, gid, mid, len)
	local stmt = conn:prepare('INSERT INTO mutes (guild_id, user_id, length, end_timestamp) VALUES (?, ?, ?, ?);')
	stmt:reset():bind(gid, mid, len, os.time() + len):step()
	stmt:close()
end

local function compareRoles(role1, role2)
    if role1.position == role2.position then
        return role2.id - role1.id
    end
    return role1.position - role2.position
end

local function validMute(msg, settings, args)
    if not settings.mute_role then return false, 'There isn\'t a mute role set.' end
    if args.target == msg.member then return false, 'I am not going to mute you!' end
    if args.target == msg.guild.me then return false, 'Nice try, buddy!' end

    local role = msg.guild:getRole(settings.mute_role)

    if not role then return false, 'The mute role is invalid!' end
    if not toast.util.manageable(args.target) then
        return false, 'I cannot manage this user!'
    elseif compareRoles(args.target.highestRole, msg.member.highestRole) > 0 and not msg.guild.owner == msg.member then
        return false, 'You cannot manage this user!'
    end

    return role
end

local function remute(conn, gid, mid, len)
	local stmt = conn:prepare('UPDATE mutes SET length = ?, end_timestamp = ? WHERE guild_id = ? AND user_id = ?;')
	stmt:reset():bind(len, os.time() + len, gid, mid):step()
	stmt:close()
end

local function delete(conn, gid, mid)
	conn:exec('DELETE FROM mutes WHERE guild_id = "' .. gid .. '" AND user_id = "' .. mid .. '";')
end

local function unmute(conn, gid, member, role)
    delete(conn, gid, member.id)

    return member:removeRole(role)
end

local function isMuted(conn, gid, mid)
    return conn:exec('SELECT * FROM mutes WHERE guild_id = "'..gid..'" AND user_id = "'..mid..'";')
end

local function muteEmbed(chnl, msg, color, footer)
    if not chnl then return end
    local embed = toast.Embed()
        :setDescription(msg)
        :setColor(color)

    if footer then embed:setFooter(footer) end
    return embed:send(chnl)
end

return {
    mute = mute,
    remute = remute,
    unmute = unmute,
    delete = delete,
    isMuted = isMuted,
    validMute = validMute,
    muteEmbed = muteEmbed
}