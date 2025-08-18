local useOx = Config.UseOxInventoryIfAvailable and (GetResourceState('ox_inventory') == 'started')

print(('[boot_menu] Standalone mode. ox_inventory detected: %s'):format(useOx and 'yes' or 'no'))

local function giveItem(src, item, count)
    count = tonumber(count) or 1

    if useOx then
        local ok = exports.ox_inventory:AddItem(src, item, count)
        if not ok then
            TriggerClientEvent('ox_lib:notify', src, { title = 'Boot', description = ('No space for %s x%d'):format(item, count), type = 'error' })
        end
        return
    end

    -- Pure standalone fallback: we can’t “store” items without an inventory.
    -- Be transparent so admins know nothing was lost silently.
    TriggerClientEvent('ox_lib:notify', src, { title = 'Boot', description = ('(Standalone) Would give %s x%d'):format(item, count), type = 'inform' })
end

local function giveWeapon(src, weapon, ammo, components)
    ammo = tonumber(ammo) or 0
    components = components or {}

    if useOx then
        exports.ox_inventory:AddItem(src, weapon, 1, { ammo = ammo, components = components })
        return
    end

    -- Direct to ped
    TriggerClientEvent('boot_menu:clientGiveWeapon', src, weapon, ammo, components)
end

RegisterNetEvent('boot_menu:giveItem', function(item, count)
    local src = source
    if type(item) ~= 'string' then return end
    giveItem(src, item, count)
end)

RegisterNetEvent('boot_menu:giveWeapon', function(weapon, ammo, components)
    local src = source
    if type(weapon) ~= 'string' then return end
    giveWeapon(src, weapon, ammo, components)
end)
