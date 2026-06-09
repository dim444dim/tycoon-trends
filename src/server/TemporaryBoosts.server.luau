--[[
	TemporaryBoosts.server.luau (TycoonTrends)
	Spawn des boosts temporaires globaux (2x, 3x revenus, upgrades rapides).
	Diffuse BoostSpawned / BoostExpired à tous les clients.
	ProductionTicker lit l'attribut "BoostMultiplier" sur chaque joueur.
]]

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig     = require(ReplicatedStorage.Shared.GameConfig)  -- noqa: utilisé via GameplayConfig
local GameplayConfig = require(ReplicatedStorage.Shared.GameplayConfig)
local Remotes        = require(ReplicatedStorage.Shared.Remotes)

-- ───────── CATALOGUE DES BOOSTS ─────────
local BOOST_TYPES = {
	{ id = "2xIncome",     multiplier = 2.0, duration = 60 },
	{ id = "3xIncome",     multiplier = 3.0, duration = 45 },
	{ id = "FastUpgrades", multiplier = 0.5, duration = 30 },
}

local SPAWN_CHANCE     = 0.70  -- 70 % de probabilité par cycle
local SPAWN_INTERVAL_MIN = 30
local SPAWN_INTERVAL_MAX = 60

-- activeBoosts[player] = { id, endTime, multiplier }
local activeBoosts = {}

-- Boost global courant (nil si aucun)
local currentBoost = nil  -- { id, multiplier, duration, endTime }

-- ───────── HELPERS ─────────
local function setPlayerBoost(player, boost)
	if boost then
		activeBoosts[player] = { id = boost.id, endTime = boost.endTime, multiplier = boost.multiplier }
		player:SetAttribute("BoostMultiplier", boost.multiplier)
	else
		activeBoosts[player] = nil
		player:SetAttribute("BoostMultiplier", 1.0)
	end
end

local function clearPlayerBoost(player)
	activeBoosts[player] = nil
	player:SetAttribute("BoostMultiplier", 1.0)
end

-- ───────── GESTION JOUEURS ─────────
Players.PlayerAdded:Connect(function(player)
	-- Si un boost est encore actif à l'arrivée du joueur, l'appliquer
	if currentBoost and tick() < currentBoost.endTime then
		setPlayerBoost(player, currentBoost)
	else
		player:SetAttribute("BoostMultiplier", 1.0)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	activeBoosts[player] = nil
end)

-- Initialise les joueurs déjà présents
for _, player in Players:GetPlayers() do
	player:SetAttribute("BoostMultiplier", 1.0)
end

-- ───────── SPAWN D'UN BOOST GLOBAL ─────────
local function spawnBoost()
	local boostType = BOOST_TYPES[math.random(#BOOST_TYPES)]
	local endTime   = tick() + boostType.duration

	currentBoost = {
		id         = boostType.id,
		multiplier = boostType.multiplier,
		duration   = boostType.duration,
		endTime    = endTime,
	}

	for _, player in Players:GetPlayers() do
		setPlayerBoost(player, currentBoost)
	end

	Remotes.BoostSpawned:FireAllClients({
		id         = boostType.id,
		multiplier = boostType.multiplier,
		duration   = boostType.duration,
		endsAt     = endTime,
	})

	print(string.format("[TemporaryBoosts] Boost spawné : %s (×%.1f, %ds)",
		boostType.id, boostType.multiplier, boostType.duration))
end

-- ───────── LOOP DE SPAWN ─────────
task.spawn(function()
	while true do
		task.wait(math.random(SPAWN_INTERVAL_MIN, SPAWN_INTERVAL_MAX))

		-- Ne pas empiler un boost si l'un est déjà actif
		if currentBoost and tick() < currentBoost.endTime then
			continue
		end

		if math.random() <= SPAWN_CHANCE then
			spawnBoost()
		else
			print("[TemporaryBoosts] Cycle sans boost (chance ratée)")
		end
	end
end)

-- ───────── LOOP DE NETTOYAGE (1 Hz) ─────────
task.spawn(function()
	while true do
		task.wait(1)

		if not currentBoost then continue end
		if tick() <= currentBoost.endTime then continue end

		-- Boost expiré : nettoyer tous les joueurs et diffuser
		local expiredId = currentBoost.id
		currentBoost = nil

		for _, player in Players:GetPlayers() do
			clearPlayerBoost(player)
		end

		Remotes.BoostExpired:FireAllClients({ id = expiredId })
		print(string.format("[TemporaryBoosts] Boost %s expiré", expiredId))
	end
end)

print("✅ TemporaryBoosts loaded")
