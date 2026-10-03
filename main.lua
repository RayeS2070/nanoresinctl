local colors = require("colors")
local component = require("component")
local computer = require("computer")
local coroutine = require("coroutine")
local event = require("event")

local const = {
    kDuration = 600,
    event = {
        kInterruptedEvent = "interrupted"
    }
}

local master = {
    ['Molten Samarium'] = { target = 10e6, priority = 1, color = colors.white },
    ['Molten Praseodymium'] = { target = 10e6, priority = 3, color = colors.yellow },
    ['Molten Lanthanum'] = { target = 10e6, priority = 2, color = colors.orange },
    ['Molten Cerium'] = { target = 10e6, priority = 1, color = colors.magenta },
}

local me = component.me_controller

local function update()
    while true do
        for _, fluid in ipairs(me.getFluidsInNetwork()) do
            print(fluid.label, fluid.amount)
        end
        coroutine.yield()
    end
end

local function main()
    local co = coroutine.create(update)

    while (not event.pull(const.kDuration, const.event.kInterruptedEvent)) and coroutine.status(co) ~= 'dead' do
        coroutine.resume(co)
    end

    return 0
end

print("program return: ", main())
