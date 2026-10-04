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
    if const.kDebug then print("update_fluids") end
    -- Reset Everything to Zero
    for _, fluid in pairs(master) do fluid.amount = 0 end

    -- Update Fluids from ME Network
    for _, fluid in ipairs(me.getFluidsInNetwork()) do
        if master[fluid.label] ~= nil then
            master[fluid.label].amount = fluid.amount
        end
    end
end

local function get_low_level_fluids()
    if const.kDebug then print("get_low_level_fluids") end
    -- Identify Low Fluids
    local low_fluids = {}
    for _, fluid in pairs(master) do
        if fluid.amount < const.kThreshold * fluid.target then table.insert(low_fluids, fluid) end
    end

    return low_fluids
end

local function print_dashboard()
    if const.kDebug then print("print_dashboard") end
    print("Prettify me")
    for name, fluid in pairs(master) do
        print(string.format("%-20s: %d", name, fluid.amount))
    end
end

local function set_redstone(color)
    for i = 0, 15, 1 do
        rs.setBundledOutput(sides.front, i, 0)
    end
    rs.setBundledOutput(sides.front, color, 255)
end

local function update_redstone(low_fluids)
    if const.kDebug then print("update_redstone") end

    table.sort(low_fluids, function(a, b)
        return (1 - (a.amount / a.target) ^ a.priority) < (1 - (b.amount / b.target) ^ b.priority)
    end)

    local fluid = low_fluids[#low_fluids]

    if const.kDebug then print("selected color: ", fluid.color) end

    if fluid ~= nil then
        set_redstone(fluid.color)
        return true
    end

    return false
end

local function loop_iterate()
    local key, value = next(master)
    if key == nil then
        print("Incorrect master table")
        return
    end

    while true do
        if value ~= nil
        then
            for _ = 1, value.priority, 1 do
                coroutine.yield(value.color)
            end
        end

        key, value = next(master, key)
        if (key == nil) then
            key, value = next(master)
        end
    end
end

local function update()
    local loop = coroutine.create(loop_iterate)

    while true do
        update_fluids()
        print_dashboard()
        local low_fluids = get_low_level_fluids()
        if not update_redstone(low_fluids) then
            local color = coroutine.resume(loop)
            set_redstone(color)
        end
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
