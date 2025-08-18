local function getSpawnCodeFromVeh(veh)
    if not veh or not DoesEntityExist(veh) then return nil end
    local model = GetEntityModel(veh)
    local code = GetDisplayNameFromVehicleModel(model) or ''
    return string.lower(code)
end

local function getBootTypeFromVeh(veh)
    local code = getSpawnCodeFromVeh(veh)
    if not code then return nil, nil end
    local btname = Config.VehicleBootType[code]
    if not btname then return nil, code end
    local btype = Config.BootTypes[btname]
    return btype, code, btname
end

local function openCategoryMenu(category, entries, code, btname)
    if not entries or #entries == 0 then
        lib.notify({ title = 'Boot', description = ('No %s configured for type "%s" (%s)'):format(category, btname or 'n/a', code or 'n/a'), type = 'error' })
        return
    end

    local opts = {}
    for i, entry in ipairs(entries) do
        opts[#opts+1] = {
            title = entry.label or ('Entry %d'):format(i),
            description =
                (entry.item and entry.count) and (('Item: %s • x%d'):format(entry.item, entry.count))
                or (entry.weapon and ('Weapon: %s'):format(entry.weapon))
                or nil,
            icon = category == 'weapons' and 'gun' or 'box',
            onSelect = function()
                if entry.item then
                    TriggerServerEvent('boot_menu:giveItem', entry.item, entry.count or 1)
                elseif entry.weapon then
                    TriggerServerEvent('boot_menu:giveWeapon', entry.weapon, entry.ammo or 0, entry.components or {})
                else
                    lib.notify({ title = 'Boot', description = 'Invalid entry (no item/weapon). Check config.', type = 'error' })
                end
            end
        }
    end

    lib.registerContext({
        id = 'boot_menu:cat:' .. category,
        title = ('Boot • %s'):format(category:gsub("^%l", string.upper)),
        options = opts
    })
    lib.showContext('boot_menu:cat:' .. category)
end

local function openBootMenu(veh)
    local btype, code, btname = getBootTypeFromVeh(veh)
    if not btype then
        lib.notify({ title = 'Boot', description = ('No boot type mapped for "%s"'):format(code or 'unknown'), type = 'error' })
        return
    end

    lib.registerContext({
        id = 'boot_menu:root',
        title = ('Boot • %s (%s)'):format(code, btname),
        options = {
            { title = 'Clothing',  icon = 'shirt', onSelect = function() openCategoryMenu('clothing',  btype.clothing,  code, btname) end },
            { title = 'Equipment', icon = 'tool',  onSelect = function() openCategoryMenu('equipment', btype.equipment, code, btname) end },
            { title = 'Props',     icon = 'boxes', onSelect = function() openCategoryMenu('props',     btype.props,     code, btname) end },
            { title = 'Weapons',   icon = 'gun',   onSelect = function() openCategoryMenu('weapons',   btype.weapons,   code, btname) end },
        }
    })
    lib.showContext('boot_menu:root')
end

-- Add ox_target interaction on vehicle trunk
CreateThread(function()
    exports.ox_target:addGlobalVehicle({
        {
            name = 'boot_menu:open',
            icon = 'fa-solid fa-box-open',
            label = 'Open Boot',
            bones = { 'boot' },
            distance = Config.TargetDistance or 2.0,
            onSelect = function(data)
                if not data or not data.entity then return end
                openBootMenu(data.entity)
            end
        }
    })
end)

-- Fallback: command for testing
RegisterCommand('boot', function()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh == 0 then
        -- try vehicle in front of player
        local coords = GetEntityCoords(ped)
        local forward = GetEntityForwardVector(ped)
        local to = coords + (forward * 2.0)
        local ray = StartShapeTestRay(coords.x, coords.y, coords.z, to.x, to.y, to.z, 10, ped, 0)
        local _, hit, _, _, ent = GetShapeTestResult(ray)
        if hit == 1 and IsEntityAVehicle(ent) then veh = ent end
    end
    if veh ~= 0 then openBootMenu(veh) end
end, false)

-- Client helper for direct-give weapons (when not using ox_inventory)
RegisterNetEvent('boot_menu:clientGiveWeapon', function(weapon, ammo, components)
    local ped = PlayerPedId()
    if not ped then return end
    GiveWeaponToPed(ped, joaat(weapon), ammo or 0, false, true)
    if components then
        for _, comp in ipairs(components) do
            GiveWeaponComponentToPed(ped, joaat(weapon), joaat(comp))
        end
    end
    lib.notify({ title = 'Boot', description = ('Given %s'):format(weapon), type = 'success' })
end)
