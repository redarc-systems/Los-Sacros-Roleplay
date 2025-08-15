local function isJobAllowed(src)
    if not Config.AllowedJobs then return true end
    local allowed = Config.AllowedJobs
    if type(allowed) == 'string' then allowed = { allowed } end

    -- Replace this with your framework’s job getter (ESX/QBCore/etc.)
    -- For a barebones example, always true:
    local playerJob = nil -- TODO: fetch job from your framework if you want to restrict
    if not playerJob then return true end

    for _, j in ipairs(allowed) do
        if j == playerJob then return true end
    end
    return false
end

RegisterNetEvent('rcuffs:tryCuff', function(targetId)
    local src = source
    if src == targetId then return end
    if not isJobAllowed(src) then return end

    -- Ask target client to play paired animation + apply cuffs
    TriggerClientEvent('rcuffs:client:doCuff', targetId, src)
end)

RegisterNetEvent('rcuffs:tryUncuff', function(targetId)
    local src = source
    if src == targetId then return end
    if not isJobAllowed(src) then return end

    TriggerClientEvent('rcuffs:client:doUncuff', targetId)
end)

RegisterNetEvent('rcuffs:tryEscort', function(targetId, start)
    local src = source
    if src == targetId then return end
    if not isJobAllowed(src) then return end

    TriggerClientEvent('rcuffs:client:escort', targetId, src, start)
end)
