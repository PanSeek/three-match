local Board = require('./board')
local Command = require('./command')
local utils = require('./utils')

function main()
    local board, commands
    math.randomseed(os.time())

    commands = {
        move = Command:new('m', 'move (Example: m 3 0 r)', function(s)
            s = s:gsub('%s+', ' ')
            local cmd, x, y, direction = s:match('(.-) (%d+) (%d+) (.+)')
            if cmd ~= 'm' then
                return
            end

            x, y = tonumber(x), tonumber(y)
            local checkCoord = x ~= nil and y ~= nil and (x >= 0 and x < 10) and (y >= 0 and y < 10)
            local checkDirection = direction ~= nil and (direction == 'l' or direction == 'r' or direction == 'u' or direction == 'd')

            -- Check warnings
            if not checkCoord then
                print('Warning: X and Y must be between 0 and 9')
            end

            if not checkDirection then
                print('Warning: direction must be l/r/u/d (equivalent: left/right/up/down)')
            end

            if not checkCoord or not checkDirection then
                return
            end

            -- Set move
            local to
            if direction == 'l' then        to = { x = x - 1, y = y }
            elseif direction == 'r' then    to = { x = x + 1, y = y }
            elseif direction == 'd' then    to = { x = x, y = y + 1 }
            else                            to = { x = x, y = y - 1 } end

            board:move({ x = x, y = y }, to)
        end),
        restart = Command:new('r', 'restart', function()
            utils.clear()
            board = Board:new()
        end),
        quit = Command:new('q', 'quit', function()
            os.exit()
        end),
        help = Command:new('h', 'help', function()
            local str = 'Commands:\n'
            for _, v in pairs(commands) do
                str = str .. string.format('%s - %s\n', v.command, v.description)
            end
            print(str)
        end)
    }

    commands.restart:run()
    commands.help:run()

    local answer
    repeat
        board:tick()

        io.write(('Tick: %d | Score: %d | >: '):format(board.ticks, board.score))
        io.flush()

        answer = io.read():lower()
        print() -- Space for beauty

        local first = answer:sub(1, 1)
        for _, cmd in pairs(commands) do
            if cmd:compare(first) then
                cmd:run(answer)
            end
        end
    until answer == 'exit'
end

main()