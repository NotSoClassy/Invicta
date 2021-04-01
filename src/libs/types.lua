local toast = require 'toast'

local lens = {
    seconds = function(n) return n end,
    minutes = function(n) return n * 60 end,
    hours = function(n) return n * 3600 end,
    days = function(n) return n * 3600 * 24 end
}

-- ugly alias stuff
lens.second = lens.seconds
lens.s = lens.seconds
lens.minute = lens.minutes
lens.m = lens.minutes
lens.hour = lens.hours
lens.h = lens.hours
lens.day = lens.days
lens.d = lens.days
--

toast.types.time = function(arg)
	local sum = 0
	local matched

	for n, len in arg:gmatch('%s-(%d+)%s-(%a+)') do
		if not lens[len] then return end
		matched = true
		n = tonumber(n)
		sum = sum + lens[len](n)
	end

	if not matched then return end

	return sum
end