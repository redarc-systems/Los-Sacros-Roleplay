Config = {}

-- === Discord Guild ===
-- Your Discord guild (server) ID as a string
Config.GuildId = "123456789012345678"

-- === Role Mapping (for tags/colors/priorities) ===
-- Map Discord Role IDs => label + optional chat/head-tag colors
-- Use real role IDs (not names).
Config.RoleMap = {
  ["111111111111111111"] = { label = "Owner",  chatColor = {255, 255, 255}, headColor = {255, 255, 255} },
  ["222222222222222222"] = { label = "Admin",  chatColor = {255,   0,   0}, headColor = {255,   0,   0} },
  ["333333333333333333"] = { label = "Mod",    chatColor = {  0, 153, 255}, headColor = {  0, 153, 255} },
  ["444444444444444444"] = { label = "Staff",  chatColor = {  0, 255, 128}, headColor = {  0, 255, 128} },
  ["555555555555555555"] = { label = "Police", chatColor = { 70, 150, 255}, headColor = { 70, 150, 255} },
  ["777777777777777777"] = { label = "Fire",   chatColor = {255, 100,   0}, headColor = {255, 100,   0} },
  ["666666666666666666"] = { label = "SWAT",   chatColor = {200, 200, 200}, headColor = {200, 200, 200} },
}

-- If a user has multiple mapped roles, we choose the highest in this priority list
Config.RolePriority = {
  "111111111111111111", -- Owner
  "222222222222222222", -- Admin
  "333333333333333333", -- Mod
  "444444444444444444", -- Staff
  "555555555555555555", -- Police
  "777777777777777777", -- Fire
  "666666666666666666", -- SWAT
}

-- How often to refresh cached discord roles (seconds)
Config.RefreshSeconds = 300

-- Head tags
Config.EnableHeadTags   = true
Config.HeadTagDistance  = 25.0

-- === Role-Gated Departments / Fleet Menu ===
-- Players gain access to a department if they have ANY role in `rolesAllowed`.
-- Each department may define `vehicles` and/or nested `subdepartments`.
Config.Departments = {
  {
    name = "Police",
    rolesAllowed = {
      "222222222222222222", -- Admin
      "333333333333333333", -- Mod
      "555555555555555555", -- Police role
    },
    vehicles = {
      { label = "Patrol Cruiser", model = "police"  },
      { label = "Interceptor",    model = "police2" },
      { label = "Unmarked",       model = "police4" },
    },
    subdepartments = {
      {
        name = "SWAT",
        rolesAllowed = { "222222222222222222", "666666666666666666" },
        vehicles = {
          { label = "BearCat",      model = "riot"  },
          { label = "Tactical SUV", model = "fbi2"  },
        }
      },
      {
        name = "Traffic",
        rolesAllowed = { "555555555555555555" },
        vehicles = {
          { label = "Motor Unit",      model = "policeb" },
          { label = "Traffic Charger", model = "police3" },
        }
      }
    }
  },
  {
    name = "Fire",
    rolesAllowed = {
      "444444444444444444", -- Staff
      "777777777777777777", -- Fire role
    },
    vehicles = {
      { label = "Fire Engine", model = "firetruk"    },
      { label = "Brush Truck", model = "boattrailer" }, -- replace with your add-on
    },
    subdepartments = {
      {
        name = "Rescue/EMS",
        rolesAllowed = { "777777777777777777" },
        vehicles = {
          { label = "Ambulance",  model = "ambulance" },
          { label = "Rescue SUV", model = "granger"   }, -- replace with your pack model
        }
      }
    }
  }
}

-- Spawning options
Config.SpawnAtPlayer     = true          -- if false, spawns a bit ahead
Config.SpawnClearRadius  = 3.0           -- clears nearby vehicles at spawn point
Config.MenuKeyHint       = "/fleet (use ↑ ↓ Enter Backspace)"
