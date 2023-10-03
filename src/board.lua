local utils = require('./utils')

local crystalls = { 'A', 'B', 'C', 'D', 'E', 'F' }
local board = { }

function board:new()
    local object = setmetatable({ }, self)
    self.__index = self
    object:init()
    return object
end

function board:init()
    self.fields = self:mix()
    self.fieldsTemp = { }
    self.ticks = 0
    self.score = 0
end

function board:tick()
    if not self:_hasMove() then
        print('No moves. Mix.')
        self:mix()
    end

    repeat
        local matches = self:_getMatches()
        for _, match in ipairs(matches) do
            for y = match.start.y, match.final.y do
                for x = match.start.x, match.final.x do
                    if self.fields[y][x] ~= '-' then
                        self.fields[y][x] = '-'
                        self.score = self.score + 1
                    end
                end
            end
        end
        self:_shiftCells()
    until not self:_hasMatch()

    if self:_hasBoardChanged() then
        self:dump()
        self.fieldsTemp = utils.copy(self.fields)
        self.ticks  = self.ticks + 1
    end
end

function board:move(from, to)
    if to == nil or (to.x > 9 or to.x < 0) or (to.y > 9 or to.y < 0) then
        return
    end

    self.fields[from.y][from.x], self.fields[to.y][to.x] = self.fields[to.y][to.x], self.fields[from.y][from.x]
    if not self:_hasMatch() then
        self.fields[from.y][from.x], self.fields[to.y][to.x] = self.fields[to.y][to.x], self.fields[from.y][from.x]
        print('This move didn\'t make a match')
    end
end

function board:mix()
    self.fields = { }
    for y = 0, 9 do
        self.fields[y] = {}
        for x = 0, 9 do
            repeat
                local crystall = self:_getRandomCrystall()
                self.fields[y][x] = crystall
            until not self:_hasMatchByCoord(y, x)
        end
    end
    return self.fields
end

function board:dump()
    local str = ''
    for i = 0, 9 do
        str = str .. tostring(i) .. ' '
    end
    str = str .. 'x/y\n' .. utils.sep() .. '\n'

    for y = 0, 9 do
        for x = 0, 9 do
            str = str .. self.fields[y][x] .. ' '
        end
        str = str .. ('| %d\n'):format(y)
    end
    print(str)
end

---
function board:_hasMatchByCoord(y, x) -- ONLY LEFT & UP
    local crystall = self.fields[y][x]

    if x > 1 and self.fields[y][x - 1] == crystall and self.fields[y][x - 2] == crystall then -- Left
        return true
    elseif y > 1 and self.fields[y - 1][x] == crystall and self.fields[y - 2][x] == crystall then -- Up
        return true
    end
    return false
end

function board:_hasBoardChanged()
    if #self.fieldsTemp == 0 then
        return true
    end

    for y = 0, 9 do
        for x = 0, 9 do
            if self.fields[y][x] ~= self.fieldsTemp[y][x] then
                return true
            end
        end
    end
    return false
end

function board:_shiftCells()
    local str = ''
    for y = 0, 9 do
        for x = 0, 9 do
            if self.fields[x][y] ~= '-' then
                str = str .. self.fields[x][y]
            end
        end
        str = str .. '\n'
    end

    local y = 0
    for line in str:gmatch('[^\n]+') do
        if #line ~= 10 then
            local randomCrystalls = ''
            for i = 1, 10 - #line do
                randomCrystalls = randomCrystalls .. self:_getRandomCrystall()
            end
            line = randomCrystalls .. line

            for x = 0, 9 do
                self.fields[x][y] = line:sub(x + 1, x + 1)
            end
        end
        y = y + 1
    end
end

function board:_getMatches()
    local result = { }
    
    for y = 0, 9 do
        local strH, strV = '', ''
        for x = 0, 9 do
            strH = strH .. self.fields[y][x]
            strV = strV .. self.fields[x][y]
        end

        for _, crystall in ipairs(crystalls) do
            local regex = crystall:rep(3) .. '+'
            
            local startPos, finalPos = strH:find(regex)
            if startPos ~= nil and finalPos ~= nil then
                table.insert(result, {
                    start = { x = startPos - 1, y = y },
                    final = { x = finalPos - 1, y = y },
                    crystall = crystall
                })
            end
    
            startPos, finalPos = strV:find(regex)
            if startPos ~= nil and finalPos ~= nil then
                table.insert(result, {
                    start = { x = y, y = startPos - 1 },
                    final = { x = y, y = finalPos - 1 },
                    crystall = crystall
                })
            end
        end
    end

    return result
end

function board:_hasMatch()
    for y = 0, 9 do
        local strH, strV = '', ''
        for x = 0, 9 do
            strH = strH .. self.fields[y][x]
            strV = strV .. self.fields[x][y]
        end

        for _, crystall in ipairs(crystalls) do
            local regex = crystall:rep(3) .. '+'
            if strH:find(regex) or strV:find(regex) then
                return true
            end
        end
    end
    return false
end

function board:_hasMove()
    local hasMatchSwap = function(start, final)
        self.fields[start.y][start.x], self.fields[final.y][final.x] = self.fields[final.y][final.x], self.fields[start.y][start.x]
        local r = self:_hasMatch()
        self.fields[start.y][start.x], self.fields[final.y][final.x] = self.fields[final.y][final.x], self.fields[start.y][start.x]
        return r
    end

    for y = 0, 9 do
        for x = 0, 9 do
            if x > 0 and x < 9 and (hasMatchSwap({ y = y, x = x }, { y = y, x = x - 1 }) or hasMatchSwap({ y = y, x = x }, { y = y, x = x + 1 })) then -- horizontal
                return true
            end
            if y > 0 and y < 9 and (hasMatchSwap({ y = y, x = x }, { y = y - 1, x = x }) or hasMatchSwap({ y = y, x = x }, { y = y + 1, x = x })) then -- vertical
                return true
            end
        end
    end

    return false
end

function board:_getRandomCrystall()
    return crystalls[math.random(1, #crystalls)]
end

return board