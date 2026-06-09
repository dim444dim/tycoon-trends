--[[
	DataStoreStats.server.luau (TycoonTrends)
	Copié depuis HorrorVilla — adapté pour les stats tycoon.

	Stats persistées :
	  TotalEarned  : argent total gagné toutes sessions
	  TotalBuilds  : nombre total de bâtiments achetés
	  BestSession  : meilleur gain sur une session unique
	  TotalSessions : nombre de sessions jouées

	Cycle :
	  - PlayerAdded  : load → expose en Attributes "DataXxx" sur le Player.
	  - GameState.State → "RESULTS" : applique les deltas de session.
	  - PlayerRemoving : sauvegarde finale.

	Robustesse : fallback RAM si DataStore indisponible (Studio sans API).
]]

local Players           = game:GetService("Players")
local DataStoreService  = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameplayConfig = require(ReplicatedStorage.Shared.GameplayConfig)

print("[DataStoreStats] init")

local state = ReplicatedStorage:WaitForChild("GameState", 5)

local DEFAULTS = {
	TotalEarned   = 0,
	TotalBuilds   = 0,
	BestSession   = 0,
	TotalSessions = 0,
}

local cache       = {}  -- [userId] = stats table
local appliedFor  = {}  -- [sessionId][userId] = true (anti double-update)

local dataStore
local datastoreEnabled = true
do
	local ok, ds = pcall(function()
		return DataStoreService:GetDataStore(GameplayConfig.DataStoreName)
	end)
	if ok then
		dataStore = ds
	else
		datastoreEnabled = false
		warn("[DataStoreStats] DataStore indisponible (Studio sans API ?) — fallback RAM")
	end
end

local warnedDisabled = false
local function warnOnce()
	if not warnedDisabled then
		warnedDisabled = true
		warn("[DataStoreStats] persistance désactivée, stats en RAM uniquement pour cette session")
	end
end

-- ───────── I/O avec retries ─────────

local function safeGet(key)
	if not datastoreEnabled or not dataStore then return nil end
	for attempt = 1, GameplayConfig.DataStoreRetryCount do
		local ok, result = pcall(function()
			return dataStore:GetAsync(key)
		end)
		if ok then return result end
		warn(string.format("[DataStoreStats] GetAsync fail (%d/%d) : %s",
			attempt, GameplayConfig.DataStoreRetryCount, tostring(result)))
		task.wait(GameplayConfig.DataStoreRetryDelay)
	end
	return nil
end

local function safeUpdate(key, transform)
	if not datastoreEnabled or not dataStore then return false end
	for attempt = 1, GameplayConfig.DataStoreRetryCount do
		local ok, err = pcall(function()
			dataStore:UpdateAsync(key, transform)
		end)
		if ok then return true end
		warn(string.format("[DataStoreStats] UpdateAsync fail (%d/%d) : %s",
			attempt, GameplayConfig.DataStoreRetryCount, tostring(err)))
		task.wait(GameplayConfig.DataStoreRetryDelay)
	end
	return false
end

-- ───────── HELPERS ─────────

local function mergeDefaults(stored)
	local out = {}
	for k, v in pairs(DEFAULTS) do
		out[k] = (stored and stored[k] ~= nil) and stored[k] or v
	end
	return out
end

local function userKey(player)
	return "user_" .. tostring(player.UserId)
end

local function publishAttributes(player, stats)
	player:SetAttribute("DataTotalEarned",   stats.TotalEarned)
	player:SetAttribute("DataTotalBuilds",   stats.TotalBuilds)
	player:SetAttribute("DataBestSession",   stats.BestSession)
	player:SetAttribute("DataTotalSessions", stats.TotalSessions)
end

local function loadPlayer(player)
	local stored = safeGet(userKey(player))
	if not stored and not datastoreEnabled then warnOnce() end
	local stats = mergeDefaults(stored)
	cache[player.UserId] = stats
	publishAttributes(player, stats)
	print(string.format("[DataStoreStats] load %s → TotalEarned=%.0f TotalSessions=%d",
		player.Name, stats.TotalEarned, stats.TotalSessions))
end

local function savePlayer(player)
	local stats = cache[player.UserId]
	if not stats then return end
	safeUpdate(userKey(player), function() return stats end)
end

-- ───────── DELTA FIN DE SESSION ─────────

local function applyDelta(player, sessionId)
	local stats = cache[player.UserId]
	if not stats then return end

	local earned = player:GetAttribute("SessionEarned") or 0
	local builds = 0
	local buildingsStr = player:GetAttribute("Buildings") or ""
	for _, countStr in string.gmatch(buildingsStr, "%w+:(%d+)") do
		builds += tonumber(countStr) or 0
	end

	stats.TotalSessions += 1
	stats.TotalEarned   += earned
	stats.TotalBuilds   += builds
	if earned > stats.BestSession then
		stats.BestSession = earned
	end

	publishAttributes(player, stats)
	task.spawn(function() savePlayer(player) end)
end

-- ───────── HOOKS ─────────

Players.PlayerAdded:Connect(function(player)
	publishAttributes(player, mergeDefaults(nil))
	task.spawn(function() loadPlayer(player) end)
end)
for _, p in Players:GetPlayers() do
	publishAttributes(p, mergeDefaults(nil))
	task.spawn(function() loadPlayer(p) end)
end

Players.PlayerRemoving:Connect(function(player)
	savePlayer(player)
	cache[player.UserId]      = nil
	appliedFor[player.UserId] = nil
end)

game:BindToClose(function()
	for _, p in Players:GetPlayers() do
		savePlayer(p)
	end
end)

-- Déclenche le delta quand la session passe en RESULTS
if state then
	state:GetAttributeChangedSignal("State"):Connect(function()
		if state:GetAttribute("State") ~= "RESULTS" then return end
		local sessionId = state:GetAttribute("SessionId") or 0
		if not appliedFor[sessionId] then
			appliedFor[sessionId] = {}
		end
		for _, p in Players:GetPlayers() do
			if not appliedFor[sessionId][p.UserId] then
				appliedFor[sessionId][p.UserId] = true
				applyDelta(p, sessionId)
			end
		end
	end)
end
