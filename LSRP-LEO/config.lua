Config = {}


-- Departments shown in the on-duty picker
Config.Departments = {
{ id = 'lspd', label = 'LSPD' },
{ id = 'bcso', label = 'BCSO' },
{ id = 'sahp', label = 'SAHP' },
{ id = 'sasp', label = 'SASP' },
}


-- Weapon loadout given on duty
Config.Loadout = {
{ weapon = `WEAPON_STUNGUN` },
{ weapon = `WEAPON_NIGHTSTICK` },
{ weapon = `WEAPON_FLASHLIGHT` },
{ weapon = `WEAPON_FIREEXTINGUISHER` },
{ weapon = `WEAPON_COMBATPISTOL`, components = { `COMPONENT_AT_PI_FLSH` } },
}


-- Animations and props
Config.Anims = {
cuff = { dict = 'mp_arresting', name = 'a_uncuff' }, -- short cuff-like anim
search = { dict = 'amb@prop_human_bum_bin@base', name = 'base' },
write = { dict = 'amb@world_human_clipboard@male@base', name = 'base' },
}


-- Handcuff prop model
Config.CuffProp = `p_cs_cuffs_02_s`


-- Discord webhook URL (server-side). Put your webhook URL here.
Config.DiscordWebhook = ''


-- Blip + sound when /code99 is used
Config.Code99 = {
blipSprite = 161, -- radius blip
blipColour = 1, -- red
blipScale = 1.2,
fadeTime = 60, -- seconds blip + looped notify stays
}


-- Command names
Config.Commands = {
onDuty = 'onduty',
offDuty = 'offduty',
bodycam = 'bodycam',
code99 = 'code99'
}


-- Whether only on-duty cops can target options
Config.RequireDutyForTarget = true
