local component = require("component")
local computer = require("computer")
local event = require("event")

local timer = require("timer")

local const = {
    kMaxInt = 9223372036854775807,
    event = {
        kInterruptedEvent = "interrupted"
    }
}

local me = component.me_controller

local function main()

    local timer = timer.InfinityTimer:Make(0.5, function()
        print("uptime", computer.uptime())
        for _, fluid in ipairs(me.getFluidsInNetwork()) do
            print(fluid.label, fluid.size)
        end
    end)

    while not event.pull(5, const.event.kInterruptedEvent) do end

    timer:Cancel();

    return 0
end

print("program return: ", main())
