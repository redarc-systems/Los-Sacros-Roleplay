local fleetMenu = nil
local menuOpen = false
local cursor = { stack = {}, index = 1 }
local breadcrumb = {}

-- Command to open
RegisterCommand("fleet", function()
    if menuOpen then return end
    menuOpen = true
    breadcrumb = {}
    cursor.stack = {}
    cursor.index = 1
    TriggerServerEvent("ls_roles:requestFleetMenu")
    TriggerEvent("chat:addMessage", { args = { "^3Fleet", Config.MenuKeyHint or "/fleet" } })
end)

RegisterNetEvent("ls_roles:receiveFleetMenu", function(menu)
    fleetMenu = menu or {}
    cursor.stack = { { nodes = fleetMenu, isVehicles = false } }
    cursor.index = 1
end)

-- UI helpers
local function drawTxt(x, y, scale, text, center)
    SetTextFont(4)
    SetTextScale(scale, scale)
    SetTextColour(255,255,255,255)
    SetTextOutline()
    SetTextCentre(center and 1 or 0)
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x, y)
end

local function drawRect(x, y, w, h, r, g, b, a)
    DrawRect(x + w/2, y + h/2, w, h, r, g, b, a)
end

local function currentLevel()
    return cursor.stack[#cursor.stack]
end

local function buildEntries(level)
    if level.isVehicles then
        return level.vehicles
    else
        local entries = {}
        for _, n in ipairs(level.nodes or {}) do
            table.insert(entries, { kind = "node", name = n.name, node = n })
        end
        return entries
    end
end

local function pushNode(node)
    if node.subdepartments and #node.subdepartments > 0 then
        table.insert(cursor.stack, { nodes = node.subdepartments, isVehicles = false, parent = node })
        table.insert(breadcrumb, node.name)
        cursor.index = 1
    elseif node.vehicles and #node.vehicles > 0 then
        table.insert(cursor.stack, { isVehicles = true, vehicles = node.vehicles, parent = node })
        table.insert(breadcrumb, node.name)
        cursor.index = 1
    end
end

local function popNode()
    if #cursor.stack > 1 then
        table.remove(cursor.stack)
        table.remove(breadcrumb)
        cursor.index = 1
    else
        menuOpen = false
    end
end

-- Draw + Input loop
CreateThread(function()
    while true do
        if menuOpen and fleetMenu then
            DisableControlAction(0, 200, true) -- pause
            local lvl = currentLevel()
            local entries = buildEntries(lvl)

            local baseX, baseY, width, rowH = 0.78, 0.22, 0.2, 0.032
            drawRect(baseX, baseY, width, 0.04, 0, 0, 0, 180)
            drawTxt(baseX + width/2, baseY + 0.005, 0.32, "~w~Fleet Menu", true)

            local bc = table.concat(breadcrumb, " / ")
            drawTxt(baseX + 0.005, baseY + 0.035, 0.28, bc, false)
            drawTxt(baseX + 0.005, baseY + 0.065, 0.26, "↑ ↓ Select • Enter Confirm • Backspace Back", false)

            local listY = baseY + 0.085
            local visible = math.min(#entries, 12)
            for i = 1, visible do
                local y = listY + (i-1)*(rowH+0.003)
                local selected = (i == cursor.index)
                drawRect(baseX, y, width, rowH, selected and 60 or 20, selected and 120 or 20, selected and 255 or 20, 180)
                local label
                if lvl.isVehicles then
                    label = entries[i].label .. "  [" .. entries[i].model .. "]"
                else
                    label = "→ " .. entries[i].name
                end
                drawTxt(baseX + 0.005, y + 0.005, 0.32, label, false)
            end

            -- Controls
            if IsControlJustPressed(0, 172) then -- UP
                cursor.index = cursor.index > 1 and (cursor.index - 1) or math.max(#entries,1)
            elseif IsControlJustPressed(0, 173) then -- DOWN
                cursor.index = cursor.index < #entries and (cursor.index + 1) or 1
            elseif IsControlJustPressed(0, 191) then -- ENTER
                if #entries > 0 then
                    if lvl.isVehicles then
                        local chosen = entries[cursor.index]
                        local path = {}
                        for _, seg in ipairs(breadcrumb) do table.insert(path, seg) end
                        TriggerServerEvent("ls_roles:spawnVehicleRequest", path, chosen.model)
                    else
                        pushNode(entries[cursor.index].node)
                    end
                end
            elseif IsControlJustPressed(0, 177) then -- BACKSPACE
                popNode()
            end
        end
        Wait(0)
    end
end)

-- Server-approved spawn
RegisterNetEvent("ls_roles:spawnVehicle", function(model)
    local mhash = GetHashKey(model)
    if not IsModelInCdimage(mhash) then
        TriggerEvent("chat:addMessage", { args = { "^1Fleet", "Model not found: "..model } })
        return
    end

    RequestModel(mhash)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(mhash) and GetGameTimer() < timeout do
        Wait(0)
    end
    if not HasModelLoaded(mhash) then
        TriggerEvent("chat:addMessage", { args = { "^1Fleet", "Failed to load model: "..model } })
        return
    end

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    local forward = GetEntityForwardVector(ped)

    local spawnPos
    if Config.SpawnAtPlayer then
        spawnPos = coords + forward * 3.0
    else
        spawnPos = coords + forward * 5.0
    end

    local veh = GetClosestVehicle(spawnPos.x, spawnPos.y, spawnPos.z, Config.SpawnClearRadius or 3.0, 0, 70)
    if veh ~= 0 and DoesEntityExist(veh) then
        SetEntityAsMissionEntity(veh, true, true)
        DeleteVehicle(veh)
    end

    local vehicle = CreateVehicle(mhash, spawnPos.x, spawnPos.y, spawnPos.z, heading, true, false)
    if not DoesEntityExist(vehicle) then
        SetModelAsNoLongerNeeded(mhash)
        TriggerEvent("chat:addMessage", { args = { "^1Fleet", "Could not create vehicle." } })
        return
    end

    SetPedIntoVehicle(ped, vehicle, -1)
    SetVehicleOnGroundProperly(vehicle)
    SetEntityAsMissionEntity(vehicle, true, true)
    SetVehicleDirtLevel(vehicle, 0.0)
    SetVehicleHasBeenOwnedByPlayer(vehicle, true)
    SetModelAsNoLongerNeeded(mhash)
    SetVehicleNumberPlateText(vehicle, "LS-FLEET")

    TriggerEvent("chat:addMessage", { args = { "^2Fleet", ("Spawned %s"):format(model) } })
end)
