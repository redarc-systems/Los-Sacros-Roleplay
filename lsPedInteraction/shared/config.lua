Config = {}

-- === Target system ===
-- Use 'ox_target' by default. If using another target, call our exports yourself.
Config.Target = 'ox_target'
Config.TargetDistance = 2.0

-- === Permissions (standalone) ===
-- 'everyone'  -> anybody can cuff/escort
-- 'ace'       -> only players with ACE permission 'rcuffs.cuff'
Config.PermissionMode = 'everyone'  -- 'everyone' or 'ace'
Config.AcePermission  = 'rcuffs.cuff'

-- === Cuff prop/model ===
-- If you stream your own cuffs, set the model name here (e.g. 'my_cuffs').
-- GTA stock prop (good fallback): 'p_cs_cuffs_02_s'
Config.CuffModel = 'p_cs_cuffs_02_s'

Config.Attach = {
    bone = 57005, -- SKEL_R_Hand
    pos  = vec3(0.10, 0.03, 0.0),
    rot  = vec3(90.0, 0.0, 80.0)
}

-- === Animations ===
Config.Anims = {
    officer   = { dict = 'mp_arrest_paired', anim = 'cop_p2_back_left' },
    suspect   = { dict = 'mp_arrest_paired', anim = 'crook_p2_back_left' },
    idleCuffed = { dict = 'mp_arresting',    anim = 'idle' }
}

-- === Optional sound (InteractSound or fallback UI click) ===
Config.Sound = {
    useInteractSound = true,
    soundName = 'cuff',   -- put cuff.ogg in interact-sound/client/html/sounds/
    volume = 0.6
}

-- === Escort settings ===
Config.Escort = {
    offset = vec3(0.54, 0.48, 0.0),
    bone   = 11816  -- SKEL_R_Hand
}

Config.Keys = {
    stopEscort = 'X'
}

-- Safety checks (server-side distance/LOS caps)
Config.MaxCuffDistance   = 3.0
Config.RequireLineOfSight = true
