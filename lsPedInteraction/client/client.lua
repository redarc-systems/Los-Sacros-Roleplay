local cuffProp = nil
local isCuffed = false
local escortTick = nil

local function ensureAnim(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do Wait(10) end
    end
end

local function loadModel(model)
    local hash = (type(model) == 'number') and model or joaat(model)
    if not IsModelValid(hash) then return false end
    RequestModel(hash)
    local timeout = GetGameTimer() + 6000
    while not HasModelLoaded(hash) and GetGameTimer() < timeout do Wait(10) end
    return HasModelLoaded(hash) and hash or false
end

local function playCuffSfx()
    if Config.Sound.useInteractSound then
        TriggerServerEvent('InteractSound_SV:PlayOnSource', Config.Sound.soundName, Config.Sound.volume)
    else
        PlaySoundFrontend(-1, 'FocusIn', 'HintCamSounds', true)
    end
end

local function toggleControls(disable)
    if disable then
        DisablePlayerFiring(PlayerId(), true)
        SetEnableHandcuffs(PlayerPedId(), true)
        SetCurrentPedWeapon(PlayerPedId(), joaat('WEAPON_UNARMED'), true)
        SetPedCanPlayGestureAnims(PlayerPedId(), false)
    else
        SetEnableHandcuffs(PlayerPedId(), false)
        SetPedCanPlayGestureAnims(PlayerPedId(), true)
    end
end

local function cuffLocalPlayer()
    if isCuffed then return end
    isCuffed = true

    local ped = PlayerPedId()
    ClearPedTasksImmediately(ped)

    -- suspect anim
    local a = Config.Anims.suspect
    ensureAnim(a.dict)
    TaskPlayAnim(ped, a.dict, a.anim, 4.0, -2.0, 3000, 49, 0.0, false, false, false)

    -- attach cuffs
    local modelHash = loadModel(Config.CuffModel)
    if modelHash then
        local pos = GetEntityCoords(ped)
        cuffProp = CreateObject(modelHash, pos.x, pos.y, pos.z + 0.2, true, true, false)
        AttachEntityToEntity(
            cuffProp, ped, GetPedBoneIndex(ped, Config.Attach.bone),
            Config.Attach.pos.x, Config.Attach.pos.y, Config.Attach.pos.z,
            Config.Attach.rot.x, Config.Attach.rot.y, Config.Attach.rot.z,
            true, true, false, true, 1, true
        )
        SetModelAsNoLongerNeeded(modelHash)
    end

    playCuffSfx()

    -- idle loop
    CreateThread(function()
        local idle = Config.Anims.idleCuffed
        ensureAnim(idle.dict)
        while isCuffed do
            if not IsEntityPlayingAnim(ped, idle.dict, idle.anim, 3) then
                TaskPlayAnim(ped, idle.dict, idle.anim, 4.0, -4.0, -1, 49, 0.0, false, false, false)
            end
            -- disable movement/combat each frame
            DisableControlAction(0, 21, true)  -- sprint
            DisableControlAction(0, 24, true)  -- attack
            DisableControlAction(0, 25, true)  -- aim
            DisableControlAction(0, 22, true)  -- jump
            DisableControlAction(0, 23, true)  -- enter vehicle
            DisableControlAction(0, 32, true)  -- move
            DisableControlAction(0, 33, true)
            DisableControlAction(0, 34, true)
            DisableControlAction(0, 35, true)
            DisableControlAction(0, 140, true)
            DisableControlAction(0, 141, true)
            DisableControlAction(0, 142, true)
            DisableControlAction(0, 257, true)
            DisableControlAction(0, 263, true)
            DisableControlAction(0, 264, true)
            toggleControls(true)
            Wait(0)
        end
        ClearPedTasks(ped)
        toggleControls(false)
    end)
end

local function uncuffLocalPlayer()
    if not isCuffed then return end
    isCuffed = false
    if DoesEntityExist(cuffProp) then
        DetachEntity(cuffProp, true, true)
        DeleteEntity(cuffProp)
    end
end

-- Escort (suspect attaches to officer ped)
local function startEscort(officerPed)
    if escortTick then return end
    local suspect = PlayerPedId()
    AttachEntityToEntity(suspect, officerPed, GetPedBoneIndex(officerPed, Config.Escort.bone),
        Config.Escort.offset.x, Config.Escort.offset.y, Config.Escort.offset.z,
        0.0, 0.0, 180.0, false, false, false, false, 2, true)

    escortTick = true
    CreateThread(function()
        while escortTick do
            DisableControlAction(0, 21, true)
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            Wait(0)
            if not DoesEntityExist(officerPed) or IsPedDeadOrDying(officerPed) then
                escortTick = nil
                DetachEntity(suspect, true, false)
                break
            end
        end
    end)
end

local function stopEscort()
    if not escortTick then return end
    escortTick = nil
    DetachEntity(PlayerPedId(), true, false)
end

local function hardResetRestraints()
    -- Stop escort if any
    if escortTick then
        escortTick = nil
        DetachEntity(PlayerPedId(), true, false)
    end
    -- Uncuff if cuffed
    if isCuffed and DoesEntityExist(cuffProp) then
        DetachEntity(cuffProp, true, true)
        DeleteEntity(cuffProp)
    end
    isCuffed = false
    ClearPedTasksImmediately(PlayerPedId())
    SetEnableHandcuffs(PlayerPedId(), false)
    SetPedCanPlayGestureAnims(PlayerPedId(), true)
end

-- Events from server
RegisterNetEvent('rcuffs:client:doCuff', function(officerServerId)
    cuffLocalPlayer()
end)

RegisterNetEvent('rcuffs:client:doUncuff', function()
    uncuffLocalPlayer()
end)

RegisterNetEvent('rcuffs:client:escort', function(officerServerId, officerSrc, start)
    local ply = GetPlayerFromServerId(officerSrc)
    if ply == -1 then return end
    local officerPed = GetPlayerPed(ply)
    if start then startEscort(officerPed) else stopEscort() end
end)

RegisterNetEvent('rcuffs:client:officerAnim', function()
    local a = Config.Anims.officer
    ensureAnim(a.dict)
    TaskPlayAnim(PlayerPedId(), a.dict, a.anim, 4.0, -2.0, 3000, 49, 0.0, false, false, false)
end)



-- === Target options (ox_target) ===
local function registerOxTarget()
    if Config.Target ~= 'ox_target' then return end
    exports.ox_target:addGlobalPlayer({
        {
            icon = 'handcuffs',
            label = 'Cuff / Uncuff',
            distance = Config.TargetDistance,
            onSelect = function(data)
                local targetPed = data.entity
                local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(targetPed))
                if not targetId then return end
                lib.registerContext({
                    id = 'rcuffs_menu',
                    title = 'Restraint',
                    options = {
                        {
                            title = 'Cuff',
                            onSelect = function()
                                TriggerServerEvent('rcuffs:tryCuff', targetId)
                            end
                        },
                        {
                            title = 'Uncuff',
                            onSelect = function()
                                TriggerServerEvent('rcuffs:tryUncuff', targetId)
                            end
                        }
                    }
                })
                lib.showContext('rcuffs_menu')
            end
        },
        {
            icon = 'person-walking',
            label = 'Hold / Escort',
            distance = Config.TargetDistance,
            onSelect = function(data)
                local targetPed = data.entity
                local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(targetPed))
                if not targetId then return end
                lib.registerContext({
                    id = 'rcuffs_escort',
                    title = 'Escort',
                    options = {
                        {
                            title = 'Start Escort',
                            onSelect = function()
                                TriggerServerEvent('rcuffs:tryEscort', targetId, true)
                            end
                        },
                        {
                            title = 'Stop Escort',
                            onSelect = function()
                                TriggerServerEvent('rcuffs:tryEscort', targetId, false)
                            end
                        }
                    }
                })
                lib.showContext('rcuffs_escort')
            end
        }
    })
