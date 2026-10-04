local colors = require("colors")
local component = require("component")
local computer = require("computer")
local coroutine = require("coroutine")
local event = require("event")
local sides = require("sides")

local const = {
    kDebug = false,
    kDuration = 600,
    kThreshold = 0.8,
    event = {
        kInterruptedEvent = "interrupted"
    }
}

local master = {
    ['Molten Samarium'] = { target = 10e6, priority = 1, amount = 0, color = colors.white },
    ['Molten Praseodymium'] = { target = 10e6, priority = 3, amount = 0, color = colors.yellow },
    ['Molten Lanthanum'] = { target = 10e6, priority = 2, amount = 0, color = colors.orange },
    ['Molten Cerium'] = { target = 10e6, priority = 1, amount = 0, color = colors.magenta },
}

local me = component.me_controller
local rs = component.redstone

local function update_fluids()
    -- Reset Everything to Zero
    for _, fluid in pairs(master) do fluid.amount = 0 end

    -- Update Fluids from ME Network
    for _, fluid in ipairs(me.getFluidsInNetwork()) do
        if master[fluid.label] ~= nil then master[fluid.label].amount = fluid.size end
    end
end

local function get_low_level_fluids()
    -- Identify Low Fluids
    local lowFluids = {}
    for _, fluid in pairs(master) do
        if fluid.amount < const.kThreshold * fluid.target then table.insert(lowFluids, fluid) end
    end

    return lowFluids
end

local function print_dashboard()
    print("Prettify me")
    for name, fluid in pairs(master) do
        print(string.format("%-20s: %d", fluid.label, fluid.amount))
    end
end

local function update_redstone(low_fluids)
    table.sort(low_fluids, function(a, b)
        return (1 - (a.amount / a.target) ^ a.priority) < (1 - (b.amount / b.target) ^ b.priority)
    end)

    local fluid = low_fluids[#low_fluids]
    if fluid ~= nil then
        rs.setBundledOutput(sides.back, fluid.color, 255)
    end
end

local function update()
    while true do
        update_fluids()
        print_dashboard()
        local low_fluids = get_low_level_fluids()
        update_redstone(low_fluids)
        coroutine.yield()
    end
end

local function main()
    local co = coroutine.create(update)
    local errorfree = coroutine.resume(co)
    if const.kDebug then print("E: ", errorfree) end

    while (not event.pull(const.kDuration, const.event.kInterruptedEvent)) and coroutine.status(co) ~= 'dead' do
        errorfree = coroutine.resume(co)
        if const.kDebug then print("E: ", errorfree) end
    end

    return 0
end

print("program return: ", main())
