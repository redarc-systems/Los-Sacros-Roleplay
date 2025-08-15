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
