Config = {}

-- Default officer name and unit/callsign.
-- Players can override unit live with /setcallsign 123 if you enable AllowSetCallsign.
Config.OfficerNameSource = 'playername'  -- 'playername' or 'static'
Config.StaticOfficerName = 'Officer Smith'

Config.DefaultCallsign = 'P-101'
Config.AllowSetCallsign = true

-- Overlay tweaks
Config.ShowAgency = true
Config.AgencyText  = 'Los Sacros'
Config.ShowGPS     = true         -- shows player street/area at the bottom of the box
Config.ShowBattery = true         -- fun cosmetic battery icon (not tied to anything)
Config.Use24hClock = true

-- Sound settings
Config.ActivateSound = 'activate.ogg'   -- file inside html/sounds
Config.DeactivateSound = nil            -- e.g. 'deactivate.ogg' or nil to skip
Config.PeriodicBeepSound = 'periodic.ogg'  -- soft beep while recording (nil to disable)
Config.PeriodicBeepInterval = 30           -- seconds between periodic beeps (set nil to disable)
Config.Volume = 0.45                       -- 0.0 - 1.0

-- Hotkeys (optional)
Config.EnableHotkey = true
Config.Hotkey = 'F6' -- also has /bodycam command

-- UI position/scale
Config.Position = 'top-right'  -- 'top-right' (default), 'top-left'
Config.Scale = 1.0             -- 1.0 = 100%
