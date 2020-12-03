local toast = require 'toast'

return {
	name = 'member-auto-role',
	description = 'Gives the auto role',
	event = 'client.memberJoin',
	disabledByDefault = true,
	execute = function(member, settings)
		if not settings.auto_role then return end

		local me = member.guild.members:get(member.guild.client.user.id)

		if not me:hasPermission('manageRoles') or not toast.util.manageable(member) then return end

		local role = member.guild:getRole(settings.auto_role)

		if not role then return end

		return member:addRole(role.id)
	end
}