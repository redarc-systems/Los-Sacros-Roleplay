local myLabel = nil
local labels = {} -- [serverId] = { label="Admin", roleId="..." }

RegisterNetEvent("ls_roles:setOwnRoleLabel", function(label, roleId)
    myLabel = label
end)

RegisterNetEvent("ls_roles:updateRoleLabel", function(serverId, label, roleId)
    labels[serverId] = { label = label, roleId = roleId }
end)

RegisterNetEvent("ls_roles:removeRoleLabel", function(serverId)
    labels[serverId] = nil
end)

CreateThread(function()
    Wait(3000)
    TriggerServerEvent("ls_roles:requestLabels")
end)

-- === 3D head tags ===
local function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local camCoords = GetGameplayCamCoords()
    local dist = #(vector3(x, y, z) - camCoords)

    local scale = (1 / dist) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov

    if onScreen then
        SetTextScale(0.35 * scale, 0.35 * scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextOutline()
        SetTextCentre(1)
        BeginTextCommandDisplayText("STRING")
        AddTextComponentSubstringPlayerName(text)
        EndTextCommandDisplayText(_x, _y)
    end
end

CreateThread(function()
    while true do
        if Config.EnableHeadTags then
            local myPed = PlayerPedId()
            local myCoords = GetEntityCoords(myPed)
            for _, pid in ipairs(GetActivePlayers()) do
                local sid = GetPlayerServerId(pid)
                local data = labels[sid]
                if data and data.label then
                    local ped = GetPlayerPed(pid)
                    if DoesEntityExist(ped) then
                        local pedCoords = GetEntityCoords(ped)
                        local dist = #(myCoords - pedCoords)
                        if dist <= Config.HeadTagDistance then
                            local x, y, z = table.unpack(GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.0, 1.05))
                            DrawText3D(x, y, z + 0.25, ("[%s]"):format(data.label))
                        end
                    end
                end
            end
        end
        Wait(0)
    end
end)
