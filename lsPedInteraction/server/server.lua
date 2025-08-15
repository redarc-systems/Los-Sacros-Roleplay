local function hasPerm(src)
    if Config.PermissionMode == 'everyone' then return true end
    return IsPlayerAceAllowed(src, Config.AcePermission)
end

local function playersCloseEnough(src, tgt, maxDist, requireLOS)
    local sp = GetPlayerPed(src)
    local tp = GetPlayerPed(tgt)
    if sp == 0 or tp == 0 then return false end

    local sc = GetEntityCoords(sp)
    local tc = GetEntityCoords(tp)
    if #(sc - tc) > (maxDist or 3.0) then return false end

    if requireLOS then
        return HasEntityClearLosToEntity(sp, tp, 17) -- 17 = LOS flags
    end
    return true
end

RegisterNetEvent('rcuffs:tryCuff', function(targetId)
    local src = source
    if src == targetId then return end
    if not hasPerm(src) then return end
    if not playersCloseEnough(src, targetId, Config.MaxCuffDistance, Config.RequireLineOfSight) then return end

    -- tell target to apply cuff state, and officer to play their anim (cosmetic)
    TriggerClientEvent('rcuffs:client:doCuff', targetId, src)
    TriggerClientEvent('rcuffs:client:officerAnim', src)
end)

RegisterNetEvent('rcuffs:tryUncuff', function(targetId)
    local src = source
    if src == targetId then return end
    if not hasPerm(src) then return end
    if not playersCloseEnough(src, targetId, Config.MaxCuffDistance, false) then return end

    TriggerClientEvent('rcuffs:client:doUncuff', targetId)
end)

RegisterNetEvent('rcuffs:tryEscort', function(targetId, start)
    local src = source
    if src == targetId then return end
    if not hasPerm(src) then return end
    if start and not playersCloseEnough(src, targetId, Config.MaxCuffDistance, false) then return end

    TriggerClientEvent('rcuffs:client:escort', targetId, src, start)
end)
