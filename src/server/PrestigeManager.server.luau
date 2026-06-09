--[[
	PrestigeManager.server.luau (TycoonTrends)
	Réinitialise le joueur (bâtiments + cash) en échange d'un multiplicateur permanent.

	DataStore dédié "TycoonTrendsPrestige_v1" — indépendant de DataStoreStats.
	Données persistées : prestige_multiplier, PrestigeCount.

	Flow :
	  PlayerAdded        → charge prestige depuis DataStore → SetAttribute
	  PrestigeReset (RE) → valide tier → reset → sauvegarde → FireClient
	  PlayerRemoving     → sauvegarde finale
]]

local Players           = game:GetService("Players")
local DataStoreService  = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig     = require(ReplicatedStorage.Shared.GameConfig)
local GameplayConfig = require(ReplicatedStorage.Shared.GameplayConfig)
local Remotes        = require(ReplicatedStorage.Shared.Remotes)

print("[PrestigeManager] loaded")

-- ───────── DATASTORE ─────────

local prestigeStore
local datastoreEnabled = true
do
	local ok, ds = pcall(function()
		return DataStoreService:GetDataStore("TycoonTrendsPrestige_v1")
	end)
	if ok then
		prestigeStore = ds
	else
		datastoreEnabled = false
		warn("[PrestigeManager] DataStore indisponible — fallback RAM")
	end
end

local function safeGet(key)
	if not datastoreEnabled then return nil end
	for attempt = 1, GameplayConfig.DataStoreRetryCount do
		local ok, result = pcall(function()
			return prestigeStore:GetAsync(key)
		end)
		if ok then return result end
		warn(string.format("[PrestigeManager] GetAsync fail (%d/%d): %s",
			attempt, GameplayConfig.DataStoreRetryCount, tostring(result)))
		task.wait(GameplayConfig.DataStoreRetryDelay)
	end
	return nil
end

local function safeSet(key, value)
	if not datastoreEnabled then return end
	for attempt = 1, GameplayConfig.DataStoreRetryCount do
		local ok, err = pcall(function()
			prestigeStore:SetAsync(key, value)
		end)
		if ok then return end
		warn(string.format("[PrestigeManager] SetAsync fail (%d/%d): %s",
			attempt, GameplayConfig.DataStoreRetryCount, tostring(err)))
		task.wait(GameplayConfig.DataStoreRetryDelay)
	end
end

local function prestigeKey(player)
	return "prestige_" .. tostring(player.UserId)
end

-- ───────── LOAD / SAVE ─────────

local function loadPrestige(player)
	local data       = safeGet(prestigeKey(player))
	local multiplier = (data and data.multiplier) or 1.0
	local count      = (data and data.count)      or 0
	player:SetAttribute("prestige_multiplier", multiplier)
	player:SetAttribute("PrestigeCount",        count)
	print(string.format("[PrestigeManager] %s → ×%.2f (prestiges: %d)",
		player.Name, multiplier, count))
end

local function savePrestige(player)
	local multiplier = player:GetAttribute("prestige_multiplier") or 1.0
	local count      = player:GetAttribute("PrestigeCount")        or 0
	safeSet(prestigeKey(player), { multiplier = multiplier, count = count })
end

-- ───────── HOOKS JOUEUR ─────────

Players.PlayerAdded:Connect(function(player)
	player:SetAttribute("prestige_multiplier", 1.0)
	player:SetAttribute("PrestigeCount",        0)
	task.spawn(function() loadPrestige(player) end)
end)

for _, player in Players:GetPlayers() do
	task.spawn(function() loadPrestige(player) end)
end

Players.PlayerRemoving:Connect(function(player)
	savePrestige(player)
end)

game:BindToClose(function()
	for _, player in Players:GetPlayers() do
		savePrestige(player)
	end
end)

-- ───────── LOGIQUE PRESTIGE ─────────

local function getPrestigeTier(cash)
	local tier = 0
	for i, threshold in ipairs(GameConfig.PrestigeThresholds) do
		if cash >= threshold then
			tier = i
		end
	end
	return tier
end

Remotes.PrestigeReset.OnServerEvent:Connect(function(player, data)
	if not data or data.confirm ~= true then return end

	local cash = player:GetAttribute("Cash") or 0
	local tier = getPrestigeTier(cash)

	if tier == 0 then
		Remotes.PrestigeReset:FireClient(player, { success = false, error = "not_enough_cash" })
		return
	end

	local newMultiplier = GameConfig.PrestigeBonus[tier]
	local newCount      = (player:GetAttribute("PrestigeCount") or 0) + 1

	player:SetAttribute("prestige_multiplier", newMultiplier)
	player:SetAttribute("PrestigeCount",        newCount)
	player:SetAttribute("Buildings",            "")
	player:SetAttribute("Cash",                 0)

	task.spawn(function() savePrestige(player) end)

	Remotes.PrestigeReset:FireClient(player, { success = true, multiplier = newMultiplier })

	print(string.format("[PrestigeManager] %s prestige tier %d → ×%.2f (total: %d)",
		player.Name, tier, newMultiplier, newCount))
end)
