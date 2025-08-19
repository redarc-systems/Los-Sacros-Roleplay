local playerCache = {}  -- [src] = { discordId, roles = {}, roleId, label, lastFetch }

-- === Utilities: Discord + Role Mapping ===

local function getDiscordId(src)
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if id:sub(1, 8) == "discord:" then
            return id:sub(9)
        end
    end
    return nil
end

local function roleLabelFromRoles(roleIds)
    local bestRoleId = nil
    -- choose highest priority role that exists in RoleMap
    for _, pri in ipairs(Config.RolePriority) do
        for _, r in ipairs(roleIds) do
            if r == pri then
                bestRoleId = r
                break
            end
        end
        if bestRoleId then break end
    end
    if bestRoleId and Config.RoleMap[bestRoleId] then
        return bestRoleId, Config.RoleMap[bestRoleId].label
    end
    return nil, nil
end

local function fetchMemberRoles(discordId, cb)
    local token = GetConvar("ls_discord_roles:bot_token", "")
    if token == "" then
        print("^1[LS Discord Roles]^7 Missing bot token convar ls_discord_roles:bot_token")
        cb(nil, "NoToken")
        return
    end
    local url = ("https://discord.com/api/v10/guilds/%s/members/%s"):format(Config.GuildId, discordId)
    PerformHttpRequest(url, function(status, body, headers)
        if status == 200 and body then
            local json = json.decode(body)
            cb(json.roles or {}, nil)
        elseif status == 404 then
            cb({}, "NotInGuild")
        else
            cb(nil, "HTTP_" .. tostring(status))
        end
    end, "GET", "", { ["Authorization"] = "Bot " .. token })
end

local function ensureCached(src, forceRefresh, cb)
    local now = os.time()
    local entry = playerCache[src]
    if entry and not forceRefresh and (now - (entry.lastFetch or 0) < Config.RefreshSeconds) then
        cb(entry)
        return
    end
    local did = getDiscordId(src)
    if not did then
        playerCache[src] = { discordId = nil, roles = {}, roleId = nil, label = nil, lastFetch = now }
        cb(playerCache[src])
        return
    end
    fetchMemberRoles(did, function(roleIds, err)
        local roleId, label = nil, nil
        if roleIds then roleId, label = roleLabelFromRoles(roleIds) end
        playerCache[src] = { discordId = did, roles = roleIds or {}, roleId = roleId, label = label, lastFetch = now }
        cb(playerCache[src], err)
    end)
end

-- === Join/Drop handling + chat prefixing ===

AddEventHandler("playerJoining", function()
    local src = source
    ensureCached(src, true, function(entry, err)
        TriggerClientEvent("ls_roles:setOwnRoleLabel", src, entry.label, entry.roleId)
        TriggerClientEvent("ls_roles:updateRoleLabel", -1, src, entry.label, entry.roleId)
    end)
end)

AddEventHandler("playerDropped", function()
    local src = source
    playerCache[src] = nil
    TriggerClientEvent("ls_roles:removeRoleLabel", -1, src)
end)

RegisterCommand("rolesrefresh", function(src)
    if src == 0 then
        print("[LS Discord Roles] Refreshing all players...")
        for _, id in ipairs(GetPlayers()) do
            ensureCached(tonumber(id), true, function(entry)
                TriggerClientEvent("ls_roles:updateRoleLabel", -1, tonumber(id), entry.label, entry.roleId)
            end)
        end
        return
    end
    ensureCached(src, true, function(entry)
        TriggerClientEvent("ls_roles:updateRoleLabel", -1, src, entry.label, entry.roleId)
        TriggerClientEvent("chat:addMessage", src, { args = { "^2Roles", "Your Discord roles were refreshed." } })
    end)
end, true)

AddEventHandler("chatMessage", function(src, name, msg)
    CancelEvent()
    ensureCached(src, false, function(entry)
        local prefix = ""
        local color = { 255, 255, 255 }
        if entry and entry.label then
            prefix = "[" .. entry.label .. "] "
            local roleCfg = Config.RoleMap[entry.roleId or ""]
            if roleCfg and roleCfg.chatColor then
                color = roleCfg.chatColor
            end
        end
        TriggerClientEvent("chat:addMessage", -1, {
            color = color,
            args = { prefix .. name, msg }
        })
    end)
end)

-- API export for other resources
exports("GetPlayerRoleLabel", function(src)
    local entry = playerCache[src]
    return entry and entry.label or nil
end)

-- Provide labels to clients on request
RegisterNetEvent("ls_roles:requestLabels", function()
    local src = source
    for _, id in ipairs(GetPlayers()) do
        local entry = playerCache[tonumber(id)]
        if entry then
            TriggerClientEvent("ls_roles:updateRoleLabel", src, tonumber(id), entry.label, entry.roleId)
        end
    end
end)

-- === Fleet Menu / Permissions (merged from v2) ===

local function getPlayerRoleIds(src)
    local done = promise.new()
    ensureCached(src, false, function(entry)
        if entry and entry.discordId then
            -- Ensure we have fresh roles if cache is stale handled by ensureCached
            done:resolve(entry.roles or {})
        else
            done:resolve({})
        end
    end)
    return Citizen.Await(done)
end

local function hasAnyRole(roleIdsSet, allowed)
    if not allowed or #allowed == 0 then return true end
    local set = {}
    for _, r in ipairs(roleIdsSet) do set[r] = true end
    for _, a in ipairs(allowed) do
        if set[a] then return true end
    end
    return false
end

local function buildMenuForPlayer(src)
    local roleIds = getPlayerRoleIds(src)
    local function filterNode(node)
        if not hasAnyRole(roleIds, node.rolesAllowed) then return nil end
        local out = {
            name = node.name,
            vehicles = node.vehicles or {},
            subdepartments = {}
        }
        if node.subdepartments then
            for _, sub in ipairs(node.subdepartments) do
                local filtered = filterNode(sub)
                if filtered then table.insert(out.subdepartments, filtered) end
            end
        end
        return out
    end

    local result = {}
    for _, dept in ipairs(Config.Departments or {}) do
        local filtered = filterNode(dept)
        if filtered then table.insert(result, filtered) end
    end
    return result
end

RegisterNetEvent("ls_roles:requestFleetMenu", function()
    local src = source
    local menu = buildMenuForPlayer(src)
    TriggerClientEvent("ls_roles:receiveFleetMenu", src, menu)
end)

RegisterNetEvent("ls_roles:spawnVehicleRequest", function(path, model)
    local src = source
    local menu = buildMenuForPlayer(src)

    local function walk(nodes, depth)
        if depth > #path then return nodes, nil end
        for _, n in ipairs(nodes) do
            if n.name == path[depth] then
                if depth == #path then
                    return n.subdepartments or {}, n
                else
                    return walk(n.subdepartments or {}, depth + 1)
                end
            end
        end
        return nil, nil
    end

    local _, node = walk(menu, 1)
    if not node then return end

    local ok = false
    for _, v in ipairs(node.vehicles or {}) do
        if v.model == model then ok = true break end
    end
    if not ok then return end

    TriggerClientEvent("ls_roles:spawnVehicle", src, model)
end)