end

-- If using baseevents (recommended)
AddEventHandler('baseevents:onPlayerDied', function(killerType, deathCoords)
    hardResetRestraints()
end)

AddEventHandler('baseevents:onPlayerKilled', function(killerId, deathCoords)
    hardResetRestraints()
end)

-- Failsafe: tick watcher (works even without baseevents)
CreateThread(function()
    while true do
        if isCuffed or escortTick then
            local ped = PlayerPedId()
            if IsPedFatallyInjured(ped) or IsPedDeadOrDying(ped) then
                hardResetRestraints()
            end
        end
        Wait(500)
    end
end)

-- In startEscort() tick loop (inside while escortTick do)
if not DoesEntityExist(officerPed) or IsPedDeadOrDying(officerPed) or IsPedFatallyInjured(officerPed) then
    escortTick = nil
    DetachEntity(suspect, true, false)
    break
end

-- Optional failsafe keybind
RegisterCommand('rcuffs_stopescort', function() stopEscort() end, false)
RegisterKeyMapping('rcuffs_stopescort', 'RCuffs: Stop Escort', 'keyboard', Config.Keys.stopEscort or 'X')

CreateThread(function()
    registerOxTarget()
end)

-- Exports if you use a different target system
exports('CuffPlayer',   function(serverId) TriggerServerEvent('rcuffs:tryCuff', serverId) end)
exports('UncuffPlayer', function(serverId) TriggerServerEvent('rcuffs:tryUncuff', serverId) end)
exports('Escort',       function(serverId, start) TriggerServerEvent('rcuffs:tryEscort', serverId, start) end)
