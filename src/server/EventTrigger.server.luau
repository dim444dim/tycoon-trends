--[[
	EventTrigger.server.luau (TycoonTrends)
	Spawn automatique d'événements tendance (Twitch Raid, Rap Drop, TikTok Viral).
	40% de chance par seconde d'activer un event si aucun n'est en cours.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players           = game:GetService("Players")

local Remotes = require(ReplicatedStorage.Shared.Remotes)

local EVENTS = {
	{
		id         = "twitch_raid",
		name       = "🎮 Streamer Raid",
		multiplier = 1.5,
		duration   = 3600,
		color      = Color3.fromRGB(145, 70, 255),
	},
	{
		id         = "rapper_drop",
		name       = "🎤 Rap Drop",
		multiplier = 2.0,
		duration   = 1800,
		color      = Color3.fromRGB(255, 50, 50),
	},
	{
		id         = "tiktok_trend",
		name       = "📱 TikTok Viral",
		multiplier = 1.3,
		duration   = 900,
		color      = Color3.fromRGB(0, 0, 0),
	},
}

local activeEvent = nil -- { id, endTime }

local function clearEvent()
	activeEvent = nil
	for _, player in Players:GetPlayers() do
		player:SetAttribute("EventMultiplier", 1.0)
	end
	Remotes.EventEnded:FireAllClients()
	print("[EventTrigger] Événement terminé")
end

local function spawnEvent(event)
	local endTime = tick() + event.duration
	activeEvent = { id = event.id, endTime = endTime }
	for _, player in Players:GetPlayers() do
		player:SetAttribute("EventMultiplier", event.multiplier)
	end
	Remotes.EventStarted:FireAllClients({
		eventId    = event.id,
		name       = event.name,
		multiplier = event.multiplier,
		duration   = event.duration,
		color      = event.color,
	})
	print(string.format("[EventTrigger] %s démarré (×%.1f, %ds)", event.name, event.multiplier, event.duration))
end

-- Sync EventMultiplier pour les joueurs qui rejoignent en cours d'event
Players.PlayerAdded:Connect(function(player)
	if activeEvent then
		for _, ev in ipairs(EVENTS) do
			if ev.id == activeEvent.id then
				player:SetAttribute("EventMultiplier", ev.multiplier)
				return
			end
		end
	end
	player:SetAttribute("EventMultiplier", 1.0)
end)

task.spawn(function()
	while true do
		task.wait(1)

		if activeEvent then
			if tick() >= activeEvent.endTime then
				clearEvent()
			end
		else
			if math.random() < 0.40 then
				local event = EVENTS[math.random(#EVENTS)]
				spawnEvent(event)
			end
		end
	end
end)

print("[EventTrigger] ✅ EventTrigger loaded")
