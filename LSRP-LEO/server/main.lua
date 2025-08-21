local onDuty = {} -- [source] = { dept = 'lspd' }


local function sendDiscord(title, description, color)
if not Config.DiscordWebhook or Config.DiscordWebhook == '' then return end
local payload = json.encode({
username = 'LEO System',
embeds = {{ title = title, description = description, color = color or 16711680, timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ') }}
})
PerformHttpRequest(Config.DiscordWebhook, function(err, text, headers) end, 'POST', payload, { ['Content-Type'] = 'application/json' })
end


RegisterNetEvent('leo:server:dutyChange', function(state, dept)
local src = source
if state then
onDuty[src] = { dept = dept }
sendDiscord('On Duty', ('Officer %s is now on duty (%s).'):format(src, dept or 'unknown'), 5763719)
else
onDuty[src] = nil
sendDiscord('Off Duty', ('Officer %s has gone off duty.'):format(src), 9807270)
end
end)


AddEventHandler('playerDropped', function()
local src = source
onDuty[src] = nil
cuffStates[src] = nil
dragging[src] = nil
end)


-- Cuff/uncuff toggle
RegisterNetEvent('leo:cuffToggle', function(target)
local src = source
if not onDuty[src] then return end
local state = not cuffStates[target]
cuffStates[target] = state
TriggerClientEvent('leo:client:setCuffed', target, state)
end)


-- Drag toggle
RegisterNetEvent('leo:dragToggle', function(target)
local src = source
if not onDuty[src] then return end
if dragging[target] == src then
dragging[target] = nil
TriggerClientEvent('leo:client:dragBy', target, src, false)
else
dragging[target] = src
TriggerClientEvent('leo:client:dragBy', target, src, true)
end
end)


-- Search prompt
RegisterNetEvent('leo:requestSearchResult', function(target)
local src = source
if not onDuty[src] then return end
TriggerClientEvent('leo:client:searchPrompt', target, src)
end)


RegisterNetEvent('leo:returnSearchResult', function(officerId, text)
local src = source
TriggerClientEvent('leo:client:receiveSearch', officerId, text, src)
end)


-- Code 99
RegisterNetEvent('leo:server:code99', function(coords)
local src = source
-- notify all on-duty players
for id,_ in pairs(onDuty) do
TriggerClientEvent('leo:client:code99', id, coords, src)
end
sendDiscord('CODE 99', ('Officer %s issued CODE 99 at (%.2f, %.2f, %.2f)').format and ('Officer %s issued CODE 99 at (%.2f, %.2f, %.2f)'):format(src, coords.x, coords.y, coords.z) or ('Officer '..src..' issued CODE 99'), 15158332)
end)
