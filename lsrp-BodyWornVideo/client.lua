local active = false
local lastBeep = 0
local callsign = Config.DefaultCallsign

-- Resolve officer display name
local function getOfficerName()
    if Config.OfficerNameSource == 'static' then
        return Config.StaticOfficerName
    end
    local pid = PlayerId()
    return GetPlayerName(pid) or 'Officer'
end

-- Helper to send NUI messages
local function nui(msg)
    SendNUIMessage(msg)
end

-- Play a sound in NUI
local function playSound(name)
    if not name or name == '' then return end
    nui({ action = 'play', sound = name, volume = Config.Volume or 0.5 })
end

-- Build current HUD payload
local function pushHudOnce()
    nui({
        action   = 'hud',
        show     = active,
        agency   = (Config.ShowAgency and Config.AgencyText) or '',
        officer  = getOfficerName(),
        callsign = callsign,
        showGPS  = Config.ShowGPS,
        showBatt = Config.ShowBattery,
        pos      = Config.Position or 'top-right',
        scale    = Config.Scale or 1.0,
        clock24  = Config.Use24hClock and true or false
    })
end

-- Try to get a simple GPS string (street name & area)
local function getGpsText()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local s1, s2 = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local street = GetStreetNameFromHashKey(s1)
    local cross  = s2 ~= 0 and GetStreetNameFromHashKey(s2) or nil
    local zone = GetNameOfZone(coords.x, coords.y, coords.z)
    local area = zone and tostring(zone) or ''
    if cross then
        return string.format('%s / %s • %s', street, cross, area)
    else
        return string.format('%s • %s', street, area)
    end
end

-- Tick to update time + GPS + periodic beep
CreateThread(function()
    while true do
        if active then
            -- Update time & GPS every second
            nui({
                action = 'tick',
                gps = Config.ShowGPS and getGpsText() or '',
            })

            -- Periodic recording beep
            if Config.PeriodicBeepSound and Config.PeriodicBeepInterval then
                local now = GetGameTimer()
                if now - lastBeep > (Config.PeriodicBeepInterval * 1000) then
                    lastBeep = now
                    playSound(Config.PeriodicBeepSound)
                end
            end

            Wait(1000)
        else
            Wait(500)
        end
    end
end)

-- Toggle function
local function toggleBodycam()
    active = not active
    lastBeep = GetGameTimer()
    pushHudOnce()
    nui({ action = 'visibility', show = active })

    if active then
        playSound(Config.ActivateSound)
    else
        if Config.DeactivateSound then
            playSound(Config.DeactivateSound)
        end
    end
end

-- Command: /bodycam
RegisterCommand('bodycam', function()
    toggleBodycam()
end, false)

-- Optional hotkey
if Config.EnableHotkey and Config.Hotkey then
    RegisterKeyMapping('bodycam', 'Toggle Bodycam', 'keyboard', Config.Hotkey)
end

-- Allow changing callsign on the fly
if Config.AllowSetCallsign then
    RegisterCommand('setcallsign', function(_, args)
        if not args[1] then
            lib.notify({ title='Bodycam', description='Usage: /setcallsign <text>', type='inform' })
            return
        end
        callsign = table.concat(args, ' ')
        if active then pushHudOnce() end
        lib.notify({ title='Bodycam', description=('Callsign set to %s'):format(callsign), type='success' })
    end, false)
end

-- Ensure NUI starts hidden
CreateThread(function()
    Wait(500)
    nui({ action='visibility', show=false })
    pushHudOnce()
end)

-- Clean up if resource restarts
AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    nui({ action='visibility', show=false })
end)
