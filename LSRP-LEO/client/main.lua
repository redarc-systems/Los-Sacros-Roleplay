local duty = false
end)
end)


-- Commands
RegisterCommand(Config.Commands.onDuty, function()
if duty then return notify('LEO', 'You are already on duty.', 'inform') end
-- Department picker
local options = {}
for i, d in ipairs(Config.Departments) do options[#options+1] = d.label end
local input = lib.inputDialog('Go On Duty', {
{ type = 'select', label = 'Department', options = options, required = true }
})
if not input then return end
local label = input[1]
for _, d in ipairs(Config.Departments) do if d.label == label then dept = d.id break end end
duty = true
giveLoadout()
registerTargets()
notify('On Duty', ('You are now on duty (%s).'):format(label), 'success')
TriggerServerEvent('leo:server:dutyChange', true, dept)
end)


RegisterCommand(Config.Commands.offDuty, function()
if not duty then return notify('LEO', 'You are not on duty.', 'inform') end
duty = false
dept = nil
notify('Off Duty', 'You are now off duty.', 'inform')
TriggerServerEvent('leo:server:dutyChange', false, nil)
end)


RegisterCommand(Config.Commands.bodycam, function()
if not duty then return notify('LEO', 'Go on duty to use bodycam.', 'error') end
-- Bridge: emit an event your separate bodycam script listens for
TriggerEvent('bodycam:toggle')
end)


RegisterCommand(Config.Commands.code99, function()
if not duty then return notify('LEO', 'You must be on duty to call Code 99.', 'error') end
local ped = PlayerPedId()
local coords = GetEntityCoords(ped)
TriggerServerEvent('leo:server:code99', coords)
end)


-- Disable controls while cuffed
CreateThread(function()
while true do
if cuffed then
DisableControlAction(0, 21, true) -- sprint
DisableControlAction(0, 24, true) -- attack
DisableControlAction(0, 25, true) -- aim
DisableControlAction(0, 22, true) -- jump
DisableControlAction(0, 23, true) -- enter vehicle
DisableControlAction(0, 75, true) -- exit vehicle
end
Wait(0)
end
end)
