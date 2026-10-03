local event = require("event")

local Module = {
    SingleShotTimer = {},
    RepeatableTimer = {},
    InfinityTimer = {}
}

function Module.SingleShotTimer:Make(duration, callback)
    local obj = {}
    obj.timer_id_ = event.timer(duration, callback)

    function obj:Cancel()
        event.cancel(self.timer_id_)
    end

    function obj:Reset(duration, callback)
        self:Cancel()
        self.timer_id_ = event.timer(duration, callback)
    end

    setmetatable(obj, self)
    self.__index = self;
    return obj
end

function Module.RepeatableTimer:Make(duration, callback, times)
    local obj = {}
    obj.timer_id_ = event.timer(duration, callback, times)

    function obj:Cancel()
        event.cancel(self.timer_id_)
    end

    function obj:Reset(duration, callback)
        self:Cancel()
        self.timer_id_ = event.timer(duration, callback)
    end

    setmetatable(obj, self)
    self.__index = self;
    return obj
end

function Module.InfinityTimer:Make(duration, callback)
    local obj = {}
    obj.timer_id_ = event.timer(duration, callback, math.huge)

    function obj:Cancel()
        event.cancel(self.timer_id_)
    end

    function obj:Reset(duration, callback)
        self:Cancel()
        self.timer_id_ = event.timer(duration, callback)
    end

    setmetatable(obj, self)
    self.__index = self;
    return obj
end

return Module;
