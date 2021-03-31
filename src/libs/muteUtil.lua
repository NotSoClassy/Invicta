local function mute(conn, gid, mid, len)
	local stmt = conn:prepare('INSERT INTO mutes (guild_id, user_id, length, end_timestamp) VALUES (?, ?, ?, ?);')
	stmt:reset():bind(gid, mid, len, os.time() + len):step()
	stmt:close()
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

return {
    mute = mute,
    remute = remute,
    unmute = unmute,
    delete = delete,
    isMuted = isMuted
}