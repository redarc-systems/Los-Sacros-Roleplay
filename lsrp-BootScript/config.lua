Config = {}

-- Interaction distance at the trunk
Config.TargetDistance = 2.0

-- If true, we will try to use ox_inventory when available; otherwise fallback to notify only for "items".
Config.UseOxInventoryIfAvailable = true

-- 3A) Define reusable "boot types"
-- Each category is an array of entries.
-- Entry (item form):   { label='Repair Kit', item='repairkit', count=1 }
-- Entry (weapon form): { label='Pistol (60)', weapon='weapon_pistol', ammo=60, components={'COMPONENT_AT_PI_FLSH'} }

Config.BootTypes = {
    police_standard = {
        clothing = {
            { label = 'High-Vis Vest', item = 'highvis', count = 1 },
            { label = 'Body Armour',   item = 'armour',  count = 1 },
        },
        equipment = {
            { label = 'First Aid Kit', item = 'firstaid', count = 2 },
            { label = 'Repair Kit',    item = 'repairkit', count = 1 },
            { label = 'Torch',         item = 'flashlight', count = 1 },
        },
        props = {
            { label = 'Traffic Cone x4', item = 'trafficcone', count = 4 },
            { label = 'Road Barrier',    item = 'roadbarrier', count = 1 },
        },
        weapons = {
            { label = 'Taser', item = 'weapon_stungun', count = 1 }, -- as inventory item if ox_inventory
            { label = 'Pistol (60)', weapon = 'weapon_pistol', ammo = 60, components={'COMPONENT_AT_PI_FLSH'} },
        }
    },

    ambulance_basic = {
        clothing = {
            { label = 'Paramedic Jacket', item = 'ems_jacket', count = 1 },
        },
        equipment = {
            { label = 'Med Bag',       item = 'medbag', count = 1 },
            { label = 'Defibrillator', item = 'defib',  count = 1 },
        },
        props = {
            { label = 'Stretcher', item = 'stretcher', count = 1 },
        },
        weapons = {} -- none
    },

    traffic_unit = {
        clothing = {
            { label = 'High-Vis Vest', item = 'highvis', count = 1 },
        },
        equipment = {
            { label = 'Flares x6', item = 'flare', count = 6 },
            { label = 'Repair Kit', item = 'repairkit', count = 1 },
        },
        props = {
            { label = 'Cones x8', item = 'trafficcone', count = 8 },
            { label = 'Barriers x2', item = 'roadbarrier', count = 2 },
        },
        weapons = {
            { label = 'SMG (150)', weapon = 'weapon_smg', ammo = 150, components={'COMPONENT_AT_AR_FLSH'} },
        }
    },
}

-- 3B) Map vehicle spawn codes → boot types (lowercase keys!)
-- Example: ["police3"] = "police_standard"
Config.VehicleBootType = {
    police = 'police_standard',
    police2 = 'police_standard',
    police3 = 'police_standard',
    pranger = 'traffic_unit',
    ambulance = 'ambulance_basic',
    firetruk = 'traffic_unit',
    -- add as many as you like:
    -- ["spawncode"] = "boottype"
}
