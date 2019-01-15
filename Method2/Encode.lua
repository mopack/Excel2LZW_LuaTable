local char = string.char
local sub = string.sub
local tconcat = table.concat

local basedictcompress = {}
local A = {}
local input

local function initDict()
	basedictcompress = {}
	A = {}
	for i = 0, 255 do
    	local ic, iic = char(i), char(i, 0)
	    basedictcompress[ic] = iic
	end
	return
end
local function dictAddA(str, dict, a, b)
    if a >= 256 then
        a, b = 0, b+1
        if b >= 256 then
            dict = {}
            b = 1
        end
    end
    dict[str] = char(a,b)
    a = a+1
    return dict, a, b
end
local function compress(input)
    if type(input) ~= "string" then
        return nil, "string expected, got "..type(input)
    end
    local len = #input
    if len <= 1 then
        return "u"..input
    end

    local dict = {}
    local a, b = 0, 1

    local result = {"c"}
    local resultlen = 1
    local n = 2
    local word = ""
    for i = 1, len do
        local c = sub(input, i, i)
        local wc = word..c
        if not (basedictcompress[wc] or dict[wc]) then
            local write = basedictcompress[word] or dict[word]
            if not write then
                return nil, "algorithm error, could not fetch word"
            end
            result[n] = write
            resultlen = resultlen + #write
            n = n+1
            if  len <= resultlen then
                return "u"..input
            end
            dict, a, b = dictAddA(wc, dict, a, b)
            word = c
        else
            word = wc
        end
    end
    result[n] = basedictcompress[word] or dict[word]
    resultlen = resultlen+#result[n]
    n = n+1
    if  len <= resultlen then
        return "u"..input
    end
    return tconcat(result)
end
local function Output(str)
	input = table.concat(A, char(17))
	local compressed = compress(input)
	local out = assert(io.open(str, "wb"))
	out:write(compressed)
	assert(out:close())
end

require("LuaTable")
-- name compress --
initDict()
for k, v in ipairs(pTable) do
	A[k] = pTable[k].name
end
Output("name")

-- msg compress --
initDict()
for k, v in ipairs(pTable) do
	A[k] = pTable[k].msg
end
Output("msg")
