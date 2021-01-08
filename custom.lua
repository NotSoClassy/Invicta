local rex = require 'rex'
local input = io.read()

local vars = {
    author = { name = 'camada', mentionString = '<@!123>'},
    guild = { id = '123', name = 'troll devs'}
}

-- I'm not sure why any of this works, but it does
local output = rex.gsub(input, '{(.*?)}', function(str)
    local value
    for i in string.gmatch(str, '[^%.]+') do
        if value then
            if type(value) ~= 'table' or not value[i] then
                value = 'undefined'
                break
            end
            value = value[i]
        else
            if not vars[i] then
                value = 'undefined'
                break
            end
            value = vars[i]
        end
    end
    return value
end)

print(output)