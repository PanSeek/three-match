local command = { }

function command:new(command, description, fn)
    local object = setmetatable({ }, self)
    self.__index = self
    object:init(command, description, fn)
    return object
end

function command:init(command, description, fn)
    self.command = command
    self.description = description
    self.fn = fn
end

function command:run(cmd)
    self.fn(cmd)
end

function command:compare(cmd)
    return self.command == cmd
end

return command