local char = string.char
local sub = string.sub
local tconcat = table.concat

local basedictdecompress = {}
for i = 0, 255 do
   	local ic, iic = char(i), char(i, 0)
    basedictdecompress[iic] = ic
end
local function dictAddB(str, dict, a, b)
    if a >= 256 then
        a, b = 0, b+1
        if b >= 256 then
            dict = {}
            b = 1
        end
    end
    dict[char(a,b)] = str
    a = a+1
    return dict, a, b
end
local function decompress(input)
    if type(input) ~= "string" then
        return nil, "string expected, got "..type(input)
    end

    if #input < 1 then
        return nil, "invalid input - not a compressed string"
    end

    local control = sub(input, 1, 1)
    if control == "u" then
        return sub(input, 2)
    elseif control ~= "c" then
        return nil, "invalid input - not a compressed string"
    end
    input = sub(input, 2)
    local len = #input

    if len < 2 then
        return nil, "invalid input - not a compressed string"
    end

    local dict = {}
    local a, b = 0, 1

    local result = {}
    local n = 1
    local last = sub(input, 1, 2)
    result[n] = basedictdecompress[last] or dict[last]
    n = n+1
    for i = 3, len, 2 do
        local code = sub(input, i, i+1)
        local lastStr = basedictdecompress[last] or dict[last]
        if not lastStr then
            return nil, "could not find last from dict. Invalid input?"
        end
        local toAdd = basedictdecompress[code] or dict[code]
        if toAdd then
            result[n] = toAdd
            n = n+1
            dict, a, b = dictAddB(lastStr..sub(toAdd, 1, 1), dict, a, b)
        else
            local tmp = lastStr..sub(lastStr, 1, 1)
            result[n] = tmp
            n = n+1
            dict, a, b = dictAddB(tmp, dict, a, b)
        end
        last = code
    end
    return tconcat(result)
end
local function getTableString(str)
	local red = assert(io.open(str, "rb"))
	local reds = red:read("*all")	
	assert(red:close())
	return decompress(reds)
end

local Name = getTableString("name")
local Msg = getTableString("msg")
pTable = {}

local ns, ne, i = 1, 1, 1
for i = 1,#Name do
	ne = string.find(Name,char(17),ns)
	if ne == nil then
		pTable[i] = {name=sub(Name,ns, #Name), msg = ""}
		break
	else
		pTable[i] = {name=sub(Name,ns, ne - 1), msg = ""}
		ns = ne + 1
	end	
end

local ns, ns = 1, 1
for i = 1,#Msg do
	ne = string.find(Msg,char(17),ns)
	if ne == nil then
		pTable[i].msg = sub(Msg,ns,#Msg)
		break
	else
		pTable[i].msg = sub(Msg,ns, ne - 1)
		ns = ne + 1
	end	
end