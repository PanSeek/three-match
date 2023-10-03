function isWin() -- https://gist.github.com/Zbizu/43df621b3cd0dc460a76f7fe5aa87f30
    local fh, err = assert(io.popen('uname -o 2>/dev/null', 'r'))
	if fh then
		osname = fh:read()
	end
    return osname == nil
end

function clear()
    os.execute(isWin() and 'cls' or 'clear')
end

function sep(num)
    if num == nil or num < 0 then
        num = 10
    end
    
    local res = ''
    for i = 1, num do
        res = res .. '--'
    end
    return res
end

function copy(obj, seen)
    if type(obj) ~= 'table' then
        return obj
    end

    if seen and seen[obj] then
        return seen[obj]
    end

    local s = seen or {}
    local res = setmetatable({}, getmetatable(obj))
    s[obj] = res
    for k, v in pairs(obj) do
        res[copy(k, s)] = copy(v, s)
    end
    return res
end

return {
    clear = clear,
    sep = sep,
    copy = copy
}