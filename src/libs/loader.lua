local fs = require 'fs'
local pathjoin = require 'pathjoin'

local pathJoin = pathjoin.pathJoin
local handler = {}

function handler.load(dir)
	local files = {}
	for name, type in fs.scandirSync(dir) do
		if type == 'directory' then
			local path = pathJoin(dir, name)
			local buf = handler.load(path)
			for _, v in ipairs(buf) do
				table.insert(files, v)
			end
		elseif type == 'file' and name:match('%.lua$') then
			table.insert(files, require('../' .. pathJoin(dir, name)))
		end
	end
	return files
end

return handler