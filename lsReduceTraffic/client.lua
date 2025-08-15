-- traffic_density/client.lua

local function getNumberConvar(name, default)
    local v = tonumber(GetConvar(name, tostring(default)))
    if v == nil then return default end
    return v
end

-- Initial values (can be overridden with replicated convars in server.cfg)
local traffic = getNumberConvar('trafficDensity', 0.20)      -- 0.0 = none, 1.0 = vanilla
local parked  = getNumberConvar('parkedDensity',  0.15)
local peds    = getNumberConvar('pedDensity',     0.40)

-- Optional toggles (1 = true, 0 = false)
local disableCops   = (getNumberConvar('disableAmbientCops', 1) >= 1)
local disableBoats  = (getNumberConvar('disableRandomBoats', 1) >= 1)
local disableTrucks = (getNumberConvar('disableGarbageTrucks', 1) >= 1)

-- Periodically re-read convars so you can tweak live and `restart traffic_density`
CreateThread(function()
    while true do
        Wait(5000) -- every 5s, pick up changes after a resource restart
        traffic = getNumberConvar('trafficDensity', traffic)
        parked  = getNumberConvar('parkedDensity',  parked)
        peds    = getNumberConvar('pedDensity',     peds)

        disableCops   = (getNumberConvar('disableAmbientCops',   disableCops and 1 or 0) >= 1)
        disableBoats  = (getNumberConvar('disableRandomBoats',   disableBoats and 1 or 0) >= 1)
        disableTrucks = (getNumberConvar('disableGarbageTrucks', disableTrucks and 1 or 0) >= 1)
    end
end)

-- Apply density multipliers every frame
CreateThread(function()
    while true do
        Wait(0)
        -- Vehicles
        SetVehicleDensityMultiplierThisFrame(traffic)
        SetRandomVehicleDensityMultiplierThisFrame(traffic)
        SetParkedVehicleDensityMultiplierThisFrame(parked)

        -- Peds (ambient & scenarios)
        SetPedDensityMultiplierThisFrame(peds)
        SetScenarioPedDensityMultiplierThisFrame(peds, peds)

        -- Optional reductions for extra perf stability
        if disableCops then
            SetCreateRandomCops(false)
            SetCreateRandomCopsNotOnScenarios(false)
            SetCreateRandomCopsOnScenarios(false)
        end
        if disableBoats then
            SetRandomBoats(false)
        end
        if disableTrucks then
            SetGarbageTrucks(false)
        end
    end
end)
